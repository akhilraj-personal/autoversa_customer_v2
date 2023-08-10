import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/booking/reschedule_screen.dart';
import 'package:autoversa/screens/package_screens/coupon_list_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class ResummeryScreen extends StatefulWidget {
  final List<dynamic> custvehlist;
  final int selectedveh;
  final Map<String, dynamic> bk_data;
  String currency;
  var packid;
  var vehiclegroup;
  var couponid;
  var coupondiscounttype;
  var coupondiscount;
  var couponcode;
  var discountamount;
  var netpayableamount;
  late bool couponapplied;
  ResummeryScreen(
      {required this.bk_data,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      required this.packid,
      required this.vehiclegroup,
      required this.couponid,
      required this.coupondiscounttype,
      required this.coupondiscount,
      required this.couponcode,
      required this.discountamount,
      required this.netpayableamount,
      required this.couponapplied,
      super.key});

  @override
  State<ResummeryScreen> createState() => ResummeryScreenState();
}

class ResummeryScreenState extends State<ResummeryScreen> {
  late Map<String, dynamic> packdata = {};
  late Map<String, dynamic> bookingdetails = {};
  late Map<String, dynamic> booking_package = {};
  late Map<String, dynamic> vehicle = {};
  late Map<String, dynamic> audio = {};
  var totalamount = 0.0;
  var packagecost = 0.0;
  bool isproceeding = false;
  int bookId = 0;
  var trnxId;
  var vehiclename = "";
  String selectedTime = "";
  String currentTime = "";
  TextEditingController additionalcommentsController = TextEditingController();
  late List couponList = [];
  var couponcodeselected;
  var coupondiscountreceived;
  var coupondiscounttypereceived;
  var couponnetpayable;
  var couponapplieddiscount;
  var packagetotalamount;
  var coupon_id;
  var discount;
  late double netpayable = 0.0;
  bool couponapplied = false;
  late double highestDiscountAmount = 0.0;
  List<dynamic> highestDiscountCoupons = [];
  var vehiclgroup;
  var pack_id;

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      getBookingDetailsID();
      _setdatas();
      getCouponList();
      appliedcoupon(0, 0, 0, 0, 0);
    });
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_data['bk_id']))};
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        pack_id = value['booking']['booking_package']['bkp_pkg_id'];
        vehiclgroup = value['booking']['vgroup'];
        bookingdetails = value['booking'];
        vehicle = value['booking']['vehicle'];
        booking_package = value['booking']['booking_package'];
        value['audio'] != null ? audio = value['audio'] : "";
        additionalcommentsController.text =
            bookingdetails['bk_complaint'] != null
                ? bookingdetails['bk_complaint']
                : "";
        setState(() {});
        setState(() {
          vehiclename = vehicle['cv_variant'] != null
              ? vehicle['cv_make'] +
                  vehicle['cv_model'] +
                  vehicle['cv_variant'] +
                  vehicle['cv_year']
              : vehicle['cv_make'] + vehicle['cv_model'] + vehicle['cv_year'];
        });
      }
    });
  }

  _setdatas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      packdata = json.decode(prefs.get("booking_data").toString());
      selectedTime = packdata['selected_timeslot'].split('- ')[1];
      if (packdata['package_cost'] != null) {
        totalamount =
            double.parse((packdata['package_cost']).toString()).round() +
                double.parse(packdata['pack_vat'].toString()).round() +
                double.parse(packdata['pick_up_price'].toString());
        netpayable =
            double.parse((packdata['package_cost']).toString()).round() +
                double.parse(packdata['pack_vat'].toString()).round() +
                double.parse(packdata['pick_up_price'].toString());
        setState(() {});
        packagecost = double.parse(packdata['package_cost'].toString()) +
            double.parse(packdata['pack_vat'].toString());
      } else {
        totalamount = double.parse(packdata['pick_up_price'].toString());
        netpayable = double.parse(packdata['pick_up_price'].toString());
        setState(() {});
      }
    });
  }

  getCouponList() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "cust_id": prefs.getString("cust_id"),
      "pack_id": widget.packid,
      "vgroup_id": widget.vehiclegroup,
      "totalamount": netpayable.toString(),
    };
    couponList = [];
    await getCouponsListForCustomer(req).then((value) {
      if (value['ret_data'] == "success") {
        couponList = value['coupons'];
        for (int i = 0; i < couponList.length; i++) {
          if (double.parse(couponList[i]['discountamount'].toString()) >
              highestDiscountAmount) {
            highestDiscountAmount =
                double.parse(couponList[i]['discountamount'].toString());
            highestDiscountCoupons = [couponList[i]];
          } else if (couponList[i]['discountamount'] == highestDiscountAmount) {
            highestDiscountCoupons.add(couponList[i]);
          }
        }
        setState(() {
          couponList = highestDiscountCoupons;
        });
      }
    }).catchError((e) {
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  appliedcoupon(couponid, coupondiscounttype, coupondiscount, couponcode,
      coupondiscountamount) {
    if (widget.couponid == null) {
      netpayable = 0.0;
      coupon_id = couponid;
      couponcodeselected = couponcode.toUpperCase();
      coupondiscountreceived = coupondiscount;
      coupondiscounttypereceived = coupondiscounttype;
      setState(() {});
      if (coupondiscounttype == "1") {
        couponapplied = true;
        netpayable = (double.parse(totalamount.round().toString())) -
            (double.parse(coupondiscountamount));
        discount = (double.parse(totalamount.round().toString()) -
                double.parse(netpayable.toString()))
            .round();
        showDialog(
          context: context,
          builder: (BuildContext context) => CouponDialog(
            couponCode: couponcode.toUpperCase(),
            couponDiscount: discount,
          ),
        );
        setState(() {});
      } else if (coupondiscounttype == "0") {
        couponapplied = true;
        netpayable = (double.parse(totalamount.round().toString())) -
            (double.parse(coupondiscountamount));
        discount = (double.parse(totalamount.round().toString()) -
                double.parse(netpayable.toString()))
            .round();
        showDialog(
          context: context,
          builder: (BuildContext context) => CouponDialog(
            couponCode: couponcode.toUpperCase(),
            couponDiscount: discount,
          ),
        );
        setState(() {});
      }
    } else if (widget.couponid != null) {
      netpayable = 0.0;
      coupon_id = widget.couponid;
      couponcodeselected = widget.couponcode.toUpperCase();
      coupondiscountreceived = widget.coupondiscount;
      coupondiscounttypereceived = widget.coupondiscounttype;
      couponnetpayable = widget.netpayableamount;
      couponapplieddiscount = widget.discountamount;
      setState(() {});
      if (coupondiscounttypereceived == "1") {
        couponapplied = true;
        netpayable = couponnetpayable;
        discount = couponapplieddiscount;
        showDialog(
          context: context,
          builder: (BuildContext context) => CouponDialog(
            couponCode: couponcodeselected,
            couponDiscount: couponapplieddiscount,
          ),
        );
        setState(() {});
      } else if (coupondiscounttypereceived == "0") {
        couponapplied = true;
        netpayable = couponnetpayable;
        discount = couponapplieddiscount;
        showDialog(
          context: context,
          builder: (BuildContext context) => CouponDialog(
            couponCode: couponcodeselected,
            couponDiscount: couponapplieddiscount,
          ),
        );
        setState(() {});
      }
    }
  }

  Removedappliedcoupon(coupontype, coupondiscount) {
    if (coupontype == "1") {
      couponapplied = false;
      netpayable = totalamount;
      discount = (double.parse(totalamount.round().toString()) +
              double.parse(netpayable.toString()))
          .round();
      showCustomToast(context, "Coupon removed",
          bgColor: black, textColor: white);
      setState(() {});
    } else if (coupontype == "0") {
      couponapplied = false;
      netpayable = totalamount + (double.parse(coupondiscount));
      discount = (double.parse(totalamount.round().toString()) -
              double.parse(netpayable.toString()))
          .round();
      showCustomToast(context, "Coupon removed",
          bgColor: black, textColor: white);
      setState(() {});
    }
  }

  Future<void> init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  createBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> booking = {
        "bookid": bookingdetails['bk_id'],
        "custId": prefs.getString('cust_id'),
        "vehId": packdata['vehicle_id'],
        "bookingdate": packdata['selected_date'],
        "expenses": [],
        "slot": packdata['selected_timeid'],
        "pickupaddress": packdata['pick_up_location_id'],
        "dropaddress": packdata['drop_location_id'],
        "pickup_vat": packdata['pickup_vat'],
        "pickuptype": packdata['pick_type_id'],
        "pickupcost": (double.parse(packdata['pick_up_price']) -
                double.parse(packdata['pickup_vat']))
            .toStringAsFixed(2),
        "pack_vat": packdata['pack_vat'],
        'complaint': additionalcommentsController.text.toString(),
        "sourcetype": "MOB",
        "advance": "0",
        "coupon_id": coupon_id != 0 ? coupon_id : null,
        "discount": discount != null ? discount : "0",
        "total_amount": netpayable.round(),
      };
      await createRescheduleBooking(booking).then((value) {
        if (value['ret_data'] == "success") {
          createPayment(bookingdetails['bk_id'], value['payment_details']);
          trnxId = value['payment_details']['id'];
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  createPayment(data, payment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var billingDetails = BillingDetails(
      name: prefs.getString('name'),
      email: prefs.getString('email'),
      phone: prefs.getString('phone'),
      address: Address(
        city: 'Abu Dhabi',
        country: 'AE',
        line1: 'Mussafah',
        line2: '',
        state: 'Abu Dhabi',
        postalCode: '',
      ),
    );
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        // Main params
        paymentIntentClientSecret: payment['client_secret'],
        merchantDisplayName: 'AutoVersa',
        // Customer params
        customerId: payment['customer'],
        customerEphemeralKeySecret: payment['ephemeralKey']['secret'],
        // Extra params
        style: ThemeMode.light,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
              background: Colors.white,
              primary: Color(0xff31BBAC),
              componentBorder: Color(0xff3186AC),
              primaryText: Colors.black,
              secondaryText: Colors.black,
              componentBackground: Colors.white,
              placeholderText: Colors.black87,
              componentText: Colors.black87,
              icon: Colors.black87),
          shapes: PaymentSheetShape(
            borderWidth: 4,
            borderRadius: 10.00,
            shadow: PaymentSheetShadowParams(color: Color(0xff31BBAC)),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xff31BBAC),
                text: Colors.white,
                border: Color(0xff31BBAC),
              ),
            ),
          ),
        ),
        billingDetails: billingDetails,
      ),
    );
    try {
      await Stripe.instance.presentPaymentSheet();

      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> booking = {
        'custId': prefs.getString('cust_id'),
        'book_id': bookingdetails['bk_id'],
        'tot_amount': netpayable.round(),
        'trxn_id': trnxId,
        'complaint': additionalcommentsController.text.toString(),
        'slot': packdata['selected_timeid'],
        'bookingdate': packdata['selected_date'],
        'audiofile': audio != null ? audio['bka_url'] : ""
      };
      await confirmbookingpayment(booking).then((value) {
        if (value['ret_data'] == "success") {
        } else {
          setState(() => isproceeding = false);
          showCustomToast(context, value['ret_data'],
              bgColor: errorcolor, textColor: white);
        }
      });

      setState(() {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomSuccess(),
        );
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        setState(() => isproceeding = false);
        setState(() {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomWarning(),
          );
        });
      } else {
        setState(() => isproceeding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: ${e}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            width: width,
            height: height * 0.12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lightblueColor,
                  syanColor,
                ],
              ),
            ),
            child: ClipPath(
              clipper: SinCosineWaveClipper(
                verticalPosition: VerticalPosition.top,
              ),
              child: Container(
                height: height * 0.31,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    syanColor.withOpacity(0.3),
                    Color.fromARGB(255, 176, 205, 210),
                  ],
                )),
              ),
            ),
          ),
          title: Text(
            booking_package['pkg_name'] != null
                ? booking_package['pkg_name']
                : "Summery Page",
            style: montserratRegular.copyWith(
              fontSize: width * 0.044,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 18,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 12,
                                    color: syanColor.withOpacity(.5),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.outer,
                                    offset: Offset(0, 0)),
                              ]),
                        ),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(8),
                          width: width * 1.85,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(top: 16, left: 8)),
                              if (vehicle['cv_make'] == 'Mercedes Benz') ...[
                                Image.asset(
                                  ImageConst.benz_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'BMW') ...[
                                Image.asset(
                                  ImageConst.bmw_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'Skoda') ...[
                                Image.asset(
                                  ImageConst.skod_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'Audi') ...[
                                Image.asset(
                                  ImageConst.aud_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'Porsche') ...[
                                Image.asset(
                                  ImageConst.porsche_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] ==
                                  'Volkswagen') ...[
                                Image.asset(
                                  ImageConst.volkswagen_icon,
                                  width: width * 0.12,
                                ),
                              ] else ...[
                                Image.asset(
                                  ImageConst.defcar_ico,
                                  width: width * 0.12,
                                ),
                              ],
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 8),
                                      widget.custvehlist[widget.selectedveh]
                                                      ['cv_plate_number'] !=
                                                  "" &&
                                              widget.custvehlist[
                                                          widget.selectedveh]
                                                      ['cv_plate_number'] !=
                                                  null
                                          ? Text(
                                              widget.custvehlist[
                                                      widget.selectedveh]
                                                      ['cv_plate_number']
                                                  .toUpperCase(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: black,
                                                      fontSize: width * 0.04),
                                              maxLines: 2)
                                          : SizedBox(),
                                      // vehicle['cv_plate_number'] != "" &&
                                      //         vehicle['cv_plate_number'] != null
                                      //     ? Text(
                                      //         vehicle['cv_plate_number']
                                      //             .toUpperCase(),
                                      //         style:
                                      //             montserratSemiBold.copyWith(
                                      //                 color: black,
                                      //                 fontSize: width * 0.034),
                                      //         maxLines: 2)
                                      //     : SizedBox(),
                                      widget.custvehlist[widget.selectedveh]['cv_variant'] != "" && widget.custvehlist[widget.selectedveh]['cv_variant'] != null
                                          ? Text(
                                              widget.custvehlist[widget.selectedveh]['cv_make'] +
                                                  " " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_model'] +
                                                  " " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_variant'] +
                                                  " ( " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_year'] +
                                                  " )",
                                              style: montserratMedium.copyWith(
                                                  color: black,
                                                  fontSize: width * 0.034),
                                              overflow: TextOverflow.clip,
                                              maxLines: 5)
                                          : Text(
                                              widget.custvehlist[widget.selectedveh]['cv_make'] +
                                                  " " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_model'] +
                                                  " ( " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_year'] +
                                                  " )",
                                              style: montserratMedium.copyWith(color: black, fontSize: width * 0.034),
                                              overflow: TextOverflow.clip,
                                              maxLines: 5),
                                      // Text(vehiclename,
                                      //     style: montserratMedium.copyWith(
                                      //         color: black,
                                      //         fontSize: width * 0.034),
                                      //     overflow: TextOverflow.clip,
                                      //     maxLines: 5),
                                      Divider(),
                                      Text(
                                          booking_package['pkg_name'] != null
                                              ? booking_package['pkg_name']
                                              : "",
                                          overflow: TextOverflow.ellipsis,
                                          style: montserratMedium.copyWith(
                                              color: black,
                                              fontSize: width * 0.034)),
                                      Text(
                                        packdata['package_cost'] != null
                                            ? packdata['package_cost'] != 0
                                                ? "AED " +
                                                    (packagecost.round())
                                                        .toString()
                                                : "Based on Quotation"
                                            : "",
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.034),
                                      ),
                                      Divider(),
                                      Text(
                                        packdata['pick_type_name'] ?? "",
                                        style: montserratMedium.copyWith(
                                            color: black,
                                            fontSize: width * 0.034),
                                      ),
                                      Text(
                                        packdata['pick_up_price'] != null
                                            ? packdata['pick_up_price'] != "0"
                                                ? "AED " +
                                                    packdata['pick_up_price']
                                                        .toString()
                                                : "FREE"
                                            : "",
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.034),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Pickup Location",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.location_icon,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                packdata['pick_up_location']['cad_landmark']
                                        .toUpperCase() +
                                    " (" +
                                    packdata['pick_up_location']['cad_city'] +
                                    ")",
                                style: montserratMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: width * 0.04),
                              ),
                              Text(
                                packdata['pick_up_location']['cad_address'],
                                maxLines: 2,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: montserratMedium.copyWith(
                                    color: toastgrey, fontSize: width * 0.03),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Drop Location",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.location_icon,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                packdata['drop_location']['cad_landmark']
                                        .toUpperCase() +
                                    " (" +
                                    packdata['drop_location']['cad_city'] +
                                    ")",
                                style: montserratMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: width * 0.04),
                              ),
                              Text(
                                packdata['drop_location']['cad_address'],
                                maxLines: 2,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: montserratMedium.copyWith(
                                    color: toastgrey, fontSize: width * 0.03),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Selected Date & Time",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.date_icon,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            packdata['selected_date'] != null
                                ? DateFormat('LLLL').format(
                                    DateTime.parse(packdata['selected_date']))
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            packdata['selected_date'] != null
                                ? DateFormat('d').format(
                                    DateTime.parse(packdata['selected_date']))
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.time,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            packdata['selected_timeslot'] != null
                                ? packdata['selected_timeslot'].split('- ')[0] +
                                    "-"
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                          Text(
                            packdata['selected_timeslot'] != null
                                ? " " +
                                    packdata['selected_timeslot'].split('- ')[1]
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    couponList.length > 0
                        ? SizedBox(
                            height: 8,
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    couponList.length > 0
                        ? Container(
                            margin: EdgeInsets.only(left: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Savings",
                                  style: montserratSemiBold.copyWith(
                                    color: black,
                                    fontSize: width * 0.034,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    8.height,
                    couponList.length > 0
                        ? couponapplied
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: couponList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                      left: 15.0,
                                      right: 15.0,
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          padding: EdgeInsets.only(top: 15.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 35,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          lightblueColor,
                                                          syanColor,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          ImageConst
                                                              .coupon_icon,
                                                          width: 25,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  8.width,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child: couponList[index]
                                                                              [
                                                                              'coupon_discount_type'] ==
                                                                          "1"
                                                                      ? Text(
                                                                          "You Saved " +
                                                                              coupondiscountreceived +
                                                                              "% with this code",
                                                                          style:
                                                                              montserratSemiBold.copyWith(fontSize: width * 0.04),
                                                                        )
                                                                      : Text(
                                                                          "You Saved " +
                                                                              coupondiscountreceived +
                                                                              " AED with this code",
                                                                          style:
                                                                              montserratSemiBold.copyWith(fontSize: width * 0.04),
                                                                        ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Removedappliedcoupon(
                                                                        coupondiscounttypereceived,
                                                                        coupondiscountreceived);
                                                                  },
                                                                  child: Text(
                                                                    "Remove",
                                                                    style: montserratMedium
                                                                        .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.04,
                                                                      color:
                                                                          warningcolor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              'Code Applied',
                                                              style:
                                                                  montserratRegular
                                                                      .copyWith(
                                                                fontSize:
                                                                    width *
                                                                        0.04,
                                                                color:
                                                                    greyColor,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ).expand(),
                                                ],
                                              ).paddingOnly(
                                                  right: 16.0,
                                                  left: 16.0,
                                                  bottom: 16.0),
                                            ],
                                          ),
                                        ).paddingBottom(16.0),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: couponList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                      left: 15.0,
                                      right: 15.0,
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.0,
                                            ),
                                          ),
                                          padding: EdgeInsets.only(top: 15.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 35,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          lightblueColor,
                                                          syanColor,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          ImageConst
                                                              .coupon_icon,
                                                          width: 25,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  8.width,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child: couponList[index]
                                                                              [
                                                                              'coupon_discount_type'] ==
                                                                          "1"
                                                                      ? Text(
                                                                          "Save " +
                                                                              couponList[index]['coupon_discount'] +
                                                                              " % more on this booking",
                                                                          style:
                                                                              montserratSemiBold.copyWith(fontSize: width * 0.0425),
                                                                        )
                                                                      : Text(
                                                                          "Save AED " +
                                                                              couponList[index]['coupon_discount'] +
                                                                              " more on this booking",
                                                                          style:
                                                                              montserratSemiBold.copyWith(fontSize: width * 0.0425),
                                                                        ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    appliedcoupon(
                                                                        couponList[index]
                                                                            [
                                                                            'coupon_id'],
                                                                        couponList[index]
                                                                            [
                                                                            'coupon_discount_type'],
                                                                        couponList[index]
                                                                            [
                                                                            'coupon_discount'],
                                                                        couponList[index]
                                                                            [
                                                                            'coupon_code'],
                                                                        couponList[index]
                                                                            [
                                                                            'discountamount']);
                                                                  },
                                                                  child: Text(
                                                                    "Apply",
                                                                    style: montserratMedium
                                                                        .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.04,
                                                                      color:
                                                                          warningcolor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              'Code: ' +
                                                                  couponList[index]
                                                                          [
                                                                          'coupon_code']
                                                                      .toUpperCase(),
                                                              style:
                                                                  montserratRegular
                                                                      .copyWith(
                                                                fontSize:
                                                                    width *
                                                                        0.04,
                                                                color:
                                                                    greyColor,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ).expand(),
                                                ],
                                              ).paddingOnly(
                                                  right: 16.0, left: 16.0),
                                              8.height,
                                              Divider(
                                                  color: divider_grey_color,
                                                  thickness: 1.5,
                                                  indent: 20,
                                                  endIndent: 20),
                                              8.height,
                                              Row(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text("View all Coupons",
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.04)),
                                                      4.width,
                                                      RadiantGradientMask(
                                                        child: Icon(
                                                            Icons.arrow_forward,
                                                            color: syanColor,
                                                            size: 22),
                                                      ),
                                                    ],
                                                  ).onTap(
                                                    () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return CouponListScreen(
                                                              clickid:
                                                                  "awaiting",
                                                              packageid: widget
                                                                  .packid
                                                                  .toString(),
                                                              vehiclegroupid: widget
                                                                  .vehiclegroup
                                                                  .toString(),
                                                              totalamount:
                                                                  totalamount
                                                                      .toString(),
                                                              package_id: {},
                                                              custvehlist: widget
                                                                  .custvehlist,
                                                              selectedveh: widget
                                                                  .selectedveh,
                                                              currency: widget
                                                                  .currency,
                                                              bk_data: {},
                                                              packid: pack_id,
                                                              vehiclegroup:
                                                                  vehiclgroup,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ).expand()
                                                ],
                                              ).paddingOnly(
                                                  right: 16.0, left: 16.0),
                                              16.height,
                                            ],
                                          ),
                                        ).paddingBottom(16.0),
                                      ],
                                    ),
                                  );
                                },
                              )
                        : SizedBox(),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Additional Comments",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            color: white),
                        child: TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 230,
                            controller: additionalcommentsController,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                                counterText: "",
                                hintText: lang.S.of(context).your_message_here,
                                hintStyle: montserratRegular.copyWith(
                                    color: black, fontSize: width * 0.034),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: greyColor, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: greyColor, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ))),
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total: ",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                          Text(
                            widget.currency +
                                " " +
                                (totalamount.round()).toString(),
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                        ],
                      ),
                    ),
                    4.height,
                    couponapplied
                        ? Container(
                            margin: EdgeInsets.only(left: 30.0, right: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                couponcodeselected != null
                                    ? Text(
                                        "Coupon - " + (couponcodeselected),
                                        style: montserratSemiBold.copyWith(
                                            color: blueColor,
                                            fontSize: width * 0.034),
                                      )
                                    : Text(
                                        "Coupon",
                                        style: montserratSemiBold.copyWith(
                                            color: blueColor,
                                            fontSize: width * 0.034),
                                      ),
                                discount != null
                                    ? Text(
                                        widget.currency +
                                            " " +
                                            (discount.round()).toString(),
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.04),
                                      )
                                    : Text(
                                        widget.currency + " " + "0",
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.04),
                                      ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    4.height,
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Net Payable: ",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                          widget.netpayableamount != null &&
                                  couponapplied == true
                              ? Text(
                                  widget.currency +
                                      " " +
                                      (widget.netpayableamount.round())
                                          .toString(),
                                  style: montserratSemiBold.copyWith(
                                      color: warningcolor,
                                      fontSize: width * 0.04),
                                )
                              : Text(
                                  widget.currency +
                                      " " +
                                      (netpayable.round()).toString(),
                                  style: montserratSemiBold.copyWith(
                                      color: warningcolor,
                                      fontSize: width * 0.04),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (isproceeding) return;
                        setState(() => isproceeding = true);
                        await Future.delayed(Duration(milliseconds: 1000));
                        createBooking();
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: height * 0.045,
                            width: height * 0.37,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 16,
                                      color: syanColor.withOpacity(.6),
                                      spreadRadius: 0,
                                      blurStyle: BlurStyle.outer,
                                      offset: Offset(0, 0)),
                                ]),
                          ),
                          Container(
                            height: height * 0.075,
                            width: height * 0.4,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  syanColor,
                                  lightblueColor,
                                ],
                              ),
                            ),
                            child: !isproceeding
                                ? Text(
                                    "PROCEED TO PAY",
                                    style: montserratSemiBold.copyWith(
                                        color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: CircularProgressIndicator(
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: warningcolor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0)),
                  ),
                ),
                Column(
                  children: [
                    Image.asset(
                      ImageConst.warning,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Awaiting Payment",
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: white)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                    "Your payment is still pending. Complete payment for further proceedings.",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.032, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        lightorangeColor,
                        holdorangeColor,
                      ],
                    )),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('OK',
                    style: montserratSemiBold.copyWith(color: white)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          lightblueColor,
                          syanColor,
                        ],
                      )),
                ),
                // Container(height: 130, color: black),
                Column(
                  children: [
                    Image.asset(
                      ImageConst.success,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Payment successful!",
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: white)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                    "Your booking has been created. You can check the status of your booking on your dashboard.",
                    textAlign: TextAlign.justify,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.032, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                // Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        lightblueColor,
                        syanColor,
                      ],
                    )),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('OK',
                    style: montserratSemiBold.copyWith(color: white)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class ReScheduleTimeAndDate extends StatelessWidget {
  final Map<String, dynamic> bk_data;
  final List<dynamic> custvehlist;
  final int selectedVeh;
  String currency;
  ReScheduleTimeAndDate(
      {required this.bk_data,
      required this.currency,
      required this.custvehlist,
      required this.selectedVeh,
      super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0)),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      white,
                      white,
                      white,
                      white,
                    ],
                  )),
                ),
                // Container(height: 130, color: blackColor),
                Column(
                  children: [
                    Image.asset(
                      ImageConst.time_expired_icon,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Expired",
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: black)),
                  ],
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text("Selected time slot expired. Kindly reschedule",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.034, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RescheduleScreen(
                              bk_data: bk_data,
                              custvehlist: custvehlist,
                              currency: currency,
                              selectedVeh: selectedVeh,
                              pickup_loc: 0,
                              drop_loc: 0,
                            )));
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        lightorangeColor,
                        holdorangeColor,
                      ],
                    )),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('RESCHEDULE',
                    style: montserratSemiBold.copyWith(color: white)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class CouponDialog extends StatelessWidget {
  final String couponCode;
  final int couponDiscount;
  CouponDialog({required this.couponCode, required this.couponDiscount});
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    finish(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                ),
                Image.asset(ImageConst.success,
                    color: Colors.black, width: 55, height: 55),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text("Coupon Applied: $couponCode",
                      style: montserratRegular.copyWith(
                          color: syanColor, fontSize: width * 0.04)),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text("You saved AED $couponDiscount",
                      style: montserratMedium.copyWith(
                          color: black, fontSize: width * 0.06)),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Text("with this coupon code",
                      style: montserratMedium.copyWith(
                          color: syanColor, fontSize: width * 0.04)),
                ),
                SizedBox(height: 30),
              ],
            )));
  }
}

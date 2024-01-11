import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/screens/booking/booking_status_flow_page.dart';
import 'package:autoversa/screens/booking/schedule_drop_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nb_utils/nb_utils.dart';

class Workcard extends StatefulWidget {
  final int click_id;
  final String booking_id;
  final String vehname;
  final String vehmake;
  const Workcard(
      {required this.click_id,
      required this.booking_id,
      required this.vehname,
      required this.vehmake,
      super.key});

  @override
  State<Workcard> createState() => WorkcardState();
}

class WorkcardState extends State<Workcard> {
  bool isapproved = false;
  late Map<String, dynamic> booking = {};
  late Map<String, dynamic> packagebooking = {};
  late Map<String, dynamic> status = {};
  late Map<String, dynamic> service_advisor = {};
  late Map<String, dynamic> vehicle = {};
  var pendingjobs = [];
  var approvedjobs = [];
  var pendingjobid = {};
  List<Map<String, dynamic>> temppendingjobs = [];
  var totalamount = 0.0;
  var withoutcoupontotal = 0.0;
  var coupondiscount = 0.0;
  var normaldiscount = 0.0;
  var amounttopay = 0.0;
  var selected_package_cost = 0.0;
  var selected_pickup_type_cost = 0.0;
  var paidamount = 0.0;
  var grandtotal = 0.0;
  var grandpaidamount = 0.0;
  var pickuppackagecost = 0.0;
  var consumablecost = 0.0;
  var trnxId;
  var gs_vat;
  var type = "0";
  bool isproceeding = false;
  bool selectAll = false;
  List<Map<String, String>> selectedJobs = [];

  @override
  void initState() {
    super.initState();
    getBookingDetailsID();
    getCardJobDetails();
    init();
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

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.booking_id))};
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          booking = value['booking'];
          status = value['booking']['cust_status'];
          service_advisor = value['booking']['service_advisor'];
          vehicle = value['booking']['vehicle'];
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingStatusFlow(
          bk_id: widget.booking_id,
          vehname: widget.vehname,
          make: widget.vehmake,
        ),
      ),
    );

    return false;
  }

  getCardJobDetails() async {
    Map req = {"bookid": widget.booking_id};
    print(req);
    pendingjobs = [];
    approvedjobs = [];
    await getcardjobdetails(req)
        .then((value) => {
              if (value['ret_data'] == "success")
                {
                  setState(() {
                    temppendingjobs = [];
                    packagebooking = value['booking'];
                    totalamount = 0;
                    consumablecost = 0;
                    coupondiscount = 0;
                    normaldiscount = 0;
                    amounttopay = 0;
                    paidamount = 0;
                  }),
                  selected_package_cost =
                      double.parse(value['booking']['bkp_cust_amount']) +
                          double.parse(value['booking']['bkp_vat']),
                  selected_pickup_type_cost =
                      double.parse(value['booking']['bk_pickup_cost']) +
                          double.parse(value['booking']['bk_pickup_vat']),
                  totalamount = totalamount +
                      (selected_package_cost + selected_pickup_type_cost)
                          .round(),
                  coupondiscount =
                      double.parse(value['booking']['bk_coupondiscount']),
                  normaldiscount = double.parse(
                      value['booking']['bk_discount'] != null
                          ? value['booking']['bk_discount']
                          : 0.0),
                  for (var paylist in value['payments'])
                    {
                      paidamount = paidamount +
                          double.parse(paylist['bpt_amount'].toString()),
                    },
                  for (var joblist in value['jobs'])
                    {
                      if (joblist['bkj_status'] == "2" ||
                          joblist['bkj_status'] == "4")
                        {
                          approvedjobs.add(joblist),
                          totalamount = totalamount +
                              double.parse(joblist['bkj_cust_cost'].toString()),
                        }
                      else if (joblist['bkj_status'] == "1")
                        {
                          pendingjobs.add(joblist),
                        },
                      if (joblist['bkj_status'] == "2")
                        {
                          setState(() {
                            var pendingjobid = {"jobid": joblist['bkj_id']};
                            temppendingjobs.add(pendingjobid);
                            setState(() {});
                          })
                        }
                    },
                  if (value['booking']['bk_consumepaymentflag'] != "0")
                    {
                      consumablecost = value['booking']['bk_consumcost'] !=
                                  null &&
                              value['booking']['bk_consumvat'] != null
                          ? double.parse(value['booking']['bk_consumcost']) +
                              double.parse(value['booking']['bk_consumvat'])
                          : 0.0,
                      setState(() {})
                    },
                  withoutcoupontotal =
                      ((totalamount).toDouble() + (consumablecost).toDouble()),
                  grandtotal =
                      ((totalamount).toDouble() + (consumablecost).toDouble()) -
                          (coupondiscount + normaldiscount),
                  amounttopay = ((grandtotal) - (paidamount)).toDouble(),
                  setState(() {}),
                }
              else
                {}
            })
        .catchError((e) {});
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  createPayment(paramsconsumablecost, consumableflag) async {
    if (paramsconsumablecost != 0 &&
        temppendingjobs.length == 0 &&
        int.parse(consumableflag) == 1) {
      type = "0";
      setState(() {});
    } else if (paramsconsumablecost == "0.00" &&
            temppendingjobs.length != 0 &&
            int.parse(consumableflag) == 0 ||
        temppendingjobs.length != 0 &&
            paramsconsumablecost != 0 &&
            int.parse(consumableflag) == 4) {
      type = "1";
      setState(() {});
    } else if (temppendingjobs.length > 0 &&
        paramsconsumablecost != 0 &&
        int.parse(consumableflag) == 1) {
      type = "2";
      setState(() {});
    } else {}
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> pay_data = {
      'custId': prefs.getString('cust_id'),
      'booking_id': widget.booking_id,
      'tot_amount': amounttopay.toString(),
      'job_id': temppendingjobs
    };
    await create_workcard_payment(pay_data).then((value) {
      if (value['ret_data'] == "success") {
        trnxId = value['payment_details']['id'];
        createPaymentIntent(widget.booking_id, value['payment_details']);
      }
    }).catchError((e) {
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  createPaymentIntent(data, payment) async {
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
      Map<String, dynamic> paymentreq = {
        'custId': prefs.getString('cust_id'),
        'booking_id': widget.booking_id,
        'tot_amount': amounttopay.toString(),
        'trxn_id': trnxId,
        'job_id': temppendingjobs,
        'type': type
      };
      await create_payment_for_job_workcard(paymentreq).then((value) {
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
          builder: (BuildContext context) => CustomSuccess(
              click_id: widget.click_id,
              booking_id: widget.booking_id,
              vehname: widget.vehname,
              vehmake: widget.vehmake),
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

  Future refresh() async {
    getCardJobDetails();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.white,
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
              "Work Card",
              style: montserratRegular.copyWith(
                fontSize: width * 0.044,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingStatusFlow(
                              bk_id: widget.booking_id,
                              vehname: widget.vehname,
                              make: widget.vehmake,
                            )));
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 18,
            ),
          ),
          body: RefreshIndicator(
              displacement: 250,
              backgroundColor: Colors.white,
              color: syanColor,
              strokeWidth: 3,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 12.0,
                                  ),
                                  child: Text(
                                    widget.click_id == 1 ? "" : "",
                                    style: montserratSemiBold.copyWith(
                                        fontSize: 16,
                                        color: widget.click_id == 1
                                            ? black
                                            : black),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                children: <Widget>[
                                  SizedBox(width: 16.0),
                                  if (vehicle['cv_make'] ==
                                      'Mercedes Benz') ...[
                                    Image.asset(ImageConst.benz_ico,
                                        width: width / 8, height: 50),
                                  ] else if (vehicle['cv_make'] == 'BMW') ...[
                                    Image.asset(ImageConst.bmw_ico,
                                        width: width / 8, height: 50),
                                  ] else if (vehicle['cv_make'] == 'Skoda') ...[
                                    Image.asset(ImageConst.skod_ico,
                                        width: width / 8, height: 50),
                                  ] else if (vehicle['cv_make'] == 'Audi') ...[
                                    Image.asset(ImageConst.aud_ico,
                                        width: width / 8, height: 50),
                                  ] else if (vehicle['cv_make'] ==
                                      'Porsche') ...[
                                    Image.asset(ImageConst.porsche_ico,
                                        width: width / 8, height: 50),
                                  ] else if (vehicle['cv_make'] ==
                                      'Volkswagen') ...[
                                    Image.asset(ImageConst.volkswagen_icon,
                                        width: width / 8, height: 50),
                                  ] else ...[
                                    Image.asset(ImageConst.defcar_ico,
                                        width: width / 8, height: 50)
                                  ],
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Container(
                                                  child: Text(
                                                      booking['bk_number'] !=
                                                              null
                                                          ? "Booking ID: " +
                                                              booking[
                                                                  'bk_number']
                                                          : "",
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: width *
                                                                  0.034))),
                                            ),
                                          ],
                                        ),
                                        4.height,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Flexible(
                                              child: Container(
                                                child: Text(
                                                  widget.vehname,
                                                  overflow: TextOverflow.clip,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              vehicle['cv_plate_number'] != null
                                                  ? "Reg No: " +
                                                      vehicle['cv_plate_number']
                                                  : "",
                                              style: montserratMedium.copyWith(
                                                  color: black,
                                                  fontSize: width * 0.034),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              service_advisor['us_phone'] !=
                                                      null
                                                  ? "Advisor Contact" +
                                                      ": " +
                                                      service_advisor[
                                                          'us_phone']
                                                  : "",
                                              style: montserratMedium.copyWith(
                                                  color: black,
                                                  fontSize: width * 0.034),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: white,
                                borderRadius: radius(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Confirmed Jobs",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                      fontSize: 16,
                                      color: syanColor,
                                    ),
                                  ),
                                  16.height,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text("Package & Job Name",
                                                  overflow: TextOverflow.clip,
                                                  maxLines: 3,
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: black)),
                                            ),
                                          ),
                                        ],
                                      ).expand(),
                                      Row(
                                        children: [
                                          Container(
                                              padding: EdgeInsets.all(8),
                                              child: Text('Cost (AED)',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          fontSize:
                                                              width * 0.032,
                                                          color:
                                                              warningcolor))),
                                          24.width,
                                          Text('Status',
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      fontSize: width * 0.032,
                                                      color: black)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                packagebooking['pkg_name'] !=
                                                        null
                                                    ? packagebooking['pkg_name']
                                                    : "",
                                                overflow: TextOverflow.clip,
                                                maxLines: 3,
                                                style:
                                                    montserratMedium.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ).expand(),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6),
                                            child: Text(
                                              selected_package_cost
                                                  .round()
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.left,
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: warningcolor,
                                                      fontSize: width * 0.034),
                                            ),
                                          ),
                                          50.width,
                                          Text("PAID",
                                              style: montserratMedium.copyWith(
                                                  fontSize: width * 0.034,
                                                  color: Colors.green)),
                                        ],
                                      ),
                                    ],
                                  ).paddingSymmetric(vertical: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                "Pickup Cost",
                                                overflow: TextOverflow.clip,
                                                maxLines: 3,
                                                style:
                                                    montserratMedium.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ).expand(),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6),
                                            child: Text(
                                                selected_pickup_type_cost
                                                            .toString() ==
                                                        "0.0"
                                                    ? "FREE"
                                                    : (selected_pickup_type_cost
                                                        .toStringAsFixed(2)),
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        fontSize: width * 0.034,
                                                        color: warningcolor)),
                                          ),
                                          50.width,
                                          Text("PAID",
                                              style: montserratMedium.copyWith(
                                                  fontSize: width * 0.034,
                                                  color: Colors.green)),
                                        ],
                                      ),
                                    ],
                                  ).paddingSymmetric(vertical: 2),
                                  packagebooking['bk_consumcost'] != "0.00" &&
                                          packagebooking[
                                                  'bk_consumepaymentflag'] !=
                                              "0"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    child: Text(
                                                      "Consumables",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 3,
                                                      style: montserratMedium
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: width *
                                                                  0.034),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ).expand(),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  child: Text(
                                                      consumablecost
                                                          .toStringAsFixed(2),
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              fontSize:
                                                                  width * 0.034,
                                                              color:
                                                                  warningcolor)),
                                                ),
                                                packagebooking[
                                                            'bk_consumepaymentflag'] !=
                                                        "1"
                                                    ? SizedBox(
                                                        width: 50,
                                                      )
                                                    : SizedBox(
                                                        width: 20,
                                                      ),
                                                Text(
                                                    packagebooking[
                                                                'bk_consumepaymentflag'] !=
                                                            "1"
                                                        ? "PAID"
                                                        : "PENDING",
                                                    style: montserratMedium.copyWith(
                                                        fontSize: width * 0.034,
                                                        color: packagebooking[
                                                                    'bk_consumepaymentflag'] !=
                                                                "1"
                                                            ? Colors.green
                                                            : Colors.red)),
                                              ],
                                            ),
                                          ],
                                        ).paddingSymmetric(vertical: 2)
                                      : SizedBox(),
                                  approvedjobs.isEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0))),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0),
                                          child: Column(
                                            children: List.generate(
                                              approvedjobs.length,
                                              (i) => Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: Container(
                                                          child: Text(
                                                            approvedjobs[i][
                                                                        'bkj_jobname'] !=
                                                                    null
                                                                ? capitalize(
                                                                    approvedjobs[
                                                                            i][
                                                                        'bkj_jobname'])
                                                                : "",
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            maxLines: 3,
                                                            style:
                                                                montserratMedium
                                                                    .copyWith(
                                                              color: black,
                                                              fontSize:
                                                                  width * 0.034,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ).expand(),
                                                  status['st_code'] == 'CDLC' &&
                                                          approvedjobs[i][
                                                                  'bkj_approvedcost'] !=
                                                              approvedjobs[i][
                                                                  'bkj_cust_cost']
                                                      ? Row(
                                                          children: [
                                                            Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(6),
                                                                child: RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                        text: approvedjobs[i]['bkj_approvedcost'] !=
                                                                                null
                                                                            ? approvedjobs[i]['bkj_approvedcost']
                                                                            : "",
                                                                        style: montserratSemiBold
                                                                            .copyWith(
                                                                          color:
                                                                              Colors.grey,
                                                                          fontSize:
                                                                              width * 0.025,
                                                                          decoration:
                                                                              TextDecoration.lineThrough,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: approvedjobs[i]['bkj_cust_cost'] !=
                                                                                null
                                                                            ? " " +
                                                                                approvedjobs[i]['bkj_cust_cost']
                                                                            : "",
                                                                        style: montserratSemiBold.copyWith(
                                                                            color:
                                                                                warningcolor,
                                                                            fontSize:
                                                                                width * 0.032),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                            approvedjobs[i][
                                                                        'bkj_status'] ==
                                                                    "4"
                                                                ? SizedBox(
                                                                    width: 50,
                                                                  )
                                                                : SizedBox(
                                                                    width: 20,
                                                                  ),
                                                            approvedjobs[i][
                                                                        'bkj_status'] ==
                                                                    "4"
                                                                ? Text("PAID",
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.034,
                                                                        color: Colors
                                                                            .green))
                                                                : Text(
                                                                    "PENDING",
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.034,
                                                                        color: Colors
                                                                            .red)),
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6),
                                                              child: Text(
                                                                  approvedjobs[i][
                                                                              'bkj_cust_cost'] !=
                                                                          null
                                                                      ? approvedjobs[
                                                                              i]
                                                                          [
                                                                          'bkj_cust_cost']
                                                                      : "",
                                                                  style: montserratSemiBold.copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.032,
                                                                      color:
                                                                          warningcolor)),
                                                            ),
                                                            approvedjobs[i][
                                                                        'bkj_status'] ==
                                                                    "4"
                                                                ? SizedBox(
                                                                    width: 50,
                                                                  )
                                                                : SizedBox(
                                                                    width: 20,
                                                                  ),
                                                            approvedjobs[i][
                                                                        'bkj_status'] ==
                                                                    "4"
                                                                ? Text("PAID",
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.034,
                                                                        color: Colors
                                                                            .green))
                                                                : Text(
                                                                    "PENDING",
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.034,
                                                                        color: Colors
                                                                            .red)),
                                                          ],
                                                        )
                                                ],
                                              ).paddingSymmetric(vertical: 2),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            pendingjobs.isEmpty
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.all(16.0),
                                    decoration: boxDecorationWithRoundedCorners(
                                      backgroundColor: white,
                                      borderRadius: radius(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Job Pending Approval",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: montserratSemiBold.copyWith(
                                            fontSize: width * 0.034,
                                            color: warningcolor,
                                          ),
                                        ),
                                        4.height,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Row(children: [
                                                    Checkbox(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      value: selectAll,
                                                      fillColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  lightblueColor),
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          selectAll =
                                                              value ?? false;

                                                          if (selectAll) {
                                                            selectedJobs =
                                                                pendingjobs
                                                                    .map(
                                                                        (job) =>
                                                                            {
                                                                              'job_id': job['bkj_id'].toString(),
                                                                              'job_accepted_cost': job['bkj_cust_cost'].toString(),
                                                                              'status': "0",
                                                                            })
                                                                    .toList();
                                                          } else {
                                                            selectedJobs
                                                                .clear();
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Container(
                                                      child: Text("Job Name",
                                                          overflow:
                                                              TextOverflow.clip,
                                                          maxLines: 3,
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  fontSize:
                                                                      width *
                                                                          0.032,
                                                                  color:
                                                                      black)),
                                                    ),
                                                  ]),
                                                ),
                                              ],
                                            ).expand(),
                                            Row(
                                              children: [
                                                Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text('Cost (AED)',
                                                        style: montserratSemiBold
                                                            .copyWith(
                                                                fontSize:
                                                                    width *
                                                                        0.032,
                                                                color: black))),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Column(
                                          children: [
                                            Column(
                                              children: List.generate(
                                                pendingjobs.length,
                                                (i) => Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                ),
                                                                fillColor: MaterialStateProperty
                                                                    .all(syanColor
                                                                        .withOpacity(
                                                                            0.8)),
                                                                value: selectedJobs.any((jobInfo) =>
                                                                    jobInfo[
                                                                        'job_id'] ==
                                                                    pendingjobs[
                                                                            i][
                                                                        'bkj_id']),
                                                                onChanged:
                                                                    (bool?
                                                                        value) {
                                                                  setState(() {
                                                                    if (value !=
                                                                        null) {
                                                                      Map<String,
                                                                              String>
                                                                          jobInfo =
                                                                          {
                                                                        'job_id':
                                                                            pendingjobs[i]['bkj_id'].toString(),
                                                                        'job_accepted_cost':
                                                                            pendingjobs[i]['bkj_cust_cost'].toString(),
                                                                        'status':
                                                                            "0",
                                                                      };

                                                                      if (value) {
                                                                        selectedJobs
                                                                            .add(jobInfo);
                                                                      } else {
                                                                        selectedJobs.removeWhere((jobInfo) =>
                                                                            jobInfo['job_id'] ==
                                                                            pendingjobs[i]['bkj_id'].toString());
                                                                      }
                                                                    }
                                                                    selectAll = selectedJobs
                                                                            .length ==
                                                                        pendingjobs
                                                                            .length;
                                                                  });
                                                                },
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child: Text(
                                                                    pendingjobs[i]['bkj_jobname'] !=
                                                                            null
                                                                        ? capitalize(
                                                                            pendingjobs[i]['bkj_jobname'],
                                                                          )
                                                                        : "",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                    maxLines: 3,
                                                                    style: montserratMedium
                                                                        .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ).expand(),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                            pendingjobs[i][
                                                                'bkj_cust_cost'],
                                                            style:
                                                                montserratSemiBold
                                                                    .copyWith(
                                                              color:
                                                                  warningcolor,
                                                              fontSize:
                                                                  width * 0.032,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            selectAll || selectedJobs.isNotEmpty
                                                ? Divider(
                                                    color: black,
                                                  )
                                                : SizedBox(),
                                            selectAll || selectedJobs.isNotEmpty
                                                ? Container(
                                                    padding: EdgeInsets.all(2),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red
                                                                .withAlpha(30),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              showConfirmDialogCustom(
                                                                height: 65,
                                                                context,
                                                                title:
                                                                    'Are you sure you want to reject this job?',
                                                                primaryColor:
                                                                    warningcolor,
                                                                customCenterWidget:
                                                                    Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 8),
                                                                  child: Image
                                                                      .asset(
                                                                    "assets/icons/reject.png",
                                                                    width:
                                                                        width /
                                                                            2,
                                                                    height: 95,
                                                                  ),
                                                                ),
                                                                onAccept:
                                                                    (v) async {
                                                                  selectedJobs
                                                                      .forEach(
                                                                          (jobInfo) {
                                                                    jobInfo['status'] =
                                                                        "3";
                                                                  });
                                                                  Map req = {
                                                                    'selectedjobs':
                                                                        selectedJobs,
                                                                    'bookid': widget
                                                                        .booking_id,
                                                                    "booking_version":
                                                                        booking[
                                                                            'bk_version']
                                                                  };
                                                                  await multipleJobUpdate(
                                                                          req)
                                                                      .then(
                                                                          (value) {
                                                                    if (value[
                                                                            'ret_data'] ==
                                                                        "success") {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => Workcard(click_id: widget.click_id, booking_id: widget.booking_id, vehname: widget.vehname, vehmake: widget.vehmake)));
                                                                    } else if (value[
                                                                            'ret_data'] ==
                                                                        "changed") {
                                                                      showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder: (BuildContext context) => ShowChangePopUp(
                                                                            bk_id:
                                                                                widget.booking_id,
                                                                            vehname: widget.vehname,
                                                                            make: widget.vehmake,
                                                                            clickid: widget.click_id),
                                                                      );
                                                                    }
                                                                  });
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                                Icons
                                                                    .close_outlined,
                                                                color:
                                                                    redColor),
                                                            iconSize: 22,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.green
                                                                .withAlpha(30),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              showConfirmDialogCustom(
                                                                height: 65,
                                                                context,
                                                                title:
                                                                    'Approve Job?',
                                                                primaryColor:
                                                                    syanColor,
                                                                customCenterWidget:
                                                                    Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 8),
                                                                  child: Image
                                                                      .asset(
                                                                    "assets/icons/approve.png",
                                                                    width:
                                                                        width /
                                                                            2,
                                                                    height: 95,
                                                                  ),
                                                                ),
                                                                onAccept:
                                                                    (v) async {
                                                                  selectedJobs
                                                                      .forEach(
                                                                          (jobInfo) {
                                                                    jobInfo['status'] =
                                                                        "2";
                                                                  });

                                                                  Map req = {
                                                                    'selectedjobs':
                                                                        selectedJobs,
                                                                    'bookid': widget
                                                                        .booking_id,
                                                                    "booking_version":
                                                                        booking[
                                                                            'bk_version']
                                                                  };
                                                                  await multipleJobUpdate(
                                                                          req)
                                                                      .then(
                                                                          (value) {
                                                                    if (value[
                                                                            'ret_data'] ==
                                                                        "success") {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => Workcard(click_id: widget.click_id, booking_id: widget.booking_id, vehname: widget.vehname, vehmake: widget.vehmake)));
                                                                    } else if (value[
                                                                            'ret_data'] ==
                                                                        "changed") {
                                                                      showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder: (BuildContext context) => ShowChangePopUp(
                                                                            bk_id:
                                                                                widget.booking_id,
                                                                            vehname: widget.vehname,
                                                                            make: widget.vehmake,
                                                                            clickid: widget.click_id),
                                                                      );
                                                                    }
                                                                  });
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                                Icons
                                                                    .check_sharp,
                                                                color:
                                                                    greenColor),
                                                            iconSize: 22,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            Container(
                              padding: EdgeInsets.only(left: 16.0, right: 16.0),
                              child: Divider(
                                color: black,
                              ),
                            ),
                            coupondiscount != 0 || normaldiscount != 0
                                ? Container(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 12,
                                          child: Text(
                                            "Total Cost: ",
                                            textAlign: TextAlign.right,
                                            style: montserratSemiBold.copyWith(
                                              color: black,
                                              fontSize: width * 0.034,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            withoutcoupontotal
                                                .toStringAsFixed(2),
                                            textAlign: TextAlign.right,
                                            style: montserratSemiBold.copyWith(
                                                color: warningcolor,
                                                fontSize: width * 0.034),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 4,
                            ),
                            coupondiscount != 0
                                ? Container(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 12,
                                          child: Text(
                                            "Coupon Discounts: ",
                                            style: montserratSemiBold.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            coupondiscount.toStringAsFixed(2),
                                            style: montserratSemiBold.copyWith(
                                                color: warningcolor,
                                                fontSize: width * 0.034),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 4,
                            ),
                            normaldiscount != 0
                                ? Container(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 12,
                                          child: Text(
                                            "Discounts: ",
                                            style: montserratSemiBold.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            normaldiscount.toStringAsFixed(2),
                                            style: montserratSemiBold.copyWith(
                                                color: warningcolor,
                                                fontSize: width * 0.034),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 12,
                                    child: Text(
                                      "Grand Total\n(VAT inclusive): ",
                                      style: montserratSemiBold.copyWith(
                                          color: black,
                                          fontSize: width * 0.034),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      grandtotal.toStringAsFixed(2),
                                      style: montserratSemiBold.copyWith(
                                          color: warningcolor,
                                          fontSize: width * 0.034),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 12,
                                    child: Text(
                                      "Paid Amount: ",
                                      style: montserratSemiBold.copyWith(
                                          color: black,
                                          fontSize: width * 0.034),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      paidamount.toStringAsFixed(2),
                                      style: montserratSemiBold.copyWith(
                                          color: warningcolor,
                                          fontSize: width * 0.034),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 12,
                                    child: Text(
                                      "Balance Amount: ",
                                      style: montserratSemiBold.copyWith(
                                          color: black,
                                          fontSize: width * 0.034),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      amounttopay.toStringAsFixed(2),
                                      style: montserratSemiBold.copyWith(
                                          color: warningcolor,
                                          fontSize: width * 0.034),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            pendingjobs.isEmpty
                                ? approvedjobs.isEmpty
                                    ? SizedBox()
                                    : Container(
                                        padding: EdgeInsets.only(
                                            left: 16.0, right: 16.0),
                                        child: Divider(
                                          color: black,
                                        ),
                                      )
                                : Container(
                                    padding: EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    child: Divider(
                                      color: black,
                                    ),
                                  ),
                            pendingjobs.isEmpty
                                ? approvedjobs.isEmpty
                                    ? SizedBox()
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "DISCLAIMER",
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.clip,
                                            style: montserratSemiBold.copyWith(
                                              fontSize: 12,
                                              color: black,
                                            ),
                                          ),
                                        ],
                                      )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "DISCLAIMER",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.clip,
                                        style: montserratSemiBold.copyWith(
                                          fontSize: 12,
                                          color: black,
                                        ),
                                      ),
                                    ],
                                  ),
                            pendingjobs.isEmpty
                                ? approvedjobs.isEmpty
                                    ? SizedBox()
                                    : const SizedBox(height: 4)
                                : const SizedBox(height: 4),
                            pendingjobs.isEmpty
                                ? approvedjobs.isEmpty
                                    ? SizedBox()
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  16, 0, 16, 0),
                                              child: Text(
                                                "Please note that while the final cost may vary depending on the specifics of the completed work, it will never exceed the amount agreed upon in the initial estimate.",
                                                textAlign: TextAlign.justify,
                                                style:
                                                    montserratMedium.copyWith(
                                                  fontSize: 12,
                                                  color: black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(16, 0, 16, 0),
                                          child: Text(
                                            "Please note that while the final cost may vary depending on the specifics of the completed work, it will never exceed the amount agreed upon in the initial estimate.",
                                            textAlign: TextAlign.justify,
                                            style: montserratMedium.copyWith(
                                              fontSize: 12,
                                              color: black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            pendingjobs.isEmpty
                                ? approvedjobs.isEmpty
                                    ? SizedBox()
                                    : SizedBox(
                                        height: 20,
                                      )
                                : SizedBox(
                                    height: 20,
                                  ),
                            status['st_code'] == 'CDLC'
                                ? amounttopay.toString() != "0.0"
                                    ? GestureDetector(
                                        onTap: () async {
                                          if (isproceeding) return;
                                          setState(() => isproceeding = true);
                                          await Future.delayed(
                                              Duration(milliseconds: 1000));
                                          createPayment(
                                              packagebooking['bk_consumcost'],
                                              packagebooking[
                                                  'bk_consumepaymentflag']);
                                        },
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Container(
                                              height: height * 0.045,
                                              width: height * 0.37,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 16,
                                                        color: syanColor
                                                            .withOpacity(.6),
                                                        spreadRadius: 0,
                                                        blurStyle:
                                                            BlurStyle.outer,
                                                        offset: Offset(0, 0)),
                                                  ]),
                                            ),
                                            Container(
                                              height: height * 0.075,
                                              width: height * 0.4,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(14)),
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
                                                      "PAYMENT",
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Transform.scale(
                                                          scale: 0.7,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row()
                                : SizedBox(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onRefresh: refresh),
        ),
      ),
    );
  }
}

class CustomSuccess extends StatelessWidget {
  final int click_id;
  final String booking_id;
  final String vehname;
  final String vehmake;

  CustomSuccess({
    required this.click_id,
    required this.booking_id,
    required this.vehname,
    required this.vehmake,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: white,
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
                    Text("Payment Success",
                        textAlign: TextAlign.center,
                        style: montserratRegular.copyWith(
                            fontSize: width * 0.032, color: white)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text("Transaction Completed Successfully.",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.032, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScheduleDropScreen(
                            click_id: click_id,
                            bk_id: booking_id,
                            vehname: vehname,
                            make: vehmake)));
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
                child:
                    Text('OK', style: montserratRegular.copyWith(color: white)),
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
                    Text('Awaiting For Payment.',
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
                child: Text("Need to complete payment for further proceeding.",
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.032, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
            16.height,
          ],
        ),
      ),
    );
  }
}

class ShowChangePopUp extends StatelessWidget {
  final String bk_id;
  final String vehname;
  final String make;
  final int clickid;
  const ShowChangePopUp(
      {required this.bk_id,
      required this.vehname,
      required this.make,
      required this.clickid,
      super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius:
              BorderRadius.circular(12.0), // Adjust the value for desired curve
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
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
                      borderRadius: BorderRadius.circular(12.0),
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
                      ImageConst.change_warning,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Status Changed",
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: black)),
                  ],
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                    "Please refresh the booking to reflect the changes made to the work card.",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.034, color: black))),
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 12, right: 12),
                          height: height * 0.055,
                          width: height * 0.25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(color: syanColor),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                white,
                                white,
                                white,
                                white,
                              ],
                            ),
                          ),
                          child: Text(
                            "CLOSE",
                            style:
                                montserratSemiBold.copyWith(color: syanColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Workcard(
                                  click_id: clickid,
                                  booking_id: bk_id,
                                  vehname: vehname,
                                  vehmake: make)));
                    },
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 12, right: 12),
                          height: height * 0.055,
                          width: height * 0.25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(color: syanColor),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                lightblueColor,
                                syanColor,
                              ],
                            ),
                          ),
                          child: Text(
                            "REFRESH",
                            style: montserratSemiBold.copyWith(color: white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

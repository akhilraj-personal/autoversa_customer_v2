import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/main.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentWaitingScreen extends StatefulWidget {
  final Map<String, dynamic> bk_data;
  final List<dynamic> custvehlist;
  const PaymentWaitingScreen(
      {required this.bk_data, required this.custvehlist, super.key});

  @override
  State<PaymentWaitingScreen> createState() => PaymentWaitingScreenState();
}

class PaymentWaitingScreenState extends State<PaymentWaitingScreen> {
  bool isproceeding = false;
  late Map<String, dynamic> bookingdetails = {};
  late Map<String, dynamic> dropdetails = {};
  late Map<String, dynamic> pickup_timeslot = {};
  late Map<String, dynamic> pickup_type = {};
  late Map<String, dynamic> vehicle = {};
  late Map<String, dynamic> audio = {};
  late Map<String, dynamic> booking_package = {};
  late Map<String, dynamic> pickup_address = {};
  var trnxId;
  bool iscancelsubmitted = false;
  final _formKey = GlobalKey<FormState>();
  FocusNode cancelFocus = FocusNode();
  var cancel = "";
  bool isoffline = false;
  StreamSubscription? internetconnection;

  @override
  void initState() {
    super.initState();
    // internetconnection = Connectivity()
    //     .onConnectivityChanged
    //     .listen((ConnectivityResult result) {
    //   if (result == ConnectivityResult.none) {
    //     setState(() {
    //       isoffline = true;
    //       Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => NoInternetScreen()));
    //     });
    //   } else if (result == ConnectivityResult.mobile) {
    //     setState(() {
    //       isoffline = false;
    //     });
    //   } else if (result == ConnectivityResult.wifi) {
    //     setState(() {
    //       isoffline = false;
    //     });
    //   }
    // });
    init();
    Future.delayed(Duration.zero, () {
      getBookingDetailsID();
    });
  }

  cancelbookingbottomsheet() async {
    showModalBottomSheet(
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setBottomState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                color: white,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          margin: const EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          width: width * 1.85,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          duration: 1000.milliseconds,
                          curve: Curves.linearToEaseOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      height: 950,
                                      decoration: BoxDecoration(
                                          color:
                                              context.scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Column(
                                        children: [
                                          8.height,
                                          Column(
                                            children: <Widget>[
                                              SizedBox(
                                                width: double.infinity,
                                                child: Container(
                                                  child: Text(
                                                    "Cancel Reason" + "*",
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          8.height,
                                          Padding(
                                            padding: EdgeInsets.all(2),
                                            child: Container(
                                              width: context.width() * 0.85,
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  color: white),
                                              child: TextField(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  minLines: 1,
                                                  maxLines: 5,
                                                  maxLength: 500,
                                                  textInputAction:
                                                      TextInputAction.newline,
                                                  focusNode: cancelFocus,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      cancel = value;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                      counterText: "",
                                                      hintText: "Enter Reason",
                                                      hintStyle:
                                                          primaryTextStyle(
                                                        color: black,
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: black,
                                                                width: 0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: black,
                                                                width: 0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ))),
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          16.height,
                                          GestureDetector(
                                            onTap: () async {
                                              if (cancel == "") {
                                                setState(() =>
                                                    iscancelsubmitted = false);
                                                showCustomToast(
                                                    context, "Enter Reason",
                                                    bgColor: warningcolor,
                                                    textColor: white);
                                              } else {
                                                try {
                                                  setState(() =>
                                                      iscancelsubmitted = true);
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  Map req = {
                                                    "bookid":
                                                        widget.bk_data['bk_id'],
                                                    "reason": cancel,
                                                    "type": "CANCEL",
                                                    "backendstatus": "CANB",
                                                    "customerstatus": "CANC",
                                                    "user_type": "0",
                                                    "current_bstatus":
                                                        "Awaiting payment",
                                                    "current_cstatus":
                                                        "Awaiting payment"
                                                  };
                                                  await booking_cancel(req)
                                                      .then((value) {
                                                    if (value['ret_data'] ==
                                                        "success") {
                                                      showCustomToast(context,
                                                          "Booking Canceled",
                                                          bgColor: Colors.black,
                                                          textColor: white);

                                                      Navigator
                                                          .pushReplacementNamed(
                                                              context,
                                                              Routes.bottombar);
                                                    } else {
                                                      setState(() =>
                                                          iscancelsubmitted =
                                                              false);
                                                    }
                                                  });
                                                } catch (e) {
                                                  setState(() =>
                                                      iscancelsubmitted =
                                                          false);
                                                  showCustomToast(
                                                      context,
                                                      lang.S
                                                          .of(context)
                                                          .toast_application_error,
                                                      bgColor: errorcolor,
                                                      textColor: white);
                                                  print(e.toString());
                                                }
                                                finish(context);
                                              }
                                            },
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Container(
                                                  height: height * 0.045,
                                                  width: height * 0.37,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 16,
                                                            color: syanColor
                                                                .withOpacity(
                                                                    .6),
                                                            spreadRadius: 0,
                                                            blurStyle:
                                                                BlurStyle.outer,
                                                            offset:
                                                                Offset(0, 0)),
                                                      ]),
                                                ),
                                                Container(
                                                  height: height * 0.075,
                                                  width: height * 0.4,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                14)),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        syanColor,
                                                        lightblueColor,
                                                      ],
                                                    ),
                                                  ),
                                                  child: !iscancelsubmitted
                                                      ? Text(
                                                          lang.S
                                                              .of(context)
                                                              .book_now,
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white),
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_data['bk_id']))};
    print(req);
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          bookingdetails = value['booking'];
          dropdetails = value['booking']['drop_address'];
          pickup_type = value['booking']['pickup_type'];
          booking_package = value['booking']['booking_package'];
          vehicle = value['booking']['vehicle'];
          pickup_address = value['booking']['pickup_address'];
          value['audio'] != null ? audio = value['audio'] : "";
        });
      }
    });
  }

  Future<void> init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    // internetconnection!.cancel();
  }

  createBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> booking = {
        "bookid": bookingdetails['bk_id'],
        "custId": prefs.getString('cust_id'),
        "vehId": bookingdetails['bk_vehicle_id'],
        "bookingdate": bookingdetails['bk_booking_date'],
        "slot": bookingdetails['pickup_timeslot']['tm_id'],
        "pickupaddress": bookingdetails['bk_pickup_address'],
        "dropaddress": bookingdetails['bk_drop_address'],
        "pickuptype": bookingdetails['pickup_type']['pk_id'],
        'complaint': bookingdetails['bk_complaint'],
        "advance": "0",
        "discount": "0",
        "total_amount": bookingdetails['bk_total_amount'],
      };
      await createRescheduleBooking(booking).then((value) {
        if (value['ret_data'] == "success") {
          createPayment(bookingdetails['bk_id'], value['payment_details']);
          trnxId = value['payment_details']['id'];
        }
      });
    } catch (e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
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
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'AE',
        ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'AE',
          testEnv: true,
        ),
        style: ThemeMode.light,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
              background: Colors.white,
              primary: Colors.blue,
              componentBorder: Colors.red,
              primaryText: Colors.black,
              secondaryText: Colors.black,
              componentBackground: Colors.white,
              placeholderText: Colors.black87,
              componentText: Colors.black87,
              icon: Colors.black87),
          shapes: PaymentSheetShape(
            borderWidth: 4,
            borderRadius: 10.00,
            shadow: PaymentSheetShadowParams(color: Colors.red),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Colors.blue,
                text: Colors.white,
                border: Color.fromARGB(255, 235, 92, 30),
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
        'tot_amount': bookingdetails['bk_total_amount'],
        'trxn_id': trnxId,
        'complaint': bookingdetails['bk_complaint'],
        'slot': bookingdetails['bk_timeslot'],
        'bookingdate': bookingdetails['bk_booking_date'],
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
            " ",
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
                    Container(
                      margin: EdgeInsets.all(8.0),
                      width: context.width() * 1.95,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: white),
                      child: Row(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.all(8)),
                          Image.asset(ImageConst.defcar_ico,
                              width: 50, height: 50),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 8),
                                  Text(
                                      bookingdetails['cv_plate_number'] != null
                                          ? bookingdetails['cv_plate_number']
                                              .toUpperCase()
                                          : "",
                                      style: montserratSemiBold.copyWith(
                                          color: black,
                                          fontSize: width * 0.034),
                                      maxLines: 2),
                                  Text(
                                      vehicle['cv_make'] != null
                                          ? vehicle['cv_make'] +
                                              " " +
                                              vehicle['cv_model'] +
                                              " (" +
                                              vehicle['cv_year'] +
                                              ")"
                                          : "",
                                      style: montserratRegular.copyWith(
                                        fontSize: width * 0.032,
                                        color: black,
                                      )),
                                  Text(
                                      vehicle['cv_variant'] != null &&
                                              vehicle['cv_variant'] != ""
                                          ? vehicle['cv_variant']
                                          : "",
                                      style: montserratRegular.copyWith(
                                          fontSize: width * 0.032,
                                          color: black),
                                      maxLines: 2),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      margin: const EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      width: context.width() * 1.85,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: defaultBoxShadow(),
                      ),
                      duration: 1000.milliseconds,
                      curve: Curves.linearToEaseOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF808080).withOpacity(0.3),
                                    offset: Offset(0.0, 1.0),
                                    blurRadius: 2.0)
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8)),
                                  margin: EdgeInsets.only(left: 0, right: 16),
                                  width: 75,
                                  height: 75,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        Transform.scale(
                                      scale: 0.5,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                    imageUrl:
                                        booking_package['pkg_imageurl'] != null
                                            ? dotenv.env['aws_url']! +
                                                booking_package['pkg_imageurl']
                                            : "",
                                  ),
                                  padding: EdgeInsets.all(width / 30),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Container(
                                              child: Text(
                                                  booking_package['pkg_name'] !=
                                                          null
                                                      ? booking_package[
                                                          'pkg_name']
                                                      : "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.032)),
                                            ),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                      ),
                                      Text(
                                        booking_package['bkp_cust_amount'] !=
                                                null
                                            ? "AED " +
                                                booking_package[
                                                    'bkp_cust_amount']
                                            : "0",
                                        style: montserratRegular.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.032),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Color(0XFFB4BBC2)),
                          Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(5)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF808080).withOpacity(0.3),
                                    offset: Offset(0.0, 1.0),
                                    blurRadius: 2.0)
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[],
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            pickup_type['pk_name'] ?? "",
                                            style: montserratRegular.copyWith(
                                                color: black,
                                                fontSize: width * 0.032),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                      ),
                                      Text(
                                        bookingdetails['bk_pickup_cost'] != null
                                            ? bookingdetails[
                                                        'bk_pickup_cost'] !=
                                                    '0'
                                                ? "AED " +
                                                    bookingdetails[
                                                        'bk_pickup_cost']
                                                : "FREE"
                                            : "",
                                        style: montserratRegular.copyWith(
                                            fontSize: width * 0.032,
                                            color: black),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          12.height,
                          Row(
                            children: <Widget>[
                              Text(
                                "Pickup Location* ",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: montserratSemiBold.copyWith(
                                  fontSize: width * 0.034,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Padding(
                            padding: EdgeInsets.all(2),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  color: white),
                              child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: 5,
                                  readOnly: true,
                                  controller: TextEditingController()
                                    ..text = pickup_address['cad_address'] !=
                                            null
                                        ? pickup_address['cad_address'] +
                                                " " +
                                                pickup_address['city_name'] +
                                                " " +
                                                pickup_address['state_name'] ??
                                            ""
                                        : "",
                                  decoration: InputDecoration(
                                      hintText: "Address",
                                      hintStyle: montserratRegular.copyWith(
                                        color: black,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ))),
                              alignment: Alignment.center,
                            ),
                          ),
                          8.height,
                          Row(
                            children: <Widget>[
                              Text(
                                "Drop Location* ",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: montserratSemiBold.copyWith(
                                  fontSize: width * 0.034,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Padding(
                            padding: EdgeInsets.all(2),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  color: white),
                              child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: 5,
                                  readOnly: true,
                                  controller: TextEditingController()
                                    ..text = dropdetails['cad_address'] != null
                                        ? dropdetails['cad_address'] +
                                                ", " +
                                                dropdetails['city_name'] +
                                                ", " +
                                                dropdetails['state_name'] ??
                                            ""
                                        : "",
                                  decoration: InputDecoration(
                                      hintText: "Address",
                                      hintStyle: montserratRegular.copyWith(
                                        color: black,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ))),
                              alignment: Alignment.center,
                            ),
                          ),
                          18.height,
                          Text("Select Date & Time*",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034)),
                          12.height,
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(4)),
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: syanColor,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.date_range,
                                          color: white,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                    16.width,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            bookingdetails['bk_booking_date'] !=
                                                    null
                                                ? DateFormat('LLLL').format(
                                                    DateTime.parse(
                                                        bookingdetails[
                                                            'bk_booking_date']))
                                                : "",
                                            style: montserratRegular.copyWith(
                                                color: black,
                                                fontSize: width * 0.032)),
                                        Text(
                                            bookingdetails['bk_booking_date'] !=
                                                    null
                                                ? DateFormat('d').format(
                                                    DateTime.parse(
                                                        bookingdetails[
                                                            'bk_booking_date']))
                                                : "",
                                            style: montserratRegular.copyWith(
                                                color: errorcolor,
                                                fontSize: width * 0.032)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(4)),
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: syanColor,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.access_time_rounded,
                                          color: white,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                    16.width,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            pickup_timeslot['tm_start_time'] !=
                                                    null
                                                ? pickup_timeslot[
                                                        'tm_start_time'] +
                                                    " - "
                                                : "",
                                            maxLines: 1,
                                            style: montserratRegular.copyWith(
                                                color: errorcolor,
                                                fontSize: width * 0.032)),
                                        Text(
                                            pickup_timeslot['tm_end_time'] !=
                                                    null
                                                ? pickup_timeslot['tm_end_time']
                                                : "",
                                            style: montserratRegular.copyWith(
                                                color: errorcolor,
                                                fontSize: width * 0.032)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          16.height,
                          Row(
                            children: <Widget>[
                              Text(
                                "Additional Comments",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: montserratRegular.copyWith(
                                  fontSize: width * 0.032,
                                  color: black,
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Padding(
                            padding: EdgeInsets.all(2),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  color: white),
                              child: TextField(
                                  controller: TextEditingController()
                                    ..text =
                                        bookingdetails['bk_complaint'] != null
                                            ? bookingdetails['bk_complaint']
                                            : "",
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: 5,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      hintText: "Additional Comments",
                                      hintStyle: primaryTextStyle(
                                        color: black,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ))),
                              alignment: Alignment.center,
                            ),
                          ),
                          16.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "Grand Total" + ": ",
                                style: montserratSemiBold.copyWith(
                                    color: black, fontSize: width * 0.034),
                              ),
                              Text(
                                booking_package['bkp_cust_amount'] != null
                                    ? " AED " +
                                        (double.parse(booking_package[
                                                    'bkp_cust_amount']) +
                                                double.parse(booking_package[
                                                    'bk_pickup_cost']))
                                            .toString()
                                    : "0",
                                style: montserratSemiBold.copyWith(
                                    color: warningcolor,
                                    fontSize: width * 0.034),
                              ),
                            ],
                          ),
                          16.height,
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    cancelbookingbottomsheet();
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
                                                  color:
                                                      syanColor.withOpacity(.6),
                                                  spreadRadius: 0,
                                                  blurStyle: BlurStyle.outer,
                                                  offset: Offset(0, 0)),
                                            ]),
                                      ),
                                      Container(
                                        height: height * 0.075,
                                        width: height * 0.45,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
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
                                        child: !isproceeding
                                            ? Text(
                                                "CANCEL",
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color: Colors.white),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (isproceeding) return;
                                    setState(() => isproceeding = true);
                                    await Future.delayed(
                                        Duration(milliseconds: 1000));
                                    createBooking();
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
                                                  color:
                                                      syanColor.withOpacity(.6),
                                                  spreadRadius: 0,
                                                  blurStyle: BlurStyle.outer,
                                                  offset: Offset(0, 0)),
                                            ]),
                                      ),
                                      Container(
                                        height: height * 0.075,
                                        width: height * 0.45,
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
                                                "PROCEED TO PAY",
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color: Colors.white),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    40.height,
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
                Container(height: 130, color: warningcolor),
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
                    "Please check dashboard to complete payment for further proceedings.",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.032, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
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
                Container(height: 130, color: black),
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
                    Text("Booking Successfull",
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
                child: Text("Please check dashboard for booking status",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.032, color: black))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
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

import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
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
  List<Map<String, dynamic>> tempjobs = [];
  List<Map<String, dynamic>> temppendingjobs = [];
  var totalamount = 0.0;
  var amounttopay = 0.0;
  var pickupcost = 0.0;
  var paidamount = 0.0;
  var grandtotal = 0.0;
  var grandpaidamount = 0.0;
  var pickuppackagecost = 0.0;
  var trnxId;
  bool isoffline = false;
  StreamSubscription? internetconnection;
  bool isproceeding = false;

  @override
  void initState() {
    super.initState();
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isoffline = true;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NoInternetScreen()));
        });
      } else if (result == ConnectivityResult.mobile) {
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          isoffline = false;
        });
      }
    });
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
    internetconnection!.cancel();
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

  getCardJobDetails() async {
    Map req = {"bookid": widget.booking_id};
    pendingjobs = [];
    approvedjobs = [];
    await getcardjobdetails(req)
        .then((value) => {
              if (value['ret_data'] == "success")
                {
                  setState(() {
                    packagebooking = value['booking'];
                  }),
                  pickupcost =
                      double.parse(value['booking']['bk_total_amount']) -
                          double.parse(value['booking']['bkp_cust_amount']),
                  totalamount = totalamount +
                      (double.parse(value['booking']['bkp_cust_amount']) +
                          pickupcost),
                  pickuppackagecost =
                      double.parse(value['booking']['bkp_cust_amount']) +
                          pickupcost,
                  for (var paylist in value['payments'])
                    {
                      paidamount = paidamount +
                          double.parse(paylist['bpt_amount'].toString()),
                    },
                  for (var joblist in value['jobs'])
                    {
                      temppendingjobs = [],
                      if (joblist['bkj_status'] == "1")
                        {
                          approvedjobs.add(joblist),
                          totalamount = totalamount +
                              double.parse(joblist['bkj_cust_cost'].toString()),
                          setState(() {
                            var pendingjobid = {"jobid": joblist['bkj_id']};
                            temppendingjobs.add(pendingjobid);
                          })
                        }
                      else if (joblist['bkj_status'] == "0")
                        {
                          pendingjobs.add(joblist),
                        },
                    },
                  grandtotal = (totalamount).toDouble(),
                  amounttopay = ((totalamount) - (paidamount)).toDouble(),
                  setState(() {}),
                }
              else
                {}
            })
        .catchError((e) {});
  }

  updateJob(jobid) async {
    Map req = {
      "job_id": jobid['bkj_id'],
      "jobname": jobid['bkj_jobname'],
      "bkj_bkid": widget.booking_id,
      "status": 1,
    };
    setState(() {
      var inData = {"jobid": jobid['bkj_id']};
      temppendingjobs.add(inData);
    });
    await withoutpayment(req).then((value) {
      if (value['ret_data'] == "success") {
        approvedjobs.add(jobid);
        totalamount =
            totalamount + double.parse(jobid['bkj_cust_cost'].toString());
        grandtotal = (totalamount);
        amounttopay = (totalamount - (paidamount));
        pendingjobs.removeWhere((item) => item['bkj_id'] == jobid['bkj_id']);
        setState(() {});
      }
    });
  }

  rejectJob(jobid) async {
    Map req = {
      "job_id": jobid['bkj_id'],
      "jobname": jobid['bkj_jobname'],
      "bkj_bkid": widget.booking_id,
      "status": 2,
    };
    setState(() {});
    await withoutpayment(req).then((value) {
      if (value['ret_data'] == "success") {
        pendingjobs.removeWhere((item) => item['bkj_id'] == jobid['bkj_id']);
        setState(() {});
        showCustomToast(context, "Job Rejected",
            bgColor: Colors.black, textColor: Colors.white);
      } else {
        showCustomToast(context, value['ret_data'],
            bgColor: warningcolor, textColor: Colors.white);
      }
    });
  }

  createPayment() async {
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
      showCustomToast(context, ST.of(context).toast_application_error,
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
        'job_id': temppendingjobs
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
            "Work Card",
            style: myriadproregular.copyWith(
              fontSize: 18,
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
          child: Column(
            children: [
              SizedBox(height: 10),
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
                              widget.click_id == 1 ? "" : "Pending Payment",
                              style: montserratSemiBold.copyWith(
                                  fontSize: 16,
                                  color: widget.click_id == 1 ? black : black),
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
                            if (vehicle['cv_make'] == 'Mercedes Benz') ...[
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
                            ] else ...[
                              Image.asset(ImageConst.defcar_ico,
                                  width: width / 8, height: 50)
                            ],
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                            child: Text(
                                                booking['bk_number'] != null
                                                    ? "Booking ID: " +
                                                        booking['bk_number']
                                                    : "",
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034))),
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
                                          child: Text(widget.vehname,
                                              overflow: TextOverflow.clip,
                                              style: montserratRegular.copyWith(
                                                  color: black,
                                                  fontSize: width * 0.032)),
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
                                          style: montserratRegular.copyWith(
                                              color: black,
                                              fontSize: width * 0.032)),
                                    ],
                                  ),
                                  // 4.height,
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: <Widget>[
                                  //     Text(
                                  //         booking['bk_odometer'] != null
                                  //             ? "Odometer: " +
                                  //                 booking['bk_odometer']
                                  //             : "",
                                  //         style: montserratRegular.copyWith(
                                  //             color: black, fontSize: width * 0.032)),
                                  //   ],
                                  // ),
                                  // 4.height,
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: <Widget>[
                                  //     Text(
                                  //         booking['bk_booking_date'] != null
                                  //             ? "Date" +
                                  //                 ": " +
                                  //                 DateFormat('dd-MM-yyyy').format(
                                  //                     DateTime.tryParse(booking[
                                  //                         'bk_booking_date'])!)
                                  //             : "",
                                  //         style: montserratRegular.copyWith(
                                  //             color: black, fontSize: width * 0.032)),
                                  //   ],
                                  // ),
                                  // 4.height,
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: <Widget>[
                                  //     Text(
                                  //         service_advisor['us_firstname'] !=
                                  //                 null
                                  //             ? "Service Advisor: " +
                                  //                 service_advisor[
                                  //                     'us_firstname']
                                  //             : "Service Advisor: Not Assigned",
                                  //         style: montserratRegular.copyWith(
                                  //             color: black, fontSize: width * 0.032)),
                                  //   ],
                                  // ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          service_advisor['us_phone'] != null
                                              ? "Contact" +
                                                  ": " +
                                                  service_advisor['us_phone']
                                              : "",
                                          style: montserratRegular.copyWith(
                                              color: black,
                                              fontSize: width * 0.032)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        child: Text("Package & Job Name",
                                            overflow: TextOverflow.clip,
                                            maxLines: 3,
                                            style: montserratSemiBold.copyWith(
                                                fontSize: width * 0.032,
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
                                            style: montserratSemiBold.copyWith(
                                                fontSize: width * 0.032,
                                                color: warningcolor))),
                                    8.width,
                                    Text('Status',
                                        style: montserratSemiBold.copyWith(
                                            fontSize: width * 0.032,
                                            color: black)),
                                  ],
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        child: Text(
                                            packagebooking['pkg_name'] != null
                                                ? packagebooking['pkg_name']
                                                : "",
                                            overflow: TextOverflow.clip,
                                            maxLines: 3,
                                            style: montserratRegular.copyWith(
                                              fontSize: width * 0.032,
                                              color: black,
                                            )),
                                      ),
                                    ),
                                  ],
                                ).expand(),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      child: Text(
                                          packagebooking['bkp_cust_amount'] !=
                                                  null
                                              ? packagebooking[
                                                  'bkp_cust_amount']
                                              : "",
                                          style: montserratSemiBold.copyWith(
                                              fontSize: width * 0.032,
                                              color: warningcolor)),
                                    ),
                                    8.width,
                                    Text("PAID",
                                        style: montserratRegular.copyWith(
                                            fontSize: width * 0.032,
                                            color: Colors.green)),
                                  ],
                                ),
                              ],
                            ).paddingSymmetric(vertical: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        child: Text("Pickup Cost",
                                            overflow: TextOverflow.clip,
                                            maxLines: 3,
                                            style: montserratRegular.copyWith(
                                              fontSize: width * 0.032,
                                              color: black,
                                            )),
                                      ),
                                    ),
                                  ],
                                ).expand(),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      child: Text(
                                          pickupcost.toString() == "0.0"
                                              ? "FREE"
                                              : (pickupcost.toStringAsFixed(2)),
                                          style: montserratSemiBold.copyWith(
                                              fontSize: width * 0.032,
                                              color: warningcolor)),
                                    ),
                                    8.width,
                                    Text("PAID",
                                        style: montserratRegular.copyWith(
                                            fontSize: width * 0.032,
                                            color: Colors.green)),
                                  ],
                                ),
                              ],
                            ).paddingSymmetric(vertical: 8),
                            4.height,
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
                                                        approvedjobs[i][
                                                                    'bkj_jobname'] !=
                                                                null
                                                            ? approvedjobs[i]
                                                                ['bkj_jobname']
                                                            : "",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        maxLines: 3,
                                                        style: montserratRegular
                                                            .copyWith(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: black,
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ).expand(),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  child: Text(
                                                      approvedjobs[i][
                                                                  'bkj_cust_cost'] !=
                                                              null
                                                          ? approvedjobs[i]
                                                              ['bkj_cust_cost']
                                                          : "",
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              fontSize:
                                                                  width * 0.032,
                                                              color:
                                                                  warningcolor)),
                                                ),
                                                8.width,
                                                approvedjobs[i][
                                                            'bkj_payment_status'] ==
                                                        "0"
                                                    ? Text("PENDING",
                                                        style: montserratRegular
                                                            .copyWith(
                                                                fontSize:
                                                                    width *
                                                                        0.032,
                                                                color:
                                                                    Colors.red))
                                                    : Text("PAID",
                                                        style: montserratRegular
                                                            .copyWith(
                                                                fontSize:
                                                                    width *
                                                                        0.032,
                                                                color: Colors
                                                                    .green)),
                                              ],
                                            )
                                          ],
                                        ).paddingSymmetric(vertical: 8),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Job Pending Approval",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: black,
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
                                              child: Text("Job Name",
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
                                                          color: black))),
                                          20.width,
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text('Action',
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        fontSize: width * 0.032,
                                                        color: black)),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text('      ',
                                                style:
                                                    montserratRegular.copyWith(
                                                        fontSize: width * 0.032,
                                                        color: black)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Column(
                                    children: List.generate(
                                      pendingjobs.length,
                                      (i) => Row(
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
                                                      pendingjobs[i]
                                                              ['bkj_jobname']
                                                          .toUpperCase(),
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 3,
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: width *
                                                                  0.032)),
                                                ),
                                              ),
                                            ],
                                          ).expand(),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  pendingjobs[i]
                                                      ['bkj_cust_cost'],
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                    color: warningcolor,
                                                    fontSize: width * 0.032,
                                                  ),
                                                ),
                                              ),
                                              20.width,
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withAlpha(30),
                                                    borderRadius: radius(10),
                                                    border: Border.all(
                                                        color: Colors.red),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          content: Text(
                                                              'Are you sure you want to reject this job.?',
                                                              style: montserratSemiBold
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white)),
                                                          action:
                                                              SnackBarAction(
                                                                  label:
                                                                      'REJECT',
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  onPressed:
                                                                      () async {
                                                                    rejectJob(
                                                                        pendingjobs[
                                                                            i]);
                                                                    setState(
                                                                        () {});
                                                                  }),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                        Icons.close_outlined,
                                                        color: redColor),
                                                    iconSize: 22,
                                                  )),
                                              8.width,
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withAlpha(30),
                                                    borderRadius: radius(10),
                                                    border: Border.all(
                                                        color: Colors.green),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              Colors.green,
                                                          content: Text(
                                                              'Approve Job.?',
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white)),
                                                          action:
                                                              SnackBarAction(
                                                                  label:
                                                                      'APPROVE',
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  onPressed:
                                                                      () async {
                                                                    updateJob(
                                                                        pendingjobs[
                                                                            i]);
                                                                    setState(
                                                                        () {});
                                                                    final prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    var pendingjob =
                                                                        pendingjobs[i]
                                                                            [
                                                                            'bkj_id'];
                                                                    prefs.setString(
                                                                        "pendingjobpayment",
                                                                        pendingjob);
                                                                    showCustomToast(
                                                                        context,
                                                                        "Approved and waiting for payment",
                                                                        bgColor:
                                                                            black,
                                                                        textColor:
                                                                            white);
                                                                  }),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                        Icons.check_sharp,
                                                        color: greenColor),
                                                    iconSize: 22,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ).paddingSymmetric(vertical: 8),
                                    ),
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
                      Container(
                        padding: EdgeInsets.only(right: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Grand Total: ",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034),
                            ),
                            Text(
                              grandtotal.toString(),
                              style: montserratSemiBold.copyWith(
                                  color: warningcolor, fontSize: width * 0.034),
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
                          children: <Widget>[
                            Text(
                              "Amount To Pay: ",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034),
                            ),
                            Text(
                              amounttopay.toString(),
                              style: montserratSemiBold.copyWith(
                                  color: warningcolor, fontSize: width * 0.034),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      amounttopay.toString() != "0.0"
                          ? GestureDetector(
                              onTap: () async {
                                if (isproceeding) return;
                                setState(() => isproceeding = true);
                                await Future.delayed(
                                    Duration(milliseconds: 1000));
                                createPayment();
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
                                            "PAYMENT",
                                            style: montserratSemiBold.copyWith(
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
                            )
                          : Row(),
                      const SizedBox(height: 500),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                    Text("Success",
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
                Navigator.of(context).pop();
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
            16.height,
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
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
  bool isproceeding = false;

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
          toasty(context, value['ret_data'],
              bgColor: Color.fromARGB(255, 255, 47, 0),
              textColor: white,
              gravity: ToastGravity.BOTTOM,
              length: Toast.LENGTH_LONG);
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
          backgroundColor: white,
          shadowColor: white,
          iconTheme: IconThemeData(color: white),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
          ),
          actions: [
            Center(
              child: Row(
                children: [
                  Container(
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
                ],
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    booking['bk_number'] != null
                        ? "ID: " + booking['bk_number']
                        : "",
                    style: montserratRegular.copyWith(
                        fontSize: 14.0, color: black),
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    booking['bk_booking_date'] != null
                        ? "Date" +
                            ": " +
                            DateFormat('dd-MM-yyyy').format(
                                DateTime.tryParse(booking['bk_booking_date'])!)
                        : "",
                    style:
                        montserratRegular.copyWith(fontSize: 12, color: black),
                  ),
                ),
              ]),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        service_advisor['us_firstname'] != null
                            ? "Service Advisor: " +
                                service_advisor['us_firstname']
                            : "Service Advisor: Not Assigned",
                        style: montserratRegular.copyWith(
                            fontSize: 12, color: black),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      service_advisor['us_phone'] != null
                          ? "Contact" + ": " + service_advisor['us_phone']
                          : "",
                      style: montserratRegular.copyWith(
                          fontSize: 12.0, color: black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              widget.click_id == 1
                                  ? "Work Card"
                                  : "Pending Payment",
                              style: montserratSemiBold.copyWith(
                                  fontSize: 14,
                                  color: widget.click_id == 1 ? black : black),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(16.0),
                        width: context.width() * 1.95,
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
                                                        fontSize: 14))),
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
                                                  color: black, fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  4.height,
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
                                              color: black, fontSize: 12)),
                                    ],
                                  ),
                                  4.height,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                          booking['bk_odometer'] != null
                                              ? "Odometer: " +
                                                  booking['bk_odometer']
                                              : "",
                                          style: montserratRegular.copyWith(
                                              color: black, fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              booking['bk_booking_date'] != null
                                  ? "Date" +
                                      ": " +
                                      DateFormat('dd-MM-yyyy').format(
                                          DateTime.tryParse(
                                              booking['bk_booking_date'])!)
                                  : "",
                              style: montserratRegular.copyWith(
                                  fontSize: 12, color: black),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              booking['bk_booking_date'] != null
                                  ? "Date" +
                                      ": " +
                                      DateFormat('dd-MM-yyyy').format(
                                          DateTime.tryParse(
                                              booking['bk_booking_date'])!)
                                  : "",
                              style: montserratRegular.copyWith(
                                  fontSize: 12, color: black),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(16.0),
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
                                                fontSize: 12, color: black)),
                                      ),
                                    ),
                                  ],
                                ).expand(),
                                Row(
                                  children: [
                                    Container(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Cost (AED)',
                                            style: montserratRegular.copyWith(
                                                fontSize: 12,
                                                color: warningcolor))),
                                    8.width,
                                    Text('Status',
                                        style: montserratRegular.copyWith(
                                            fontSize: 12, color: black)),
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
                                              fontSize: 12,
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
                                          style: montserratRegular.copyWith(
                                              fontSize: 12,
                                              color: warningcolor)),
                                    ),
                                    8.width,
                                    Text("PAID",
                                        style: montserratSemiBold.copyWith(
                                            fontSize: 12, color: Colors.black)),
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
                                              fontSize: 12,
                                              color: warningcolor,
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
                                          style: montserratRegular.copyWith(
                                              fontSize: 12,
                                              color: Colors.black)),
                                    ),
                                    8.width,
                                    Text("PAID",
                                        style: montserratRegular.copyWith(
                                            fontSize: 12, color: Colors.black)),
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
                                                          fontSize: 12,
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
                                                      style: montserratRegular
                                                          .copyWith(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black)),
                                                ),
                                                8.width,
                                                approvedjobs[i][
                                                            'bkj_payment_status'] ==
                                                        "0"
                                                    ? Text("PENDING",
                                                        style: montserratRegular
                                                            .copyWith(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.red))
                                                    : Text("PAID",
                                                        style: boldTextStyle(
                                                            size: 12,
                                                            color:
                                                                Colors.black)),
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
                                backgroundColor: black,
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
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 15,
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
                                                          fontSize: 12,
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
                                                  style: montserratRegular
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color: black))),
                                          20.width,
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text('Action',
                                                style:
                                                    montserratRegular.copyWith(
                                                        fontSize: 12,
                                                        color: black)),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text('      ',
                                                style:
                                                    montserratRegular.copyWith(
                                                        fontSize: 12,
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
                                                          ['bkj_jobname'],
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 3,
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: 12)),
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
                                                  style: montserratRegular
                                                      .copyWith(
                                                    color: warningcolor,
                                                    fontSize: 12,
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
                                                                            errorcolor,
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
                      // Container(
                      //   padding: EdgeInsets.only(right: 16.0),
                      //   decoration: boxDecorationWithRoundedCorners(
                      //     backgroundColor:
                      //         appStore.isDarkModeOn ? scaffoldDarkColor : white,
                      //     borderRadius: radius(8),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: <Widget>[
                      //       text(""),
                      //       text(
                      //         "Total amount" + ": AED " + totalamount.toString(),
                      //         textColor: blackColor,
                      //         fontFamily: fontMedium,
                      //         fontSize: 12.0,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.only(right: 16.0),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: white,
                          borderRadius: radius(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(""),
                            Text(
                              "Grand Total: " + grandtotal.toString(),
                              style: montserratRegular.copyWith(
                                  color: black, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 16.0),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: white,
                          borderRadius: radius(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(""),
                            Text(
                              "Amount to pay" + ": " + amounttopay.toString(),
                              style: montserratRegular.copyWith(
                                  color: black, fontSize: 12),
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
                                            "PROCEED",
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
          color: context.cardColor,
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
                Container(height: 150, color: Colors.green),
                Column(
                  children: [
                    Image(
                        image: AssetImage("images/automobile/success.png"),
                        height: 50,
                        color: white,
                        fit: BoxFit.cover),
                    16.height,
                    Text("Success",
                        textAlign: TextAlign.center,
                        style: montserratRegular.copyWith(
                            fontSize: 14, color: white)),
                  ],
                )
              ],
            ),
            30.height,
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text("Transaction Completed Successfully.",
                    style: secondaryTextStyle())),
            16.height,
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child:
                    Text('OK', style: montserratRegular.copyWith(color: white)),
              ),
            ),
            16.height,
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
          color: context.cardColor,
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
                Container(height: 150, color: Colors.orange),
                Column(
                  children: [
                    Image(
                        image: AssetImage("images/automobile/success.png"),
                        height: 50,
                        color: white,
                        fit: BoxFit.cover),
                    16.height,
                    Text('Awaiting For Payment.',
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: 14, color: white)),
                  ],
                )
              ],
            ),
            30.height,
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text("Need to complete payment for further proceeding.",
                    style: montserratRegular.copyWith(fontSize: 14))),
            16.height,
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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

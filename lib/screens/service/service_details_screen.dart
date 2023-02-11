import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class ServicehistoryDetails extends StatefulWidget {
  final String bk_id;
  const ServicehistoryDetails({required this.bk_id, super.key});

  @override
  State<ServicehistoryDetails> createState() => ServicehistoryDetailsState();
}

class ServicehistoryDetailsState extends State<ServicehistoryDetails> {
  late Map<String, dynamic> booking = {};
  late Map<String, dynamic> status = {};
  late Map<String, dynamic> packagebooking = {};
  late Map<String, dynamic> vehicle = {};
  late Map<String, dynamic> booking_package = {};
  late Map<String, dynamic> pickup_timeslot = {};
  var pendingjobs = [];
  var approvedjobs = [];

  var totalamount = 0.0;
  var pickupcost = 0.0;
  var paidamount = 0.0;
  var grandtotal = 0.0;
  var grandpaidamount = 0.0;
  var pickuppackagecost = 0.0;
  bool isoffline = false;

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

  timeFormatter(date_data) {
    var time = date_data;
    var temp = int.parse(time.split(':')[0]);
    String? t;
    if (temp >= 12 && temp < 24) {
      t = " PM";
    } else {
      t = " AM";
    }
    if (temp > 12) {
      temp = temp - 12;
      if (temp < 10) {
        time = time.replaceRange(0, 2, "0$temp");
        time += t;
      } else {
        time = time.replaceRange(0, 2, "$temp");
        time += t;
      }
    } else if (temp == 00) {
      time = time.replaceRange(0, 2, '12');
      time += t;
    } else {
      time += t;
    }
    return time;
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_id))};
    print(req);
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          booking = value['booking'];
          status = value['booking']['cust_status'];
          vehicle = value['booking']['vehicle'];
          booking_package = value['booking']['booking_package'];
          pickup_timeslot = value['booking']['pickup_timeslot'];
        });
      }
    });
  }

  getCardJobDetails() async {
    Map req = {"bookid": widget.bk_id};
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
                      if (joblist['bkj_status'] == "1")
                        {
                          approvedjobs.add(joblist),
                          totalamount = totalamount +
                              double.parse(joblist['bkj_cust_cost'].toString()),
                        }
                      else if (joblist['bkj_status'] == "0")
                        {
                          pendingjobs.add(joblist),
                        },
                    },
                  grandtotal = (totalamount),
                  setState(() {}),
                }
              else
                {}
            })
        .catchError((e) {});
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
            "Service Details",
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
              Container(
                color: white,
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[],
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 0, right: 16),
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                    ImageConst.default_inspection_pic),
                                padding: EdgeInsets.all(width / 30),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                              booking['bk_number'] != null
                                                  ? "ID: " +
                                                      booking['bk_number']
                                                  : "",
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: black,
                                                      fontSize: width * 0.034)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                            booking_package['pkg_name'] != null
                                                ? booking_package['pkg_name']
                                                : "",
                                            overflow: TextOverflow.clip,
                                            style: montserratRegular.copyWith(
                                                color: black,
                                                fontSize: width * 0.032)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                      booking['bk_booking_date'] !=
                                                              null
                                                          ? DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime
                                                                  .tryParse(booking[
                                                                      'bk_booking_date'])!)
                                                          : "",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: width *
                                                                  0.032)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                      pickup_timeslot[
                                                                  'tm_start_time'] !=
                                                              null
                                                          ? timeFormatter(
                                                                  pickup_timeslot[
                                                                      'tm_start_time']) +
                                                              " - " +
                                                              timeFormatter(
                                                                  pickup_timeslot[
                                                                      'tm_end_time'])
                                                          : "",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: width *
                                                                  0.032)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Container(
                                            child: Text(
                                                vehicle['cv_make'] != null
                                                    ? vehicle['cv_variant'] !=
                                                            null
                                                        ? vehicle['cv_make'] +
                                                            " " +
                                                            vehicle[
                                                                'cv_model'] +
                                                            " " +
                                                            vehicle[
                                                                'cv_variant'] +
                                                            " ( " +
                                                            vehicle['cv_year'] +
                                                            " )"
                                                        : vehicle['cv_make'] +
                                                            " " +
                                                            vehicle[
                                                                'cv_model'] +
                                                            " (" +
                                                            vehicle['cv_year'] +
                                                            ")"
                                                    : "",
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.start,
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.032)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6.0,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
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
                                          "Package & Job Name",
                                          overflow: TextOverflow.clip,
                                          maxLines: 3,
                                          style: montserratSemiBold.copyWith(
                                            fontSize: width * 0.034,
                                            color: black,
                                          ),
                                        ),
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
                                              fontSize: width * 0.034,
                                              color: black,
                                            ))),
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
                                              : pickupcost.toString(),
                                          style: montserratSemiBold.copyWith(
                                              fontSize: width * 0.032,
                                              color: warningcolor)),
                                    ),
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
                                              ],
                                            )
                                          ],
                                        ).paddingSymmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                            Divider(
                              color: black,
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
                                        color: warningcolor,
                                        fontSize: width * 0.034),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Divider(
                              color: black,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Remarks",
                              style: montserratRegular.copyWith(
                                  fontSize: width * 0.032),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                        ],
                      ),
                      SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Payment Mode" + ": Card",
                              style: montserratRegular.copyWith(
                                  fontSize: width * 0.032),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Text(
                              "Paid Date" + ": ",
                              style: montserratRegular.copyWith(
                                  fontSize: width * 0.032),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Invoiced By" + ": Digital Service",
                              style: montserratRegular.copyWith(
                                  fontSize: width * 0.032),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 500),
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

import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/booking/inspection_screen.dart';
import 'package:autoversa/screens/booking/reschedule_from_booking_screen.dart';
import 'package:autoversa/screens/booking/schedule_drop_screen.dart';
import 'package:autoversa/screens/booking/workcard_screen.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingStatusFlow extends StatefulWidget {
  final String bk_id;
  final String vehname;
  final String make;
  const BookingStatusFlow(
      {required this.bk_id,
      required this.vehname,
      required this.make,
      super.key});

  @override
  State<BookingStatusFlow> createState() => BookingStatusFlowState();
}

class BookingStatusFlowState extends State<BookingStatusFlow> {
  late Map<String, dynamic> booking = {};
  late Map<String, dynamic> booking_package = {};
  late Map<String, dynamic> pickup_timeslot = {};
  late Map<String, dynamic> status = {};
  late Map<String, dynamic> backstatus = {};
  late Map<String, dynamic> drivercontact = {};
  // late Map<String, dynamic> dropdetails = {};
  late Map<String, dynamic> vehicle = {};
  var cust_status_id;
  var back_status_id;
  late List statusflow = [];
  var CurrentDate;
  bool issubmitted = false;
  final _formKey = GlobalKey<FormState>();
  FocusNode cancelFocus = FocusNode();
  var cancel = "";
  FocusNode holdFocus = FocusNode();
  var hold = "";
  var previousstatus;
  var splittedstatus;
  var reasonhold;
  var splittedreason;
  var pastcustomerstatus;
  var pastbackendstatus;
  var reasonforhold;
  var holdbooking;
  var holdedby;
  List<Map<String, dynamic>> temppendingjobs = [];
  DateTime selectedDate = DateTime.now();
  bool isoffline = false;
  StreamSubscription? internetconnection;

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
    init();
  }

  Future<void> init() async {}

  @override
  void dispose() {
    super.dispose();
    internetconnection!.cancel();
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

  Future refresh() async {
    getBookingDetailsID();
    setState(() {});
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
                          duration: Duration(milliseconds: 1000),
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
                                          color: white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 8),
                                          Column(
                                            children: <Widget>[
                                              SizedBox(
                                                width: double.infinity,
                                                child: Container(
                                                  child: Text(
                                                    "Cancel Reason" + "*",
                                                    style: montserratLight
                                                        .copyWith(
                                                            color: black,
                                                            fontSize: 14),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Stack(
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
                                                                    .5),
                                                            spreadRadius: 0,
                                                            blurStyle:
                                                                BlurStyle.outer,
                                                            offset:
                                                                Offset(0, 0)),
                                                      ]),
                                                ),
                                                Container(
                                                  width: height * 0.5,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      color: white),
                                                  child: TextField(
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    minLines: 1,
                                                    maxLines: 5,
                                                    maxLength: 500,
                                                    textInputAction:
                                                        TextInputAction.newline,
                                                    decoration: InputDecoration(
                                                        counterText: "",
                                                        hintText:
                                                            "Enter Reason",
                                                        hintStyle:
                                                            montserratRegular
                                                                .copyWith(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        12),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color:
                                                                      greyColor,
                                                                  width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color:
                                                                      greyColor,
                                                                  width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        )),
                                                    focusNode: cancelFocus,
                                                    onChanged: (value) {
                                                      cancel = value;
                                                    },
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                              ]),
                                          SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    Container(
                                                      height: height * 0.045,
                                                      width: width * 0.4,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 16,
                                                                color: syanColor
                                                                    .withOpacity(
                                                                        .6),
                                                                spreadRadius: 0,
                                                                blurStyle:
                                                                    BlurStyle
                                                                        .outer,
                                                                offset: Offset(
                                                                    0, 0)),
                                                          ]),
                                                    ),
                                                    Container(
                                                      height: height * 0.075,
                                                      width: width * 0.4,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        border: Border.all(
                                                            color: syanColor),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    14)),
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            white,
                                                            white
                                                          ],
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "BACK",
                                                        style: montserratSemiBold
                                                            .copyWith(
                                                                color:
                                                                    syanColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  if (cancel == "") {
                                                    showCustomToast(
                                                        context, "Enter Reason",
                                                        bgColor: errorcolor,
                                                        textColor: white);
                                                  } else {
                                                    try {
                                                      final prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      Map req = {
                                                        "bookid": widget.bk_id,
                                                        "reason": cancel,
                                                        "type": "CANCEL",
                                                        "backendstatus": "CANB",
                                                        "customerstatus":
                                                            "CANC",
                                                        "current_bstatus":
                                                            "Booking Created",
                                                        "current_cstatus":
                                                            "Booking Created",
                                                        "user_type": "0",
                                                      };
                                                      print(req);
                                                      await booking_cancel(req)
                                                          .then((value) {
                                                        if (value['ret_data'] ==
                                                            "success") {
                                                          showCustomToast(
                                                              context,
                                                              "Booking Canceled",
                                                              bgColor: black,
                                                              textColor: white);
                                                          Navigator
                                                              .pushReplacementNamed(
                                                                  context,
                                                                  Routes
                                                                      .bottombar);
                                                        } else {
                                                          print("value");
                                                          print(value);
                                                        }
                                                      });
                                                    } catch (e) {
                                                      print("e");
                                                      print(e.toString());
                                                    }
                                                  }
                                                },
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    Container(
                                                      height: height * 0.075,
                                                      width: width * 0.4,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 16,
                                                                color: syanColor
                                                                    .withOpacity(
                                                                        .6),
                                                                spreadRadius: 0,
                                                                blurStyle:
                                                                    BlurStyle
                                                                        .outer,
                                                                offset: Offset(
                                                                    0, 0)),
                                                          ]),
                                                    ),
                                                    Container(
                                                      height: height * 0.075,
                                                      width: width * 0.4,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    14)),
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            syanColor,
                                                            lightblueColor,
                                                          ],
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "SUBMIT",
                                                        style: montserratSemiBold
                                                            .copyWith(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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

  holdbookingbottomsheet() async {
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
                          duration: Duration(milliseconds: 1000),
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
                                          color: white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 8),
                                          Column(
                                            children: <Widget>[
                                              SizedBox(
                                                width: double.infinity,
                                                child: Container(
                                                  child: Text(
                                                    "Hold Reason" + "*",
                                                    textAlign: TextAlign.center,
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Stack(
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
                                                                    .5),
                                                            spreadRadius: 0,
                                                            blurStyle:
                                                                BlurStyle.outer,
                                                            offset:
                                                                Offset(0, 0)),
                                                      ]),
                                                ),
                                                Container(
                                                  width: height * 0.5,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      color: white),
                                                  child: TextField(
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    minLines: 1,
                                                    maxLines: 5,
                                                    maxLength: 500,
                                                    textInputAction:
                                                        TextInputAction.newline,
                                                    decoration: InputDecoration(
                                                        counterText: "",
                                                        hintText:
                                                            "Enter Reason",
                                                        hintStyle:
                                                            montserratRegular
                                                                .copyWith(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        12),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color:
                                                                      greyColor,
                                                                  width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color:
                                                                      greyColor,
                                                                  width: 0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        )),
                                                    focusNode: holdFocus,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        hold = value;
                                                      });
                                                    },
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                              ]),
                                          SizedBox(height: 20),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    setState(() {});
                                                  },
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    children: [
                                                      Container(
                                                        height: height * 0.045,
                                                        width: width * 0.4,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      16,
                                                                  color: syanColor
                                                                      .withOpacity(
                                                                          .6),
                                                                  spreadRadius:
                                                                      0,
                                                                  blurStyle:
                                                                      BlurStyle
                                                                          .outer,
                                                                  offset:
                                                                      Offset(0,
                                                                          0)),
                                                            ]),
                                                      ),
                                                      Container(
                                                        height: height * 0.075,
                                                        width: width * 0.4,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          border: Border.all(
                                                              color: syanColor),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          14)),
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              white,
                                                              white
                                                            ],
                                                          ),
                                                        ),
                                                        child: Text(
                                                          "BACK",
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  color:
                                                                      syanColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (hold == "") {
                                                      setState(() =>
                                                          issubmitted = false);
                                                      showCustomToast(context,
                                                          "Enter Reason",
                                                          bgColor: errorcolor,
                                                          textColor: white);
                                                    } else {
                                                      try {
                                                        setState(() =>
                                                            issubmitted = true);
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        Map req = {
                                                          "bookid":
                                                              widget.bk_id,
                                                          "reason": hold,
                                                          "type": "HOLD",
                                                          "user_type": "0",
                                                          "backendstatus":
                                                              "HOLDB",
                                                          "customerstatus":
                                                              "HOLDC",
                                                          "current_bstatus":
                                                              backstatus[
                                                                  'st_code'],
                                                          "current_cstatus":
                                                              status['st_code']
                                                        };
                                                        await booking_cancel(
                                                                req)
                                                            .then((value) {
                                                          if (value[
                                                                  'ret_data'] ==
                                                              "success") {
                                                            showCustomToast(
                                                                context,
                                                                "Booking is under hold",
                                                                bgColor: black,
                                                                textColor:
                                                                    white);
                                                            setBottomState(() {
                                                              Navigator
                                                                  .pushReplacementNamed(
                                                                      context,
                                                                      Routes
                                                                          .bottombar);
                                                            });
                                                          } else {
                                                            setBottomState(() =>
                                                                issubmitted =
                                                                    false);
                                                          }
                                                        });
                                                      } catch (e) {
                                                        setBottomState(() =>
                                                            issubmitted =
                                                                false);
                                                        print(e.toString());
                                                      }
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    children: [
                                                      Container(
                                                        height: height * 0.045,
                                                        width: width * 0.4,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  blurRadius:
                                                                      16,
                                                                  color: syanColor
                                                                      .withOpacity(
                                                                          .6),
                                                                  spreadRadius:
                                                                      0,
                                                                  blurStyle:
                                                                      BlurStyle
                                                                          .outer,
                                                                  offset:
                                                                      Offset(0,
                                                                          0)),
                                                            ]),
                                                      ),
                                                      Container(
                                                        height: height * 0.075,
                                                        width: width * 0.4,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          14)),
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              syanColor,
                                                              lightblueColor,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Text(
                                                          "SUBMIT",
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
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

  unholdbookingbottomsheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Unhold Booking.?',
            style: montserratSemiBold.copyWith(color: black, fontSize: 21)),
        action: SnackBarAction(
            label: 'Unhold',
            textColor: Colors.white,
            onPressed: () async {
              try {
                setState(() => issubmitted = true);
                final prefs = await SharedPreferences.getInstance();
                Map req = {
                  "bookid": widget.bk_id,
                  "backendstatus": pastbackendstatus,
                  "customerstatus": pastcustomerstatus,
                  "unhold": true,
                  "user_type": "0",
                };
                await booking_unhold(req).then((value) {
                  if (value['ret_data'] == "success") {
                    showCustomToast(context, "Booking hold removed",
                        bgColor: warningcolor, textColor: white);
                    setState(() {
                      Navigator.pushReplacementNamed(context, Routes.bottombar);
                    });
                  } else {
                    setState(() => issubmitted = false);
                  }
                });
              } catch (e) {
                setState(() => issubmitted = false);
                print(e.toString());
              }
            }),
      ),
    );
  }

  getBookingDetailsID() async {
    final now = new DateTime.now();
    CurrentDate = DateFormat('dd-MM-yyyy').format(now);
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_id))};
    print(req);
    setState(() {
      statusflow = [];
    });
    await getbookingdetails(req).then((value) async {
      if (value['ret_data'] == "success") {
        print(value);
        setState(() {
          booking = value['booking'];
          booking_package = value['booking']['booking_package'];
          pickup_timeslot = value['booking']['pickup_timeslot'];
          drivercontact = value['booking']['driver_contact'];
          // dropdetails = value['booking']['drop_address'];
          vehicle = value['booking']['vehicle'];
        });
      }
      Map req = {
        "book_id": base64.encode(utf8.encode(widget.bk_id)),
        "backend_status": value['booking']['back_status']['st_id'],
        "customer_status": value['booking']['cust_status']['st_id'],
      };
      setState(() {
        statusflow = [];
      });
      await getbookingjobs_forcustomer(req).then((value) {
        if (value['ret_data'] == "success") {
          status = value['booking']['cust_status'];
          backstatus = value['booking']['back_status'];
          for (var joblist in value['booking']['jobs']) {
            temppendingjobs = [];
            if (joblist['bkj_status'] == "1" &&
                joblist['bkj_payment_status'] == "0") {
              setState(() {
                var paymentpendingjobid = {"jobid": joblist['bkj_id']};
                temppendingjobs.add(paymentpendingjobid);
              });
            }
            ;
          }
          ;

          var cust_status_master = [
            'BKCC',
            'DRPC',
            'PIPC',
            'PIWC',
            'VAWC',
            'WIPC',
            'CDLC',
            'RFDC',
            'DEDC',
            'DLCC',
            'HOLDC'
          ];
          var position = cust_status_master
              .indexOf(value['booking']['cust_status']['st_code']);
          for (var statuslist in value['booking']['status_flow']) {
            if (statuslist["bkt_code"] == "BKCC") {
              var temp = {
                "status": "Booking Created",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/booking_created_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "DRPC") {
              var temp = {
                "status": "Driver enroute\nto location",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/driver_enrouted_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "PIPC") {
              var temp = {
                "status": "Pickup in progress",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/pickup_progress_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "PIWC") {
              var temp = {
                "status": "Pickedup & enroute\nto workshop",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/pickedup_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "VAWC") {
              var temp = {
                "status": "Vehicle at workshop",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/vehicle_workshop_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "WIPC") {
              var temp = {
                "status": "Work in progress",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/work_in_progress_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "CDLC") {
              var temp = {
                "status": "Confirm\ndrop location",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/location_icon.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "RFDC") {
              var temp = {
                "status": "Ready for delivery",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/ready_delivery_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "DEDC") {
              var temp = {
                "status": "Vehicle enrouted to\nyour location",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/enrouted_drop_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "DLCC") {
              var temp = {
                "status": "Delivery completed",
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/delivery_complete_active.png',
                "color": activecolor,
                "active_flag": true,
                "hold_flag": false
              };
              if ((statusflow.singleWhere(
                      (it) => it["code"] == statuslist["bkt_code"],
                      orElse: () => null)) ==
                  null) {
                statusflow.add(temp);
              }
            } else if (statuslist["bkt_code"] == "HOLDC") {
              reasonhold = statuslist['bkt_content'];
              splittedreason = reasonhold.split(':');
              var temp = {
                "status": "Reason: " + splittedreason[1].trim(),
                "time": DateFormat('dd-MM-yyyy').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!) +
                    " / " +
                    DateFormat('hh:mm a').format(
                        DateTime.tryParse(statuslist["bkt_created_on"])!),
                "code": statuslist["bkt_code"],
                "icon": 'assets/icons/hold.png',
                "color": Colors.transparent,
                "active_flag": true,
                "hold_flag": true
              };
              statusflow.add(temp);
            }
            if (statuslist['bkt_task'] == "Hold") {
              holdbooking = statuslist['bkt_task'];
              holdedby = statuslist['bkt_usertype_flag'];
              previousstatus = statuslist['bkt_url'];
              splittedstatus = previousstatus.split(',');
              reasonhold = statuslist['bkt_content'];
              splittedreason = reasonhold.split(':');
              pastcustomerstatus = splittedstatus[1].trim();
              pastbackendstatus = splittedstatus[0].trim();
              reasonforhold = splittedreason[1].trim();
              setState(() {});
            }
          }
          ;
          for (int i = (position + 1); i < cust_status_master.length; i++) {
            if (cust_status_master[i] == "DRPC") {
              var temp = {
                "status": "Driver Enroute\nto Location",
                "time": "",
                "code": "",
                "icon": 'assets/icons/driver_enrouted_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "PIPC") {
              var temp = {
                "status": "Pickup In Progress",
                "time": "",
                "code": "",
                "icon": 'assets/icons/pickup_progress_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "PIWC") {
              var temp = {
                "status": "Pickedup & enroute\nto workshop",
                "time": "",
                "code": "",
                "icon": 'assets/icons/pickedup_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "VAWC") {
              var temp = {
                "status": "Vehicle @ Workshop",
                "time": "",
                "code": "",
                "icon": 'assets/icons/vehicle_workshop_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "WIPC") {
              var temp = {
                "status": "Work In Progress",
                "time": "",
                "code": "",
                "icon": 'assets/icons/work_in_progress_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "CDLC") {
              var temp = {
                "status": "Confirm\nDrop Location",
                "time": "",
                "code": "",
                "icon": 'assets/icons/location_icon_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "RFDC") {
              var temp = {
                "status": "Ready for Delivery",
                "time": "",
                "code": "",
                "icon": 'assets/icons/ready_delivery_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "DEDC") {
              var temp = {
                "status": "Driver Enroute\nfor Delivery",
                "time": "",
                "code": "",
                "icon": 'assets/icons/enrouted_drop_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
            }
            if (cust_status_master[i] == "DLCC") {
              var temp = {
                "status": "Delivery Completed",
                "time": "",
                "code": "",
                "icon": 'assets/icons/delivery_complete_inactive.png',
                "color": Colors.transparent,
                "active_flag": false,
                "hold_flag": false
              };
              statusflow.add(temp);
              setState(() {});
            }
          }
        }
      });
    });
  }

  Widget statusView(
      String? title, String? icon, String? time, bool isActive, bool ishold) {
    return Row(
      children: [
        if (isActive && !ishold) ...[
          Container(
            height: height * 0.05,
            width: height * 0.05,
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
            child: Image.asset(icon.validate(),
                width: width * 0.12, fit: BoxFit.cover),
          )
        ] else if (!isActive) ...[
          Container(
            height: height * 0.05,
            width: height * 0.05,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade200,
                ],
              ),
            ),
            child: Image.asset(icon.validate(),
                width: width * 0.12, fit: BoxFit.cover),
          ),
        ] else if (ishold && isActive) ...[
          Container(
            height: height * 0.05,
            width: height * 0.05,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
                colors: [
                  lightorangeColor,
                  holdorangeColor,
                ],
              ),
            ),
            child: Image.asset(icon.validate(),
                width: width * 0.12, fit: BoxFit.cover),
          )
        ],
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title!,
                overflow: TextOverflow.clip,
                style: montserratSemiBold.copyWith(
                    color:
                        isActive ? Colors.black : Colors.grey.withOpacity(0.5),
                    fontSize: 14)),
            Text(time!,
                overflow: TextOverflow.clip,
                style: montserratRegular.copyWith(
                    color:
                        isActive ? Colors.black : Colors.grey.withOpacity(0.5),
                    fontSize: 12)),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
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
              height: height * 0.42,
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
                  height: height * 0.81,
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
              "Booking Details",
              style: myriadproregular.copyWith(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 18,
            ),
          ),
          body: RefreshIndicator(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
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
                            Padding(padding: EdgeInsets.all(4)),
                            if (widget.make == 'Mercedes Benz') ...[
                              Image.asset(
                                ImageConst.benz_ico,
                                width: width * 0.12,
                              ),
                            ] else if (widget.make == 'BMW') ...[
                              Image.asset(
                                ImageConst.bmw_ico,
                                width: width * 0.12,
                              ),
                            ] else if (widget.make == 'Skoda') ...[
                              Image.asset(
                                ImageConst.skod_ico,
                                width: width * 0.12,
                              ),
                            ] else if (widget.make == 'Audi') ...[
                              Image.asset(
                                ImageConst.aud_ico,
                                width: width * 0.12,
                              ),
                            ] else ...[
                              Image.asset(
                                ImageConst.defcar_ico,
                                width: width * 0.12,
                              ),
                            ],
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          child: Text(
                                              booking_package['pkg_name'] !=
                                                      null
                                                  ? booking_package[
                                                          'pkg_name'] +
                                                      " (" +
                                                      booking['bk_number'] +
                                                      ")"
                                                  : "",
                                              overflow: TextOverflow.clip,
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: black,
                                                      fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 4,
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
                                                    overflow: TextOverflow.clip,
                                                    style: montserratRegular
                                                        .copyWith(
                                                            color: black,
                                                            fontSize: 12)),
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
                                                    overflow: TextOverflow.clip,
                                                    style: montserratRegular
                                                        .copyWith(
                                                            color: black,
                                                            fontSize: 12)),
                                              ),
                                            ),
                                          ],
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
                                  status['st_code'] == "HOLDC"
                                      ? Row(
                                          children: <Widget>[
                                            status['st_code'] == "BKCC" ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        pastcustomerstatus ==
                                                            "BKCC"
                                                ? Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                          color: greyColor,
                                                          style: BorderStyle
                                                              .solid, //Style of the border
                                                          width:
                                                              0.8, //width of the border
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          side: BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        cancelbookingbottomsheet();
                                                      },
                                                      child: Text('Cancel',
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.021)),
                                                    ),
                                                  )
                                                : Row(),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            status['st_code'] == "BKCC" ||
                                                    status['st_code'] ==
                                                        "CDLC" ||
                                                    status['st_code'] ==
                                                        "RFDC" ||
                                                    status['st_code'] ==
                                                        "DEDC" ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "BKCC") &&
                                                        (holdedby == "0") ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "CDLC") &&
                                                        (holdedby == "0") ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "RFDC") &&
                                                        (holdedby == "0") ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "DEDC") &&
                                                        (holdedby == "0")
                                                ? Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                          color: greyColor,
                                                          style: BorderStyle
                                                              .solid, //Style of the border
                                                          width:
                                                              0.8, //width of the border
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          side: BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        unholdbookingbottomsheet();
                                                      },
                                                      child: Text('Unhold',
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.021)),
                                                    ),
                                                  )
                                                : Row(),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            status['st_code'] == "BKCC" ||
                                                    status['st_code'] ==
                                                        "CDLC" ||
                                                    status['st_code'] ==
                                                        "RFDC" ||
                                                    status['st_code'] ==
                                                        "DEDC" ||
                                                    status['st_code'] == "HOLDC"
                                                ? Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                          color: greyColor,
                                                          style: BorderStyle
                                                              .solid, //Style of the border
                                                          width:
                                                              0.8, //width of the border
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          side: BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        status['st_code'] ==
                                                                    "BKCC" ||
                                                                (status['st_code'] ==
                                                                        "HOLDC" &&
                                                                    pastcustomerstatus ==
                                                                        "BKCC")
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ReschedulefromBooking(
                                                                        scheduletype:
                                                                            3,
                                                                        bk_id: widget
                                                                            .bk_id)))
                                                            : Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ReschedulefromBooking(
                                                                        scheduletype:
                                                                            4,
                                                                        bk_id: widget
                                                                            .bk_id)));
                                                      },
                                                      child: Text('Reschedule',
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.021)),
                                                    ),
                                                  )
                                                : Row(),
                                          ],
                                        )
                                      : Row(
                                          children: <Widget>[
                                            status['st_code'] == "BKCC" ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        pastcustomerstatus ==
                                                            "BKCC"
                                                ? Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                          color: greyColor,
                                                          style: BorderStyle
                                                              .solid, //Style of the border
                                                          width:
                                                              0.8, //width of the border
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          side: BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        cancelbookingbottomsheet();
                                                      },
                                                      child: Text('Cancel',
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.021)),
                                                    ),
                                                  )
                                                : Row(),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            status['st_code'] == "BKCC" ||
                                                    status['st_code'] ==
                                                        "CDLC" ||
                                                    status['st_code'] ==
                                                        "RFDC" ||
                                                    status['st_code'] ==
                                                        "DEDC" ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "BKCC") &&
                                                        (holdedby == "0") ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "CDLC") &&
                                                        (holdedby == "0") ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "RFDC") &&
                                                        (holdedby == "0") ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        (pastcustomerstatus ==
                                                            "DEDC") &&
                                                        (holdedby == "0")
                                                ? Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                          color: greyColor,
                                                          style: BorderStyle
                                                              .solid, //Style of the border
                                                          width:
                                                              0.8, //width of the border
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          side: BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        holdbookingbottomsheet();
                                                      },
                                                      child: Text('Hold',
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.021)),
                                                    ),
                                                  )
                                                : Row(),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            status['st_code'] == "BKCC" ||
                                                    status['st_code'] ==
                                                        "CDLC" ||
                                                    status['st_code'] ==
                                                        "RFDC" ||
                                                    status['st_code'] ==
                                                        "DEDC" ||
                                                    status['st_code'] ==
                                                            "HOLDC" &&
                                                        pastcustomerstatus ==
                                                            "BKCC"
                                                ? Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        side: BorderSide(
                                                          color: greyColor,
                                                          style: BorderStyle
                                                              .solid, //Style of the border
                                                          width:
                                                              0.8, //width of the border
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          side: BorderSide(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        status['st_code'] ==
                                                                    "BKCC" ||
                                                                (status['st_code'] ==
                                                                        "HOLDC" &&
                                                                    pastcustomerstatus ==
                                                                        "BKCC")
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ReschedulefromBooking(
                                                                        scheduletype:
                                                                            3,
                                                                        bk_id: widget
                                                                            .bk_id)))
                                                            : Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ReschedulefromBooking(
                                                                        scheduletype:
                                                                            4,
                                                                        bk_id: widget
                                                                            .bk_id)));
                                                      },
                                                      child: Text('Reschedule',
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color: black,
                                                                  fontSize:
                                                                      width *
                                                                          0.021)),
                                                    ),
                                                  )
                                                : Row(),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: Text('Order Status',
                                style: montserratSemiBold.copyWith(
                                    color: black, fontSize: 17)),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.all(17.5),
                          padding: EdgeInsets.all(8.5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 12,
                                    color: syanColor.withOpacity(.9),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.outer,
                                    offset: Offset(0, 0)),
                              ]),
                        ),
                        Container(
                            margin: EdgeInsets.all(16.0),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  booking['cv_registrationvalidity'] != null &&
                                          booking['cv_registrationvalidity']
                                                  .compareTo(CurrentDate) <
                                              0
                                      ? Divider()
                                      : Row(),
                                  booking['cv_registrationvalidity'] != null &&
                                          booking['cv_registrationvalidity']
                                                  .compareTo(CurrentDate) <
                                              0
                                      ? Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.all(16),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Text(
                                                    "Registration card validity expired at " +
                                                        booking[
                                                            'cv_registrationvalidity'] +
                                                        ".",
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.red,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(),
                                  statusflow.length > 0
                                      ? ListView.builder(
                                          itemCount: statusflow.length,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 5,
                                                        child: statusView(
                                                            statusflow[index]
                                                                ["status"],
                                                            statusflow[index]
                                                                ["icon"],
                                                            statusflow[index]
                                                                ["time"],
                                                            statusflow[index]
                                                                ["active_flag"],
                                                            statusflow[index]
                                                                ["hold_flag"]),
                                                      ),
                                                      statusflow[index]
                                                                  ['code'] ==
                                                              "DRPC"
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    // bool? res = await FlutterPhoneDirectCaller.callNumber(drivercontact[
                                                                    //         'us_country_code'] +
                                                                    //     drivercontact[
                                                                    //         'us_phone']);
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    side:
                                                                        BorderSide(
                                                                      color:
                                                                          syanColor, //Color of the border
                                                                      style: BorderStyle
                                                                          .solid, //Style of the border
                                                                      width:
                                                                          0.8, //width of the border
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      side:
                                                                          BorderSide(
                                                                        color:
                                                                            syanColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      Align(
                                                                          alignment: Alignment
                                                                              .centerRight,
                                                                          child:
                                                                              Icon(
                                                                            Icons.phone,
                                                                            color:
                                                                                syanColor,
                                                                            size:
                                                                                16,
                                                                          )),
                                                                      Text(
                                                                        "Call",
                                                                        style: montserratRegular.copyWith(
                                                                            color:
                                                                                syanColor,
                                                                            fontSize:
                                                                                width * 0.026),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                          : const SizedBox(
                                                              height: 0,
                                                            ),
                                                      statusflow[index]
                                                                  ['code'] ==
                                                              "PIWC"
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => InspectionScreen(
                                                                                bookid: widget.bk_id,
                                                                                booknum: booking['bk_number'],
                                                                                bookdate: booking['bk_booking_date'],
                                                                                booktime: timeFormatter(pickup_timeslot['tm_start_time']) + " - " + timeFormatter(pickup_timeslot['tm_end_time']),
                                                                                pkgname: booking_package['pkg_name'],
                                                                                vehname: widget.vehname,
                                                                                vehmake: vehicle['cv_make'])));
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    side:
                                                                        BorderSide(
                                                                      color:
                                                                          syanColor, //Color of the border
                                                                      style: BorderStyle
                                                                          .solid, //Style of the border
                                                                      width:
                                                                          0.8, //width of the border
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      side:
                                                                          BorderSide(
                                                                        color:
                                                                            syanColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        'Inspection\nReport',
                                                                        style: montserratRegular.copyWith(
                                                                            color:
                                                                                syanColor,
                                                                            fontSize:
                                                                                width * 0.026),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                          : const SizedBox(
                                                              height: 0,
                                                            ),
                                                      statusflow[index]
                                                                  ['code'] ==
                                                              "WIPC"
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => Workcard(
                                                                                click_id: 1,
                                                                                booking_id: widget.bk_id,
                                                                                vehname: widget.vehname,
                                                                                vehmake: vehicle['cv_make'])));
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    side:
                                                                        BorderSide(
                                                                      color:
                                                                          syanColor, //Color of the border
                                                                      style: BorderStyle
                                                                          .solid, //Style of the border
                                                                      width:
                                                                          0.8, //width of the border
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      side:
                                                                          BorderSide(
                                                                        color:
                                                                            syanColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        'Work Card',
                                                                        style: montserratRegular.copyWith(
                                                                            color:
                                                                                syanColor,
                                                                            fontSize:
                                                                                width * 0.026),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                          : const SizedBox(
                                                              height: 0,
                                                            ),
                                                      statusflow[index]
                                                                  ['code'] ==
                                                              "CDLC"
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    temppendingjobs.length ==
                                                                            0
                                                                        ? Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => ScheduleDropScreen(bk_id: widget.bk_id)))
                                                                        : Navigator.push(context, MaterialPageRoute(builder: (context) => Workcard(click_id: 2, booking_id: widget.bk_id, vehname: widget.vehname, vehmake: vehicle['cv_make'])));
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    side:
                                                                        BorderSide(
                                                                      color:
                                                                          syanColor, //Color of the border
                                                                      style: BorderStyle
                                                                          .solid, //Style of the border
                                                                      width:
                                                                          0.8, //width of the border
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      side:
                                                                          BorderSide(
                                                                        color:
                                                                            syanColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      temppendingjobs.length ==
                                                                              0
                                                                          ? Text(
                                                                              'Schedule\nDelivery',
                                                                              style: montserratRegular.copyWith(color: syanColor, fontSize: 12))
                                                                          : Text('Pending Payment', style: montserratRegular.copyWith(color: syanColor, fontSize: 12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ))
                                                          : const SizedBox(
                                                              height: 0,
                                                            ),
                                                      statusflow[index]
                                                                  ['code'] ==
                                                              "DEDC"
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                  child:
                                                                      OutlinedButton(
                                                                style: OutlinedButton
                                                                    .styleFrom(
                                                                  side:
                                                                      BorderSide(
                                                                    color:
                                                                        syanColor,
                                                                    style: BorderStyle
                                                                        .solid, //Style of the border
                                                                    width:
                                                                        0.8, //width of the border
                                                                  ),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30),
                                                                    side:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  bool? res = await FlutterPhoneDirectCaller.callNumber(drivercontact[
                                                                          'us_country_code'] +
                                                                      drivercontact[
                                                                          'us_phone']);
                                                                },
                                                                child: Stack(
                                                                  children: <
                                                                      Widget>[
                                                                    Align(
                                                                        alignment:
                                                                            Alignment
                                                                                .centerRight,
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .phone,
                                                                          color:
                                                                              syanColor,
                                                                          size:
                                                                              16,
                                                                        )),
                                                                    Text(
                                                                      "Call",
                                                                      style: montserratRegular.copyWith(
                                                                          color:
                                                                              syanColor,
                                                                          fontSize:
                                                                              12),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    )
                                                                  ],
                                                                ),
                                                              )))
                                                          : const SizedBox(
                                                              height: 0,
                                                            ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 30,
                                                    width: 2,
                                                    color: statusflow[index]
                                                        ["color"],
                                                    margin: EdgeInsets.only(
                                                      left: 25,
                                                    ),
                                                  ),
                                                ]);
                                          })
                                      : SizedBox(),
                                ])),
                      ],
                    ),
                  ],
                ),
              ),
              onRefresh: refresh),
        ));
  }
}

Widget commonCacheImageWidget(String? url, double height,
    {double? width, BoxFit? fit}) {
  if (url.validate().startsWith('http')) {
    if (isMobile) {
      return CachedNetworkImage(
        placeholder:
            placeholderWidgetFn() as Widget Function(BuildContext, String)?,
        imageUrl: '$url',
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorWidget: (_, __, ___) {
          return SizedBox(height: height, width: width);
        },
      );
    } else {
      return Image.network(url!,
          height: height, width: width, fit: fit ?? BoxFit.cover);
    }
  } else {
    return Image.asset(url!,
        height: height, width: width, fit: fit ?? BoxFit.cover);
  }
}

Widget? Function(BuildContext, String) placeholderWidgetFn() =>
    (_, s) => placeholderWidget();

Widget placeholderWidget() =>
    Image.asset('images/app/placeholder.jpg', fit: BoxFit.cover);

BoxConstraints dynamicBoxConstraints({double? maxWidth}) {
  return BoxConstraints(maxWidth: maxWidth ?? width);
}

double dynamicWidth(BuildContext context) {
  return isMobile ? context.width() : width;
}

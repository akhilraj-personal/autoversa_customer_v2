import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/AppWidgets.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class ReschedulefromBooking extends StatefulWidget {
  final String bk_id;
  final int scheduletype;
  const ReschedulefromBooking(
      {required this.bk_id, required this.scheduletype, super.key});

  @override
  State<ReschedulefromBooking> createState() => ReschedulefromBookingState();
}

class ReschedulefromBookingState extends State<ReschedulefromBooking> {
  late Map<String, dynamic> bookingdetails = {};
  late Map<String, dynamic> dropdetails = {};
  DateTime selectedDate = DateTime.now();
  var selected_timeslot = "";
  late List timeslots = [];
  var max_days = 0;
  bool isExpanded = false;
  var isTimeCheck;
  var selected_timeid = 0;
  bool isproceeding = false;
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
    getBookingDetailsID();
    _fetchdatas();
    init();
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_id))};
    print(req);
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          bookingdetails = value['booking'];
          dropdetails = value['booking']['drop_address'];
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

  Future<void> _selectDate(BuildContext context) async {
    var last_date = DateTime.now().add(Duration(days: 5));
    final DateTime? picked = await showDatePicker(
        helpText: "Select Booking Date",
        cancelText: 'Not Now',
        confirmText: "Confirm",
        fieldLabelText: 'Booking Date',
        fieldHintText: 'Month/Date/Year',
        errorFormatText: 'Enter valid date',
        errorInvalidText: 'Enter date in valid range',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        builder: (BuildContext context, Widget? child) {
          return CustomTheme(
            child: child,
          );
        },
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(new Duration(days: max_days)));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selected_timeslot = "";
        selected_timeid = 0;
        isTimeCheck = "";
        getTimeSlots(picked);
      });
    }
    setState(() {
      selected_timeslot = "";
      selected_timeid = 0;
      isTimeCheck = "";
    });
  }

  getTimeSlots(pickdate) async {
    selected_timeslot = "";
    selected_timeid = 0;
    isTimeCheck = "";
    setState(() {});
    Map req = {
      "day": DateFormat('EEEE').format(pickdate),
      "date": DateFormat('dd-MM-yyyy').format(pickdate).toString(),
      "branch_id": 1
    };
    try {
      await getTimeSlotsForBooking(req).then((value) {
        timeslots = [];
        if (value['ret_data'] == "success") {
          for (var bslots in value['time_slots']) {
            var count = value['assigned_emp']
                .where((c) => c['tem_slotid'] == bslots['tm_id'])
                .toList()
                .length;

            if (count == value['driver_count']) {
              var slotemp = {
                "tm_id": bslots['tm_id'],
                "tm_start_time": bslots['tm_start_time'],
                "tm_end_time": bslots['tm_end_time'],
                "active_flag": 1
              };
              timeslots.add(slotemp);
            } else {
              var slotemp = {
                "tm_id": bslots['tm_id'],
                "tm_start_time": bslots['tm_start_time'],
                "tm_end_time": bslots['tm_end_time'],
                "active_flag": 0
              };
              timeslots.add(slotemp);
            }
          }
        }
      });
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  _fetchdatas() async {
    await getPickupOptions().then((value) {
      max_days = int.parse(value['settings']['gs_nofdays']);
    });
  }

  RescheduleClick() async {
    late Map<String, dynamic> packdata = {};
    if (selected_timeid == 0) {
      setState(() => isproceeding = false);
      showCustomToast(context, "Choose a time slot",
          bgColor: Colors.black, textColor: white);
    } else {
      Map req = {
        "bookid": widget.bk_id,
        "bookingdate": selectedDate.toString(),
        "slot": selected_timeslot,
        "scheduletype": "3"
      };
      await booking_reschedule(req).then((value) {
        if (value['ret_data'] == "success") {
          setState(() {
            showCustomToast(context, "Booking Reschedule Successfully",
                bgColor: Colors.black, textColor: white);
            Navigator.pushReplacementNamed(context, Routes.bottombar);
          });
        } else {
          setState(() => isproceeding = false);
        }
      });
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
            "Reschedule Booking",
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
          child: Container(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      width: width * 1.85,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: defaultBoxShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8),
                          ),
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
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Selected Location",
                                  textAlign: TextAlign.start,
                                  style: montserratRegular.copyWith(
                                    fontSize: width * 0.032,
                                    color: black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dropdetails['cad_address'] != null
                                      ? dropdetails['cad_landmark'] != null
                                          ? ": " +
                                              dropdetails['cad_address'] +
                                              " " +
                                              dropdetails['city_name'] +
                                              " " +
                                              dropdetails['state_name'] +
                                              " " +
                                              dropdetails['cad_landmark']
                                          : ": " +
                                              dropdetails['cad_address'] +
                                              " " +
                                              dropdetails['city_name'] +
                                              " " +
                                              dropdetails['state_name']
                                      : "",
                                  textAlign: TextAlign.start,
                                  style: montserratRegular.copyWith(
                                    fontSize: width * 0.032,
                                    color: black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 4, 0, 0),
                              ),
                              Text(
                                "Select Date & Time",
                                textAlign: TextAlign.start,
                                style: montserratRegular.copyWith(
                                  fontSize: width * 0.032,
                                  color: black,
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Card(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10)),
                                  side: BorderSide(
                                      width: 1, color: Colors.black)),
                              elevation: 4,
                              child: ListTile(
                                trailing: RadiantGradientMask(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.date_range,
                                      color: white,
                                    ),
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                  ),
                                ),
                                onTap: () {
                                  _selectDate(context);
                                },
                                title: Text(
                                  'Select Reschedule date',
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034, color: black),
                                ),
                                subtitle: Text(
                                  DateFormat('dd-MM-yyyy').format(selectedDate),
                                  style: montserratRegular.copyWith(
                                      fontSize: width * 0.032, color: black),
                                ),
                              )),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Container(
                            margin: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: radius(10),
                              color: context.cardColor,
                              border: Border.all(
                                color: black,
                              ),
                            ),
                            child: ExpansionTile(
                              childrenPadding: EdgeInsets.all(8),
                              leading: Container(
                                width: 25,
                                height: 25,
                                child: RadiantGradientMask(
                                  child: Icon(Icons.av_timer_outlined,
                                      color: white, size: 28),
                                ),
                              ),
                              title: Text(ST.of(context).select_a_time_slot,
                                  overflow: TextOverflow.ellipsis,
                                  style: montserratLight.copyWith(
                                      color: black, fontSize: width * 0.034),
                                  maxLines: 3),
                              subtitle: Text(
                                  selected_timeslot == ""
                                      ? ST.of(context).select_a_time_slot + "*"
                                      : selected_timeslot,
                                  style: montserratLight.copyWith(
                                      color: black, fontSize: width * 0.034)),
                              textColor: black,
                              trailing: isExpanded
                                  ? Container(
                                      child: Icon(Icons.keyboard_arrow_up,
                                          color: syanColor, size: 30),
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          borderRadius: radius(100),
                                          color: context.accentColor
                                              .withAlpha(32)),
                                    )
                                  : Icon(Icons.keyboard_arrow_down,
                                      color: syanColor, size: 30),
                              onExpansionChanged: (t1) {
                                isExpanded = !isExpanded;
                                setState(() {});
                              },
                              children: [
                                Container(
                                  decoration: boxDecorationDefault(
                                      color: context.cardColor,
                                      boxShadow: null),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      timeslots.length > 0
                                          ? ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.only(
                                                  top: 16, bottom: 16),
                                              itemCount: timeslots.length,
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  children: <Widget>[
                                                    Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                              unselectedWidgetColor:
                                                                  syanColor),
                                                      child: Radio(
                                                        value: timeslots[index][
                                                                'tm_start_time'] +
                                                            " - " +
                                                            timeslots[index]
                                                                ['tm_end_time'],
                                                        groupValue: isTimeCheck,
                                                        onChanged:
                                                            (dynamic value) {
                                                          timeslots[index][
                                                                      'active_flag'] ==
                                                                  1
                                                              ? value = 0
                                                              : setState(() {
                                                                  isTimeCheck =
                                                                      value;
                                                                  selected_timeid =
                                                                      int.parse(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_id']);
                                                                  selected_timeslot = timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_start_time']) +
                                                                      " - " +
                                                                      timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_end_time']);
                                                                });
                                                        },
                                                      ),
                                                    ),
                                                    timeslots[index][
                                                                'active_flag'] ==
                                                            1
                                                        ? Text(
                                                            timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_start_time']) +
                                                                " - " +
                                                                timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_end_time']) +
                                                                "\n" +
                                                                ST
                                                                    .of(context)
                                                                    .slot_is_full,
                                                            style:
                                                                montserratLight
                                                                    .copyWith(
                                                              fontSize:
                                                                  width * 0.034,
                                                              color: black,
                                                            ),
                                                          )
                                                        : Text(
                                                            timeFormatter(timeslots[
                                                                        index][
                                                                    'tm_start_time']) +
                                                                " - " +
                                                                timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_end_time']),
                                                            style:
                                                                montserratLight
                                                                    .copyWith(
                                                              fontSize:
                                                                  width * 0.034,
                                                              color: black,
                                                            ),
                                                          ),
                                                  ],
                                                );
                                              })
                                          : Text(
                                              ST
                                                  .of(context)
                                                  .no_time_slot_available,
                                              style: montserratLight.copyWith(
                                                fontSize: width * 0.034,
                                                color: black,
                                              ),
                                            ),
                                      8.height,
                                    ],
                                  ).paddingAll(8),
                                )
                              ],
                            ),
                          ),
                          12.height,
                          GestureDetector(
                            onTap: () async {
                              if (isproceeding) return;
                              setState(() => isproceeding = true);
                              await Future.delayed(
                                  Duration(milliseconds: 1000));
                              RescheduleClick();
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(16),
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
                                  width: height * 0.45,
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
                                          "RESCHEDULE",
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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

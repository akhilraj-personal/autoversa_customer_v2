import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
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
  late Map<String, dynamic> dropdetails = {};
  DateTime selectedDate = DateTime.now();
  var selected_timeslot = "";
  late List timeslots = [];
  var max_days = 0;
  bool isExpanded = false;
  var isTimeCheck;
  var selected_timeid = 0;
  bool isproceeding = false;
  var buffertime = "0";
  var bookeddate;

  @override
  void initState() {
    super.initState();
    getBookingDetailsID();
    _fetchdatas();
    getTimeSlots(new DateTime.now());
    init();
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_id))};
    print(req);
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          bookeddate = value['booking']['bk_booking_date'];
          dropdetails = value['booking']['drop_address'];
        });
      }
    });
  }

  _fetchdatas() async {
    await getPickupOptions().then((value) {
      max_days = int.parse(value['settings']['gs_nofdays']);
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

  int calculateDifference(DateTime selectedDate) {
    DateTime now = DateTime.now();
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  String getCurrentTime() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(now);
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
        buffertime = value['settings']['gs_bookingbuffer_time'];
        timeslots = [];
        if (value['ret_data'] == "success") {
          if (calculateDifference(selectedDate) == 0) {
            final DateTime now = DateTime.now();
            DateTime newTime =
                now.add(Duration(minutes: int.parse(buffertime)));
            DateFormat formatter = DateFormat('HH:mm');
            String formattedTime = formatter.format(newTime);
            for (var bslots in value['time_slots']) {
              String startTime = bslots['tm_start_time'];
              if (startTime.compareTo(formattedTime) >= 0) {
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
          } else if (calculateDifference(selectedDate) > 0) {
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
        }
      });
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  RescheduleClick() async {
    if (selected_timeid == 0) {
      setState(() => isproceeding = false);
      showCustomToast(context, "Choose a time slot",
          bgColor: Colors.black, textColor: white);
    } else {
      Map req = {
        "bookid": widget.bk_id,
        "bookingdate": selectedDate.toString(),
        "slot": selected_timeid,
        "scheduletype": widget.scheduletype,
        "prebookingdate": bookeddate
      };
      print("000===>");
      print(req);
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
                      margin: const EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      width: width * 1.85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Selected Location",
                                      textAlign: TextAlign.start,
                                      style: montserratMedium.copyWith(
                                        fontSize: width * 0.035,
                                        color: black,
                                      ),
                                    ),
                                  )),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dropdetails['cad_city'] != null
                                          ? dropdetails['cad_city']
                                          : "",
                                      maxLines: 1,
                                      style: montserratMedium.copyWith(
                                          color: Colors.black,
                                          fontSize: width * 0.04),
                                    ),
                                    Text(
                                      dropdetails['cad_address'] != null
                                          ? dropdetails['cad_address']
                                          : "",
                                      maxLines: 2,
                                      textAlign: TextAlign.justify,
                                      overflow: TextOverflow.ellipsis,
                                      style: montserratMedium.copyWith(
                                          color: toastgrey,
                                          fontSize: width * 0.03),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 4, 0, 0),
                                child: Text(
                                  "Select Date & Time",
                                  textAlign: TextAlign.start,
                                  style: montserratSemiBold.copyWith(
                                      color: Colors.black,
                                      fontSize: width * 0.034),
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(12),
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
                              Padding(
                                padding: EdgeInsets.all(0),
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                                          lang.S.of(context).select_booking_date +
                                              " ",
                                          style: montserratMedium.copyWith(
                                              color: black,
                                              fontSize: width * 0.04),
                                          maxLines: 3),
                                      subtitle: Text(
                                        selectedDate == " "
                                            ? " "
                                            : DateFormat('dd-MM-yyyy')
                                                .format(selectedDate),
                                        style: montserratSemiBold.copyWith(
                                            color: black,
                                            fontSize: width * 0.04),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                margin: EdgeInsets.all(16.0),
                                padding: EdgeInsets.all(12),
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
                              Padding(
                                padding: EdgeInsets.all(0),
                                child: Container(
                                  margin: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: white,
                                    border: Border.all(
                                      color: black,
                                    ),
                                  ),
                                  child: ExpansionTile(
                                    childrenPadding: EdgeInsets.all(8),
                                    leading: Container(
                                      width: 30,
                                      height: 30,
                                      child: RadiantGradientMask(
                                        child: Icon(Icons.av_timer_outlined,
                                            color: white, size: 28),
                                      ),
                                    ),
                                    title: Text(
                                        lang.S.of(context).select_a_time_slot,
                                        overflow: TextOverflow.ellipsis,
                                        style: montserratMedium.copyWith(
                                            color: black,
                                            fontSize: width * 0.04),
                                        maxLines: 3),
                                    subtitle: Text(
                                        selected_timeslot == ""
                                            ? "Choose time slot"
                                            : selected_timeslot,
                                        style: montserratSemiBold.copyWith(
                                            color: black,
                                            fontSize: selected_timeslot == ""
                                                ? width * 0.034
                                                : width * 0.04)),
                                    textColor: black,
                                    trailing: isExpanded
                                        ? Container(
                                            child: RadiantGradientMask(
                                              child: Icon(
                                                  Icons.keyboard_arrow_up,
                                                  color: white,
                                                  size: 30),
                                            ),
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: white.withAlpha(32)),
                                          )
                                        : RadiantGradientMask(
                                            child: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: white,
                                                size: 30),
                                          ),
                                    onExpansionChanged: (t1) {
                                      isExpanded = !isExpanded;
                                      setState(() {});
                                    },
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: white, boxShadow: null),
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            timeslots.length > 0
                                                ? ListView.builder(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    padding: EdgeInsets.only(
                                                        top: 16, bottom: 16),
                                                    itemCount: timeslots.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Row(
                                                        children: <Widget>[
                                                          Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                                    unselectedWidgetColor:
                                                                        black),
                                                            child: Radio(
                                                              value: timeslots[
                                                                          index]
                                                                      [
                                                                      'tm_start_time'] +
                                                                  " - " +
                                                                  timeslots[
                                                                          index]
                                                                      [
                                                                      'tm_end_time'],
                                                              groupValue:
                                                                  isTimeCheck,
                                                              fillColor: MaterialStateColor
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          syanColor),
                                                              onChanged:
                                                                  (dynamic
                                                                      value) {
                                                                timeslots[index]
                                                                            [
                                                                            'active_flag'] ==
                                                                        1
                                                                    ? value = 0
                                                                    : setState(
                                                                        () {
                                                                        isTimeCheck =
                                                                            value;
                                                                        selected_timeid =
                                                                            int.parse(timeslots[index]['tm_id']);
                                                                        selected_timeslot = timeFormatter(timeslots[index]['tm_start_time']) +
                                                                            " - " +
                                                                            timeFormatter(timeslots[index]['tm_end_time']);
                                                                      });
                                                              },
                                                            ),
                                                          ),
                                                          timeslots[index][
                                                                      'active_flag'] ==
                                                                  1
                                                              ? Text(
                                                                  timeFormatter(timeslots[index]['tm_start_time']) +
                                                                      " - " +
                                                                      timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_end_time']) +
                                                                      "\n" +
                                                                      lang.S
                                                                          .of(context)
                                                                          .slot_is_full,
                                                                  style: montserratMedium
                                                                      .copyWith(
                                                                    fontSize:
                                                                        width *
                                                                            0.034,
                                                                    color:
                                                                        errorcolor,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_start_time']) +
                                                                      " - " +
                                                                      timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_end_time']),
                                                                  style: montserratMedium
                                                                      .copyWith(
                                                                    fontSize:
                                                                        width *
                                                                            0.04,
                                                                    color:
                                                                        black,
                                                                  ),
                                                                ),
                                                        ],
                                                      );
                                                    })
                                                : Text(
                                                    lang.S
                                                        .of(context)
                                                        .no_time_slot_available,
                                                    style: montserratMedium
                                                        .copyWith(
                                                      fontSize: width * 0.034,
                                                      color: black,
                                                    ),
                                                  ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

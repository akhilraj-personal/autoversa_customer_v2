import 'dart:convert';
import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:autoversa/screens/package_screens/sound_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class SummeryinBooking extends StatefulWidget {
  final String bk_id;
  const SummeryinBooking({required this.bk_id, super.key});

  @override
  State<SummeryinBooking> createState() => SummeryinBookingState();
}

class SummeryinBookingState extends State<SummeryinBooking> {
  late Map<String, dynamic> booking = {};
  late Map<String, dynamic> booking_package = {};
  late Map<String, dynamic> pickup_address = {};
  late Map<String, dynamic> drop_address = {};
  late Map<String, dynamic> pickup_timeslot = {};
  late Map<String, dynamic> pickup_type = {};
  var audiofile;
  var packdataaudio;
  final player = SoundPlayer();
  bool isPlaying = false;
  double total_amount = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      init();
      getBookingDetailsID();
    });
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_id))};
    print(req);
    await getbookingdetails(req).then((value) async {
      if (value['ret_data'] == "success") {
        booking = value['booking'];
        booking_package = value['booking']['booking_package'];
        pickup_type = value['booking']['pickup_type'];
        pickup_address = value['booking']['pickup_address'];
        drop_address = value['booking']['drop_address'];
        pickup_timeslot = value['booking']['pickup_timeslot'];
        total_amount = double.parse(value['booking']['bk_total_amount']) +
            double.parse(value['booking']['bk_coupondiscount']);
        setState(() {});
      }
      if (booking["audio"] != null) {
        if (booking["audio"].containsKey("bka_url")) {
          packdataaudio = booking["audio"]["bka_url"];
        } else {
          packdataaudio = null;
        }
      } else {
        packdataaudio = null;
      }
    });
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

  Future<void> init() async {
    player.init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // bool isPlaying = player.isPlaying;
    // final playrecordicon = isPlaying
    //     ? Icons.stop_circle_outlined
    //     : Icons.play_circle_outline_sharp;
    // final playrecordtext = isPlaying ? "Stop Playing" : "Play Recording";
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: width,
                    height: height * 0.2,
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
                        height: height * 0.1,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.fromLTRB(
                            16.5, height * 0.07, height * 0.07, 16.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: width * 0.054,
                              ),
                            ),
                            SizedBox(width: width * 0.08),
                            Text(
                              "Booking Details",
                              style: montserratRegular.copyWith(
                                fontSize: width * 0.044,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(top: 16, left: 8)),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8)),
                                  ),
                                  margin: EdgeInsets.only(left: 0, right: 16),
                                  width: 75,
                                  height: 75,
                                  child: Image.asset(
                                      (ImageConst.default_service_list)
                                          .validate(),
                                      fit: BoxFit.fill),
                                  padding: EdgeInsets.all(width / 30),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            booking_package['pkg_name'] != null
                                                ? booking_package['pkg_name'] +
                                                    " (" +
                                                    booking['bk_number'] +
                                                    ")"
                                                : "",
                                            style: montserratSemiBold.copyWith(
                                                color: black,
                                                fontSize: width * 0.04),
                                            maxLines: 2),
                                        SizedBox(height: 4),
                                        Text(
                                            pickup_type['pk_name'] != null
                                                ? pickup_type['pk_name']
                                                : "",
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                            overflow: TextOverflow.clip,
                                            maxLines: 5),
                                        SizedBox(height: 4),
                                        Text(
                                            booking['bk_total_amount'] != null
                                                ? "AED" +
                                                    " " +
                                                    double.parse(booking[
                                                            'bk_total_amount'])
                                                        .toStringAsFixed(2)
                                                : "AED 0.00",
                                            style: montserratMedium.copyWith(
                                                color: warningcolor,
                                                fontSize: width * 0.04),
                                            overflow: TextOverflow.clip,
                                            maxLines: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup Location",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.04),
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
                                pickup_address['cad_landmark'] != null
                                    ? Text(
                                        pickup_address['cad_landmark']
                                                .toUpperCase() +
                                            " (" +
                                            pickup_address['cad_city'] +
                                            ")",
                                        style: montserratMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: width * 0.04),
                                      )
                                    : Text(
                                        pickup_address['cad_city'] != null
                                            ? pickup_address['cad_city']
                                            : "",
                                        style: montserratMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: width * 0.04),
                                      ),
                                Text(
                                  pickup_address['cad_address'] != null
                                      ? pickup_address['cad_address']
                                      : "",
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
                                  color: black, fontSize: width * 0.04),
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
                                drop_address['cad_landmark'] != null
                                    ? Text(
                                        drop_address['cad_landmark']
                                                .toUpperCase() +
                                            " (" +
                                            drop_address['cad_city'] +
                                            ")",
                                        style: montserratMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: width * 0.04),
                                      )
                                    : Text(
                                        drop_address['cad_city'] != null
                                            ? drop_address['cad_city']
                                            : "",
                                        style: montserratMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: width * 0.04),
                                      ),
                                Text(
                                  drop_address['cad_address'] != null
                                      ? drop_address['cad_address']
                                      : "",
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
                              "Booked Date & Time",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.04),
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
                                ImageConst.date_and_time,
                                scale: 4.5,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              booking['bk_booking_date'] != null
                                  ? DateFormat('LLLL').format(DateTime.parse(
                                      booking['bk_booking_date']))
                                  : "",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              booking['bk_booking_date'] != null
                                  ? DateFormat('d').format(DateTime.parse(
                                      booking['bk_booking_date']))
                                  : "",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034),
                            ),
                            Text(
                              pickup_timeslot['tm_start_time'] != null
                                  ? "   &   " +
                                      timeFormatter(
                                          pickup_timeslot['tm_start_time']) +
                                      " - " +
                                      timeFormatter(
                                          pickup_timeslot['tm_end_time'])
                                  : "",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034),
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
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Additional Comments",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.04),
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
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    booking['bk_complaint']?.isEmpty ?? true
                                        ? 'No Comments Recorded'
                                        : booking['bk_complaint'],
                                    style: montserratMedium.copyWith(
                                      color: Colors.black,
                                      fontSize: width * 0.034,
                                    ),
                                  ),
                                ],
                              ),
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
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Recordings",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.04),
                            ),
                          ],
                        ),
                      ),
                      packdataaudio != null
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 20, 0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          14.0, 0, 0, 0),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            blurRadius: 0.1,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                        border: Border.all(
                                            color: greyColor.withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                  padding: EdgeInsets.all(4)),
                                              Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.all(8),
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
                                                child: Icon(
                                                    Icons
                                                        .record_voice_over_outlined,
                                                    color: Colors.white,
                                                    size: 20),
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      isPlaying
                                                          ? "Stop Playing"
                                                          : "Play Recording",
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: width *
                                                                  0.034)),
                                                ],
                                              )
                                            ],
                                          ),
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              icon: Icon(
                                                  isPlaying
                                                      ? Icons
                                                          .stop_circle_outlined
                                                      : Icons
                                                          .play_circle_outline_sharp,
                                                  color: Colors.black),
                                              onPressed: () async {
                                                await player.togglePlaying(
                                                    whenFinished: () =>
                                                        setState(() {}));
                                                setState(() {
                                                  isPlaying = !isPlaying;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.fromLTRB(30, 8, 20, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text("No Recordings",
                                      style: montserratMedium.copyWith(
                                        fontSize: width * 0.034,
                                        color: black,
                                      )),
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
                      booking['bk_coupondiscount'] != "0.00"
                          ? SizedBox(
                              height: 8,
                            )
                          : SizedBox(
                              height: 0,
                            ),
                      booking['bk_coupondiscount'] != "0.00"
                          ? Container(
                              margin: EdgeInsets.only(left: 30.0, right: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total: ",
                                    style: montserratSemiBold.copyWith(
                                        color: black, fontSize: width * 0.034),
                                  ),
                                  Text(
                                    "AED" +
                                        " " +
                                        total_amount.toStringAsFixed(2),
                                    style: montserratSemiBold.copyWith(
                                        color: warningcolor,
                                        fontSize: width * 0.04),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      booking['bk_coupondiscount'] != "0.00"
                          ? 4.height
                          : 0.height,
                      booking['bk_coupondiscount'] != "0.00"
                          ? Container(
                              margin: EdgeInsets.only(left: 30.0, right: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Coupon Discount: ",
                                    style: montserratSemiBold.copyWith(
                                        color: black, fontSize: width * 0.034),
                                  ),
                                  Text(
                                    booking['bk_coupondiscount'] != null
                                        ? "AED" +
                                            " " +
                                            double.parse(booking[
                                                    'bk_coupondiscount'])
                                                .toStringAsFixed(2)
                                        : "0.00",
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
                              "Grand Total: ",
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.034),
                            ),
                            Text(
                              booking['bk_total_amount'] != null
                                  ? "AED" +
                                      " " +
                                      double.parse(booking['bk_total_amount'])
                                          .toStringAsFixed(2)
                                  : "0.00",
                              style: montserratSemiBold.copyWith(
                                  color: warningcolor, fontSize: width * 0.04),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                        },
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: height * 0.035,
                              width: height * 0.17,
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
                              height: height * 0.055,
                              width: height * 0.24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
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
                                "CLOSE",
                                style: montserratSemiBold.copyWith(
                                    color: Colors.white),
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
          ),
        ));
  }
}

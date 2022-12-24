import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/screens/package_screens/schedule_screen.dart';
import 'package:autoversa/screens/package_screens/sound_player_screen.dart';
import 'package:autoversa/screens/package_screens/sound_recorder_screen.dart';
import 'package:autoversa/screens/package_screens/timer_controller.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackageDetails extends StatefulWidget {
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedVeh;
  String currency;
  final List<dynamic> booking_list;
  final int pack_type;
  PackageDetails(
      {required this.custvehlist,
      required this.package_id,
      required this.selectedVeh,
      required this.booking_list,
      required this.currency,
      required this.pack_type,
      super.key});

  @override
  State<PackageDetails> createState() => PackageDetailsState();
}

class PackageDetailsState extends State<PackageDetails> {
  // final timeController = TimerController();
  // final recorder = SoundRecorder();
  // final player = SoundPlayer();

  bool recordLocation = false;
  var optionList = [];
  int currentveh = 0;
  bool isPriceShow = false;
  late Map<String, dynamic> packageinfo;
  double totalCost = 0.0;
  bool isbooked = false;
  bool isoffline = false;
  bool isServicing = true;
  String serviceMsg = '';
  bool recordPending = false;

  TextEditingController complaint = new TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      _getpackageinfo();
      currentveh = widget.selectedVeh;
    });
  }

  proceedbooking() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> packdata = {
      "packtype": widget.pack_type,
      "package_id": widget.package_id['pkg_id'],
      "vehicle_id": widget.custvehlist[currentveh]['cv_id'],
      "complaint": complaint.text.toString(),
      "audio_location": prefs.containsKey('comp_audio')
          ? prefs.containsKey('comp_audio')
          : "",
      "package_cost": totalCost
    };
    prefs.setString("booking_data", json.encode(packdata));
    setState(() => isbooked = false);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScheduleScreen(
                package_id: widget.package_id,
                custvehlist: widget.custvehlist,
                currency: widget.currency,
                selectedveh: currentveh)));
  }

  _getpackageinfo() async {
    var booking_flag = false;
    if (widget.booking_list.length > 0) {
      for (var bookings in widget.booking_list) {
        if (bookings['bk_vehicle_id'] ==
                widget.custvehlist[currentveh]['cv_id'] &&
            bookings['custstatus'] != 'Delivery Completed' &&
            bookings['custstatus'] != 'Booking Canceled') {
          booking_flag = true;
        }
      }
    }
    if (booking_flag == false) {
      try {
        Map req = {
          "package": widget.package_id['pkg_id'],
          "brand": widget.custvehlist[currentveh]['cv_make'],
          "model": widget.custvehlist[currentveh]['cv_model'],
          "variant": widget.custvehlist[currentveh]['cv_variant'],
          "year": widget.custvehlist[currentveh]['cv_year'],
        };
        totalCost = 0.0;
        var nonMapCount = 0;
        await getPackageDetails(req).then((value) {
          if (value['ret_data'] == "success") {
            optionList = [];
            setState(() {});
            isServicing = true;
            packageinfo = value;
            for (var sup_packs in value['sub_packages']) {
              optionList.add(sup_packs['sp_name']);
              for (var operations in sup_packs['operations']) {
                if (operations['opvm_timeunit'] != null) {
                  totalCost = totalCost +
                      (double.parse(operations['opvm_timeunit']) *
                              double.parse(value['labourrate']['lr_rate']))
                          .round();
                } else {
                  nonMapCount++;
                }
              }
              for (var spares in sup_packs['spares']) {
                if (spares['spares_used'].length > 0) {
                  for (var spareused in spares['spares_used']) {
                    if (spareused['scvm_price'] != null) {
                      totalCost = totalCost +
                          (double.parse(spareused['scvm_price']) *
                                  double.parse(spareused['scvm_quantity']))
                              .round();
                    }
                  }
                } else {
                  nonMapCount++;
                }
              }
            }
            for (var serv in value['services']) {
              optionList.add(serv['ser_name']);
              if (serv['sevm_timeunit'] != null) {
                totalCost = totalCost +
                    (double.parse(serv['sevm_timeunit']) *
                            double.parse(value['labourrate']['lr_rate']))
                        .round();
              } else {
                nonMapCount++;
              }
            }
            if (nonMapCount == 0) {
              isPriceShow = true;
              setState(() {});
            } else {
              totalCost = 0.0;
              isServicing = false;
              isPriceShow = true;
              serviceMsg = "Sorry currently we couldn't service selected model";
              setState(() {});
            }
          } else {
            totalCost = 0.0;
            isServicing = false;
            isPriceShow = true;
            serviceMsg = "Sorry currently we couldn't service selected model";
            setState(() {});
          }
        });
      } catch (e) {
        print(e.toString());
      }
    } else {
      totalCost = 0.0;
      serviceMsg =
          "Selected vehicle have an active booking. Please contact your Service Advisor";
      isServicing = false;
      isPriceShow = true;
      setState(() {});
    }
  }

  Future<void> init() async {
    super.initState();
    // recorder.init();
    // player.init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("booking_data");
    await prefs.remove("comp_audio");
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    // recorder.dispose();
    // player.dispose();
    optionList = [];
    totalCost = 0.0;
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
          backgroundColor: whiteColor,
          shadowColor: whiteColor,
          iconTheme: IconThemeData(color: whiteColor),
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
                          blueColor,
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
          child: Container(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            if (widget.custvehlist[0]['cv_make'] ==
                                'Mercedes Benz') ...[
                              Image.asset(
                                ImageConst.benz_ico,
                                width: width * 0.18,
                              ),
                            ] else if (widget.custvehlist[0]['cv_make'] ==
                                'BMW') ...[
                              Image.asset(
                                ImageConst.bmw_ico,
                                width: width * 0.18,
                              ),
                            ] else if (widget.custvehlist[0]['cv_make'] ==
                                'Skoda') ...[
                              Image.asset(
                                ImageConst.skod_ico,
                                width: width * 0.18,
                              ),
                            ] else ...[
                              Image.asset(
                                ImageConst.defcar_ico,
                                width: width * 0.18,
                              ),
                            ],
                            SizedBox(width: 8.0),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Flexible(
                                        child: Container(
                                          child: Text("ccc",
                                              overflow: TextOverflow.clip,
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: blackColor,
                                                      fontSize: 14)),
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
                                          child: Text("rrr",
                                              overflow: TextOverflow.clip,
                                              style: montserratRegular.copyWith(
                                                  color: blackColor,
                                                  fontSize: 12)),
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
                                          child: Text("xxxxxx",
                                              overflow: TextOverflow.clip,
                                              style: montserratRegular.copyWith(
                                                  color: blackColor,
                                                  fontSize: 12)),
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
                                          child: Text("sssssss",
                                              overflow: TextOverflow.clip,
                                              style: montserratRegular.copyWith(
                                                  color: blackColor,
                                                  fontSize: 12)),
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
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: Text(widget.package_id['pkg_name'],
                                style: montserratSemiBold.copyWith(
                                    color: blackColor, fontSize: 17)),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.all(16.0),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
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

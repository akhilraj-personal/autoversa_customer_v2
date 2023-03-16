import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/package_screens/schedule_screen.dart';
import 'package:autoversa/screens/package_screens/sound_player_screen.dart';
import 'package:autoversa/screens/package_screens/sound_recorder_screen.dart';
import 'package:autoversa/screens/package_screens/timer_controller.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/common_utils.dart';

class PackageDetails extends StatefulWidget {
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedVeh;
  String currency;
  final List<dynamic> booking_list;
  final int pack_type;
  PackageDetails(
      {required this.package_id,
      required this.custvehlist,
      required this.currency,
      required this.selectedVeh,
      required this.booking_list,
      required this.pack_type,
      super.key});

  @override
  State<PackageDetails> createState() => PackageDetailsState();
}

class PackageDetailsState extends State<PackageDetails> {
  final timeController = TimerController();
  final recorder = SoundRecorder();
  final player = SoundPlayer();

  bool recordLocation = false;
  var optionList = [];
  int currentveh = 0;
  bool isPriceShow = false;
  late Map<String, dynamic> packageinfo;
  double totalCost = 0.0;
  double packVat = 0.0;
  bool isbooked = false;
  bool isServicing = true;
  String serviceMsg = '';
  bool recordPending = false;
  StreamSubscription? internetconnection;
  bool isoffline = false;
  TextEditingController complaint = new TextEditingController();

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
      "package_cost": totalCost,
      "pack_vat": packVat
    };
    prefs.setString("booking_data", json.encode(packdata));
    print(json.encode(packdata));
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
            var gs_vat = int.parse(value['settings']['gs_vat']);
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
            if (value['settings']['gs_isvat'] == "1") {
              packVat = totalCost * (gs_vat / 100);
              totalCost = totalCost + (totalCost * (gs_vat / 100));
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
            // optionList.add("Sorry currently we don't service your vehicle");
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
    recorder.init();
    player.init();
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
    // internetconnection!.cancel();
    recorder.dispose();
    player.dispose();
    optionList = [];
    totalCost = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.mic;
    final animate = recorder.isRecording;
    final isPlaying = player.isPlaying;
    final playrecordicon = isPlaying
        ? Icons.stop_circle_outlined
        : Icons.play_circle_outline_sharp;
    final playrecordtext = isPlaying ? "Stop Playing" : "Play Recording";
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
              alignment: Alignment.topCenter,
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
                  child:
                      ////--------------- ClipPath for curv----------
                      ClipPath(
                    clipper: SinCosineWaveClipper(
                      verticalPosition: VerticalPosition.top,
                    ),
                    child: Container(
                      height: height * 0.1,
                      // padding: EdgeInsets.all(20),
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
                            widget.package_id['pkg_name'],
                            style: montserratRegular.copyWith(
                              fontSize: width * 0.044,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.custvehlist.length > 0
                        ? widget.custvehlist.length >= 2
                            ? Container(
                                margin: EdgeInsets.only(top: height * 0.01),
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                      aspectRatio: 3.0,
                                      enlargeCenterPage: true,
                                      viewportFraction: 0.65,
                                      autoPlay: false,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          currentveh = index;
                                          isPriceShow = false;
                                          _getpackageinfo();
                                        });
                                      },
                                      initialPage: widget.selectedVeh),
                                  items: widget.custvehlist
                                      .map((item) => Container(
                                              child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(16),
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius: 12,
                                                          color: syanColor
                                                              .withOpacity(.9),
                                                          spreadRadius: 0,
                                                          blurStyle:
                                                              BlurStyle.outer,
                                                          offset: Offset(0, 0)),
                                                    ]),
                                              ),
                                              Container(
                                                margin: EdgeInsets.all(5.0),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0)),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          child: Card(
                                                            semanticContainer:
                                                                true,
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            color: Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            5,
                                                                            0,
                                                                            5,
                                                                            0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Row(
                                                                          children: <
                                                                              Widget>[
                                                                            SizedBox(width: 5),
                                                                            Image.asset(
                                                                              item['cv_make'] == 'Mercedes Benz'
                                                                                  ? ImageConst.benz_ico
                                                                                  : item['cv_make'] == 'BMW'
                                                                                      ? ImageConst.bmw_ico
                                                                                      : item['cv_make'] == 'Skoda'
                                                                                          ? ImageConst.skod_ico
                                                                                          : item['cv_make'] == 'Audi'
                                                                                              ? ImageConst.aud_ico
                                                                                              : item['cv_make'] == 'Porsche'
                                                                                                  ? ImageConst.porsche_ico
                                                                                                  : item['cv_make'] == 'Volkswagen'
                                                                                                      ? ImageConst.volkswagen_icon
                                                                                                      : ImageConst.defcar_ico,
                                                                              width: width * 0.12,
                                                                            ),
                                                                            SizedBox(width: 5),
                                                                            Expanded(
                                                                              child: Container(
                                                                                padding: EdgeInsets.only(left: 4),
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    item['cv_plate_number'] != "" && item['cv_plate_number'] != null ? Text(item['cv_plate_number'], style: montserratSemiBold.copyWith(color: black, fontSize: width * 0.04), maxLines: 2) : SizedBox(),
                                                                                    item['cv_variant'] != "" && item['cv_variant'] != null ? Text(item['cv_make'] + " " + item['cv_model'] + " " + item['cv_variant'] + " (" + item['cv_year'] + ")", style: montserratRegular.copyWith(color: black, fontSize: width * 0.034), maxLines: 5) : Text(item['cv_make'] + item['cv_model'] + " (" + item['cv_year'] + ")", style: montserratRegular.copyWith(color: black, fontSize: width * 0.034), maxLines: 5),
                                                                                    Text(
                                                                                      isPriceShow ? widget.currency + " " + (totalCost.round()).toString() : "Loading",
                                                                                      style: montserratSemiBold.copyWith(color: warningcolor, fontSize: width * 0.04),
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
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ],
                                          )))
                                      .toList(),
                                ))
                            : Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                        16.5, height * 0.11, 16.5, 16.5),
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
                                    margin:
                                        EdgeInsets.only(top: 12, bottom: 12),
                                    width: width * 0.92,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(height * 0.02),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(width: 5),
                                                  if (widget.custvehlist[0]
                                                          ['cv_make'] ==
                                                      'Mercedes Benz') ...[
                                                    Image.asset(
                                                      ImageConst.benz_ico,
                                                      width: width * 0.12,
                                                    ),
                                                  ] else if (widget
                                                              .custvehlist[0]
                                                          ['cv_make'] ==
                                                      'BMW') ...[
                                                    Image.asset(
                                                      ImageConst.bmw_ico,
                                                      width: width * 0.12,
                                                    ),
                                                  ] else if (widget
                                                              .custvehlist[0]
                                                          ['cv_make'] ==
                                                      'Skoda') ...[
                                                    Image.asset(
                                                      ImageConst.skod_ico,
                                                      width: width * 0.12,
                                                    ),
                                                  ] else if (widget
                                                              .custvehlist[0]
                                                          ['cv_make'] ==
                                                      'Audi') ...[
                                                    Image.asset(
                                                      ImageConst.aud_ico,
                                                      width: width * 0.12,
                                                    ),
                                                  ] else if (widget
                                                              .custvehlist[0]
                                                          ['cv_make'] ==
                                                      'Porsche') ...[
                                                    Image.asset(
                                                      ImageConst.porsche_ico,
                                                      width: width * 0.12,
                                                    ),
                                                  ] else if (widget
                                                              .custvehlist[0]
                                                          ['cv_make'] ==
                                                      'Volkswagen') ...[
                                                    Image.asset(
                                                      ImageConst
                                                          .volkswagen_icon,
                                                      width: width * 0.12,
                                                    ),
                                                  ] else ...[
                                                    Image.asset(
                                                      ImageConst.defcar_ico,
                                                      width: width * 0.12,
                                                    ),
                                                  ],
                                                  SizedBox(width: 15),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              1, 0, 1, 0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          widget.custvehlist[0][
                                                                          'cv_plate_number'] !=
                                                                      "" &&
                                                                  widget.custvehlist[
                                                                              0]
                                                                          [
                                                                          'cv_plate_number'] !=
                                                                      null
                                                              ? Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        widget.custvehlist[0]
                                                                            [
                                                                            'cv_plate_number'],
                                                                        style: montserratSemiBold.copyWith(
                                                                            color:
                                                                                black,
                                                                            fontSize:
                                                                                width * 0.04),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : SizedBox(),
                                                          Text(
                                                            widget.custvehlist[
                                                                        0][
                                                                    'cv_make'] +
                                                                " ( " +
                                                                widget.custvehlist[
                                                                        0][
                                                                    'cv_year'] +
                                                                " )",
                                                            style: montserratSemiBold
                                                                .copyWith(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        width *
                                                                            0.034),
                                                          ),
                                                          Text(
                                                              widget.custvehlist[0]['cv_variant'] !=
                                                                          "" &&
                                                                      widget.custvehlist[0]['cv_variant'] !=
                                                                          null
                                                                  ? widget.custvehlist[0][
                                                                          'cv_model'] +
                                                                      " - " +
                                                                      widget.custvehlist[0][
                                                                          'cv_variant']
                                                                  : widget.custvehlist[0][
                                                                      'cv_model'],
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize: width *
                                                                          0.028),
                                                              maxLines: 2),
                                                          Text(
                                                            isPriceShow
                                                                ? widget.currency +
                                                                    " " +
                                                                    (totalCost
                                                                            .round())
                                                                        .toString()
                                                                : "Loading",
                                                            style: montserratSemiBold
                                                                .copyWith(
                                                                    color:
                                                                        warningcolor,
                                                                    fontSize:
                                                                        17),
                                                          ),
                                                        ],
                                                      )),
                                                  const SizedBox(width: 5),
                                                ]),
                                          ]),
                                    ),
                                  ),
                                ],
                              )
                        : Row(),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 12,
                              ),
                              isServicing
                                  ? optionList.isEmpty
                                      ? ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          itemCount: 3,
                                          itemBuilder: (context, index) {
                                            return Shimmer.fromColors(
                                              baseColor: lightGreyColor,
                                              highlightColor: greyColor,
                                              child: Container(
                                                height: height * 0.075,
                                                margin: EdgeInsets.only(
                                                    left: width * 0.01,
                                                    right: width * 0.01,
                                                    top: height * 0.01,
                                                    bottom: height * 0.01),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      white,
                                                      white,
                                                      white,
                                                      borderGreyColor,
                                                    ],
                                                  ),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    SizedBox(height: 30),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  height: 15,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ]),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: UL(
                                            symbolType: SymbolType.Bullet,
                                            symbolColor: syanColor,
                                            spacing: 24,
                                            children: List.generate(
                                              optionList.length,
                                              (i) => Text(optionList[i]!,
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          color: Colors.black,
                                                          fontSize:
                                                              width * 0.04)),
                                            ),
                                          ),
                                        )
                                  : Container(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(serviceMsg,
                                                maxLines: 10,
                                                textAlign: TextAlign.center,
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034)),
                                          ]),
                                    ),
                              SizedBox(
                                height: 12,
                              ),
                              isServicing
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(left: 16)),
                                        Text(ST.of(context).additional_queries,
                                            maxLines: 10,
                                            style: montserratRegular.copyWith(
                                                color: black,
                                                fontSize: width * 0.034))
                                      ],
                                    )
                                  : Container(),
                              isServicing
                                  ? Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            color: white),
                                        child: TextField(
                                            keyboardType:
                                                TextInputType.multiline,
                                            minLines: 1,
                                            maxLines: 5,
                                            maxLength: 230,
                                            textInputAction:
                                                TextInputAction.newline,
                                            controller: complaint,
                                            decoration: InputDecoration(
                                                counterText: "",
                                                hintText: ST
                                                    .of(context)
                                                    .your_message_here,
                                                hintStyle:
                                                    montserratRegular.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: greyColor,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: greyColor,
                                                      width: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ))),
                                        alignment: Alignment.center,
                                      ),
                                    )
                                  : SizedBox(),
                              isServicing
                                  ? Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      14, 0, 14, 14),
                                              child: Text(
                                                  ST
                                                      .of(context)
                                                      .press_record_dialogue,
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  AvatarGlow(
                                                    endRadius: 60,
                                                    glowColor: Colors.green,
                                                    animate: animate,
                                                    repeatPauseDuration:
                                                        Duration(
                                                            milliseconds: 100),
                                                    child: CircleAvatar(
                                                      radius: 22,
                                                      backgroundColor:
                                                          isRecording
                                                              ? Colors.red
                                                              : black,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 20,
                                                            backgroundColor:
                                                                isRecording
                                                                    ? Colors.red
                                                                    : white,
                                                            child:
                                                                RadiantGradientMask(
                                                              child: IconButton(
                                                                icon: Icon(icon,
                                                                    color:
                                                                        white,
                                                                    size: 25),
                                                                onPressed:
                                                                    () async {
                                                                  PermissionStatus
                                                                      microphoneStatus =
                                                                      await Permission
                                                                          .microphone
                                                                          .request();

                                                                  if (microphoneStatus ==
                                                                      PermissionStatus
                                                                          .granted) {
                                                                    await recorder
                                                                        .toggleRecording();

                                                                    final isRecording =
                                                                        recorder
                                                                            .isRecording;
                                                                    recordPending =
                                                                        recorder
                                                                            .isRecording;
                                                                    setState(
                                                                        () {});

                                                                    if (isRecording) {
                                                                      timeController
                                                                          .startTimer();
                                                                    } else {
                                                                      timeController
                                                                          .stopTimer();
                                                                      setState(
                                                                          () {
                                                                        recordLocation =
                                                                            true;
                                                                      });
                                                                    }
                                                                  }
                                                                  if (microphoneStatus ==
                                                                      PermissionStatus
                                                                          .denied) {
                                                                    showCustomToast(
                                                                        context,
                                                                        "This Permission is recommended for audio recording.",
                                                                        bgColor:
                                                                            errorcolor,
                                                                        textColor:
                                                                            white);
                                                                  }
                                                                  if (microphoneStatus ==
                                                                      PermissionStatus
                                                                          .permanentlyDenied) {
                                                                    openAppSettings();
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          AMTimerWidget(
                                                              controller:
                                                                  timeController),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              recordLocation == true
                                  ? Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                14.0, 0, 0, 0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  blurRadius: 0.1,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                              border:
                                                  Border.all(color: syanColor),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topRight,
                                                          end: Alignment
                                                              .bottomRight,
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(playrecordtext,
                                                            style: montserratRegular
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        width *
                                                                            0.034)),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: Colors.white,
                                                  child: IconButton(
                                                    icon: Icon(playrecordicon,
                                                        color: Colors.black),
                                                    onPressed: () async {
                                                      await player.togglePlaying(
                                                          whenFinished: () =>
                                                              setState(() {}));
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              icon: Icon(
                                                  Icons.delete_forever_outlined,
                                                  color: Colors.grey,
                                                  size: 32),
                                              onPressed: () {
                                                setState(() {
                                                  recordLocation = false;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: height * 0.04),
                              isServicing && recordPending == false
                                  ? GestureDetector(
                                      onTap: () async {
                                        if (isbooked) return;
                                        setState(() => isbooked = true);
                                        await Future.delayed(
                                            Duration(milliseconds: 1000));
                                        proceedbooking();
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
                                            child: !isbooked
                                                ? Text(
                                                    ST.of(context).book_now,
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontSize:
                                                                width * 0.034),
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
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ],
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

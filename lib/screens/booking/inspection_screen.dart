import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/screens/booking/image_full_screen.dart';
import 'package:autoversa/screens/booking/image_size_widget.dart';
import 'package:autoversa/screens/booking/inspection_image_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';

class InspectionScreen extends StatefulWidget {
  final String bookid;
  final String pkgname;
  final String vehname;
  final String booknum;
  final String bookdate;
  final String booktime;
  final String vehmake;
  const InspectionScreen(
      {required this.bookid,
      required this.pkgname,
      required this.vehname,
      required this.booknum,
      required this.bookdate,
      required this.booktime,
      required this.vehmake,
      super.key});

  @override
  State<InspectionScreen> createState() => InspectionScreenState();
}

class InspectionScreenState extends State<InspectionScreen>
    with WidgetsBindingObserver {
  var isloaded = false;
  bool isBuffering = false;
  bool showOverLay = false;
  bool isFullScreen = false;
  late Map<String, dynamic> getinspection = {};
  late VideoPlayerController _controller;
  late String vehicle_video;
  var vehicleimages = [];
  var vehiclevideourl;
  var carcontentlist = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getInspectionDetailsList();
    });
    _controller = VideoPlayerController.network("");
    _controller.setLooping(false);
    _controller
      ..initialize().then((_) {
        setState(() {
          isloaded = true;
        });
      });
    _controller.play();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getInspectionDetailsList() async {
    Map req = {"bookid": widget.bookid, "type": "1"};
    await getInspectionDetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          getinspection = value['inspection'];
          for (var filetype in value['medias']) {
            if (filetype['bka_type'] == "png" ||
                filetype['bka_type'] == "5" ||
                filetype['bka_type'] == "6") {
              vehicleimages.add(filetype['bka_url']);
              setState(() {});
            } else if (filetype['bka_type'] == "mp4") {
              vehiclevideourl = dotenv.env['aws_url']! + filetype['bka_url'];
              _controller = VideoPlayerController.network(vehiclevideourl);
              _controller.addListener(() {
                setState(() {});
              });
              _controller.initialize().then((value) {
                setState(() {});
              });
            }
          }
          for (var getcontent in value['contents']) {
            carcontentlist.add(getcontent);
          }
        });
      } else {
        setState(() {});
      }
    }).catchError((e) {
      setState(() {});
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
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
            "Inspection Details",
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
                      margin: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            if (widget.vehmake == 'Mercedes Benz') ...[
                              Image.asset(ImageConst.benz_ico,
                                  width: width / 8, height: 50),
                            ] else if (widget.vehmake == 'BMW') ...[
                              Image.asset(ImageConst.bmw_ico,
                                  width: width / 8, height: 50),
                            ] else if (widget.vehmake == 'Skoda') ...[
                              Image.asset(ImageConst.skod_ico,
                                  width: width / 8, height: 50),
                            ] else if (widget.vehmake == 'Audi') ...[
                              Image.asset(ImageConst.aud_ico,
                                  width: width / 8, height: 50),
                            ] else if (widget.vehmake == 'Porsche') ...[
                              Image.asset(ImageConst.porsche_ico,
                                  width: width / 8, height: 50),
                            ] else if (widget.vehmake == 'Volkswagen') ...[
                              Image.asset(ImageConst.volkswagen_icon,
                                  width: width / 8, height: 50),
                            ] else ...[
                              Image.asset(ImageConst.defcar_ico,
                                  width: width / 8, height: 50)
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
                                            child: Text(
                                                widget.pkgname != null
                                                    ? "Booking ID: " +
                                                        widget.booknum
                                                    : "",
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034))),
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
                                          child: Text(
                                            widget.pkgname,
                                            overflow: TextOverflow.clip,
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                          ),
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
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(DateTime.tryParse(
                                                          widget.bookdate)!),
                                                  overflow: TextOverflow.clip,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034),
                                                ),
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
                                                  widget.booktime,
                                                  overflow: TextOverflow.clip,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034),
                                                ),
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
                                          child: Text(
                                            widget.vehname,
                                            overflow: TextOverflow.clip,
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                          ),
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
                    AnimatedContainer(
                      margin: const EdgeInsets.all(14),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 4, left: 10.0),
                                child: Text(
                                  "Inspection Details",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034, color: black),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(8),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            getinspection['cv_plate_number'] !=
                                                    null
                                                ? "Plate No" +
                                                    ": " +
                                                    getinspection[
                                                        'cv_plate_number']
                                                : "Plate No" + ": No details",
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            getinspection['bk_odometer'] != null
                                                ? "Odometer" +
                                                    ": " +
                                                    getinspection['bk_odometer']
                                                : "Odometer" + ": No details",
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.clip,
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            getinspection['us_firstname'] !=
                                                    null
                                                ? "Inspection By" +
                                                    ": " +
                                                    getinspection[
                                                        'us_firstname']
                                                : "Inspection By " +
                                                    ": No details",
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.clip,
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034),
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
                          4.height,
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Images",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                        fontSize: width * 0.034)),
                                vehicleimages.length > 0
                                    ? TextButton(
                                        onPressed: () {
                                          InspectionImageScreen(
                                                  img: vehicleimages)
                                              .launch(context);
                                        },
                                        child: Text("Show all",
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.034)),
                                      )
                                    : Row(),
                              ],
                            ),
                          ),
                          vehicleimages.length > 0
                              ? HorizontalList(
                                  padding: EdgeInsets.only(left: 0, right: 16),
                                  itemCount: vehicleimages.length,
                                  itemBuilder: (_, index) {
                                    return InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        ImageFullscreen(
                                                img: dotenv.env['aws_url']! +
                                                    vehicleimages[index])
                                            .launch(context);
                                      },
                                      child: ImageWidget(
                                          img: dotenv.env['aws_url']! +
                                              vehicleimages[index]),
                                    );
                                  },
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("No Vehicle Images",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: montserratMedium.copyWith(
                                              color: black,
                                              fontSize: width * 0.034)),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 16, width: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Video",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                        fontSize: width * 0.034)),
                              ],
                            ),
                          ),
                          8.height,
                          vehiclevideourl != null
                              ? Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: AspectRatio(
                                    aspectRatio: isloaded
                                        ? _controller.value.aspectRatio
                                        : 12 / 6,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        VideoPlayer(_controller),
                                        Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    showOverLay = !showOverLay;
                                                    print("showoverlay:" +
                                                        showOverLay.toString());
                                                  },
                                                );
                                              },
                                            ),
                                            AnimatedSwitcher(
                                              duration:
                                                  Duration(milliseconds: 50),
                                              reverseDuration:
                                                  Duration(milliseconds: 200),
                                              child: showOverLay
                                                  ? Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 0),
                                                      color: Colors.black38,
                                                      child: Stack(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        children: [
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  IconButton(
                                                                    icon: Icon(isFullScreen
                                                                        ? Icons
                                                                            .fullscreen_exit
                                                                        : Icons
                                                                            .fullscreen),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                        () {
                                                                          !isFullScreen
                                                                              ? SystemChrome.setPreferredOrientations(
                                                                                  [
                                                                                    DeviceOrientation.landscapeRight,
                                                                                    DeviceOrientation.landscapeLeft
                                                                                  ],
                                                                                )
                                                                              : SystemChrome.setPreferredOrientations(
                                                                                  [
                                                                                    DeviceOrientation.portraitUp,
                                                                                    DeviceOrientation.portraitDown
                                                                                  ],
                                                                                );
                                                                          isFullScreen =
                                                                              !isFullScreen;
                                                                        },
                                                                      );
                                                                    },
                                                                  ).visible(
                                                                      !isBuffering)
                                                                ],
                                                              ),
                                                              VideoProgressIndicator(
                                                                  _controller,
                                                                  allowScrubbing:
                                                                      true),
                                                            ],
                                                          ),
                                                          Center(
                                                            child: IconButton(
                                                              icon: Icon(
                                                                _controller
                                                                        .value
                                                                        .isPlaying
                                                                    ? Icons
                                                                        .pause
                                                                    : Icons
                                                                        .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                                size: 56.0,
                                                              ),
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    _controller
                                                                            .value
                                                                            .isPlaying
                                                                        ? _controller
                                                                            .pause()
                                                                        : _controller
                                                                            .play();
                                                                    showOverLay = _controller
                                                                            .value
                                                                            .isPlaying
                                                                        ? false
                                                                        : true;
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ).onTap(
                                                      () {
                                                        setState(
                                                          () {
                                                            showOverLay =
                                                                !showOverLay;
                                                            print("showoverlay:" +
                                                                showOverLay
                                                                    .toString());
                                                          },
                                                        );
                                                      },
                                                    )
                                                  : SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                        Center(child: loadingWidgetMaker())
                                            .visible(isBuffering)
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("No Vehicle Video",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: montserratMedium.copyWith(
                                              color: black,
                                              fontSize: width * 0.034)),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 8.0),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Registration Card",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                        fontSize: width * 0.034)),
                              ],
                            ),
                          ),
                          8.height,
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: black),
                                      child: Radio(
                                          value: '0',
                                          fillColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) => syanColor),
                                          groupValue: getinspection[
                                              'bki_reg_card_flag'],
                                          onChanged: (value) {
                                            onChanged:
                                            (value) => getinspection[
                                                    'bki_reg_card_flag']
                                                ? null
                                                : value = 'Hard Copy';
                                          }),
                                    ),
                                    Text("Hard Copy",
                                        style: montserratMedium.copyWith(
                                            color: black,
                                            fontSize: width * 0.034)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: <Widget>[
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                          unselectedWidgetColor: black),
                                      child: Radio(
                                        fillColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => syanColor),
                                        value: '1',
                                        groupValue:
                                            getinspection['bki_reg_card_flag'],
                                        onChanged: (value) {
                                          onChanged:
                                          (value) =>
                                              getinspection['bki_reg_card_flag']
                                                  ? null
                                                  : value = "Soft Copy";
                                        },
                                      ),
                                    ),
                                    Text("Soft Copy",
                                        style: montserratMedium.copyWith(
                                            color: black,
                                            fontSize: width * 0.034)),
                                  ],
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: Row(
                              //     children: <Widget>[
                              //       Theme(
                              //         data: Theme.of(context).copyWith(
                              //             unselectedWidgetColor:
                              //                 appStore.textPrimaryColor),
                              //         child: Radio(
                              // fillColor: MaterialStateColor.resolveWith(
                              //         (states) => syanColor),
                              //           value: '2',
                              //           groupValue:
                              //               getinspection['bki_reg_card_flag'],
                              //           onChanged: (value) {
                              //             onChanged:
                              //             (value) =>
                              //                 getinspection['bki_reg_card_flag']
                              //                     ? null
                              //                     : value = "None";
                              //           },
                              //         ),
                              //       ),
                              //       Text(
                              //         "None",
                              //         style: TextStyle(
                              //           fontSize: 11,
                              //           color:
                              //               appStore.isDarkModeOn ? white : black,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          2.height,
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Registration Validity Details",
                                    textAlign: TextAlign.start,
                                    style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                      getinspection[
                                                  'cv_registrationvalidity'] !=
                                              null
                                          ? ": " +
                                              DateFormat('dd-MM-yyyy').format(
                                                  DateTime.tryParse(getinspection[
                                                      'cv_registrationvalidity'])!)
                                          : ": No details",
                                      textAlign: TextAlign.start,
                                      style: montserratMedium.copyWith(
                                          color: black,
                                          fontSize: width * 0.034)),
                                ),
                              ],
                            ),
                          ),
                          // Row(
                          //   children: <Widget>[
                          //     Expanded(
                          //       flex: 1,
                          //       child: Text(
                          //         "Registration Validity Details: ",
                          //         textAlign: TextAlign.start,
                          //         style: TextStyle(
                          //           fontSize: width * 0.034,
                          //           color: appStore.isDarkModeOn ? white : black,
                          //         ),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       flex: 1,
                          //       child: Text(
                          //         getinspection['cv_registrationvalidity'] != null
                          //             ? ": " +
                          //                 getinspection['cv_registrationvalidity']
                          //             : "",
                          //         textAlign: TextAlign.start,
                          //         style: TextStyle(
                          //           fontSize: width * 0.034,
                          //           color: appStore.isDarkModeOn ? white : black,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          8.height,
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Contents In Vehicle",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                        fontSize: width * 0.034)),
                              ],
                            ),
                          ),
                          8.height,
                          carcontentlist.length != 0
                              ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 0),
                                  child: Column(
                                    children: List.generate(
                                      carcontentlist.length,
                                      (i) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 12),
                                              child: Text(
                                                  carcontentlist[i]['civ_name'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("No Contents",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: montserratMedium.copyWith(
                                              color: black,
                                              fontSize: width * 0.034)),
                                    ],
                                  ),
                                ),
                          8.height,
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("Comments Recorded",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratSemiBold.copyWith(
                                        fontSize: width * 0.034)),
                              ],
                            ),
                          ),
                          8.height,
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                    getinspection['bki_comments'] != null
                                        ? getinspection['bki_comments']
                                        : "No Comments Recorded",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.clip,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034)),
                              ],
                            ),
                          ),
                          16.height,
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
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
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Container(
                                    height: height * 0.075,
                                    width: width,
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
                                    child: Text(
                                      "CLOSE",
                                      style: montserratSemiBold.copyWith(
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          )
                        ],
                      ),
                    ),
                    20.height,
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

Widget loadingWidgetMaker() {
  return Container(
    alignment: Alignment.center,
    child: Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4.0,
      margin: EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      child: Container(
        width: 45,
        height: 45,
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    ),
  );
}

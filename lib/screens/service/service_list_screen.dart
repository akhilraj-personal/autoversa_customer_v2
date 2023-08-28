import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/screens/service/service_details_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';

class ServiceList extends StatefulWidget {
  final int click_id;
  const ServiceList({required this.click_id, super.key});

  @override
  State<ServiceList> createState() => ServiceListState();
}

class ServiceListState extends State<ServiceList> {
  var bookingList = [];
  bool isActive = true;
  var splittedreason;
  var cancelreason;
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
    init();
    Future.delayed(Duration.zero, () {
      getBookings();
    });
  }

  getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> send_data = {
      'custId': prefs.getString('cust_id'),
    };
    print(send_data);
    bookingList = [];
    await get_service_history(send_data).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          for (var bookings in value['book_list']) {
            bookingList.add(bookings);
          }
          for (var cancelled in value['cancelled_list']) {
            bookingList.add(cancelled);
            splittedreason = cancelled['bkt_content'].split(':');
            cancelreason = splittedreason[1].split(')')[0];
          }
          isActive = false;
          setState(() {});
        });
      } else {
        isActive = false;
        setState(() {});
      }
    }).catchError((e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
    ;
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    // internetconnection!.cancel();
  }

  Future<bool> _onWillPop() async {
    return (await showConfirmDialogCustom(
          context,
          height: 65,
          title: 'Confirmation',
          subTitle: 'Are to sure you want to exit ?',
          primaryColor: syanColor,
          customCenterWidget: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Image.asset("assets/icons/logout_icon.png",
                width: width / 2, height: 95),
          ),
          onAccept: (v) {
            Navigator.of(context).pop(true);
          },
        )) ??
        false;
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
      child: WillPopScope(
          onWillPop: () {
            widget.click_id == 2
                ? Navigator.pop(context)
                : Navigator.pushReplacementNamed(context, Routes.bottombar);
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              flexibleSpace: Container(
                alignment: Alignment.bottomCenter,
                width: width,
                height: height * 0.31,
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
                "Service History",
                style: montserratSemiBold.copyWith(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  widget.click_id == 2
                      ? Navigator.pop(context)
                      : Navigator.pushReplacementNamed(
                          context, Routes.bottombar);
                },
                icon: Icon(Icons.arrow_back,
                    color: Colors.white, size: width * 0.054),
              ),
            ),
            body: Container(
              child: Column(
                children: <Widget>[
                  isActive
                      ? Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return Shimmer.fromColors(
                                  baseColor: lightGreyColor,
                                  highlightColor: greyColor,
                                  child: Container(
                                    height: height * 0.220,
                                    margin: EdgeInsets.only(
                                        left: width * 0.05,
                                        right: width * 0.05,
                                        top: height * 0.01,
                                        bottom: height * 0.01),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
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
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(height: 40),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 15, right: 10, top: 15),
                                              height: 80,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  color: Colors.white),
                                            ),
                                            Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      height: 18,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Container(
                                                      height: 14,
                                                      width: 160,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Container(
                                                      height: 10,
                                                      width: 100,
                                                      color: Colors.grey,
                                                    ),
                                                  ]),
                                            ),
                                            Container(
                                              height: 10,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        ),
                                        SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      : Expanded(
                          child: bookingList.length > 0
                              ? ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  itemCount: bookingList.length,
                                  itemBuilder: (context, index) {
                                    AlertDialog Cancelreason = AlertDialog(
                                      backgroundColor: context.cardColor,
                                      title: Text(
                                        "Cancel Reason",
                                        style: montserratSemiBold.copyWith(
                                            color: black,
                                            fontSize: width * 0.034),
                                      ),
                                      content: Text(
                                        cancelreason != null
                                            ? cancelreason.toUpperCase()
                                            : "",
                                        style: montserratRegular.copyWith(
                                            color: black,
                                            fontSize: width * 0.032),
                                      ),
                                      actions: [],
                                    );
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(12),
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                            margin: EdgeInsets.all(8.0),
                                            padding: EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 0.1,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.19)),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8),
                                                            topRight:
                                                                Radius.circular(
                                                                    8),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8)),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      left: 0, right: 16),
                                                  width: 75,
                                                  height: 75,
                                                  child: Image.asset(
                                                      (ImageConst
                                                              .default_service_list)
                                                          .validate(),
                                                      fit: BoxFit.fill),
                                                  padding: EdgeInsets.all(
                                                      width / 30),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 8, 8, 0),
                                                            child: Text(
                                                              bookingList[index]
                                                                  ['pkg_name'],
                                                              style: montserratSemiBold
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            child: Container(
                                                              child: Text(
                                                                  bookingList[index][
                                                                              'cv_make'] !=
                                                                          null
                                                                      ? bookingList[index][
                                                                              'cv_make'] +
                                                                          " " +
                                                                          bookingList[index][
                                                                              'cv_model']
                                                                      : "",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: montserratRegular
                                                                      .copyWith(
                                                                          color:
                                                                              black,
                                                                          fontSize:
                                                                              12)),
                                                            ),
                                                          ),
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            child: Container(
                                                              child: Text(
                                                                  bookingList[index][
                                                                              'cv_variant'] !=
                                                                          null
                                                                      ? bookingList[index][
                                                                              'cv_variant'] +
                                                                          " (" +
                                                                          bookingList[index][
                                                                              'cv_year'] +
                                                                          ")"
                                                                      : " (" +
                                                                          bookingList[index][
                                                                              'cv_year'] +
                                                                          ")",
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: montserratRegular
                                                                      .copyWith(
                                                                          color:
                                                                              black,
                                                                          fontSize:
                                                                              12)),
                                                            ),
                                                          ),
                                                        ],
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              'Date: ' +
                                                                  DateFormat(
                                                                          'dd-MM-yyyy')
                                                                      .format(DateTime
                                                                          .tryParse(
                                                                    bookingList[index]
                                                                            [
                                                                            'bk_booking_date']
                                                                        .toString(),
                                                                  )!),
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          black)),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      bookingList[index]
                                                                  ['st_code'] ==
                                                              "CANC"
                                                          ? Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              2,
                                                                          vertical:
                                                                              4),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration:
                                                                      boxDecorationWithRoundedCorners(
                                                                    backgroundColor:
                                                                        warningcolor,
                                                                    borderRadius:
                                                                        radius(
                                                                            6),
                                                                  ),
                                                                  child: Text(
                                                                    "Cancelled",
                                                                    style: montserratRegular.copyWith(
                                                                        color:
                                                                            black,
                                                                        fontSize:
                                                                            12),
                                                                  ).paddingOnly(
                                                                      left: 8.0,
                                                                      right:
                                                                          8.0),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return Cancelreason;
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Padding(
                                                                      padding: EdgeInsets.only(right: 8, top: 8),
                                                                      child: Icon(
                                                                        Icons
                                                                            .info,
                                                                        color:
                                                                            black,
                                                                        size:
                                                                            22,
                                                                      )),
                                                                )
                                                              ],
                                                            )
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              2,
                                                                          vertical:
                                                                              4),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration:
                                                                      boxDecorationWithRoundedCorners(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green,
                                                                    borderRadius:
                                                                        radius(
                                                                            6),
                                                                  ),
                                                                  child: Text(
                                                                    "Completed",
                                                                    style: montserratRegular.copyWith(
                                                                        color:
                                                                            white,
                                                                        fontSize:
                                                                            12),
                                                                  ).paddingOnly(
                                                                      left: 8.0,
                                                                      right:
                                                                          8.0),
                                                                ),
                                                              ],
                                                            ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ).onTap(
                                              () {
                                                bookingList[index]['st_code'] ==
                                                        "CANC"
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ServicehistoryDetails(
                                                                    bk_id: bookingList[index]
                                                                        [
                                                                        'bk_id'])))
                                                    : Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ServicehistoryDetails(
                                                                    bk_id: bookingList[
                                                                            index]
                                                                        ['bk_id'])));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                              : Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: height * 0.02,
                                          left: width * 0.04,
                                          right: width * 0.04),
                                      height: height * 0.18,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 12,
                                                color:
                                                    syanColor.withOpacity(.9),
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, 0)),
                                          ]),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: height * 0.02,
                                          left: width * 0.04,
                                          right: width * 0.04),
                                      height: height * 0.18,
                                      decoration: BoxDecoration(
                                          color: white,
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8)),
                                              ),
                                              margin: EdgeInsets.only(
                                                  left: 0, right: 12),
                                              child: Image.asset(
                                                ImageConst.no_data_found_icon,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                fit: BoxFit.fill,
                                              ),
                                              padding:
                                                  EdgeInsets.all(width / 30),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text(
                                                          "NO SERVICE HISTORY",
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  fontSize:
                                                                      width *
                                                                          0.0375,
                                                                  color: Colors
                                                                      .black)),
                                                    ),
                                                  ],
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
                ],
              ),
            ),
          )),
    );
  }
}

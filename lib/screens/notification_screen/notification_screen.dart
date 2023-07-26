import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/main.dart';
import 'package:autoversa/model/model.dart';
import 'package:autoversa/screens/booking/booking_status_flow_page.dart';
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

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late List<NotificationModel> notificationList = [];
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      _getNotificationList();
    });
  }

  Future<void> init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  _getNotificationList() async {
    notificationList = [];
    final prefs = await SharedPreferences.getInstance();
    Map req = {"custId": prefs.getString('cust_id')};
    await getCustomerNotificationList(req).then((value) {
      if (value['ret_data'] == "success") {
        for (var notify in value['notification_list']) {
          NotificationModel noti = new NotificationModel();
          noti.nt_id = notify['nt_id'];
          noti.nt_header = notify['nt_header'];
          noti.nt_content = notify['nt_content'];
          noti.nt_created_on = notify['nt_created_on'];
          noti.pkg_name = notify['pkg_name'];
          noti.nt_read = notify['nt_read'];
          noti.nt_bookid = notify['nt_bookid'];
          noti.cv_make = notify['cv_make'];
          noti.cv_model = notify['cv_model'];
          noti.cv_variant = notify['cv_variant'];
          noti.cv_year = notify['cv_year'];
          noti.st_code = notify['st_code'];
          notificationList.add(noti);
        }
        setState(() {
          isActive = false;
        });
      } else {
        isActive = false;
        setState(() {});
      }
    }).catchError((e) {
      print(e.toString());
      setState(() {
        isActive = false;
      });
      print("11111====>");
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  clearNotification() async {
    Map req = {};
    await clear_notification(req).then((value) {
      if (value['ret_data'] == "success") {
        showCustomToast(context, "Notification Cleared",
            bgColor: black, textColor: white);
        Navigator.pushReplacementNamed(context, Routes.bottombar);
      }
    }).catchError((e) {
      print("222222====>");
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
      setState(() {
        isActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
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
            "Notification",
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
          actions: [
            notificationList.length > 0
                ? IconButton(
                    icon: Icon(Icons.delete, color: white),
                    onPressed: () {
                      showConfirmDialogCustom(
                        context,
                        title:
                            'Are you sure you want to clear all notifications.?',
                        primaryColor: syanColor,
                        onAccept: (v) async {
                          clearNotification();
                          setState(() {});
                        },
                      );
                    },
                  )
                : SizedBox()
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
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
                                            left: 15,
                                            right: 10,
                                          ),
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
                          }))
                  : Expanded(
                      child: notificationList.length > 0
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: notificationList.length,
                              itemBuilder: (context, index) {
                                return Notification(
                                    notificationList[index], index);
                              },
                            )
                          : Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: width * 0.31),
                                  padding: EdgeInsets.all(12),
                                  height: height * 0.045,
                                  width: height * 0.37,
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
                                  margin: EdgeInsets.only(
                                      top: height * 0.02,
                                      left: width * 0.04,
                                      right: width * 0.04,
                                      bottom: width * 1.2),
                                  decoration: BoxDecoration(
                                      color: white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
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
                                          padding: EdgeInsets.all(width / 30),
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
                                                  child: Text("No Notification",
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              fontSize: width *
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
      ),
    );
  }
}

class Notification extends StatelessWidget {
  late NotificationModel model;

  Notification(NotificationModel model, int pos) {
    this.model = model;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0, top: 12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: model.nt_read == "0"
                ? Colors.grey.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            blurRadius: 0.1,
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: syanColor,
              borderRadius: radius(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    (DateFormat('d')
                        .format(DateTime.tryParse(model.nt_created_on)!)),
                    style: boldTextStyle(size: 20, color: white)),
                Text(
                    (DateFormat('MMM')
                        .format(DateTime.tryParse(model.nt_created_on)!)),
                    style: secondaryTextStyle(color: white)),
              ],
            ),
          ),
          6.width,
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        model.nt_header,
                        overflow: TextOverflow.clip,
                        maxLines: 3,
                        softWrap: true,
                        style: montserratSemiBold.copyWith(
                          fontSize: width * 0.034,
                          color: black,
                        ),
                      ),
                    ),
                  ),
                  12.width,
                  Text(
                      DateFormat('h:mm a')
                          .format(DateTime.tryParse(model.nt_created_on)!),
                      style: montserratRegular.copyWith(
                        fontSize: width * 0.032,
                        color: black,
                      )),
                ],
              ),
              4.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(model.pkg_name,
                      style: montserratRegular.copyWith(
                        fontSize: width * 0.032,
                        color: black,
                      )),
                ],
              ),
              4.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      child: Text(
                        model.nt_content,
                        overflow: TextOverflow.clip,
                        maxLines: 3,
                        style: montserratRegular.copyWith(
                          fontSize: width * 0.032,
                          color: black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).expand()
        ],
      ).onTap(() async {
        if (model.nt_read == "0" && model.st_code != "DLCC") {
          Map req = {"nt_id": model.nt_id};
          await read_notification(req).then((value) {
            if (value['ret_data'] == "success") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BookingStatusFlow(
                            bk_id: model.nt_bookid,
                            vehname: model.cv_make != null
                                ? model.cv_variant != null
                                    ? model.cv_make +
                                        " " +
                                        model.cv_model +
                                        " " +
                                        model.cv_variant +
                                        " ( " +
                                        model.cv_year +
                                        " )"
                                    : model.cv_make +
                                        " " +
                                        model.cv_model +
                                        " (" +
                                        model.cv_variant +
                                        ")"
                                : "",
                            make: model.cv_make,
                          )));
            }
          }).catchError((e) {
            print("33333====>");
            print(e.toString());
            showCustomToast(context, lang.S.of(context).toast_application_error,
                bgColor: errorcolor, textColor: white);
          });
        } else if (model.nt_read == "1" && model.st_code != "DLCC") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookingStatusFlow(
                        bk_id: model.nt_bookid,
                        vehname: model.cv_make != null
                            ? model.cv_variant != null
                                ? model.cv_make +
                                    " " +
                                    model.cv_model +
                                    " " +
                                    model.cv_variant +
                                    " ( " +
                                    model.cv_year +
                                    " )"
                                : model.cv_make +
                                    " " +
                                    model.cv_model +
                                    " (" +
                                    model.cv_variant +
                                    ")"
                            : "",
                        make: model.cv_make,
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ServicehistoryDetails(
                        bk_id: model.nt_bookid,
                      )));
        }
      }),
    );
  }
}

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/model/model.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late List<NotificationModel> notificationList = [];
  bool isoffline = false;
  // late List notificationlist = [];
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
    await getCustomerNotificationList().then((value) {
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
          notificationList.add(noti);
        }
        setState(() {
          // notificationlist = value['notification_list'];
          isActive = false;
        });
      } else {
        isActive = false;
        setState(() {});
        // toasty(context, "No Notification");
      }
    }).catchError((e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  clearNotification() async {
    // Map req = {
    //   "nt_id": notificationList,
    //   "nt_header": "Delivery Completed",
    //   "nt_content": " completed for the delivery for the booking-BK141",
    //   "nt_read": "0",
    //   "nt_bookid": "1",
    //   "nt_stcode": "DECB",
    //   "nt_created_on": "2022-12-05 17:33:59",
    //   "nt_status": "2"
    // };
    // await clear_notification(req).then((value) {
    //   if (value['ret_data'] == "success") {
    //     toasty(context, "Notification Cleared");
    //   }
    // });
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
                ],
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              isActive
                  ? Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          padding:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.black,
                              highlightColor: Colors.white12,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black, width: 1.0))),
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
                          : Container(
                              height: height(),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'images/automobile/no_data_found.png',
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth,
                                  ),
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
                ? Colors.grey.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
            blurRadius: 0.1,
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
          onTap: () async {
            if (model.nt_read == "0") {
              Map req = {"nt_id": model.nt_id};
              await read_notification(req).then((value) {
                if (value['ret_data'] == "success") {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => AMBookingPackage(
                  //               bk_id: model.nt_bookid,
                  //               vehname: model.cv_make != null
                  //                   ? model.cv_variant != null
                  //                       ? model.cv_make +
                  //                           " " +
                  //                           model.cv_model +
                  //                           " " +
                  //                           model.cv_variant +
                  //                           " ( " +
                  //                           model.cv_year +
                  //                           " )"
                  //                       : model.cv_make +
                  //                           " " +
                  //                           model.cv_model +
                  //                           " (" +
                  //                           model.cv_variant +
                  //                           ")"
                  //                   : "",
                  //             )));
                } else {
                  print(value);
                }
              }).catchError((e) {
                print(e.toString());
                showCustomToast(context, S.of(context).toast_application_error,
                    bgColor: errorcolor, textColor: whiteColor);
              });
            } else if (model.nt_read == "1") {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => AMBookingPackage(
              //               bk_id: model.nt_bookid,
              //               vehname: model.cv_make != null
              //                   ? model.cv_variant != null
              //                       ? model.cv_make +
              //                           " " +
              //                           model.cv_model +
              //                           " " +
              //                           model.cv_variant +
              //                           " ( " +
              //                           model.cv_year +
              //                           " )"
              //                       : model.cv_make +
              //                           " " +
              //                           model.cv_model +
              //                           " (" +
              //                           model.cv_variant +
              //                           ")"
              //                   : "",
              //             )));
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        (DateFormat('d')
                            .format(DateTime.tryParse(model.nt_created_on)!)),
                        style: montserratSemiBold.copyWith(
                            color: blackColor, fontSize: 20)),
                    Text(
                        (DateFormat('MMM')
                            .format(DateTime.tryParse(model.nt_created_on)!)),
                        style: montserratSemiBold.copyWith(color: whiteColor)),
                  ],
                ),
              ),
              SizedBox(width: 6),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff3a57e8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                          DateFormat('h:mm a')
                              .format(DateTime.tryParse(model.nt_created_on)!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(model.pkg_name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.normal,
                            fontSize: 12,
                            color: Color(0xff000000),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          child: Text(
                            model.nt_content,
                            overflow: TextOverflow.clip,
                            maxLines: 3,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )),

      // .onTap(() async {
      //   if (model.nt_read == "0") {
      //     Map req = {"nt_id": model.nt_id};
      //     await read_notification(req).then((value) {
      //       if (value['ret_data'] == "success") {
      //         // Navigator.push(
      //         //     context,
      //         //     MaterialPageRoute(
      //         //         builder: (context) => AMBookingPackage(
      //         //               bk_id: model.nt_bookid,
      //         //               vehname: model.cv_make != null
      //         //                   ? model.cv_variant != null
      //         //                       ? model.cv_make +
      //         //                           " " +
      //         //                           model.cv_model +
      //         //                           " " +
      //         //                           model.cv_variant +
      //         //                           " ( " +
      //         //                           model.cv_year +
      //         //                           " )"
      //         //                       : model.cv_make +
      //         //                           " " +
      //         //                           model.cv_model +
      //         //                           " (" +
      //         //                           model.cv_variant +
      //         //                           ")"
      //         //                   : "",
      //         //             )));
      //       } else {
      //         print(value);
      //       }
      //     }).catchError((e) {
      //       print(e.toString());
      //       showCustomToast(context, S.of(context).toast_application_error,
      //           bgColor: errorcolor, textColor: whiteColor);
      //     });
      //   } else if (model.nt_read == "1") {
      //     // Navigator.push(
      //     //     context,
      //     //     MaterialPageRoute(
      //     //         builder: (context) => AMBookingPackage(
      //     //               bk_id: model.nt_bookid,
      //     //               vehname: model.cv_make != null
      //     //                   ? model.cv_variant != null
      //     //                       ? model.cv_make +
      //     //                           " " +
      //     //                           model.cv_model +
      //     //                           " " +
      //     //                           model.cv_variant +
      //     //                           " ( " +
      //     //                           model.cv_year +
      //     //                           " )"
      //     //                       : model.cv_make +
      //     //                           " " +
      //     //                           model.cv_model +
      //     //                           " (" +
      //     //                           model.cv_variant +
      //     //                           ")"
      //     //                   : "",
      //     //             )));
      //   }
      // }
      // ),
    );
  }
}

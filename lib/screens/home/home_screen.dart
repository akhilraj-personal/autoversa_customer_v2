import 'dart:async';

import 'package:autoversa/main.dart';
import 'package:autoversa/model/model.dart';
import 'package:autoversa/screens/booking/booking_status_flow_page.dart';
import 'package:autoversa/screens/booking/reschedule_screen.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/screens/notification_screen/notification_screen.dart';
import 'package:autoversa/screens/package_screens/car_repair_screen.dart';
import 'package:autoversa/screens/package_screens/package_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/image_const.dart';
import '../../constant/text_style.dart';
import '../../generated/l10n.dart';
import '../../services/post_auth_services.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_utils.dart';
import '../../utils/text_utils.dart';
// import '../NextScreen.dart';
import '../settings/edit_profile.dart';
import '../vehicle/vehicle_add_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String cut_name = "";
  late List customerVehList = [];
  late List bookingList = [];
  late List packageList = [];
  late List<NotificationModel> notificationList = [];
  String currency = "";
  int selectedVeh = 0;
  bool noofvehicle = false;
  StreamSubscription? internetconnection;
  bool isoffline = false;
  bool isActive = true;

  bool isBookingLoaded = false,
      isVehicleLoaded = false,
      isPackageLoaded = false,
      isExpanded = false;

  List offerList = [
    {
      "offerName": TextConst.carRepair.toUpperCase(),
    },
    {
      "offerName": TextConst.carWash.toUpperCase(),
    }
  ];

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
          Navigator.pushReplacementNamed(context, Routes.bottombar);
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          isoffline = false;
          Navigator.pushReplacementNamed(context, Routes.bottombar);
        });
      }
    });
    Future.delayed(Duration.zero, () {
      _getCustomerVehicles();
      _getPackages();
      _getCustomerBookingList();
      _getNotificationList();
    });
    Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    internetconnection!.cancel();
    super.dispose();
  }

  _getPackages() async {
    try {
      Map req = {};
      await getPackages(req).then((value) {
        if (value['ret_data'] == "success") {
          setState(() {
            packageList = value['package_list'];
            currency = value['currency']['cy_code'];
            isPackageLoaded = true;
          });
        }
      });
    } catch (e) {
      isPackageLoaded = false;
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    }
  }

  _getCustomerVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {"custId": prefs.getString("cust_id")};
    await getCustomerVehicles(req).then((value) {
      if (value['ret_data'] == "success") {
        if (value['vehList'].length == 0) {
          setState(() {
            noofvehicle = false;
          });
        } else {
          setState(() {
            noofvehicle = true;
          });
        }
        setState(() {
          customerVehList = value['vehList'];
          isVehicleLoaded = true;
        });
      }
    }).catchError((e) {
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  _getCustomerBookingList() async {
    bookingList = [];
    final prefs = await SharedPreferences.getInstance();
    Map req = {"custId": prefs.getString("cust_id")};
    await getCustomerBookingList(req).then((value) {
      if (value['ret_data'] == "success") {
        for (var booklist in value['book_list']) {
          if (booklist['st_code'] != "DLCC" && booklist['st_code'] != "CANC") {
            setState(() {
              bookingList.add(booklist);
              isBookingLoaded = true;
            });
          }
        }
      } else {
        setState(() {
          isBookingLoaded = true;
          bookingList = [];
        });
      }
    }).catchError((e) {
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  _getNotificationList() async {
    Map req = {};
    await getCustomerNotificationList(req).then((value) {
      if (value['ret_data'] == "success") {
        for (var notify in value['notification_list']) {
          NotificationModel noti = new NotificationModel();
          noti.nt_read = notify['nt_read'];
          if (noti.nt_read == "0") {
            notificationList.add(noti);
          }
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
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  redirectPackage(pack_details, pack_typ, currency, noofvehicle) {
    if (noofvehicle) {
      if (pack_typ == "1") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PackageDetails(
                      package_id: pack_details,
                      custvehlist: customerVehList,
                      currency: currency,
                      selectedVeh: selectedVeh,
                      booking_list: bookingList,
                      pack_type: 1,
                    )));
      } else if (pack_typ == "2") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CarRepair(
                      package_id: pack_details,
                      custvehlist: customerVehList,
                      currency: currency,
                      selectedVeh: selectedVeh,
                      booking_list: bookingList,
                      pack_type: 2,
                    )));
      }
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => VehicleAddPage()));
    }
  }

  Future refresh() async {
    _getCustomerBookingList();
    setState(() {});
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cut_name = prefs.getString('name')!;
    });
  }

  notificationclick() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NotificationPage()));
  }

  Future<bool> _onWillPop() async {
    return (await showConfirmDialogCustom(
          context,
          height: 65,
          title: 'Confirmation',
          subTitle: 'Are you sure you want to exit ?',
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
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
        ),
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              body: RefreshIndicator(
                  child: SingleChildScrollView(
                      child: Column(children: [
                    Stack(alignment: Alignment.bottomCenter, children: [
                      Column(children: [
                        Stack(children: [
                          Container(
                            alignment: Alignment.bottomCenter,
                            width: width,
                            height: isExpanded == false
                                ? bookingList.length > 0
                                    ? bookingList.length > 1
                                        ? height *
                                            0.4 *
                                            (bookingList.length * 0.6)
                                        : height * 0.4
                                    : isVehicleLoaded
                                        ? customerVehList.length == 0
                                            ? height * 0.2
                                            : height * 0.3
                                        : height * 0.3
                                : bookingList.length > 1
                                    ? height * 0.7 * (bookingList.length * 0.6)
                                    : height * 0.7,
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
                                height: isExpanded
                                    ? height * 0.61
                                    : bookingList.length > 0
                                        ? height * 0.31
                                        : isVehicleLoaded
                                            ? customerVehList.length == 0
                                                ? height * 0.11
                                                : height * 0.20
                                            : height * 0.20,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: height * 0.057,
                                      left: width * 0.04,
                                      right: width * 0.04),
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      //-------------- welcome ---------
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return Editprofie();
                                                  },
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              ImageConst.person,
                                              scale: 3.6,
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(
                                                  left: width * 0.03),
                                              child: RichText(
                                                text: TextSpan(
                                                  text: ST
                                                          .of(context)
                                                          .dash_intro_text +
                                                      " ",
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: white,
                                                          fontSize:
                                                              width * 0.034),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: cut_name,
                                                        style: montserratBold
                                                            .copyWith(
                                                                color: white,
                                                                fontSize:
                                                                    width *
                                                                        0.034)),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),

                                      ///--------- notification---------
                                      GestureDetector(
                                        onTap: () {
                                          notificationclick();
                                        },
                                        child: notificationList.length != 0
                                            ? Image.asset(
                                                ImageConst.notification_with,
                                                scale: 3.7,
                                              )
                                            : Image.asset(
                                                ImageConst.notification_without,
                                                scale: 3.7,
                                              ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: height * 0.02,
                                      left: width * 0.04,
                                      right: width * 0.03,
                                      bottom: height * 0.02),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        bookingList.length > 0
                                            ? Container(
                                                child: Text(
                                                  TextConst.myActive,
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          color: white,
                                                          fontSize:
                                                              width * 0.04),
                                                ),
                                              )
                                            : SizedBox(),
                                        bookingList.length > 0
                                            ? ListView.builder(
                                                padding:
                                                    EdgeInsets.only(top: 0),
                                                itemCount: bookingList.length,
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return (bookingList[index]
                                                                  ['st_code'] !=
                                                              "DLCC") &&
                                                          (bookingList[index]
                                                                  ['st_code'] !=
                                                              "CANC")
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: height *
                                                                      0.02),
                                                          decoration: BoxDecoration(
                                                              color: white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: width * 0.04,
                                                            right: width * 0.03,
                                                            top: height * 0.012,
                                                            bottom:
                                                                height * 0.012,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  ///--------- first text -------------
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        bookingList[index]['pkg_name'] !=
                                                                                null
                                                                            ? bookingList[index]['pkg_name'] +
                                                                                " (" +
                                                                                bookingList[index]['bk_number'] +
                                                                                ")"
                                                                            : "",
                                                                        style: montserratSemiBold.copyWith(
                                                                            color:
                                                                                black,
                                                                            fontSize:
                                                                                width * 0.034),
                                                                      ),
                                                                      Text(
                                                                        bookingList[index]['custstatus'] !=
                                                                                null
                                                                            ? bookingList[index]['custstatus']
                                                                            : "",
                                                                        style: montserratBold.copyWith(
                                                                            color:
                                                                                syanColor,
                                                                            fontSize:
                                                                                width * 0.031),
                                                                      ),
                                                                      Container(
                                                                        child:
                                                                            Text(
                                                                          bookingList[index]['cv_make'] +
                                                                              " " +
                                                                              bookingList[index]['cv_model'],
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: montserratRegular.copyWith(
                                                                              color: black,
                                                                              fontSize: width * 0.029),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  ///--------- up down arrow -------------
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        isExpanded =
                                                                            !isExpanded;
                                                                        if (bookingList[index]['detail_flag'] ==
                                                                            true) {
                                                                          bookingList[index]['detail_flag'] =
                                                                              false;
                                                                        } else {
                                                                          bookingList[index]['detail_flag'] =
                                                                              true;
                                                                        }
                                                                      });
                                                                    },
                                                                    child: Image
                                                                        .asset(
                                                                      bookingList[index]['detail_flag'] !=
                                                                              null
                                                                          ? bookingList[index]['detail_flag'] == true
                                                                              ? ImageConst.upArrow
                                                                              : ImageConst.downarrow
                                                                          : ImageConst.downarrow,
                                                                      scale: 4,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              isExpanded == true
                                                                  ? bookingList[index]
                                                                              [
                                                                              'detail_flag'] ==
                                                                          true
                                                                      ? Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            ///--------- Package -------------
                                                                            Container(
                                                                              margin: EdgeInsets.only(top: height * 0.03),
                                                                              child: Text(
                                                                                bookingList[index]['cv_variant'] != null ? bookingList[index]['cv_make'] + " " + bookingList[index]['cv_model'] + " " + bookingList[index]['cv_variant'] + " (" + bookingList[index]['cv_year'] + ")" : bookingList[index]['cv_make'] + " " + bookingList[index]['cv_model'] + " (" + bookingList[index]['cv_year'] + ")",
                                                                                style: montserratRegular.copyWith(color: black, fontSize: width * 0.037),
                                                                              ),
                                                                            ),

                                                                            ///--------- Date -------------
                                                                            Container(
                                                                                margin: EdgeInsets.only(top: height * 0.007, bottom: height * 0.007),
                                                                                child: RichText(
                                                                                  text: TextSpan(
                                                                                    text: "Date: ",
                                                                                    style: montserratSemiBold.copyWith(color: black, fontSize: width * 0.034),
                                                                                    children: <TextSpan>[
                                                                                      TextSpan(text: bookingList[index]['bk_booking_date'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.tryParse(bookingList[index]['bk_booking_date'])!) : "", style: montserratRegular.copyWith(color: black, fontSize: width * 0.034)),
                                                                                    ],
                                                                                  ),
                                                                                )),

                                                                            ///--------- time -------------
                                                                            RichText(
                                                                              text: TextSpan(
                                                                                text: "Time: ",
                                                                                style: montserratSemiBold.copyWith(color: black, fontSize: width * 0.034),
                                                                                children: <TextSpan>[
                                                                                  TextSpan(text: bookingList[index]['tm_start_time'] != null ? timeFormatter(bookingList[index]['tm_start_time']) + " - " + timeFormatter(bookingList[index]['tm_end_time']) : "", style: montserratRegular.copyWith(color: black, fontSize: width * 0.034)),
                                                                                ],
                                                                              ),
                                                                            ),

                                                                            ///--------- divider -------------
                                                                            Container(
                                                                              margin: EdgeInsets.only(top: height * 0.02, bottom: height * 0.02, left: width * 0.01, right: width * 0.01),
                                                                              height: 1,
                                                                              width: width,
                                                                              color: greyColor,
                                                                            ),

                                                                            ///--------- currentOrder status -------------
                                                                            Container(
                                                                              margin: EdgeInsets.only(bottom: height * 0.008),
                                                                              child: Text(
                                                                                TextConst.currentOrder,
                                                                                style: montserratSemiBold.copyWith(color: black, fontSize: width * 0.034),
                                                                              ),
                                                                            ),

                                                                            ///--------- car image -------------

                                                                            Row(
                                                                              children: [
                                                                                if (bookingList[index]['st_code'] == "BKCC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.booking_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "DRPC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.driver_enroute_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "PIPC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.pickup_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "PIWC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.pickup_enroute_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "VAWC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.vehicle_wrkshp_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "WIPC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.work_in_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "CDLC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.confirm_drop_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "RFDC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.ready_delivery_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "DEDC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.drop_enrouted,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "DLCC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.delivery_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "HOLDC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.hold_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ] else if (bookingList[index]['st_code'] == "BAPC") ...[
                                                                                  Image.asset(
                                                                                    ImageConst.awaiting_payment_icon,
                                                                                    scale: 4,
                                                                                  ),
                                                                                ],

                                                                                ///--------- booking status -------------

                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: width * 0.02),
                                                                                  child: Text(
                                                                                    bookingList[index]['custstatus'] != null ? bookingList[index]['custstatus'] : "",
                                                                                    style: montserratRegular.copyWith(color: black, fontSize: width * 0.034),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),

                                                                            ///--------- view details -------------

                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                if (bookingList[index]['st_code'] == "BAPC") {
                                                                                  if (DateTime.now().isBefore(DateTime.tryParse(bookingList[index]['bk_booking_date'])!)) {
                                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RescheduleScreen(bk_data: bookingList[index], custvehlist: customerVehList, currency: currency, selectedVeh: selectedVeh)));
                                                                                  } else {
                                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RescheduleScreen(bk_data: bookingList[index], custvehlist: customerVehList, currency: currency, selectedVeh: selectedVeh)));
                                                                                  }
                                                                                } else {
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => BookingStatusFlow(
                                                                                                bk_id: bookingList[index]['bk_id'],
                                                                                                vehname: bookingList[index]['cv_make'] != null
                                                                                                    ? bookingList[index]['cv_variant'] != null
                                                                                                        ? bookingList[index]['cv_make'] + " " + bookingList[index]['cv_model'] + " " + bookingList[index]['cv_variant'] + " ( " + bookingList[index]['cv_year'] + " )"
                                                                                                        : bookingList[index]['cv_make'] + " " + bookingList[index]['cv_model'] + " (" + bookingList[index]['cv_year'] + ")"
                                                                                                    : "",
                                                                                                make: bookingList[index]['cv_make'],
                                                                                              )));
                                                                                }
                                                                                // Navigator.push(
                                                                                //     context,
                                                                                //     MaterialPageRoute(
                                                                                //         builder: (context) => BookingStatusFlow(
                                                                                //               bk_id: bookingList[index]['bk_id'],
                                                                                //               vehname: bookingList[index]['cv_make'] != null
                                                                                //                   ? bookingList[index]['cv_variant'] != null
                                                                                //                       ? bookingList[index]['cv_make'] + " " + bookingList[index]['cv_model'] + " " + bookingList[index]['cv_variant'] + " ( " + bookingList[index]['cv_year'] + " )"
                                                                                //                       : bookingList[index]['cv_make'] + " " + bookingList[index]['cv_model'] + " (" + bookingList[index]['cv_year'] + ")"
                                                                                //                   : "",
                                                                                //               make: bookingList[index]['cv_make'],
                                                                                //             )));
                                                                              },
                                                                              child: Container(
                                                                                margin: EdgeInsets.only(top: height * 0.02, bottom: height * 0.01),
                                                                                width: width / 3,
                                                                                padding: EdgeInsets.all(height * 0.014),
                                                                                decoration: BoxDecoration(
                                                                                  color: lightGreyColor,
                                                                                  border: Border.all(color: greyColor),
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    height * 0.1,
                                                                                  ),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Text(
                                                                                      TextConst.view,
                                                                                      style: montserratSemiBold.copyWith(color: black, fontSize: width * 0.034),
                                                                                    ),
                                                                                    Image.asset(
                                                                                      ImageConst.right_arrow,
                                                                                      color: greyColor,
                                                                                      scale: 4,
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        )
                                                                      : Container()
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        )
                                                      : Container();
                                                })
                                            : Container(),
                                        isVehicleLoaded &&
                                                customerVehList.length > 0
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    top: bookingList.length > 0
                                                        ? height * 0.02
                                                        : height * 0.01),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      TextConst.myVehicles,
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              color: white,
                                                              fontSize:
                                                                  width * 0.04),
                                                    ),
                                                    //------------------add new ---------------
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          VehicleAddPage()));
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            TextConst.addNew,
                                                            style: montserratSemiBold
                                                                .copyWith(
                                                                    color:
                                                                        white,
                                                                    fontSize:
                                                                        width *
                                                                            0.04),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: width *
                                                                        0.02),
                                                            child: Image.asset(
                                                              ImageConst.add,
                                                              scale: 4.7,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ]),
                                ),
                              ]),
                        ]),
                        Container(
                            height:
                                isVehicleLoaded && customerVehList.length > 1
                                    ? isBookingLoaded &&
                                            bookingList.length > 0 &&
                                            bookingList.length < 2
                                        ? height * 0.11
                                        : bookingList.length > 1
                                            ? height * 0.13
                                            : height * 0.08
                                    : isBookingLoaded &&
                                            bookingList.length > 0 &&
                                            bookingList.length < 2
                                        ? height * 0.07
                                        : bookingList.length > 1
                                            ? height * 0.09
                                            : height * 0.07),
                      ]),
                      isVehicleLoaded
                          ? customerVehList.length < 2
                              ? Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.08,
                                          right: width * 0.08,
                                          top: width * 0.38),
                                      padding: EdgeInsets.only(
                                          left: width * 0.04,
                                          right: width * 0.08,
                                          top: height * 0.03,
                                          bottom: height * 0.03),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color: Colors.lightBlue[500]!,
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, -7)),
                                          ]),
                                    ),
                                    Card(
                                        elevation: 0,
                                        borderOnForeground: false,
                                        // shadowColor: Color.fromARGB(255, 154, 197, 231),
                                        margin: EdgeInsets.only(
                                          left: width * 0.035,
                                          right: width * 0.035,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: customerVehList.length == 0
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                VehicleAddPage()));
                                                  });
                                                },
                                                child: Container(
                                                  height: height * 0.14,
                                                  width: width,
                                                  padding: EdgeInsets.only(
                                                      left: width * 0.04,
                                                      right: width * 0.08,
                                                      top: height * 0.03,
                                                      bottom: height * 0.03),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        white,
                                                        white,
                                                        borderGreyColor,
                                                      ],
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        ST
                                                            .of(context)
                                                            .new_vehicle_text,
                                                        style:
                                                            montserratSemiBold
                                                                .copyWith(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        16),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: greyColor,
                                                        size: height * 0.04,
                                                        semanticLabel:
                                                            'Add vehicle',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : customerVehList.length == 1
                                                ? Container(
                                                    padding: EdgeInsets.only(
                                                        left: width * 0.04,
                                                        right: width * 0.08,
                                                        top: height * 0.03,
                                                        bottom: height * 0.03),
                                                    constraints: BoxConstraints(
                                                        minHeight:
                                                            height * 0.16),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          white,
                                                          white,
                                                          white,
                                                          borderGreyColor,
                                                        ],
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              customerVehList[0]
                                                                  [
                                                                  'cv_plate_number'],
                                                              style: montserratSemiBold
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          width *
                                                                              0.034),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets.only(
                                                                  top: height *
                                                                      0.004,
                                                                  bottom:
                                                                      height *
                                                                          0.004),
                                                              child: Text(
                                                                customerVehList[
                                                                        0]
                                                                    ['cv_make'],
                                                                style: montserratRegular.copyWith(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        width *
                                                                            0.034),
                                                              ),
                                                            ),
                                                            Text(
                                                              customerVehList[0]
                                                                      [
                                                                      'cv_model'] +
                                                                  " (" +
                                                                  customerVehList[
                                                                          0][
                                                                      'cv_year'] +
                                                                  ")",
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          width *
                                                                              0.034),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            customerVehList[0][
                                                                        'cv_variant'] !=
                                                                    null
                                                                ? Container(
                                                                    margin: EdgeInsets.only(
                                                                        top: height *
                                                                            0.004,
                                                                        bottom: height *
                                                                            0.004),
                                                                    child: Text(
                                                                      customerVehList[
                                                                              0]
                                                                          [
                                                                          'cv_variant'],
                                                                      style: montserratRegular.copyWith(
                                                                          color:
                                                                              black,
                                                                          fontSize:
                                                                              width * 0.034),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  )
                                                                : SizedBox(),
                                                          ],
                                                        ),
                                                        Image.asset(
                                                          customerVehList[0][
                                                                      'cv_make'] ==
                                                                  'Mercedes Benz'
                                                              ? ImageConst
                                                                  .benz_ico
                                                              : customerVehList[
                                                                              0]
                                                                          [
                                                                          'cv_make'] ==
                                                                      'BMW'
                                                                  ? ImageConst
                                                                      .bmw_ico
                                                                  : customerVehList[0]
                                                                              [
                                                                              'cv_make'] ==
                                                                          'Skoda'
                                                                      ? ImageConst
                                                                          .skod_ico
                                                                      : customerVehList[0]['cv_make'] ==
                                                                              'Audi'
                                                                          ? ImageConst
                                                                              .aud_ico
                                                                          : ImageConst
                                                                              .defcar_ico,
                                                          width: width * 0.2,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : SizedBox()),
                                  ],
                                )
                              : Container(
                                  height: height * 0.2,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                        left: width * 0.02,
                                        right: width * 0.02),
                                    itemCount: customerVehList.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Stack(children: [
                                        Card(
                                          elevation: 0,
                                          color: syanColor.withOpacity(0.4),
                                          borderOnForeground: false,
                                          // shadowColor: Colors.lightBlue[500]!,
                                          margin: EdgeInsets.only(
                                            top: 2,
                                            left: width * 0.018,
                                            right: width * 0.018,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Container(
                                            width: customerVehList.length == 2
                                                ? width * 0.44
                                                : width * 0.4,
                                            margin: EdgeInsets.only(
                                                bottom: height * 0.002),
                                            padding: EdgeInsets.only(
                                              left: width * 0.04,
                                              right: width * 0.08,
                                              top: height * 0.03,
                                            ),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  customerVehList[index]
                                                      ['cv_plate_number'],
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.037),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: height * 0.004,
                                                      bottom: height * 0.004),
                                                  child: Text(
                                                    customerVehList[index]
                                                        ['cv_make'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: montserratRegular
                                                        .copyWith(
                                                            color: black,
                                                            fontSize:
                                                                width * 0.037),
                                                  ),
                                                ),
                                                Text(
                                                  customerVehList[index]
                                                          ['cv_model'] +
                                                      " (" +
                                                      customerVehList[index]
                                                          ['cv_year'] +
                                                      ")",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: height * 0.004,
                                                      bottom: height * 0.004),
                                                  child: Text(
                                                    customerVehList[index][
                                                                'cv_variant'] !=
                                                            null
                                                        ? customerVehList[index]
                                                            ['cv_variant']
                                                        : "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: montserratRegular
                                                        .copyWith(
                                                            color: black,
                                                            fontSize:
                                                                width * 0.026),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: height * 0.01,
                                                  bottom: height * 0.007,
                                                  left: width * 0.055),
                                              child: Image.asset(
                                                customerVehList[index][
                                                            'cv_make'] ==
                                                        'Mercedes Benz'
                                                    ? ImageConst.benz_ico
                                                    : customerVehList[index][
                                                                'cv_make'] ==
                                                            'BMW'
                                                        ? ImageConst.bmw_ico
                                                        : customerVehList[index]
                                                                    [
                                                                    'cv_make'] ==
                                                                'Skoda'
                                                            ? ImageConst
                                                                .skod_ico
                                                            : customerVehList[
                                                                            index]
                                                                        [
                                                                        'cv_make'] ==
                                                                    'Audi'
                                                                ? ImageConst
                                                                    .aud_ico
                                                                : ImageConst
                                                                    .defcar_ico,
                                                width: width * 0.1,
                                              ),
                                            ))
                                      ]);
                                    },
                                  ),
                                )
                          : Stack(alignment: Alignment.bottomCenter, children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.08,
                                    right: width * 0.08,
                                    top: width * 0.38),
                                padding: EdgeInsets.only(
                                    left: width * 0.04,
                                    right: width * 0.08,
                                    top: height * 0.03,
                                    bottom: height * 0.03),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 16,
                                          color: Colors.lightBlue[500]!,
                                          spreadRadius: 0,
                                          blurStyle: BlurStyle.outer,
                                          offset: Offset(0, -7)),
                                    ]),
                              ),
                              Card(
                                elevation: 0,
                                borderOnForeground: false,
                                // shadowColor: Color.fromARGB(255, 154, 197, 231),
                                margin: EdgeInsets.only(
                                  left: width * 0.035,
                                  right: width * 0.035,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Shimmer.fromColors(
                                    baseColor: lightGreyColor,
                                    highlightColor: greyColor,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: width * 0.04,
                                          right: width * 0.08,
                                          top: height * 0.03,
                                          bottom: height * 0.03),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "DU 55566",
                                                style:
                                                    montserratSemiBold.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: height * 0.004,
                                                    bottom: height * 0.004),
                                                child: Text(
                                                  "Mercedes Benz",
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034),
                                                ),
                                              ),
                                              Text(
                                                "E Class (2000)",
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: height * 0.004,
                                                    bottom: height * 0.004),
                                                child: Text(
                                                  "F 300",
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.034),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Image.asset(
                                            ImageConst.handel,
                                            scale: 4,
                                          )
                                        ],
                                      ),
                                    )),
                              )
                            ]),
                    ]),
                    Container(
                        margin: EdgeInsets.only(
                          top: height * 0.02,
                          left: width * 0.04,
                          right: width * 0.04,
                        ),
                        child: Column(children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              TextConst.services,
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.043),
                            ),
                          ),
                          isPackageLoaded
                              ? GridView.builder(
                                  padding: EdgeInsets.only(top: height * 0.02),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          // maxCrossAxisExtent: 200,
                                          // childAspectRatio: 3 / 2,
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 25,
                                          mainAxisSpacing: 17),
                                  itemCount: packageList.length,
                                  itemBuilder: (BuildContext ctx, index) {
                                    return commonWidget(
                                        dotenv.env['aws_url']! +
                                            this.packageList[index]
                                                ['pkg_imageUrl'],
                                        this.packageList[index]['pkg_name'],
                                        true,
                                        packageList[index],
                                        packageList[index]['pkg_type'],
                                        currency,
                                        noofvehicle);
                                  })
                              : Shimmer.fromColors(
                                  baseColor: lightGreyColor,
                                  highlightColor: greyColor,
                                  child: Column(children: [
                                    GridView.count(
                                      padding:
                                          EdgeInsets.only(top: height * 0.02),
                                      shrinkWrap: true,
                                      primary: false,
                                      crossAxisSpacing: 25,
                                      mainAxisSpacing: 17,
                                      crossAxisCount: 2,
                                      children: <Widget>[
                                        commonWidget(ImageConst.img1, "Sample",
                                            false, "0", "1", "AED", "0"),
                                        commonWidget(ImageConst.img1, "Sample",
                                            false, "0", "1", "AED", "0"),
                                        commonWidget(ImageConst.img1, "Sample",
                                            false, "0", "1", "AED", "0"),
                                        commonWidget(ImageConst.img1, "Sample",
                                            false, "0", "1", "AED", "0"),
                                      ],
                                    )
                                  ])),
                          Container(
                            margin: EdgeInsets.only(
                                top: height * 0.023, bottom: height * 0.01),
                            child: Text(
                              TextConst.addOnServices,
                              style: montserratSemiBold.copyWith(
                                  color: black, fontSize: width * 0.043),
                            ),
                          ),
                          ////------------- All Service Container------------
                          Container(
                            margin: EdgeInsets.only(
                              bottom: height * 0.03,
                            ),
                            padding: EdgeInsets.only(
                                left: width * 0.026,
                                right: width * 0.026,
                                bottom: height * 0.015,
                                top: height * 0.02),
                            decoration: BoxDecoration(
                              color: container_grey_color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommanService(
                                  ImageConst.insurance,
                                  TextConst.insurance,
                                ),
                                CommanService(
                                  ImageConst.road_asset,
                                  TextConst.roadAssistance,
                                ),
                                CommanService(
                                  ImageConst.abcd,
                                  TextConst.carpassing,
                                ),
                                CommanService(
                                  ImageConst.drive_car,
                                  TextConst.cardetailing,
                                ),
                              ],
                            ),
                          ),
                          ////------------- Offer for you ------------
                          Container(
                            margin: EdgeInsets.only(
                              bottom: height * 0.07,
                            ),
                            height: height * 0.19,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: offerList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => NextPage()));
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          index == 0
                                              ? Text(
                                                  TextConst.offerForYou,
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.043),
                                                )
                                              : Text(
                                                  '',
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          color: black,
                                                          fontSize:
                                                              width * 0.043),
                                                ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: height * 0.017),
                                            height: height * 0.14,
                                            padding: EdgeInsets.only(
                                                left: width * 0.03),
                                            width: width / 1.7,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                begin: Alignment.topRight,
                                                end: Alignment.bottomLeft,
                                                colors: [
                                                  syanColor,
                                                  lightblueColor,
                                                ],
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ////------------- offer name------------
                                                Text(
                                                  offerList[index]["offerName"],
                                                  style: montserratSemiBold
                                                      .copyWith(
                                                          color: white,
                                                          fontSize:
                                                              width * 0.053),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      ////------------- person image ------------
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        margin: EdgeInsets.only(
                                            right: width * 0.03),
                                        child: Image.asset(
                                          ImageConst.person1,
                                          height: height * 0.175,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.only(right: width * 0.03),
                                );
                              },
                            ),
                          )
                        ])),
                  ])),
                  onRefresh: refresh),
            )));
  }

  commonWidget(String img, String text, bool type, pack_details, pack_typ,
      currency, noofvehicle) {
    return GestureDetector(
      onTap: () {
        redirectPackage(pack_details, pack_typ, currency, noofvehicle);
      },
      child: Container(
        padding: EdgeInsets.only(
            left: width * 0.03, right: width * 0.06, bottom: height * 0.027),
        decoration: BoxDecoration(
            image: type
                ? DecorationImage(image: CachedNetworkImageProvider(img))
                : DecorationImage(image: AssetImage(img)),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: montserratMedium.copyWith(
                    color: white, fontSize: width * 0.045),
              ),
            ),
            Image.asset(
              ImageConst.right_arrow,
              scale: 3.5,
            )
          ],
        ),
      ),
    );
  }

  CommanService(String image, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(height * 0.023),
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
              image,
              height: height * 0.043,
              width: height * 0.043,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: height * 0.01, top: height * 0.006),
          child: Text(
            text,
            style: montserratRegular.copyWith(
                color: black, fontSize: width * 0.033),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
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
}

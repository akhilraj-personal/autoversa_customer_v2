import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/model/model.dart';
import 'package:autoversa/screens/vehicle/vehicle_add_page.dart';
import 'package:autoversa/screens/vehicle/vehicle_update_page.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';

class Vehiclelist extends StatefulWidget {
  final int click_id;
  const Vehiclelist({required this.click_id, super.key});

  @override
  State<Vehiclelist> createState() => VehiclelistState();
}

class VehiclelistState extends State<Vehiclelist> {
  late List<VehicleModel> custvehlist = [];
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getCustomerVehicles();
    });
  }

  _getCustomerVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {"custId": prefs.getString("cust_id")};
    custvehlist = [];
    await getCustomerVehicles(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          for (var veh in value['vehList']) {
            VehicleModel temp = new VehicleModel();
            temp.cv_id = veh['cv_id'];
            temp.cv_make = veh['cv_make'];
            temp.cv_model = veh['cv_model'];
            temp.cv_variant = veh['cv_variant'];
            temp.cv_year = veh['cv_year'];
            temp.cv_vinnumber = veh['cv_vinnumber'];
            temp.cv_plate_number = veh['cv_plate_number'];
            temp.cv_odometer = veh['cv_odometer'];
            temp.cv_group_id = veh['cv_group_id'];
            temp.cv_cust_id = veh['cv_cust_id'];
            temp.cv_created_on = veh['cv_created_on'];
            temp.cv_created_by = veh['cv_created_by'];
            temp.cv_updated_on = veh['cv_updated_on'];
            temp.cv_updated_by = veh['cv_updated_by'];
            temp.cv_status_flag = veh['cv_status_flag'];
            temp.cv_delete_flag = veh['cv_delete_flag'];
            custvehlist.add(temp);
          }
          isActive = false;
        });
      } else {
        setState(() {
          isActive = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  vehicle_delete(id) async {
    Map delreq = {"cv_id": id};
    await deleteCustomerVehicle(delreq).then((value) async {
      if (value['ret_data'] == "success") {
        showCustomToast(context, "Vehicle Deleted",
            bgColor: Colors.black, textColor: Colors.white);
        await Future.delayed(Duration(milliseconds: 1000));
        _getCustomerVehicles();
      } else {
        showCustomToast(
            context, "Created a booking. so can't delete the vehicle",
            bgColor: warningcolor, textColor: Colors.white);
      }
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
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
                    "Vehicle List",
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
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                  )),
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
                                                    left: 15,
                                                    right: 10,
                                                    top: 15),
                                                height: 80,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color: Colors.white),
                                              ),
                                              Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                            child: custvehlist.length > 0
                                ? ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    padding:
                                        EdgeInsets.only(top: 16, bottom: 16),
                                    itemCount: custvehlist.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              topRight: Radius
                                                                  .circular(8),
                                                              bottomLeft: Radius
                                                                  .circular(8),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8)),
                                                        ),
                                                        margin: EdgeInsets.only(
                                                            left: 0, right: 16),
                                                        width: width * 0.2,
                                                        child: Image.asset(
                                                          custvehlist[index]
                                                                      .cv_make ==
                                                                  'Mercedes Benz'
                                                              ? ImageConst
                                                                  .benz_ico
                                                              : custvehlist[index]
                                                                          .cv_make ==
                                                                      'BMW'
                                                                  ? ImageConst
                                                                      .bmw_ico
                                                                  : custvehlist[index]
                                                                              .cv_make ==
                                                                          'Skoda'
                                                                      ? ImageConst
                                                                          .skod_ico
                                                                      : custvehlist[index].cv_make ==
                                                                              'Audi'
                                                                          ? ImageConst
                                                                              .aud_ico
                                                                          : custvehlist[index].cv_make == 'Porsche'
                                                                              ? ImageConst.porsche_ico
                                                                              : custvehlist[index].cv_make == 'Volkswagen'
                                                                                  ? ImageConst.volkswagen_icon
                                                                                  : ImageConst.defcar_ico,
                                                        ),
                                                        padding: EdgeInsets.all(
                                                            width / 30),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
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
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            8,
                                                                            8,
                                                                            0),
                                                                child: Text(
                                                                    custvehlist[
                                                                            index]
                                                                        .cv_plate_number,
                                                                    style: montserratSemiBold.copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            width *
                                                                                0.043)),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              Flexible(
                                                                child:
                                                                    Container(
                                                                  child: Text(
                                                                      custvehlist[index].cv_make +
                                                                          " " +
                                                                          custvehlist[index]
                                                                              .cv_model +
                                                                          " " +
                                                                          (custvehlist[index].cv_variant != null
                                                                              ? custvehlist[index]
                                                                                  .cv_variant
                                                                              : "") +
                                                                          " (" +
                                                                          custvehlist[index]
                                                                              .cv_year +
                                                                          ")",
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                      style: montserratRegular.copyWith(
                                                                          color:
                                                                              black,
                                                                          fontSize:
                                                                              width * 0.034)),
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
                                                          // Row(
                                                          //   mainAxisAlignment:
                                                          //       MainAxisAlignment
                                                          //           .spaceBetween,
                                                          //   children: <Widget>[
                                                          //     Container(
                                                          //       child: Text(
                                                          //           custvehlist[index].cv_odometer !=
                                                          //                   null
                                                          //               ? "Odometer: " +
                                                          //                   custvehlist[index]
                                                          //                       .cv_odometer
                                                          //               : "",
                                                          //           style: montserratRegular.copyWith(
                                                          //               fontSize:
                                                          //                   width *
                                                          //                       0.034,
                                                          //               color: Colors
                                                          //                   .black)),
                                                          //     ),
                                                          //   ],
                                                          // ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            showConfirmDialogCustom(
                                                              height: 65,
                                                              context,
                                                              title:
                                                                  'Are you sure you want to delete this vehicle.?',
                                                              primaryColor:
                                                                  syanColor,
                                                              customCenterWidget:
                                                                  Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 8),
                                                                child: Image.asset(
                                                                    "assets/icons/car.png",
                                                                    width:
                                                                        width /
                                                                            2,
                                                                    height: 95),
                                                              ),
                                                              onAccept: (v) {
                                                                vehicle_delete(
                                                                    custvehlist[
                                                                            index]
                                                                        .cv_id);
                                                              },
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 8,
                                                                    left: 8),
                                                            child: Container(
                                                              width: 40,
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.3),
                                                              ),
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                ).onTap(() {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              VehicleUpdate(
                                                                  vehicle_id: custvehlist[
                                                                          index]
                                                                      .cv_id)));
                                                })),
                                          ],
                                        ),
                                      );
                                    },
                                  )
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
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(8),
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
                                                            "NO SAVED VEHICLES",
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
              floatingActionButton: FloatingActionButton(
                child: Container(
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.add,
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          LinearGradient(colors: [lightblueColor, syanColor])),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              VehicleAddPage(click: "fromlist")));
                },
                heroTag: 'Add Vehicle',
              ))),
    );
  }
}

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/model/model.dart';
import 'package:autoversa/screens/vehicle/vehicle_add_page.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class Vehiclelist extends StatefulWidget {
  final int click_id;
  const Vehiclelist({required this.click_id, super.key});

  @override
  State<Vehiclelist> createState() => VehiclelistState();
}

class VehiclelistState extends State<Vehiclelist> {
  late List<VehicleModel> custvehlist = [];
  bool isActive = true;
  bool isoffline = false;

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
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  vehicle_delete(id) async {
    Map delreq = {"cv_id": id};
    await deleteCustomerVehicle(delreq).then((value) {
      if (value['ret_data'] == "success") {
        _getCustomerVehicles();
        showCustomToast(context, "Vehicle Deleted",
            bgColor: Colors.black, textColor: Colors.white);
      } else {
        showCustomToast(
            context, "Created a booking. so can't delete the vehicle",
            bgColor: warningcolor, textColor: Colors.white);
      }
    });
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
              "Vehicle List",
              style: myriadproregular.copyWith(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            leading: widget.click_id == 2
                ? IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 18,
                  )
                : Row(),
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
                        child: custvehlist.length > 0
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                padding: EdgeInsets.only(top: 16, bottom: 16),
                                itemCount: custvehlist.length,
                                itemBuilder: (context, index) {
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
                                                    blurStyle: BlurStyle.outer,
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
                                                    left: 0, right: 16),
                                                width: 75,
                                                height: 75,
                                                child: Image.asset(
                                                  custvehlist[index].cv_make ==
                                                          'Mercedes Benz'
                                                      ? ImageConst.benz_ico
                                                      : custvehlist[index]
                                                                  .cv_make ==
                                                              'BMW'
                                                          ? ImageConst.bmw_ico
                                                          : custvehlist[index]
                                                                      .cv_make ==
                                                                  'Skoda'
                                                              ? ImageConst
                                                                  .skod_ico
                                                              : custvehlist[index]
                                                                          .cv_make ==
                                                                      'Audi'
                                                                  ? ImageConst
                                                                      .aud_ico
                                                                  : ImageConst
                                                                      .defcar_ico,
                                                ),
                                                padding:
                                                    EdgeInsets.all(width / 30),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              custvehlist[index]
                                                                  .cv_plate_number,
                                                              style: montserratSemiBold
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          14)),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            showConfirmDialogCustom(
                                                              context,
                                                              title:
                                                                  'Are you sure you want to delete this vehicle.?',
                                                              primaryColor:
                                                                  syanColor,
                                                              customCenterWidget:
                                                                  Image.asset(
                                                                      "assets/icons/car.png"),
                                                              onAccept: (v) {
                                                                vehicle_delete(
                                                                    custvehlist[
                                                                            index]
                                                                        .cv_id);
                                                              },
                                                            );
                                                          },
                                                          child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right: 8,
                                                                      top: 8),
                                                              child: Icon(
                                                                Icons.delete,
                                                                color: black,
                                                                size: 22,
                                                              )),
                                                        )
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
                                                                custvehlist[
                                                                            index]
                                                                        .cv_make +
                                                                    " " +
                                                                    custvehlist[
                                                                            index]
                                                                        .cv_model +
                                                                    " " +
                                                                    (custvehlist[index].cv_variant !=
                                                                            null
                                                                        ? custvehlist[index]
                                                                            .cv_variant
                                                                        : "") +
                                                                    " (" +
                                                                    custvehlist[
                                                                            index]
                                                                        .cv_year +
                                                                    ")",
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
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
                                                    custvehlist[index]
                                                                .cv_odometer !=
                                                            null
                                                        ? Row(
                                                            children: <Widget>[
                                                                Text(
                                                                    "Odometer:",
                                                                    style: montserratRegular.copyWith(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black)),
                                                                Text(
                                                                  custvehlist[index]
                                                                          .cv_odometer ??
                                                                      "",
                                                                  style: montserratRegular
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ])
                                                        : SizedBox(height: 0),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: white,
                                ),
                                height: context.height(),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      ImageConst.no_data_found,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ],
                                ),
                              ).center(),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VehicleAddPage()));
            },
            heroTag: 'Add Vehicle',
          )),
    );
  }
}

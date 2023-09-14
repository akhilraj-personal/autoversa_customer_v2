import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/address/address_list_screen.dart';
import 'package:autoversa/screens/service/service_list_screen.dart';
import 'package:autoversa/screens/settings/edit_profile.dart';
import 'package:autoversa/screens/support/support_screen.dart';
import 'package:autoversa/screens/vehicle/vehicle_list_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../constant/image_const.dart';
import '../../provider/provider.dart';
import '../../utils/common_utils.dart';

class ProfilePage extends StatefulWidget {
  final String click_root;
  const ProfilePage({required this.click_root, super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> custdetails = {};
  var vehcount = 0;
  String? nameProfile;

  @override
  void initState() {
    super.initState();
    init();
    getProfileDetails();
  }

  Future<void> init() async {
    //
  }

  getProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "cust_id":
          base64.encode(utf8.encode(prefs.getString("cust_id").toString()))
    };
    print(req);
    await getprofiledetails(req)
        .then((value) => {
              if (value['ret_data'] == "success")
                {
                  setState(() {
                    custdetails = value['cust_info'];
                    vehcount = value['veh_count'];
                  }),
                }
              else
                {}
            })
        .catchError((e) {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  logout_user() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, Routes.loginPage);
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
            "Settings",
            style: montserratSemiBold.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.bottombar);
            },
            icon: Icon(Icons.arrow_back,
                color: Colors.white, size: width * 0.054),
          ),
        ),
        body: SingleChildScrollView(
          child: WillPopScope(
            onWillPop: () {
              Navigator.pushReplacementNamed(context, Routes.bottombar);
              return Future.value(false);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                bottomRight: Radius.circular(16.0)),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: borderGreyColor),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(16.0))),
                              child: custdetails['cust_profile_pic'] != null &&
                                      custdetails['cust_profile_pic'] != ''
                                  ? CachedNetworkImage(
                                      placeholder: (context, url) =>
                                          Transform.scale(
                                        scale: 0.5,
                                        child: CircularProgressIndicator(),
                                      ),
                                      imageUrl: dotenv.env['aws_url']! +
                                          custdetails['cust_profile_pic'],
                                      height: width * 0.35,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      ImageConst.default_pro_pic,
                                      fit: BoxFit.contain,
                                      height: width * 0.35,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  custdetails['cust_fullname'] != null
                                      ? custdetails['cust_fullname']
                                      : "",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: 18, color: black)),
                              SizedBox(height: 4.0),
                              Text(
                                  custdetails['cust_phone'] != null
                                      ? custdetails['cust_country_code'] +
                                          custdetails['cust_phone']
                                      : " ",
                                  style: montserratRegular.copyWith(
                                      color: black, fontSize: width * 0.034)),
                              SizedBox(height: 4.0),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 4.0),
                                        child: RadiantGradientMask(
                                          child: Icon(Icons.location_on,
                                              color: syanColor, size: 18),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                        text: custdetails['state_name'] != null
                                            ? custdetails['state_name']
                                            : "",
                                        style: montserratRegular.copyWith(
                                            color: black)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        vehcount.toString(),
                                        style: montserratBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.05),
                                      ),
                                      Text(
                                        "Vehicle",
                                        style: montserratRegular.copyWith(
                                            color: black),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: width * 0.1,
                                    width: 0.5,
                                    color: Color(0xFFB4BBC2),
                                    margin: EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("0",
                                          style: montserratBold.copyWith(
                                              color: syanColor,
                                              fontSize: width * 0.05)),
                                      Text("Credits",
                                          style: montserratRegular.copyWith(
                                              color: black)),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("Edit Profile",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {
                      String? name = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Editprofie(
                              click_root: "editprofile",
                            );
                          },
                        ),
                      );
                      nameProfile = name;
                      setState(() {});
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.language,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("Preferred Language",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          // <-- SEE HERE
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        builder: (context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.language_outlined),
                                title: Text('English'),
                                onTap: () async {
                                  context
                                      .read<LanguageChangeProvider>()
                                      .changeLocale("en");
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.language_rounded),
                                title: Text('عربي'),
                                onTap: () async {
                                  context
                                      .read<LanguageChangeProvider>()
                                      .changeLocale("ar");
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {});
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.map,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("My Address",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {
                      String? name = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddressList(
                              click_id: 1,
                            );
                          },
                        ),
                      );
                      nameProfile = name;
                      setState(() {});
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.car_rental,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("My Vehicles",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {
                      String? name = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Vehiclelist(click_id: 2);
                          },
                        ),
                      );
                      nameProfile = name;
                      setState(() {});
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.build,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("My Services",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {
                      String? name = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ServiceList(click_id: 2);
                          },
                        ),
                      );
                      nameProfile = name;
                      setState(() {});
                    }),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Container(
                    //           alignment: Alignment.center,
                    //           margin: EdgeInsets.symmetric(vertical: 8),
                    //           padding: EdgeInsets.all(10),
                    //           decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             gradient: LinearGradient(
                    //               begin: Alignment.topRight,
                    //               end: Alignment.bottomRight,
                    //               colors: [
                    //                 lightblueColor,
                    //                 syanColor,
                    //               ],
                    //             ),
                    //           ),
                    //           child:
                    //               Icon(Icons.list, color: Colors.white, size: 20),
                    //         ),
                    //         16.width,
                    //         Text("My Invoices",
                    //             style: montserratSemiBold.copyWith()),
                    //       ],
                    //     ).paddingOnly(left: 16),
                    //     Icon(Icons.arrow_forward_ios, color: syanColor, size: 16)
                    //         .paddingOnly(right: 16),
                    //   ],
                    // ).onTap(() async {}),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.support_agent,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("Support",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {
                      String? name = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Support(click_id: 2);
                          },
                        ),
                      );
                      nameProfile = name;
                      setState(() {});
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              padding: EdgeInsets.all(10),
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
                              child: Icon(Icons.lock,
                                  color: Colors.white, size: 20),
                            ),
                            16.width,
                            Text("Privacy",
                                style: montserratSemiBold.copyWith()),
                          ],
                        ).paddingOnly(left: 16),
                        Icon(Icons.arrow_forward_ios,
                                color: syanColor, size: 16)
                            .paddingOnly(right: 16),
                      ],
                    ).onTap(() async {}),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         Container(
                    //           alignment: Alignment.center,
                    //           margin: EdgeInsets.symmetric(vertical: 8),
                    //           padding: EdgeInsets.all(10),
                    //           decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             gradient: LinearGradient(
                    //               begin: Alignment.topRight,
                    //               end: Alignment.bottomRight,
                    //               colors: [
                    //                 lightblueColor,
                    //                 syanColor,
                    //               ],
                    //             ),
                    //           ),
                    //           child: Icon(MaterialCommunityIcons.google_translate,
                    //               color: Colors.white, size: 20),
                    //         ),
                    //         16.width,
                    //         Text("Language",
                    //             style: montserratSemiBold.copyWith()),
                    //       ],
                    //     ).paddingOnly(left: 16),
                    //     Icon(Icons.arrow_forward_ios, color: syanColor, size: 16)
                    //         .paddingOnly(right: 16),
                    //   ],
                    // ).onTap(() async {
                    //   LanguageSelection()
                    //       .launch(context)
                    //       .then((value) => setState(() {}));
                    // }),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        primaryColor: syanColor,
                        title: "Do you want to logout from the app?",
                        onAccept: (v) {
                          logout_user();
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                      padding: EdgeInsets.only(left: 16),
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        color: signout_button,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24.0),
                          bottomRight: Radius.circular(24.0),
                        ),
                        border: Border.all(color: syanColor, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 24),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Text(
                              "Signout",
                              textAlign: TextAlign.start,
                              style: montserratSemiBold.copyWith(
                                  color: Colors.white, fontSize: width * 0.034),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

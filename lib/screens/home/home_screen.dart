import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/screens/NextScreen.dart';
import 'package:autoversa/utils/text_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/image_const.dart';
import '../../generated/l10n.dart';
import '../../services/post_auth_services.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

bool isExpanded = false;
bool isAdded = false;

class _HomeScreenState extends State<HomeScreen> {
  String cut_name = "";
  late List customerVehList = [];

  bool isVehicleLoaded = false;

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
    Future.delayed(Duration.zero, () {
      _getCustomerVehicles();
      // _getPackages();
      // _getCustomerBookingList();
    });
    init();
  }

  _getCustomerVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {"custId": prefs.getString("cust_id")};
    await getCustomerVehicles(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          customerVehList = value['vehList'];
          isVehicleLoaded = true;
        });
      }
    }).catchError((e) {
      showCustomToast(context, S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cut_name = prefs.getString('name')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            alignment: Alignment.bottomCenter,
                            width: width,
                            height: isExpanded == false
                                ? height * 0.4
                                : height * 0.7,
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
                            child:
                                ////--------------- ClipPath for curv----------
                                ClipPath(
                              clipper: SinCosineWaveClipper(
                                verticalPosition: VerticalPosition.top,
                              ),
                              child: Container(
                                height:
                                    isExpanded ? height * 0.61 : height * 0.31,
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
                                                    builder: (context) =>
                                                        NextPage()));
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
                                                text: S
                                                        .of(context)
                                                        .dash_intro_text +
                                                    " ",
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: whiteColor,
                                                        fontSize:
                                                            width * 0.034),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: cut_name,
                                                      style: montserratBold
                                                          .copyWith(
                                                              color: whiteColor,
                                                              fontSize: width *
                                                                  0.034)),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),

                                    ///--------- notification---------
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NextPage()));
                                      },
                                      child: Image.asset(
                                        ImageConst.notification,
                                        scale: 3.7,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              ///--------- my activity-------------
                              Container(
                                margin: EdgeInsets.only(
                                    top: height * 0.028,
                                    left: width * 0.04,
                                    right: width * 0.03,
                                    bottom: height * 0.02),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ///--------- my activity-------------
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: width * 0.02),
                                      child: Text(
                                        TextConst.myActive,
                                        style: montserratSemiBold.copyWith(
                                            color: whiteColor,
                                            fontSize: width * 0.04),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: height * 0.007),
                                      decoration: BoxDecoration(
                                          color: whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: EdgeInsets.only(
                                        left: width * 0.04,
                                        right: width * 0.03,
                                        top: height * 0.012,
                                        bottom: height * 0.012,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ///--------- first text -------------
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "DU 55566",
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            color: blackColor,
                                                            fontSize:
                                                                width * 0.034),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "Mercedes Benz",
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color: blackColor,
                                                              fontSize: width *
                                                                  0.034),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              ///--------- up down arrow -------------
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isExpanded = !isExpanded;
                                                  });
                                                },
                                                child: Image.asset(
                                                  isExpanded == true
                                                      ? ImageConst.upArrow
                                                      : ImageConst.downarrow,
                                                  scale: 4,
                                                ),
                                              )
                                            ],
                                          ),
                                          isExpanded == true
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ///--------- Regular Oil Service -------------
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: height * 0.03),
                                                      child: Text(
                                                        "Regular Oil Service (BK108)",
                                                        style: montserratRegular
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.037),
                                                      ),
                                                    ),

                                                    ///--------- Date -------------
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: height * 0.007,
                                                            bottom:
                                                                height * 0.007),
                                                        child: RichText(
                                                          text: TextSpan(
                                                            text: "Date: ",
                                                            style: montserratSemiBold.copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      '12-11-2022',
                                                                  style: montserratRegular.copyWith(
                                                                      color:
                                                                          blackColor,
                                                                      fontSize:
                                                                          width *
                                                                              0.034)),
                                                            ],
                                                          ),
                                                        )),

                                                    ///--------- time -------------
                                                    RichText(
                                                      text: TextSpan(
                                                        text: "Time: ",
                                                        style: montserratSemiBold
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text:
                                                                  '04:00 PM - 05:00 OM',
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          blackColor,
                                                                      fontSize:
                                                                          width *
                                                                              0.034)),
                                                        ],
                                                      ),
                                                    ),

                                                    ///--------- divider -------------
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: height * 0.02,
                                                          bottom: height * 0.02,
                                                          left: width * 0.01,
                                                          right: width * 0.01),
                                                      height: 1,
                                                      width: width,
                                                      color: greyColor,
                                                    ),

                                                    ///--------- currentOrder status -------------
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          bottom:
                                                              height * 0.008),
                                                      child: Text(
                                                        TextConst.currentOrder,
                                                        style: montserratSemiBold
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                      ),
                                                    ),

                                                    ///--------- car image -------------

                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          ImageConst.car,
                                                          scale: 4,
                                                        ),

                                                        ///--------- vehicle at workshop -------------

                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: width *
                                                                      0.02),
                                                          child: Text(
                                                            TextConst.vehicle,
                                                            style: montserratRegular.copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                          ),
                                                        )
                                                      ],
                                                    ),

                                                    ///--------- view details -------------

                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        NextPage()));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: height * 0.02,
                                                            bottom:
                                                                height * 0.01),
                                                        width: width / 3,
                                                        padding: EdgeInsets.all(
                                                            height * 0.014),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: lightGreyColor,
                                                          border: Border.all(
                                                              color: greyColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            height * 0.1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              TextConst.view,
                                                              style: montserratSemiBold
                                                                  .copyWith(
                                                                      color:
                                                                          blackColor,
                                                                      fontSize:
                                                                          width *
                                                                              0.034),
                                                            ),
                                                            Image.asset(
                                                              ImageConst
                                                                  .right_arrow,
                                                              color: greyColor,
                                                              scale: 4,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    //------------------vehicle ---------------
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.01,
                                          top: height * 0.02),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            TextConst.myVehicles,
                                            style: montserratSemiBold.copyWith(
                                                color: whiteColor,
                                                fontSize: width * 0.04),
                                          ),
                                          //------------------add new ---------------
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isAdded = !isAdded;
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
                                                          color: whiteColor,
                                                          fontSize:
                                                              width * 0.04),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: width * 0.02),
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Container(
                          height: customerVehList.length < 1 && isVehicleLoaded
                              ? height * 0.05
                              : height * 0.083),
                    ],
                  ),
                  //------------------vehicle card---------------
                  customerVehList.length < 2 && isVehicleLoaded
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: width * 0.08,
                                right: width * 0.08,
                              ),
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
                                      whiteColor,
                                      whiteColor,
                                      whiteColor,
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
                                          style: montserratSemiBold.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.034),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: height * 0.004,
                                              bottom: height * 0.004),
                                          child: Text(
                                            "Mercedes Benz",
                                            style: montserratRegular.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.034),
                                          ),
                                        ),
                                        Text(
                                          "E Class (2000)",
                                          style: montserratRegular.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.034),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: height * 0.004,
                                              bottom: height * 0.004),
                                          child: Text(
                                            "F 300",
                                            style: montserratRegular.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.034),
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
                              ),
                            ),
                          ],
                        )
                      : Container(
                          height: height * 0.2,
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                                left: width * 0.02, right: width * 0.02),
                            itemCount: 4,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  margin:
                                      EdgeInsets.only(bottom: height * 0.002),
                                  padding: EdgeInsets.only(
                                    left: width * 0.04,
                                    right: width * 0.08,
                                    top: height * 0.03,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        whiteColor,
                                        whiteColor,
                                        whiteColor,
                                        borderGreyColor,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DU 55566",
                                        style: montserratSemiBold.copyWith(
                                            color: blackColor,
                                            fontSize: width * 0.037),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: height * 0.004,
                                            bottom: height * 0.004),
                                        child: Text(
                                          "Mercedes Benz",
                                          style: montserratRegular.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.037),
                                        ),
                                      ),
                                      Text(
                                        "E Class (2000)",
                                        style: montserratRegular.copyWith(
                                            color: blackColor,
                                            fontSize: width * 0.037),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: height * 0.004,
                                            bottom: height * 0.004),
                                        child: Text(
                                          "F 300",
                                          style: montserratRegular.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.037),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: height * 0.01,
                                            bottom: height * 0.007),
                                        child: Image.asset(
                                          ImageConst.handel,
                                          scale: 9.5,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                  top: height * 0.03,
                  left: width * 0.04,
                  right: width * 0.04,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ////------------- Service------------
                    Text(
                      TextConst.services,
                      style: montserratSemiBold.copyWith(
                          color: blackColor, fontSize: width * 0.043),
                    ),
                    ////------------- Service Images ------------
                    GridView.count(
                      padding: EdgeInsets.only(top: height * 0.02),
                      shrinkWrap: true,
                      primary: false,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 17,
                      crossAxisCount: 2,
                      children: <Widget>[
                        commonWidget(ImageConst.img1, TextConst.oilService),
                        commonWidget(ImageConst.img2, TextConst.minorService),
                        commonWidget(ImageConst.img3, TextConst.majorService),
                        commonWidget(ImageConst.img4, TextConst.carRepair),
                      ],
                    ),
                    ////------------- addOnServices------------
                    Container(
                      margin: EdgeInsets.only(
                          top: height * 0.023, bottom: height * 0.01),
                      child: Text(
                        TextConst.addOnServices,
                        style: montserratSemiBold.copyWith(
                            color: blackColor, fontSize: width * 0.043),
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
                            TextConst.abcd,
                          ),
                          CommanService(
                            ImageConst.drive_car,
                            TextConst.abcd,
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NextPage()));
                            },
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    index == 0
                                        ? Text(
                                            TextConst.offerForYou,
                                            style: montserratSemiBold.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.043),
                                          )
                                        : Text(
                                            '',
                                            style: montserratSemiBold.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.043),
                                          ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: height * 0.017),
                                      height: height * 0.14,
                                      padding:
                                          EdgeInsets.only(left: width * 0.03),
                                      width: width / 1.7,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            syanColor,
                                            blueColor,
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
                                            style: montserratSemiBold.copyWith(
                                                color: whiteColor,
                                                fontSize: width * 0.053),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                ////------------- person image ------------
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(right: width * 0.03),
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
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.only(right: width * 0.03),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  commonWidget(String img, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NextPage()));
      },
      child: Container(
        padding: EdgeInsets.only(
            left: width * 0.03, right: width * 0.06, bottom: height * 0.027),
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(img)),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: montserratMedium.copyWith(
                    color: whiteColor, fontSize: width * 0.045),
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
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => NextPage()));
          },
          child: Container(
            padding: EdgeInsets.all(height * 0.023),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
                colors: [
                  blueColor,
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
                color: blackColor, fontSize: width * 0.033),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

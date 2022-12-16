import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/image_const.dart';
import '../../constant/text_style.dart';
import '../../generated/l10n.dart';
import '../../services/post_auth_services.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_utils.dart';
import '../../utils/text_utils.dart';
import '../NextScreen.dart';

class DashScreen extends StatefulWidget {
  const DashScreen({super.key});

  @override
  State<DashScreen> createState() => _DashScreenState();
}

class _DashScreenState extends State<DashScreen> {
  String cut_name = "";
  late List customerVehList = [];
  late List bookingList = [];
  late List packageList = [];
  String currency = "";

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
    Future.delayed(Duration.zero, () {
      _getCustomerVehicles();
      _getPackages();
      _getCustomerBookingList();
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

  _getCustomerBookingList() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {"custId": prefs.getString("cust_id")};
    await getCustomerBookingList(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          // bookingList = value['book_list'];
          isBookingLoaded = true;
        });
      } else {
        setState(() {
          isBookingLoaded = true;
          bookingList = [];
        });
      }
    }).catchError((e) {
      showCustomToast(context, S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
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
      showCustomToast(context, S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    }
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
                child: Column(children: [
          Stack(alignment: Alignment.bottomCenter, children: [
            Column(children: [
              Stack(children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  width: width,
                  height: isExpanded == false
                      ? bookingList.length > 0
                          ? height * 0.5
                          : height * 0.3
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
                      height: isExpanded
                          ? height * 0.61
                          : bookingList.length > 0
                              ? height * 0.28
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
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: height * 0.057,
                        left: width * 0.04,
                        right: width * 0.04),
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //-------------- welcome ---------
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NextPage()));
                              },
                              child: Image.asset(
                                ImageConst.person,
                                scale: 3.6,
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: width * 0.03),
                                child: RichText(
                                  text: TextSpan(
                                    text: S.of(context).dash_intro_text + " ",
                                    style: montserratRegular.copyWith(
                                        color: whiteColor,
                                        fontSize: width * 0.034),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: cut_name,
                                          style: montserratBold.copyWith(
                                              color: whiteColor,
                                              fontSize: width * 0.034)),
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
                                    builder: (context) => NextPage()));
                          },
                          child: Image.asset(
                            ImageConst.notification,
                            scale: 3.7,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: height * 0.01,
                        left: width * 0.04,
                        right: width * 0.03,
                        bottom: height * 0.02),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: width * 0.01, top: height * 0.02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      // isAdded = !isAdded;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        TextConst.addNew,
                                        style: montserratSemiBold.copyWith(
                                            color: whiteColor,
                                            fontSize: width * 0.04),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: width * 0.02),
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
                        ]),
                  ),
                ]),
              ]),
              Container(
                  height: isVehicleLoaded && customerVehList.length > 1
                      ? height * 0.08
                      : height * 0.05),
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
                              child: customerVehList.length == 0
                                  ? Container(
                                      height: height * 0.15,
                                      width: width,
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
                                            lightGreyColor,
                                            borderGreyColor
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            S.of(context).new_vehicle_text,
                                            style: montserratSemiBold.copyWith(
                                                color: blackColor,
                                                fontSize: 16),
                                          ),
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: blackColor,
                                            size: 40.0,
                                            semanticLabel:
                                                'Text to announce in accessibility modes',
                                          ),
                                        ],
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
                                              minHeight: height * 0.16),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
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
                                                    customerVehList[0]
                                                        ['cv_plate_number'],
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            color: blackColor,
                                                            fontSize:
                                                                width * 0.034),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: height * 0.004,
                                                        bottom: height * 0.004),
                                                    child: Text(
                                                      customerVehList[0]
                                                          ['cv_make'],
                                                      style: montserratRegular
                                                          .copyWith(
                                                              color: blackColor,
                                                              fontSize: width *
                                                                  0.034),
                                                    ),
                                                  ),
                                                  Text(
                                                    customerVehList[0]
                                                            ['cv_model'] +
                                                        " (" +
                                                        customerVehList[0]
                                                            ['cv_year'] +
                                                        ")",
                                                    style: montserratRegular
                                                        .copyWith(
                                                            color: blackColor,
                                                            fontSize:
                                                                width * 0.034),
                                                  ),
                                                  customerVehList[0]
                                                              ['cv_variant'] !=
                                                          null
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: height *
                                                                      0.004,
                                                                  bottom:
                                                                      height *
                                                                          0.004),
                                                          child: Text(
                                                            customerVehList[0]
                                                                ['cv_variant'],
                                                            style: montserratRegular.copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              Image.asset(
                                                ImageConst.handel,
                                                scale: 4,
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
                              left: width * 0.02, right: width * 0.02),
                          itemCount: customerVehList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  width: customerVehList.length == 2
                                      ? width * 0.44
                                      : width * 0.4,
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
                                        customerVehList[index]
                                            ['cv_plate_number'],
                                        style: montserratSemiBold.copyWith(
                                            color: blackColor,
                                            fontSize: width * 0.037),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: height * 0.004,
                                            bottom: height * 0.004),
                                        child: Text(
                                          customerVehList[index]['cv_make'],
                                          overflow: TextOverflow.ellipsis,
                                          style: montserratRegular.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.037),
                                        ),
                                      ),
                                      Text(
                                        customerVehList[index]['cv_model'] +
                                            " (" +
                                            customerVehList[index]['cv_year'] +
                                            ")",
                                        style: montserratRegular.copyWith(
                                            color: blackColor,
                                            fontSize: width * 0.034),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: height * 0.004,
                                            bottom: height * 0.004),
                                        child: Text(
                                          customerVehList[index]
                                                      ['cv_variant'] !=
                                                  null
                                              ? customerVehList[index]
                                                  ['cv_variant']
                                              : "",
                                          overflow: TextOverflow.ellipsis,
                                          style: montserratRegular.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.026),
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
                                      customerVehList[index]['cv_make'] ==
                                              'Mercedes Benz'
                                          ? ImageConst.benz_ico
                                          : customerVehList[index]['cv_make'] ==
                                                  'BMW'
                                              ? ImageConst.bmw_ico
                                              : customerVehList[index]
                                                          ['cv_make'] ==
                                                      'Skoda'
                                                  ? ImageConst.skod_ico
                                                  : customerVehList[index]
                                                              ['cv_make'] ==
                                                          'Audi'
                                                      ? ImageConst.aud_ico
                                                      : ImageConst.defcar_ico,
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
                                  whiteColor,
                                  whiteColor,
                                  whiteColor,
                                  borderGreyColor,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: blackColor, fontSize: width * 0.043),
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
                                mainAxisSpacing: 2),
                        itemCount: packageList.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return commonWidget(
                              dotenv.env['aws_url']! +
                                  this.packageList[index]['pkg_imageUrl'],
                              this.packageList[index]['pkg_name'],
                              true);
                        })
                    : Shimmer.fromColors(
                        baseColor: lightGreyColor,
                        highlightColor: greyColor,
                        child: Column(children: [
                          GridView.count(
                            padding: EdgeInsets.only(top: height * 0.02),
                            shrinkWrap: true,
                            primary: false,
                            crossAxisSpacing: 25,
                            mainAxisSpacing: 17,
                            crossAxisCount: 2,
                            children: <Widget>[
                              commonWidget(ImageConst.img1, "Sample", false),
                              commonWidget(ImageConst.img1, "Sample", false),
                              commonWidget(ImageConst.img1, "Sample", false),
                              commonWidget(ImageConst.img1, "Sample", false),
                            ],
                          )
                        ])),
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
                                  margin: EdgeInsets.only(top: height * 0.017),
                                  height: height * 0.14,
                                  padding: EdgeInsets.only(left: width * 0.03),
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
              ])),
        ]))));
  }

  commonWidget(String img, String text, bool type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NextPage()));
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

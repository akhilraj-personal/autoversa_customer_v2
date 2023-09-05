import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/package_screens/package_details_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class HomeVehicleListClick extends StatefulWidget {
  final String vehicle_id;
  final int selectedVeh;
  const HomeVehicleListClick(
      {required this.vehicle_id, required this.selectedVeh, super.key});

  @override
  State<HomeVehicleListClick> createState() => HomeVehicleListClickState();
}

class HomeVehicleListClickState extends State<HomeVehicleListClick> {
  late Map<String, dynamic> vehicledetails = {};
  int indexTop = 0;
  double valueBottom = 20;
  bool isPackageLoaded = false;
  late List packageList = [];
  late List customerVehList = [];
  late List bookingList = [];
  String currency = "";
  bool noofvehicle = false;
  int selectedVeh = 0;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      CustomerVehicleDetails();
      _getCustomerBookingList();
      _getCustomerVehicles();
      _getPackages();
    });
    super.initState();
  }

  _getPackages() async {
    try {
      Map req = {};
      await getPackages(req).then((value) {
        if (value['ret_data'] == "success") {
          setState(() {
            packageList = value['package_list']
                .where((pkg) => pkg['pkg_type'] == "1")
                .toList();
            currency = value['currency']['cy_code'];
            isPackageLoaded = true;
          });
        }
      });
    } catch (e) {
      isPackageLoaded = false;
      showCustomToast(context, lang.S.of(context).toast_application_error,
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
        });
      }
    }).catchError((e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  CustomerVehicleDetails() async {
    await getCustomerVehicleDetails(widget.vehicle_id).then((value) async {
      if (value['ret_data'] == "success") {
        vehicledetails = value['vehicle_details'];
        setState(() {});
      }
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
            });
          }
        }
      } else {
        setState(() {
          bookingList = [];
        });
      }
    }).catchError((e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
  }

  redirectPackage(pack_details, pack_typ, currency, noofvehicle) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PackageDetails(
                  package_id: pack_details,
                  custvehlist: customerVehList,
                  currency: currency,
                  selectedVeh: widget.selectedVeh,
                  booking_list: bookingList,
                  pack_type: 1,
                )));
  }

  @override
  void dispose() {
    super.dispose();
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
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  width: width,
                  height: height * 0.2,
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
                      height: height * 0.1,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.fromLTRB(
                          16.5, height * 0.07, height * 0.07, 16.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, Routes.bottombar);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: width * 0.054,
                            ),
                          ),
                          SizedBox(width: width * 0.08),
                          Text(
                            "Vehicle Details",
                            style: montserratRegular.copyWith(
                              fontSize: width * 0.044,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              16.0, height * 0.01, 16.0, 16.0),
                          padding: EdgeInsets.all(12),
                          height: height * 0.045,
                          width: height * 0.37,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 12,
                                    color: syanColor.withOpacity(.5),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.outer,
                                    offset: Offset(0, 0)),
                              ]),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              16.0, height * 0.01, 16.0, 16.0),
                          padding: EdgeInsets.all(8),
                          width: width * 1.85,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(8)),
                              if (vehicledetails['cv_make'] ==
                                  'Mercedes Benz') ...[
                                Image.asset(
                                  ImageConst.benz_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicledetails['cv_make'] ==
                                  'BMW') ...[
                                Image.asset(
                                  ImageConst.bmw_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicledetails['cv_make'] ==
                                  'Skoda') ...[
                                Image.asset(
                                  ImageConst.skod_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicledetails['cv_make'] ==
                                  'Audi') ...[
                                Image.asset(
                                  ImageConst.aud_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicledetails['cv_make'] ==
                                  'Porsche') ...[
                                Image.asset(
                                  ImageConst.porsche_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicledetails['cv_make'] ==
                                  'Volkswagen') ...[
                                Image.asset(
                                  ImageConst.volkswagen_icon,
                                  width: width * 0.12,
                                ),
                              ] else ...[
                                Image.asset(
                                  ImageConst.defcar_ico,
                                  width: width * 0.12,
                                ),
                              ],
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 8),
                                      vehicledetails['cv_plate_number'] != "" &&
                                              vehicledetails[
                                                      'cv_plate_number'] !=
                                                  null
                                          ? Text(
                                              vehicledetails['cv_plate_number']
                                                  .toUpperCase(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: black,
                                                      fontSize: width * 0.04),
                                              maxLines: 2)
                                          : SizedBox(),
                                      Text(
                                        vehicledetails['cv_make'] != null
                                            ? vehicledetails['cv_variant'] !=
                                                    null
                                                ? vehicledetails['cv_make'] +
                                                    " " +
                                                    vehicledetails['cv_model'] +
                                                    " " +
                                                    vehicledetails[
                                                        'cv_variant'] +
                                                    " (" +
                                                    vehicledetails['cv_year'] +
                                                    ")"
                                                : vehicledetails['cv_make'] +
                                                    " " +
                                                    vehicledetails['cv_model'] +
                                                    " (" +
                                                    vehicledetails['cv_year'] +
                                                    ")"
                                            : "",
                                        textAlign: TextAlign.start,
                                        style: montserratMedium.copyWith(
                                          fontSize: width * 0.034,
                                          overflow: TextOverflow.clip,
                                          color: black,
                                        ),
                                      ),
                                      vehicledetails['cv_odometer'] != "" &&
                                              vehicledetails['cv_odometer'] !=
                                                  null
                                          ? Text(
                                              vehicledetails['cv_odometer']
                                                  .toUpperCase(),
                                              style: montserratMedium.copyWith(
                                                  color: black,
                                                  fontSize: width * 0.034),
                                              maxLines: 2)
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 22.0, left: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Odometer Reading",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    8.height,
                    Container(
                      margin: EdgeInsets.only(right: 22.0, left: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Odometer year/range & will recommend services",
                            style: montserratMedium.copyWith(
                                color: black.withOpacity(0.5),
                                fontSize: width * 0.03),
                          ),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          buildSliderTopLabel(),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 22.0, left: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recommended Services",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    8.height,
                    Container(
                      margin: EdgeInsets.only(right: 22.0, left: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                "● With the first visit at approximately 10,000 miles or 1 years whichever comes first and then approximately every 20,000 miles or 2 years we suggest Minor Service",
                                style: montserratMedium.copyWith(
                                    color: black, fontSize: width * 0.03),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    4.height,
                    Container(
                      margin: EdgeInsets.only(right: 22.0, left: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                "● With the first visit at approximately 20,000 miles or 1 year after the previous service - and then approximately every 20,000 miles or 2 years after that we suggest Major Service",
                                style: montserratMedium.copyWith(
                                    color: black, fontSize: width * 0.03),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.height,
                    Container(
                      margin: EdgeInsets.only(right: 22.0, left: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Our Services",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: height * 0.02,
                        left: width * 0.04,
                        right: width * 0.04,
                      ),
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSliderTopLabel() {
    final labels = [
      "1YR/10K",
      "2YR/20K",
      "3YR/30K",
      "4YR/40K",
      "5YR/50K",
      "6YR/60K",
      "7YR/70K",
      "8YR/80K",
      "9YR/90K",
      "10YR/100K"
    ];
    final double min = 0;
    final double max = labels.length - 1.0;
    final divisions = labels.length - 1;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(right: 22.0, left: 22.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: Utils.modelBuilder(
              labels,
              (index, label) {
                final selectedColor = Colors.black;
                final unselectedColor = Colors.black.withOpacity(0.3);
                final isSelected = index <= indexTop;
                final color = isSelected ? selectedColor : unselectedColor;

                return buildLabel(label: label, color: color, width: 30);
              },
            ),
          ),
        ),
        SliderTheme(
            data: SliderThemeData(
                activeTrackColor: syanColor,
                inactiveTrackColor: syanColor.withOpacity(0.1),
                thumbColor: syanColor,
                valueIndicatorColor: syanColor,
                activeTickMarkColor: Colors.transparent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Slider(
                    value: indexTop.toDouble(),
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: (double value) {
                      setState(() => this.indexTop = value.toInt());
                    })
              ],
            )),
      ],
    );
  }

  Widget buildLabel({
    required String label,
    required double width,
    required Color color,
  }) =>
      Container(
        width: width,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: montserratLight
              .copyWith(
                fontSize: width * 0.335,
                fontWeight: FontWeight.bold,
              )
              .copyWith(color: color),
        ),
      );

  Widget buildSideLabel(double value) => Container(
        width: 25,
        child: Text(
          value.round().toString(),
          style: montserratLight.copyWith(
              fontSize: width * 0.335, fontWeight: FontWeight.bold),
        ),
      );

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
}

class Utils {
  static List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();
}

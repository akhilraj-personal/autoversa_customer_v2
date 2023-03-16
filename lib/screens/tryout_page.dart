import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/address/address_add_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => AddressListState();
}

class AddressListState extends State<AddressList> {
  late List custAddressList = [];
  late List stateList = [];
  late List citylist = [];
  late List areaList = [];
  List<String?> SelectAddressList = <String?>["Select Address"];
  List<String?> SelectCityList = <String?>["Select City"];
  List<String?> SelectAreaList = <String?>["Select Area"];
  final GlobalKey<FormFieldState> addAddressArea = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> addAddressCity = GlobalKey<FormFieldState>();
  var emirates = 0, city = 0;
  var AddressType = "Home";
  var Statelat = "24.3547";
  var Statelong = "54.5020";
  var Marklat = 0.0;
  var Marklong = 0.0;
  var address = "";
  var landmark = "";
  bool isDefaultAddressChecked = true;
  bool isActive = true;
  List<Marker> myMarker = [];
  final _formKey = GlobalKey<FormState>();
  bool isgooglemap = false;
  FocusNode addressFocus = FocusNode();
  FocusNode landmarkFocusNode = FocusNode();
  final GlobalKey<FormFieldState> areaKey = GlobalKey<FormFieldState>();

  final TextEditingController textEditingController = TextEditingController();
  bool issubmitted = false;
  bool isproceeding = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      addressList();
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

  addressList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map req = {"customerId": prefs.getString('cust_id')};
      custAddressList = [];
      await getCustomerAddresses(req).then((value) {
        if (value['ret_data'] == "success") {
          custAddressList = value['cust_addressList'];
          for (var address in value['cust_addressList']) {
            SelectAddressList.add(address['cad_address'] +
                "\n" +
                address['city_name'] +
                ", " +
                address['state_name'] +
                ", " +
                address['country_code']);
          }
          setState(() {
            isActive = false;
          });
        } else {
          setState(() {
            isActive = false;
          });
        }
      });
      Map country = {
        "countryId": 1,
      };
      await getStateList(country).then((value) {
        if (value['ret_data'] == "success") {
          stateList = value['statelist'];
          for (var state in value['statelist']) {
            SelectCityList.add(state['state_name']);
          }
        }
      });
      setState(() {});
    } catch (e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    }
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
            "Address List",
            style: montserratSemiBold.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
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
                      child: custAddressList.length > 0
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              itemCount: custAddressList.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(17.5),
                                          padding: EdgeInsets.all(8.5),
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
                                            margin: EdgeInsets.all(12.0),
                                            padding: EdgeInsets.all(8.0),
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
                                                SizedBox(width: 16.0),
                                                Image.asset(
                                                    ImageConst.adrresslist_logo,
                                                    width: width / 8,
                                                    height: 50),
                                                SizedBox(width: 16.0),
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Flexible(
                                                            child:
                                                                new Container(
                                                              padding:
                                                                  new EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          13.0),
                                                              child: new Text(
                                                                custAddressList[index]
                                                                            [
                                                                            'cad_address'] !=
                                                                        null
                                                                    ? custAddressList[
                                                                            index]
                                                                        [
                                                                        'cad_address']
                                                                    : "",
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                style:
                                                                    new TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color: black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      4.height,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                              custAddressList[index]
                                                                          [
                                                                          'state_name'] !=
                                                                      null
                                                                  ? "City" +
                                                                      ": " +
                                                                      custAddressList[
                                                                              index]
                                                                          [
                                                                          'state_name']
                                                                  : "",
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12)),
                                                        ],
                                                      ),
                                                      4.height,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                              custAddressList[index]
                                                                          [
                                                                          'city_name'] !=
                                                                      null
                                                                  ? "Area" +
                                                                      ": " +
                                                                      custAddressList[
                                                                              index]
                                                                          [
                                                                          'city_name']
                                                                  : "",
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12)),
                                                        ],
                                                      ),
                                                      4.height,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                              custAddressList[
                                                                              index][
                                                                          'cad_landmark'] !=
                                                                      null
                                                                  ? "Building Name/Flat No" +
                                                                      ": " +
                                                                      custAddressList[
                                                                              index]
                                                                          [
                                                                          'cad_landmark']
                                                                  : "",
                                                              maxLines: 5,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textDirection:
                                                                  TextDirection
                                                                      .rtl,
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12)),
                                                        ],
                                                      ),
                                                      4.height,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                              custAddressList[index]
                                                                          [
                                                                          'cad_address_type'] !=
                                                                      null
                                                                  ? "Type" +
                                                                      ": " +
                                                                      custAddressList[
                                                                              index]
                                                                          [
                                                                          'cad_address_type']
                                                                  : "",
                                                              style: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          13)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ],
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
                                      right: width * 0.04),
                                  height: height * 0.18,
                                  decoration: BoxDecoration(
                                      color: white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12)),
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
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Container(
                                                    child: Text("NO SAVED ADDRESS",
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
                gradient: LinearGradient(colors: [lightblueColor, syanColor])),
          ),
          onPressed: () async {
            PermissionStatus locationStatus =
                await Permission.location.request();
            if (locationStatus == PermissionStatus.denied) {
              showCustomToast(context,
                  "This Permission is recommended for location access.",
                  bgColor: errorcolor, textColor: white);
            }
            if (locationStatus == PermissionStatus.permanentlyDenied) {
              openAppSettings();
            }
            if (locationStatus == PermissionStatus.granted) {
              Completer<GoogleMapController> _controller = Completer();
              showModalBottomSheet(
                enableDrag: true,
                isDismissible: true,
                isScrollControlled: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (builder) {
                  return StatefulBuilder(builder: (BuildContext context,
                      StateSetter setBottomState /*You can rename this!*/) {
                    CameraPosition _initialPosition = CameraPosition(
                        target: LatLng(24.3547, 54.5020), zoom: 13);
                    getcitylist(data) async {
                      if (SelectCityList.indexOf(data) > 0) {
                        var temp = citylist[SelectCityList.indexOf(data) - 1];
                        emirates = int.parse(temp['state_id']);
                        Map state = {
                          "stateId": temp['state_id'],
                        };
                        CameraPosition _kLake = CameraPosition(
                          target: LatLng(double.parse(temp['state_lattitude']),
                              double.parse(temp['state_longitude'])),
                          zoom: 13.4746,
                        );
                        final GoogleMapController controller =
                            await _controller.future;
                        controller
                            .moveCamera(CameraUpdate.newCameraPosition(_kLake));
                        setBottomState(() {
                          Statelat = temp['state_lattitude'];
                          Statelong = temp['state_longitude'];
                          SelectAreaList = <String?>["Select Area"];
                          addAddressArea.currentState?.reset();
                        });
                        SelectAreaList.length = 1;
                        await getCityList(state).then((value) {
                          if (value['ret_data'] == "success") {
                            setBottomState(() {
                              areaList = [];
                              SelectAreaList = <String?>["Select Area"];
                            });
                            areaList = value['citylist'];
                            for (var city in value['citylist']) {
                              SelectAreaList.add(city['city_name']);
                            }
                          }
                        });
                        setBottomState(() {});
                      }
                    }

                    getarealist(data) async {
                      // areaKey.currentState!.reset();
                      if (SelectAreaList.indexOf(data.toString()) > 0) {
                        setBottomState(() {});
                        var temp = areaList[
                            SelectAreaList.indexOf(data.toString()) - 1];
                        CameraPosition _kLake = CameraPosition(
                          target: LatLng(double.parse(temp['city_lattitude']),
                              double.parse(temp['city_longitude'])),
                          zoom: 15.4746,
                        );
                        final GoogleMapController controller =
                            await _controller.future;
                        controller
                            .moveCamera(CameraUpdate.newCameraPosition(_kLake));
                        setBottomState(() {
                          city = int.parse(temp['city_id']);
                          Statelat = temp['city_lattitude'];
                          Statelong = temp['city_longitude'];
                        });
                      }
                    }

                    return DraggableScrollableSheet(
                      initialChildSize: 0.6,
                      minChildSize: 0.2,
                      maxChildSize: 1,
                      builder: (context, scrollController) {
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: defaultBoxShadow(),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                                    width: width * 1.85,
                                    decoration: BoxDecoration(
                                      color: context.cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: defaultBoxShadow(),
                                    ),
                                    duration: 1000.milliseconds,
                                    curve: Curves.linearToEaseOut,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          child: Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: context.cardColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8))),
                                                child: Column(
                                                  children: [
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Container(
                                                            child: Text(
                                                              "Select City" +
                                                                  "*",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                      color:
                                                                          black),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    8.height,
                                                    DropdownButtonFormField2(
                                                      value: SelectCityList[0],
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      decoration:
                                                          InputDecoration(
                                                        //Add isDense true and zero Padding.
                                                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xffCCCCCC),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xffCCCCCC),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xffCCCCCC),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xfffff),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        errorStyle: TextStyle(
                                                          fontSize: 12,
                                                          color: warningcolor,
                                                        ),
                                                        //Add more decoration as you want here
                                                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                      ),
                                                      isExpanded: true,
                                                      hint: Text(
                                                        "Select City" + "*",
                                                        style: montserratMedium
                                                            .copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    width *
                                                                        0.04),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      buttonHeight:
                                                          height * 0.075,
                                                      buttonPadding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 10),
                                                      dropdownDecoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      items: SelectCityList.map(
                                                          (String? value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value!,
                                                            style: montserratMedium
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        width *
                                                                            0.04),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setBottomState(() {
                                                          isgooglemap = true;
                                                        });
                                                        getcitylist(value);
                                                      },
                                                    ),
                                                    8.height,
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Container(
                                                            child: Text(
                                                              "Select Area" +
                                                                  "*",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          width *
                                                                              0.034),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    8.height,
                                                    DropdownButtonFormField2(
                                                      key: addAddressArea,
                                                      value: SelectAreaList[0],
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      decoration:
                                                          InputDecoration(
                                                        //Add isDense true and zero Padding.
                                                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xffCCCCCC),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xffCCCCCC),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xffCCCCCC),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          // width: 0.0 produces a thin "hairline" border
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: const Color(
                                                                      0xfffff),
                                                                  width: 0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        errorStyle: TextStyle(
                                                          fontSize: 12,
                                                          color: warningcolor,
                                                        ),
                                                        //Add more decoration as you want here
                                                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                      ),
                                                      isExpanded: true,
                                                      hint: Text(
                                                        "Select Area" + "*",
                                                        style: montserratMedium
                                                            .copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    width *
                                                                        0.04),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      buttonHeight:
                                                          height * 0.075,
                                                      buttonPadding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 10),
                                                      dropdownDecoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      items: SelectAreaList.map(
                                                          (String? value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value!,
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          width *
                                                                              0.04)),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        getarealist(value);
                                                      },
                                                      searchController:
                                                          textEditingController,
                                                      searchInnerWidgetHeight:
                                                          height * 0.07,
                                                      searchInnerWidget:
                                                          Container(
                                                        height: height * 0.07,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 8,
                                                          bottom: 4,
                                                          right: 8,
                                                          left: 8,
                                                        ),
                                                        child: TextFormField(
                                                          expands: true,
                                                          maxLines: null,
                                                          controller:
                                                              textEditingController,
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 10,
                                                              vertical: 8,
                                                            ),
                                                            hintText:
                                                                'Search area...',
                                                            hintStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          syanColor,
                                                                      width:
                                                                          0.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      searchMatchFn:
                                                          (item, searchValue) {
                                                        return (item.value
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(searchValue
                                                                .toLowerCase()));
                                                      },
                                                      //This to clear the search value when you close the menu
                                                      onMenuStateChange:
                                                          (isOpen) {
                                                        if (!isOpen) {
                                                          textEditingController
                                                              .clear();
                                                        }
                                                      },
                                                    ),
                                                    8.height,
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Container(
                                                            child: Text(
                                                              "Address",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                      color:
                                                                          black),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    8.height,
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            16)),
                                                            color: white),
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          minLines: 1,
                                                          maxLines: 2,
                                                          maxLength: 80,
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          style: montserratMedium
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      width *
                                                                          0.04),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              address = value;
                                                            });
                                                          },
                                                          validator: (value) {
                                                            return addressValidation(
                                                                value, context);
                                                          },
                                                          onFieldSubmitted:
                                                              (value) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    landmarkFocusNode);
                                                          },
                                                          focusNode:
                                                              addressFocus,
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          decoration:
                                                              InputDecoration(
                                                                  counterText:
                                                                      "",
                                                                  hintText:
                                                                      "Address",
                                                                  hintStyle: montserratMedium.copyWith(
                                                                      color:
                                                                          greyColor,
                                                                      fontSize:
                                                                          width *
                                                                              0.04),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: const BorderSide(
                                                                        color:
                                                                            black,
                                                                        width:
                                                                            0.5),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: const BorderSide(
                                                                        color:
                                                                            black,
                                                                        width:
                                                                            0.5),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  )),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    ),
                                                    12.height,
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Container(
                                                            child: Text(
                                                              "Building Name/Flat No",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                      color:
                                                                          black),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    8.height,
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            16)),
                                                            color: white),
                                                        child: TextFormField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            minLines: 1,
                                                            maxLength: 50,
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            style: montserratMedium
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize: width *
                                                                        0.04),
                                                            onChanged: (value) {
                                                              if (value != "") {
                                                                var ret =
                                                                    buildingValidation(
                                                                        value);
                                                                if (ret ==
                                                                    null) {
                                                                  setState(() {
                                                                    landmark =
                                                                        value;
                                                                  });
                                                                } else {
                                                                  showCustomToast(
                                                                      context,
                                                                      "Enter valid details",
                                                                      bgColor:
                                                                          errorcolor,
                                                                      textColor:
                                                                          white);
                                                                }
                                                              }
                                                            },
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .sentences,
                                                            decoration:
                                                                InputDecoration(
                                                                    counterText:
                                                                        "",
                                                                    hintText:
                                                                        "Building Name/Flat No",
                                                                    hintStyle: montserratMedium.copyWith(
                                                                        color:
                                                                            greyColor,
                                                                        fontSize:
                                                                            width *
                                                                                0.04),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: const BorderSide(
                                                                          color:
                                                                              black,
                                                                          width:
                                                                              0.5),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: const BorderSide(
                                                                          color:
                                                                              black,
                                                                          width:
                                                                              0.5),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ))),
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    ),
                                                    8.height,
                                                    Wrap(
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .center,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        direction:
                                                            Axis.horizontal,
                                                        children: [
                                                          Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                                    unselectedWidgetColor:
                                                                        syanColor),
                                                            child: Radio(
                                                              value: 'Home',
                                                              groupValue:
                                                                  AddressType,
                                                              fillColor: MaterialStateColor
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          syanColor),
                                                              onChanged:
                                                                  (dynamic
                                                                      value) {
                                                                setBottomState(
                                                                    () {
                                                                  AddressType =
                                                                      value;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          Text("Home",
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                      color:
                                                                          black)),
                                                          Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                              unselectedWidgetColor:
                                                                  syanColor,
                                                            ),
                                                            child: Radio(
                                                              value: 'Office',
                                                              groupValue:
                                                                  AddressType,
                                                              fillColor: MaterialStateColor
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          syanColor),
                                                              onChanged:
                                                                  (dynamic
                                                                      value) {
                                                                setBottomState(
                                                                    () {
                                                                  AddressType =
                                                                      value;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          Text("Office",
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                      color:
                                                                          black)),
                                                          Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                                    unselectedWidgetColor:
                                                                        syanColor),
                                                            child: Radio(
                                                              value: 'Other',
                                                              groupValue:
                                                                  AddressType,
                                                              fillColor: MaterialStateColor
                                                                  .resolveWith(
                                                                      (states) =>
                                                                          syanColor),
                                                              onChanged:
                                                                  (dynamic
                                                                      value) {
                                                                setBottomState(
                                                                    () {
                                                                  AddressType =
                                                                      value;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          Text("Other",
                                                              style: montserratMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          width *
                                                                              0.034,
                                                                      color:
                                                                          black)),
                                                        ]),
                                                    8.height,
                                                    isgooglemap
                                                        ? Column(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    Container(
                                                                  child: Text(
                                                                    "Tap to mark",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: montserratMedium.copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.034,
                                                                        color:
                                                                            black),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Row(),
                                                    8.height,
                                                    isgooglemap
                                                        ? isMobile
                                                            ? Container(
                                                                height: 130,
                                                                width: width,
                                                                color: white,
                                                                child:
                                                                    GoogleMap(
                                                                  initialCameraPosition:
                                                                      _initialPosition,
                                                                  myLocationButtonEnabled:
                                                                      true,
                                                                  onMapCreated:
                                                                      (GoogleMapController
                                                                          controller) {
                                                                    _controller
                                                                        .complete(
                                                                            controller);
                                                                  },
                                                                ),
                                                              )
                                                            : Container(
                                                                color: Colors
                                                                    .transparent,
                                                                height: context
                                                                    .height(),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                width: width,
                                                                child: Text(
                                                                    "Google Map",
                                                                    style: montserratRegular.copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.034)),
                                                              )
                                                        : Row(),
                                                    8.height,
                                                    Row(
                                                      children: <Widget>[
                                                        Checkbox(
                                                          value:
                                                              isDefaultAddressChecked,
                                                          fillColor:
                                                              MaterialStateProperty
                                                                  .all(
                                                                      syanColor),
                                                          onChanged: (value) {
                                                            setBottomState(
                                                              () {
                                                                isDefaultAddressChecked =
                                                                    value!;
                                                              },
                                                            );
                                                          },
                                                        ),
                                                        Text(
                                                          "Set as default address",
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow:
                                                              TextOverflow.clip,
                                                          style:
                                                              montserratMedium
                                                                  .copyWith(
                                                            fontSize: 12,
                                                            color: black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    26.height,
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (emirates == 0) {
                                                          setState(() =>
                                                              issubmitted =
                                                                  false);
                                                          showCustomToast(
                                                              context,
                                                              "Select City",
                                                              bgColor:
                                                                  errorcolor,
                                                              textColor: white);
                                                        } else if (city == 0) {
                                                          setState(() =>
                                                              issubmitted =
                                                                  false);
                                                          showCustomToast(
                                                              context,
                                                              "Select Area",
                                                              bgColor:
                                                                  errorcolor,
                                                              textColor: white);
                                                        } else if (address ==
                                                            "") {
                                                          setState(() =>
                                                              issubmitted =
                                                                  false);
                                                          showCustomToast(
                                                              context,
                                                              "Enter Address",
                                                              bgColor:
                                                                  errorcolor,
                                                              textColor: white);
                                                        } else {
                                                          final prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          try {
                                                            setState(() =>
                                                                issubmitted =
                                                                    true);
                                                            await Future.delayed(
                                                                Duration(
                                                                    milliseconds:
                                                                        1000));
                                                            Map req = {
                                                              "countryId": 1,
                                                              "stateId":
                                                                  emirates,
                                                              "cityId": city,
                                                              "address":
                                                                  address,
                                                              "landmark":
                                                                  landmark,
                                                              "add_type":
                                                                  AddressType,
                                                              "lattitude":
                                                                  Marklat != 0.0
                                                                      ? Marklat
                                                                      : Statelat,
                                                              "longitude":
                                                                  Marklong !=
                                                                          0.0
                                                                      ? Marklong
                                                                      : Statelong,
                                                              "cust_id": prefs
                                                                  .getString(
                                                                      "cust_id")
                                                            };
                                                            await saveCustomerAddress(
                                                                    req)
                                                                .then((value) {
                                                              if (value[
                                                                      'ret_data'] ==
                                                                  "success") {
                                                                emirates = 0;
                                                                city = 0;
                                                                address = "";
                                                                landmark = "";
                                                                issubmitted =
                                                                    false;
                                                                Marklat = 0.0;
                                                                Marklong = 0.0;
                                                                AddressType =
                                                                    "Home";
                                                                setBottomState(
                                                                    () {
                                                                  addAddressCity
                                                                      .currentState
                                                                      ?.reset();
                                                                  addAddressArea
                                                                      .currentState
                                                                      ?.reset();
                                                                  SelectCityList =
                                                                      <String?>[
                                                                    "Select City"
                                                                  ];
                                                                  SelectAreaList =
                                                                      <String?>[
                                                                    "Select Area"
                                                                  ];
                                                                });
                                                                setState(() {});
                                                                addressList();
                                                                setState(() =>
                                                                    isgooglemap =
                                                                        false);
                                                                setState(() =>
                                                                    issubmitted =
                                                                        false);
                                                              } else {
                                                                setState(() =>
                                                                    issubmitted =
                                                                        false);
                                                              }
                                                            });
                                                          } catch (e) {
                                                            setState(() =>
                                                                issubmitted =
                                                                    false);
                                                            print(e.toString());
                                                          }
                                                          finish(context);
                                                        }
                                                      },
                                                      child: Stack(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        children: [
                                                          Container(
                                                            height:
                                                                height * 0.045,
                                                            width:
                                                                height * 0.37,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      blurRadius:
                                                                          16,
                                                                      color: syanColor
                                                                          .withOpacity(
                                                                              .6),
                                                                      spreadRadius:
                                                                          0,
                                                                      blurStyle:
                                                                          BlurStyle
                                                                              .outer,
                                                                      offset:
                                                                          Offset(
                                                                              0,
                                                                              0)),
                                                                ]),
                                                          ),
                                                          Container(
                                                            height:
                                                                height * 0.075,
                                                            width:
                                                                height * 0.45,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          14)),
                                                              gradient:
                                                                  LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  syanColor,
                                                                  lightblueColor,
                                                                ],
                                                              ),
                                                            ),
                                                            child: !isproceeding
                                                                ? Text(
                                                                    ST
                                                                        .of(context)
                                                                        .save,
                                                                    style: montserratSemiBold
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.white),
                                                                  )
                                                                : Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Transform
                                                                          .scale(
                                                                        scale:
                                                                            0.7,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color:
                                                                              white,
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
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  });
                },
              ).whenComplete(() {
                setState(() => isgooglemap = false);
              });
            }
          },
          heroTag: 'Add Address',
        ),
      ),
    );
  }
}

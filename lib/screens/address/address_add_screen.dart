import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/address/address_list_screen.dart';
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

class AddressAdd extends StatefulWidget {
  const AddressAdd({super.key});

  @override
  State<AddressAdd> createState() => AddressAddState();
}

class AddressAddState extends State<AddressAdd> {
  late List citylist = [];
  late List areaList = [];
  List<String?> SelectCityList = <String?>["Select City"];
  List<String?> SelectAreaList = <String?>["Select Area"];
  var emirates = 0, city = 0;
  var address = "";
  var landmark = "";
  var Statelat = "24.3547";
  var Statelong = "54.5020";
  var Marklat = 0.0;
  var Marklong = 0.0;
  var AddressType = "Home";
  bool isDefaultAddressChecked = true;
  bool isgooglemap = false;
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.3547, 54.5020), zoom: 13);
  Completer<GoogleMapController> _controller = Completer();
  bool issubmitted = false;
  final _formKey = GlobalKey<FormState>();
  List<Marker> myMarker = [];
  FocusNode addressFocus = FocusNode();
  FocusNode flatnoFocus = FocusNode();
  final GlobalKey<FormFieldState> areaKey = GlobalKey<FormFieldState>();

  final TextEditingController textEditingController = TextEditingController();
  final GlobalKey<FormFieldState> addAddresscity = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> addAddressarea = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchdatas(0);
      getcitylist(0);
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

  _fetchdatas(address_index) async {
    try {
      Map country = {
        "countryId": 1,
      };
      await getStateList(country).then((value) {
        if (value['ret_data'] == "success") {
          citylist = value['statelist'];
          for (var state in value['statelist']) {
            SelectCityList.add(state['state_name']);
          }
        }
      });
      setState(() {});
    } catch (e) {
      // toast(e.toString());
    }
  }

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
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(CameraUpdate.newCameraPosition(_kLake));
      setState(() {
        Statelat = temp['state_lattitude'];
        Statelong = temp['state_longitude'];
        SelectAreaList = <String?>["Select Area"];
        addAddressarea.currentState?.reset();
      });
      SelectAreaList.length = 1;
      await getCityList(state).then((value) {
        if (value['ret_data'] == "success") {
          setState(() {
            areaList = [];
            SelectAreaList = <String?>["Select Area"];
          });
          areaList = value['citylist'];
          for (var city in value['citylist']) {
            SelectAreaList.add(city['city_name']);
          }
        }
      });
      setState(() {});
    }
  }

  getarealist(data) async {
    // areaKey.currentState!.reset();
    if (SelectAreaList.indexOf(data.toString()) > 0) {
      setState(() {});
      var temp = areaList[SelectAreaList.indexOf(data.toString()) - 1];
      CameraPosition _kLake = CameraPosition(
        target: LatLng(double.parse(temp['city_lattitude']),
            double.parse(temp['city_longitude'])),
        zoom: 15.4746,
      );
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(CameraUpdate.newCameraPosition(_kLake));
      setState(() {
        city = int.parse(temp['city_id']);
        Statelat = temp['city_lattitude'];
        Statelong = temp['city_longitude'];
      });
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
              "Address Add",
              style: montserratSemiBold.copyWith(
                fontSize: 18,
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
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    height: 1000,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Select City*",
                                  style: montserratLight.copyWith(
                                      color: black, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        height: height * 0.045,
                                        width: height * 0.37,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 16,
                                                  color:
                                                      syanColor.withOpacity(.5),
                                                  spreadRadius: 0,
                                                  blurStyle: BlurStyle.outer,
                                                  offset: Offset(0, 0)),
                                            ]),
                                      ),
                                      Container(
                                          height: height * 0.075,
                                          width: height * 0.4,
                                          decoration: BoxDecoration(
                                            color: white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  child:
                                                      DropdownButtonFormField2(
                                                    value: SelectCityList[0],
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    decoration: InputDecoration(
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
                                                                color:
                                                                    const Color(
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
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  width * 0.04),
                                                    ),
                                                    alignment: Alignment.center,
                                                    buttonHeight:
                                                        height * 0.075,
                                                    buttonPadding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 10),
                                                    dropdownDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                                      setState(() {
                                                        isgooglemap = true;
                                                      });
                                                      getcitylist(value);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                    ]),
                                SizedBox(height: height * 0.04),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Area*",
                                  style: montserratLight.copyWith(
                                      color: black, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        height: height * 0.045,
                                        width: height * 0.37,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 16,
                                                  color:
                                                      syanColor.withOpacity(.5),
                                                  spreadRadius: 0,
                                                  blurStyle: BlurStyle.outer,
                                                  offset: Offset(0, 0)),
                                            ]),
                                      ),
                                      Container(
                                          height: height * 0.075,
                                          width: height * 0.4,
                                          decoration: BoxDecoration(
                                            color: white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  child:
                                                      DropdownButtonFormField2(
                                                    key: addAddressarea,
                                                    value: SelectAreaList[0],
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    decoration: InputDecoration(
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
                                                                color:
                                                                    const Color(
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
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  width * 0.04),
                                                    ),
                                                    alignment: Alignment.center,
                                                    buttonHeight:
                                                        height * 0.075,
                                                    buttonPadding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 10),
                                                    dropdownDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
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
                                                          const EdgeInsets.only(
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
                                                                  fontSize: 12),
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
                                                                    width: 0.0),
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
                                                ),
                                              ),
                                            ],
                                          ))
                                    ]),
                                SizedBox(height: height * 0.04),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Address*",
                                  style: montserratLight.copyWith(
                                      color: black, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Stack(alignment: Alignment.bottomCenter, children: [
                            Container(
                              height: height * 0.045,
                              width: height * 0.37,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 16,
                                        color: syanColor.withOpacity(.5),
                                        spreadRadius: 0,
                                        blurStyle: BlurStyle.outer,
                                        offset: Offset(0, 0)),
                                  ]),
                            ),
                            Container(
                                height: height * 0.075,
                                width: height * 0.4,
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: width * 0.025,
                                            left: width * 0.025),
                                        child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLength: 80,
                                          maxLines: 3,
                                          style: montserratLight.copyWith(
                                              color: black, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  montserratRegular.copyWith(
                                                      fontSize: 12,
                                                      color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: "Address",
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: black,
                                                      fontSize: 14),
                                              border: InputBorder.none,
                                              fillColor: white),
                                          onFieldSubmitted: (value) {
                                            FocusScope.of(context)
                                                .requestFocus(flatnoFocus);
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              address = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return addressValidation(
                                                  value, context);
                                            }
                                          },
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Building Name/Flat No",
                                  style: montserratLight.copyWith(
                                      color: black, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Stack(alignment: Alignment.bottomCenter, children: [
                            Container(
                              height: height * 0.045,
                              width: height * 0.37,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 16,
                                        color: syanColor.withOpacity(.5),
                                        spreadRadius: 0,
                                        blurStyle: BlurStyle.outer,
                                        offset: Offset(0, 0)),
                                  ]),
                            ),
                            Container(
                                height: height * 0.075,
                                width: height * 0.4,
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: width * 0.025,
                                            left: width * 0.025),
                                        child: TextFormField(
                                          maxLength: 60,
                                          focusNode: flatnoFocus,
                                          style: montserratLight.copyWith(
                                              color: black, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  montserratRegular.copyWith(
                                                      fontSize: 12,
                                                      color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: "Building Name/Flat No",
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: black,
                                                      fontSize: 14),
                                              border: InputBorder.none,
                                              fillColor: white),
                                          onChanged: (value) {
                                            if (value != "") {
                                              var ret =
                                                  buildingValidation(value);
                                              if (ret == null) {
                                                setState(() {
                                                  landmark = value;
                                                });
                                              } else {
                                                showCustomToast(context,
                                                    "Enter valid details",
                                                    bgColor: errorcolor,
                                                    textColor: white);
                                              }
                                            }
                                          },
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          SizedBox(height: 8),
                          Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.start,
                              direction: Axis.horizontal,
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: syanColor),
                                  child: Radio(
                                    value: 'Home',
                                    groupValue: AddressType,
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => syanColor),
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        AddressType = value;
                                      });
                                    },
                                  ),
                                ),
                                Text("Home",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14)),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: syanColor,
                                  ),
                                  child: Radio(
                                    value: 'Office',
                                    groupValue: AddressType,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        AddressType = value;
                                      });
                                    },
                                  ),
                                ),
                                Text("Office",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14)),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: syanColor),
                                  child: Radio(
                                    value: 'Other',
                                    groupValue: AddressType,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        AddressType = value;
                                      });
                                    },
                                  ),
                                ),
                                Text("Other",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14)),
                              ]),
                          SizedBox(
                            height: 8,
                          ),
                          isgooglemap
                              ? Container(
                                  margin:
                                      EdgeInsets.only(top: 16.0, left: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tap to mark location",
                                        style: montserratLight.copyWith(
                                            color: black, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(),
                          SizedBox(
                            height: 8,
                          ),
                          isgooglemap
                              ? isMobile
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 8.0, left: 20.0),
                                      height: 200,
                                      width: context.width(),
                                      color: white,
                                      child: GoogleMap(
                                        initialCameraPosition: _initialPosition,
                                        myLocationEnabled: true,
                                        markers: Set.from(myMarker),
                                        onTap: _handleTap,
                                        myLocationButtonEnabled: true,
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          _controller.complete(controller);
                                        },
                                      ),
                                    )
                                  : Container(
                                      color: Colors.transparent,
                                      height: 200,
                                      alignment: Alignment.center,
                                      width: width,
                                      child: Text(
                                          'Google Maps support is coming soon',
                                          style: montserratRegular.copyWith(
                                              fontSize: 14)),
                                    )
                              : Row(),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: isDefaultAddressChecked,
                                fillColor: MaterialStateProperty.all(syanColor),
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isDefaultAddressChecked = value!;
                                    },
                                  );
                                },
                              ),
                              Text(
                                "Set As Default Address",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: montserratRegular.copyWith(
                                  fontSize: 14,
                                  color: black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.07),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                if (emirates == 0) {
                                  setState(() => issubmitted = false);
                                  showCustomToast(context, "Select City",
                                      bgColor: errorcolor, textColor: white);
                                } else if (city == 0) {
                                  setState(() => issubmitted = false);
                                  showCustomToast(context, "Select Area",
                                      bgColor: errorcolor, textColor: white);
                                } else if (address == "") {
                                  setState(() => issubmitted = false);
                                  showCustomToast(context, "Enter Address",
                                      bgColor: errorcolor, textColor: white);
                                } else {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  try {
                                    // if (issubmitted) return;
                                    setState(() => issubmitted = true);
                                    await Future.delayed(
                                        Duration(milliseconds: 1000));
                                    Map req = {
                                      "countryId": 1,
                                      "stateId": emirates,
                                      "cityId": city,
                                      "address": address,
                                      "landmark": landmark,
                                      "add_type": AddressType,
                                      "lattitude":
                                          Marklat != 0.0 ? Marklat : Statelat,
                                      "longitude": Marklong != 0.0
                                          ? Marklong
                                          : Statelong,
                                      "cust_id": prefs.getString("cust_id")
                                    };
                                    await saveCustomerAddress(req)
                                        .then((value) {
                                      if (value['ret_data'] == "success") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return AddressList();
                                            },
                                          ),
                                        );
                                        setState(() => isgooglemap = false);
                                        setState(() => issubmitted = false);
                                      } else {
                                        setState(() => issubmitted = false);
                                      }
                                    });
                                  } catch (e) {
                                    setState(() => issubmitted = false);
                                    print(e.toString());
                                  }
                                }
                              }
                              ;
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: height * 0.045,
                                  width: height * 0.37,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 16,
                                            color: syanColor.withOpacity(.6),
                                            spreadRadius: 0,
                                            blurStyle: BlurStyle.outer,
                                            offset: Offset(0, 0)),
                                      ]),
                                ),
                                Container(
                                  height: height * 0.075,
                                  width: height * 0.4,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        syanColor,
                                        lightblueColor,
                                      ],
                                    ),
                                  ),
                                  child: issubmitted
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Transform.scale(
                                              scale: 0.7,
                                              child: CircularProgressIndicator(
                                                color: white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          ST.of(context).save.toUpperCase(),
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _handleTap(LatLng tappedpoint) {
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(tappedpoint.toString()), position: tappedpoint));
      Marklat = tappedpoint.latitude;
      Marklong = tappedpoint.longitude;
    });
  }
}

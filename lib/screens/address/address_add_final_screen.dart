// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/screens/address/address_list_screen.dart';
import 'package:autoversa/screens/booking/reschedule_screen.dart';
import 'package:autoversa/screens/booking/schedule_drop_screen.dart';
import 'package:autoversa/screens/package_screens/schedule_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressAddFinalScreen extends StatefulWidget {
  final int click_id;
  final int pack_type;
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedveh;
  String currency;
  final int pickup_loc;
  final int drop_loc;
  final bool drop_flag;
  final String selected_street;
  final String selected_sublocality;
  final String selected_administrativeArea;
  final String selected_latitude;
  final String selected_longitude;
  final String bk_id;
  final String vehname;
  final String make;
  AddressAddFinalScreen(
      {required this.package_id,
      required this.pack_type,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      required this.pickup_loc,
      required this.drop_loc,
      required this.click_id,
      required this.drop_flag,
      required this.bk_id,
      required this.vehname,
      required this.make,
      required this.selected_street,
      required this.selected_sublocality,
      required this.selected_administrativeArea,
      required this.selected_latitude,
      required this.selected_longitude,
      super.key});

  @override
  State<AddressAddFinalScreen> createState() => _AddressAddFinalScreenState();
}

class _AddressAddFinalScreenState extends State<AddressAddFinalScreen> {
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.3547, 54.5020), zoom: 15);
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController cityController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  var AddressType = "Home";
  var address = "";
  var landmark = "";
  FocusNode addressFocus = FocusNode();
  FocusNode landmarkFocusNode = FocusNode();
  bool isproceeding = false;
  bool isDefaultAddressChecked = true;
  bool isgooglemap = false;
  int pickup_loc_map = 0;
  int drop_loc_map = 0;
  bool drop_flag_map = false;
  @override
  void initState() {
    super.initState();
    pickup_loc_map = widget.pickup_loc;
    drop_loc_map = widget.drop_loc;
    drop_flag_map = widget.drop_flag;
    new_map_location();
  }

  late GoogleMapController _mapController;

  new_map_location() async {
    cityController.text = widget.selected_administrativeArea != null
        ? widget.selected_administrativeArea
        : "";
    areaController.text =
        widget.selected_sublocality != null ? widget.selected_sublocality : "";
    addressController.text =
        widget.selected_street != null ? widget.selected_street : "";
    CameraPosition _kLake = CameraPosition(
        target: LatLng(double.parse(widget.selected_latitude),
            double.parse(widget.selected_longitude)),
        zoom: 15);
    setState(() {});
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    setState(() {});
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
          body: Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: width,
                            height: width * 0.45,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: black,
                              ),
                            ),
                            child: GoogleMap(
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              initialCameraPosition: _initialPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ),
                          ),
                          SizedBox(height: width * 0.02),
                          8.height,
                          Center(
                              child: Wrap(
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
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black)),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: syanColor,
                                  ),
                                  child: Radio(
                                    value: 'Office',
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
                                Text("Office",
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black)),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: syanColor),
                                  child: Radio(
                                    value: 'Other',
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
                                Text("Other",
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black)),
                              ])),
                          8.height,
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "City",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Stack(alignment: Alignment.bottomCenter, children: [
                            Container(
                              height: height * 0.045,
                              width: height * 0.37,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
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
                                height: height * 0.075,
                                decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: lightGreyColor),
                                        padding: EdgeInsets.only(
                                            left: width * 0.025,
                                            right: width * 0.025),
                                        child: TextField(
                                          controller: cityController,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          keyboardType: TextInputType.number,
                                          maxLines: 1,
                                          style: montserratMedium.copyWith(
                                              color: Colors.black,
                                              fontSize: width * 0.04),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: width * 0.032,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: "Selected city",
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: Colors.black,
                                                      fontSize: width * 0.034),
                                              border: InputBorder.none,
                                              fillColor: lightGreyColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          8.height,
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "Area",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Stack(alignment: Alignment.bottomCenter, children: [
                            Container(
                              height: height * 0.045,
                              width: height * 0.37,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
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
                                height: height * 0.075,
                                decoration: BoxDecoration(
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: lightGreyColor),
                                        padding: EdgeInsets.only(
                                            left: width * 0.025,
                                            right: width * 0.025),
                                        child: TextField(
                                          controller: areaController,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          keyboardType: TextInputType.number,
                                          maxLines: 1,
                                          style: montserratMedium.copyWith(
                                              color: Colors.black,
                                              fontSize: width * 0.04),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: width * 0.032,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: "Selected area",
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: Colors.black,
                                                      fontSize: width * 0.034),
                                              border: InputBorder.none,
                                              fillColor: lightGreyColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          8.height,
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "Address",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: height * 0.045,
                                width: height * 0.37,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
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
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    color: white),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: addressController,
                                  minLines: 1,
                                  maxLines: 6,
                                  maxLength: 120,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  style: montserratMedium.copyWith(
                                      color: Colors.black,
                                      fontSize: width * 0.04),
                                  onChanged: (value) {
                                    setState(() {
                                      address = value;
                                    });
                                  },
                                  validator: (value) {
                                    return addressValidation(value, context);
                                  },
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(landmarkFocusNode);
                                  },
                                  focusNode: addressFocus,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "Address",
                                      hintStyle: montserratMedium.copyWith(
                                          color: greyColor,
                                          fontSize: width * 0.04),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: black, width: 0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                alignment: Alignment.center,
                              ),
                            ],
                          ),
                          12.height,
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "Building Name/Flat No",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.034, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          8.height,
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: height * 0.045,
                                width: height * 0.37,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
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
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    color: white),
                                child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLength: 50,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    style: montserratMedium.copyWith(
                                        color: Colors.black,
                                        fontSize: width * 0.04),
                                    onChanged: (value) {
                                      if (value != "") {
                                        var ret = buildingValidation(value);
                                        if (ret == null) {
                                          setState(() {
                                            landmark = value;
                                          });
                                        } else {
                                          showCustomToast(
                                              context, "Enter valid details",
                                              bgColor: errorcolor,
                                              textColor: white);
                                        }
                                      }
                                    },
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "Building Name/Flat No",
                                        hintStyle: montserratMedium.copyWith(
                                            color: greyColor,
                                            fontSize: width * 0.04),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: black, width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: black, width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ))),
                                alignment: Alignment.center,
                              ),
                            ],
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
                                "Set as default address",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: montserratMedium.copyWith(
                                  fontSize: 12,
                                  color: black,
                                ),
                              ),
                            ],
                          ),
                          26.height,
                          GestureDetector(
                            onTap: () async {
                              if (addressController.text == "") {
                                setState(() => isproceeding = false);
                                showCustomToast(context, "Enter Address",
                                    bgColor: errorcolor, textColor: white);
                              } else {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                try {
                                  setState(() => isproceeding = true);
                                  await Future.delayed(
                                      Duration(milliseconds: 1000));
                                  Map req = {
                                    "countryId": 1,
                                    "stateId":
                                        widget.selected_administrativeArea,
                                    "cityId": widget.selected_sublocality,
                                    "address": addressController.text,
                                    "landmark": landmark,
                                    "add_type": AddressType,
                                    "lattitude": widget.selected_latitude,
                                    "longitude": widget.selected_longitude,
                                    "cust_id": prefs.getString("cust_id")
                                  };
                                  await saveCustomerAddress(req).then((value) {
                                    if (value['ret_data'] == "success") {
                                      // int count = 0;
                                      if (drop_flag_map == true) {
                                        pickup_loc_map = -1;
                                        drop_loc_map = 0;
                                      } else {
                                        pickup_loc_map = widget.pickup_loc;
                                        drop_loc_map = -1;
                                      }
                                      if (widget.click_id == 1) {
                                        showCustomToast(context,
                                            "Your address has been saved successfully.",
                                            bgColor: black, textColor: white);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return AddressList(
                                                click_id: 2,
                                              );
                                            },
                                          ),
                                        );
                                      } else if (widget.click_id == 2) {
                                        showCustomToast(context,
                                            "Your address has been saved successfully.",
                                            bgColor: black, textColor: white);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ScheduleScreen(
                                                package_id: widget.package_id,
                                                custvehlist: widget.custvehlist,
                                                currency: widget.currency,
                                                selectedveh: widget.selectedveh,
                                                pickup_loc: pickup_loc_map,
                                                drop_loc: drop_loc_map,
                                                click_id: 2,
                                                pack_type: widget.pack_type,
                                                booking_list: [],
                                              );
                                            },
                                          ),
                                        );
                                      } else if (widget.click_id == 3) {
                                        showCustomToast(context,
                                            "Your address has been saved successfully.",
                                            bgColor: black, textColor: white);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return RescheduleScreen(
                                                  bk_data: widget.package_id,
                                                  custvehlist:
                                                      widget.custvehlist,
                                                  currency: widget.currency,
                                                  selectedVeh:
                                                      widget.selectedveh,
                                                  pickup_loc: pickup_loc_map,
                                                  drop_loc: drop_loc_map);
                                            },
                                          ),
                                        );
                                      } else if (widget.click_id == 4) {
                                        showCustomToast(context,
                                            "Your address has been saved successfully.",
                                            bgColor: black, textColor: white);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ScheduleDropScreen(
                                                  click_id: 2,
                                                  bk_id: widget.bk_id,
                                                  vehname: widget.vehname,
                                                  make: widget.make);
                                            },
                                          ),
                                        );
                                      }
                                      setState(() => isgooglemap = false);
                                      setState(() => isproceeding = false);
                                    } else {
                                      setState(() => isproceeding = false);
                                    }
                                  });
                                } catch (e) {
                                  setState(() => isproceeding = false);
                                  print(e.toString());
                                }
                              }
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
                                  width: height * 0.45,
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
                                  child: !isproceeding
                                      ? Text(
                                          "SAVE",
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white),
                                        )
                                      : Row(
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
}

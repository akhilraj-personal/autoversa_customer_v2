import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/screens/address/address_list_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressEdit extends StatefulWidget {
  final String address_id;
  const AddressEdit({required this.address_id, super.key});

  @override
  State<AddressEdit> createState() => AddressEditState();
}

class AddressEditState extends State<AddressEdit> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> customeraddressdetails = {};
  bool isDefaultAddressChecked = true;
  bool isgooglemap = false;
  final TextEditingController textEditingController = TextEditingController();
  var emirates = 0, city = 0;
  var address = "";
  var landmark = "";
  var Statelat = "24.3547";
  var Statelong = "54.5020";
  var AddressType = "Home";
  String area_id = '0';

  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.3547, 54.5020), zoom: 13);
  Completer<GoogleMapController> _controller = Completer();
  bool issubmitted = false;
  FocusNode addressFocus = FocusNode();
  FocusNode flatnoFocus = FocusNode();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController builderController = TextEditingController();
  List<DropdownMenuItem<String>> items = [];
  List data = List<String>.empty();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      CustomerAddressDetails();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  CustomerAddressDetails() async {
    await getCustomerAddressDetails(widget.address_id).then((value) async {
      if (value['ret_data'] == "success") {
        customeraddressdetails = value['cust_address'];
        AddressType = value['cust_address']['cad_address_type'];
        cityController.text = customeraddressdetails['state_name'] != null
            ? customeraddressdetails['state_name']
            : "";
        stateController.text = customeraddressdetails['city_name'] != null
            ? customeraddressdetails['city_name']
            : "";
        addressController.text = customeraddressdetails['cad_address'] != null
            ? customeraddressdetails['cad_address']
            : "";
        builderController.text = customeraddressdetails['cad_landmark'] != null
            ? customeraddressdetails['cad_landmark']
            : "";
        CameraPosition _kLake = CameraPosition(
          target: LatLng(double.parse(value['cust_address']['cad_lattitude']),
              double.parse(value['cust_address']['cad_longitude'])),
          zoom: 16,
        );
        final GoogleMapController controller = await _controller.future;
        controller.moveCamera(CameraUpdate.newCameraPosition(_kLake));
        setState(() {});
        print(customeraddressdetails);
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
              "Address Update",
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
                                            color: lightGreyColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: lightGreyColor),
                                                  padding: EdgeInsets.only(
                                                      right: width * 0.025),
                                                  child: TextField(
                                                    controller: cityController,
                                                    enabled: false,
                                                    textAlign: TextAlign.left,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    maxLines: 1,
                                                    style: montserratMedium
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width * 0.04),
                                                    decoration: InputDecoration(
                                                        errorStyle: TextStyle(
                                                            fontSize:
                                                                width * 0.032,
                                                            color:
                                                                warningcolor),
                                                        counterText: "",
                                                        filled: true,
                                                        hintText: "Select City",
                                                        hintStyle: montserratRegular
                                                            .copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                        border:
                                                            InputBorder.none,
                                                        fillColor:
                                                            lightGreyColor),
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
                                            color: lightGreyColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: lightGreyColor),
                                                  padding: EdgeInsets.only(
                                                      right: width * 0.025),
                                                  child: TextField(
                                                    controller: stateController,
                                                    enabled: false,
                                                    textAlign: TextAlign.left,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    maxLines: 1,
                                                    style: montserratMedium
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width * 0.04),
                                                    decoration: InputDecoration(
                                                        errorStyle: TextStyle(
                                                            fontSize:
                                                                width * 0.032,
                                                            color:
                                                                warningcolor),
                                                        counterText: "",
                                                        filled: true,
                                                        hintText: "Select City",
                                                        hintStyle: montserratRegular
                                                            .copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                        border:
                                                            InputBorder.none,
                                                        fillColor:
                                                            lightGreyColor),
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
                                          controller: addressController,
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
                                          controller: builderController,
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
                                    unselectedWidgetColor: syanColor,
                                  ),
                                  child: Radio(
                                    value: 'Home',
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => syanColor),
                                    groupValue: AddressType,
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
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => syanColor),
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
                                    unselectedWidgetColor: syanColor,
                                  ),
                                  child: Radio(
                                    value: 'Other',
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => syanColor),
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
                          isMobile
                              ? Container(
                                  margin: EdgeInsets.only(top: 8.0, left: 20.0),
                                  height: 200,
                                  width: context.width(),
                                  color: white,
                                  child: GoogleMap(
                                    initialCameraPosition: _initialPosition,
                                    myLocationEnabled: true,
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
                                ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                if (addressController == "") {
                                  setState(() => issubmitted = false);
                                  showCustomToast(context, "Enter Address",
                                      bgColor: errorcolor, textColor: white);
                                } else {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  try {
                                    setState(() => issubmitted = true);
                                    await Future.delayed(
                                        Duration(milliseconds: 1000));
                                    Map req = {
                                      "addressId": widget.address_id,
                                      "countryId": 1,
                                      "stateId":
                                          customeraddressdetails['state_id'],
                                      "cityId":
                                          customeraddressdetails['city_id'],
                                      "address": addressController.text
                                                  .toString() !=
                                              null
                                          ? addressController.text.toString()
                                          : "",
                                      "landmark": builderController.text
                                                  .toString() !=
                                              null
                                          ? builderController.text.toString()
                                          : "",
                                      "add_type": AddressType,
                                      "lattitude": customeraddressdetails[
                                          'cad_lattitude'],
                                      "longitude": customeraddressdetails[
                                          'cad_longitude'],
                                      "cust_id": prefs.getString("cust_id")
                                    };
                                    print(req);
                                    await updateCustomerAddress(req)
                                        .then((value) {
                                      if (value['ret_data'] == "success") {
                                        showCustomToast(
                                            context, "Address Updated",
                                            bgColor: black, textColor: white);
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
                                          "UPDATE",
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
}

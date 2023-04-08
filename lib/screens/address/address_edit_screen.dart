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
    print(widget.address_id);
    await getCustomerAddressDetails(widget.address_id).then((value) async {
      if (value['ret_data'] == "success") {
        customeraddressdetails = value['cust_address'];
        AddressType = value['cust_address']['cad_address_type'];
        cityController.text = customeraddressdetails['cad_state'] != null
            ? customeraddressdetails['cad_state']
            : "";
        stateController.text = customeraddressdetails['cad_city'] != null
            ? customeraddressdetails['cad_city']
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
                          SizedBox(height: height * 0.02),
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
                          SizedBox(height: height * 0.02),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "City",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.04, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
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
                                          color: lightGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.only(
                                            right: width * 0.05,
                                            left: width * 0.05),
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
                          SizedBox(height: height * 0.02),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "Area",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.04, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
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
                                          color: lightGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.only(
                                            right: width * 0.05,
                                            left: width * 0.05),
                                        child: TextField(
                                          controller: stateController,
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
                          SizedBox(height: height * 0.02),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "Address",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.04, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
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
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(flatnoFocus);
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
                          SizedBox(height: height * 0.02),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  child: Text(
                                    "Building Name/Flat No",
                                    textAlign: TextAlign.left,
                                    style: montserratMedium.copyWith(
                                        fontSize: width * 0.04, color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.02),
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
                                    controller: builderController,
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
                                      "stateId": cityController.text.toString(),
                                      "cityId": stateController.text.toString(),
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

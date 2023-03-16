import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleUpdate extends StatefulWidget {
  final String vehicle_id;
  const VehicleUpdate({required this.vehicle_id, super.key});

  @override
  State<VehicleUpdate> createState() => VehicleUpdateState();
}

class VehicleUpdateState extends State<VehicleUpdate> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> customervehicledetails = {};
  bool issubmitted = false;
  var plate = "";

  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController varientController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController platenumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      CustomerVehicleDetails();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  CustomerVehicleDetails() async {
    await getCustomerVehicleDetails(widget.vehicle_id).then((value) async {
      if (value['ret_data'] == "success") {
        customervehicledetails = value['vehicle_details'];
        makeController.text = customervehicledetails['cv_make'] != null
            ? customervehicledetails['cv_make']
            : "";
        modelController.text = customervehicledetails['cv_model'] != null
            ? customervehicledetails['cv_model']
            : "";
        varientController.text = customervehicledetails['cv_variant'] != null
            ? customervehicledetails['cv_variant']
            : "";
        yearController.text = customervehicledetails['cv_year'] != null
            ? customervehicledetails['cv_year']
            : "";
        platenumberController.text =
            customervehicledetails['cv_plate_number'] != null
                ? customervehicledetails['cv_plate_number']
                : "";
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  CustomerVehicleUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      'custvehId': widget.vehicle_id,
      'cv_make': customervehicledetails['cv_make'],
      'cv_model': customervehicledetails['cv_model'],
      'cv_variant': customervehicledetails['cv_variant'] != null
          ? customervehicledetails['cv_variant']
          : "",
      'cv_year': customervehicledetails['cv_year'],
      'cv_platenumber': platenumberController.text.toString() != null
          ? platenumberController.text.toString()
          : "",
      "cv_vinnumber": customervehicledetails['cv_vinnumber'] != null
          ? customervehicledetails['cv_vinnumber']
          : "",
      "cv_odometer": customervehicledetails['cv_cust_id'] != null
          ? customervehicledetails['cv_cust_id']
          : "",
      "cv_cust_id": customervehicledetails['cv_cust_id'] != null
          ? customervehicledetails['cv_cust_id']
          : "",
    };
    await updateCustomerVehicle(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          showCustomToast(context, "Vehicle Details Updated",
              bgColor: blackColor, textColor: whiteColor);
          setState(() => issubmitted = false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBarScreen(
                index: 2,
              ),
            ),
            (route) => false,
          );
        });
      } else {
        setState(() => issubmitted = false);
      }
    }).catchError((e) {
      setState(() => issubmitted = false);
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: syanColor,
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
            "Vehicle Update",
            style: montserratRegular.copyWith(
              fontSize: width * 0.044,
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
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: whiteColor,
                      padding: EdgeInsets.all(20),
                      height: height - height * 0.12,
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                                  color: lightGreyColor,
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
                                        decoration: BoxDecoration(
                                            color: lightGreyColor),
                                        padding: EdgeInsets.only(
                                            right: width * 0.025),
                                        child: TextField(
                                          controller: makeController,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          keyboardType: TextInputType.text,
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
                                              hintText: "Make",
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
                          SizedBox(height: height * 0.04),
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
                                  color: lightGreyColor,
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
                                        decoration: BoxDecoration(
                                            color: lightGreyColor),
                                        padding: EdgeInsets.only(
                                            right: width * 0.025),
                                        child: TextField(
                                          controller: modelController,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          keyboardType: TextInputType.text,
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
                                              hintText: "Model",
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
                          customervehicledetails['cv_variant'] != null
                              ? SizedBox(height: height * 0.04)
                              : SizedBox(height: height * 0.001),
                          customervehicledetails['cv_variant'] != null
                              ? Stack(
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
                                                    controller:
                                                        varientController,
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
                                                        hintText: "Varient",
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
                                    ])
                              : Container(),
                          SizedBox(height: height * 0.04),
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
                                  color: lightGreyColor,
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
                                        decoration: BoxDecoration(
                                            color: lightGreyColor),
                                        padding: EdgeInsets.only(
                                            right: width * 0.025),
                                        child: TextField(
                                          controller: yearController,
                                          enabled: false,
                                          textAlign: TextAlign.left,
                                          keyboardType: TextInputType.text,
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
                                              hintText: "Year",
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
                          SizedBox(height: height * 0.04),
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
                                  color: whiteColor,
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
                                          controller: platenumberController,
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLength: 80,
                                          maxLines: 3,
                                          style: montserratLight.copyWith(
                                              color: blackColor, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle:
                                                  montserratRegular.copyWith(
                                                      fontSize: 12,
                                                      color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: "Plate Number",
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: blackColor,
                                                      fontSize: 14),
                                              border: InputBorder.none,
                                              fillColor: whiteColor),
                                          onChanged: (value) {
                                            setState(() {
                                              plate = value;
                                            });
                                          },
                                          validator: (value) {
                                            return plateNumberValidation(value);
                                          },
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          SizedBox(height: height * 0.04),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                if (issubmitted) return;
                                setState(() => issubmitted = true);
                                await Future.delayed(
                                    Duration(milliseconds: 1000));
                                CustomerVehicleUpdate();
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
                                                color: whiteColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "UPDATE",
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white,
                                              fontSize: width * 0.034),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

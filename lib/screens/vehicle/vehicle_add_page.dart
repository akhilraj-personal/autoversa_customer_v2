import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleAddPage extends StatefulWidget {
  const VehicleAddPage({super.key});

  @override
  State<VehicleAddPage> createState() => VehicleAddPageState();
}

class VehicleAddPageState extends State<VehicleAddPage> {
  List<DropdownMenuItem<String>> brands = [];
  List<DropdownMenuItem<String>> models = [];
  List<DropdownMenuItem<String>> variants = [];
  List<DropdownMenuItem<String>> modyears = [];

  List data = List<String>.empty();
  final GlobalKey<FormFieldState> modelKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _varkey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _yearkey = GlobalKey<FormFieldState>();

  TextEditingController plateNumberController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  var brandname, modelname, variantname, yearselected = '';
  final _formKey = GlobalKey<FormState>();
  bool isvariant = false;
  bool issubmitted = false;
  bool isoffline = false;
  StreamSubscription? internetconnection;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      this._getMakeList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> init() async {}

  _getMakeList() async {
    await getVehicleBrands().then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['brands'];
          brands = data
              .map((item) => DropdownMenuItem(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        item['veh_brand'],
                        style: montserratMedium.copyWith(
                            color: blackColor, fontSize: width * 0.04),
                      )),
                  value: item['veh_brand'].toString()))
              .toList();
          models = [];
          variants = [];
          modyears = [];
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  getVehicleModel(brand) async {
    data = List<String>.empty();
    modelKey.currentState!.reset();
    brandname = brand;
    setState(() {
      models = [];
      variants = [];
      modyears = [];
    });
    Map req = {
      "brand": brand,
    };
    await getVehicleModels(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['models'];
          models = data
              .map((item) => DropdownMenuItem(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        item['veh_model'],
                        style: montserratMedium.copyWith(
                            color: blackColor, fontSize: width * 0.04),
                      )),
                  value: item['veh_model'].toString()))
              .toList();
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  getVariant(smodel) async {
    data = List<String>.empty();
    modelname = smodel;
    setState(() {
      _varkey.currentState?.reset();
      variants = [];
      modyears = [];
    });
    Map req = {
      "brand": brandname,
      "model": smodel,
    };
    await getVehicleVariants(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['variants'];
          variants = data
              .map((item) => DropdownMenuItem(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        item['veh_variant'],
                        style: montserratMedium.copyWith(
                            color: blackColor, fontSize: width * 0.04),
                      )),
                  value: item['veh_variant'].toString()))
              .toList();
        });
      } else {
        // toasty(context, language!.lblPhoneErr);
      }
    }).catchError((e) {
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  getModelyear(smodel) async {
    data = List<String>.empty().toList();
    _yearkey.currentState!.reset();
    modelname = smodel;
    Map req = {
      "brand": brandname,
      "model": smodel,
    };
    await getVehicleModelYears(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          var last_year = 0;
          if (value['year'][0]['to_year'] == "9999") {
            final now = DateTime.now();
            final presentYear = DateTime.parse(now.toString());
            last_year = presentYear.year;
          } else {
            last_year = int.parse(value['year'][0]['to_year']);
          }
          for (var i = int.parse(value['year'][0]['from_year']);
              i <= last_year;
              i++) {
            data.add(i.toString());
          }
          modyears = data
              .map((item) => DropdownMenuItem(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        item,
                        style: montserratMedium.copyWith(
                            color: blackColor, fontSize: width * 0.04),
                      )),
                  value: item.toString()))
              .toList();
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  getModelVariantYear(svariant) async {
    variantname = svariant;
    data = List<String>.empty().toList();
    setState(() {
      _yearkey.currentState?.reset();
    });
    Map req = {
      "brand": brandname,
      "model": modelname,
      "varient": svariant,
    };
    await getVehicleModelVariantYears(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          var end_year = 0;
          if (value['years'][0]['to_year'] == "9999") {
            final now = DateTime.now();
            final currentyear = DateTime.parse(now.toString());
            end_year = currentyear.year;
          } else {
            end_year = int.parse(value['years'][0]['to_year']);
          }
          for (var i = int.parse(value['years'][0]['from_year']);
              i <= end_year;
              i++) {
            data.add(i.toString());
          }
          modyears = data
              .map((item) => DropdownMenuItem(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        item,
                        style: montserratMedium.copyWith(
                            color: blackColor, fontSize: width * 0.04),
                      )),
                  value: item.toString()))
              .toList();
        });
      }
    }).catchError((e) {
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  saveCustomerVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      'cv_make': brandname,
      'cv_model': modelname,
      'cv_variant': variantname,
      'cv_year': yearselected,
      'cv_platenumber': plateNumberController.text.toString() != null
          ? plateNumberController.text.toString()
          : "",
      "custId": prefs.getString("cust_id")
    };
    await addCustomerVehicle(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = List<String>.empty().toList();
          _yearkey.currentState?.reset();
          _varkey.currentState?.reset();
          models = [];
          brands = [];
          brandname = '';
          modelname = '';
          variantname = '';
          yearselected = '';
          showCustomToast(context, lang.S.of(context).vehicle_save_toast,
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
        if (value['ret_message'] == "duplicate") {
          setState(() => issubmitted = false);
          showCustomToast(context, lang.S.of(context).vehicle_already_exist,
              bgColor: warningcolor, textColor: whiteColor);
        } else {
          showCustomToast(context, lang.S.of(context).vehicle_save_toast,
              bgColor: blackColor, textColor: whiteColor);
        }
      }
    }).catchError((e) {
      setState(() => issubmitted = false);
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
            "Add Vehicle",
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
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: DropdownButtonFormField2(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            //Add isDense true and zero Padding.
                                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            focusedBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color: const Color(0xfffff),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                            lang.S.of(context).make + "*",
                                            style: montserratMedium.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.04),
                                          ),
                                          alignment: Alignment.center,
                                          buttonHeight: height * 0.075,
                                          buttonPadding: const EdgeInsets.only(
                                              left: 20, right: 10),
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          items: brands,
                                          validator: (value) {
                                            if (value == null) {
                                              return selectmakeValidation(
                                                  value);
                                            }
                                          },
                                          onChanged: (value) {
                                            getVehicleModel(value);
                                          },
                                        ),

                                        // DropdownButtonFormField(
                                        //   isExpanded: true,
                                        //   decoration: InputDecoration.collapsed(
                                        //       hintText: ''),
                                        //   hint: Align(
                                        //       alignment: Alignment.center,
                                        //       child: Text(
                                        //         lang.S.of(context).make + "*",
                                        //         style:
                                        //             montserratRegular.copyWith(
                                        //                 color: blackColor,
                                        //                 fontSize:
                                        //                     width * 0.034),
                                        //       )),
                                        //   items: brands,
                                        //   validator: (value) {
                                        //     if (value == null) {
                                        //       return selectmakeValidation(
                                        //           value);
                                        //     }
                                        //   },
                                        //   onChanged: (value) {
                                        //     getVehicleModel(value);
                                        //   },
                                        // ),
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
                                  color: models.isNotEmpty
                                      ? whiteColor
                                      : lightGreyColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: DropdownButtonFormField2(
                                          key: modelKey,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            //Add isDense true and zero Padding.
                                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            focusedBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color: const Color(0xfffff),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                            lang.S.of(context).model + "*",
                                            style: montserratMedium.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.04),
                                          ),
                                          alignment: Alignment.center,
                                          buttonHeight: height * 0.075,
                                          buttonPadding: const EdgeInsets.only(
                                              left: 20, right: 10),
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          items: models,
                                          validator: (value) {
                                            if (value == null) {
                                              return selectmodelValidation(
                                                  value);
                                            }
                                          },
                                          onChanged: (value) {
                                            brandname == 'Mercedes Benz' ||
                                                    brandname == 'BMW'
                                                ? getVariant(value)
                                                : getModelyear(value);
                                            setState(() {
                                              brandname == 'Mercedes Benz' ||
                                                      brandname == 'BMW'
                                                  ? isvariant = true
                                                  : isvariant = false;
                                            });
                                          },
                                          dropdownMaxHeight: height * 0.5,
                                          searchController:
                                              textEditingController,
                                          searchInnerWidgetHeight:
                                              height * 0.07,
                                          searchInnerWidget: Container(
                                            height: height * 0.07,
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 4,
                                              right: 8,
                                              left: 8,
                                            ),
                                            child: TextFormField(
                                              expands: true,
                                              maxLines: null,
                                              controller: textEditingController,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                                hintText: 'Search model...',
                                                hintStyle: const TextStyle(
                                                    fontSize: 12),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                      color: syanColor,
                                                      width: 0.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          searchMatchFn: (item, searchValue) {
                                            return (item.value
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    searchValue.toLowerCase()));
                                          },
                                          //This to clear the search value when you close the menu
                                          onMenuStateChange: (isOpen) {
                                            if (!isOpen) {
                                              textEditingController.clear();
                                            }
                                          },
                                        ),
                                        //
                                        // DropdownButtonFormField(
                                        //   key: modelKey,
                                        //   isExpanded: true,
                                        //   decoration: InputDecoration.collapsed(
                                        //       hintText: ''),
                                        //   hint: Align(
                                        //       alignment: Alignment.center,
                                        //       child: Text(
                                        //         lang.S.of(context).model + "*",
                                        //         style:
                                        //             montserratRegular.copyWith(
                                        //                 color: blackColor,
                                        //                 fontSize:
                                        //                     width * 0.034),
                                        //       )),
                                        //   items: models,
                                        //   validator: (value) {
                                        //     if (value == null) {
                                        //       return selectmodelValidation(
                                        //           value);
                                        //     }
                                        //   },
                                        //   onChanged: (value) {
                                        //     brandname == 'Mercedes Benz' ||
                                        //             brandname == 'BMW'
                                        //         ? getVariant(value)
                                        //         : getModelyear(value);
                                        //     setState(() {
                                        //       brandname == 'Mercedes Benz' ||
                                        //               brandname == 'BMW'
                                        //           ? isvariant = true
                                        //           : isvariant = false;
                                        //     });
                                        //   },
                                        // ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          isvariant
                              ? SizedBox(height: height * 0.04)
                              : SizedBox(height: height * 0.001),
                          isvariant
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
                                            color: variants.isNotEmpty
                                                ? whiteColor
                                                : lightGreyColor,
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
                                                    key: _varkey,
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
                                                      lang.S
                                                              .of(context)
                                                              .variant +
                                                          "*",
                                                      style: montserratMedium
                                                          .copyWith(
                                                              color: blackColor,
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
                                                    items: variants,
                                                    validator: (value) {
                                                      if (value == null) {
                                                        return selectvariantValidation(
                                                            value);
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      getModelVariantYear(
                                                          value);
                                                    },
                                                    dropdownMaxHeight:
                                                        height * 0.5,
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
                                                              'Search variant...',
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
                                                  //     DropdownButtonFormField(
                                                  //   key: _varkey,
                                                  //   isExpanded: true,
                                                  //   decoration: InputDecoration
                                                  //       .collapsed(
                                                  //           hintText: ''),
                                                  //   hint: Align(
                                                  //       alignment:
                                                  //           Alignment.center,
                                                  //       child: Text(
                                                  //         ST
                                                  //                 .of(context)
                                                  //                 .variant +
                                                  //             "*",
                                                  //         style: montserratRegular
                                                  //             .copyWith(
                                                  //                 color:
                                                  //                     blackColor,
                                                  //                 fontSize:
                                                  //                     width *
                                                  //                         0.034),
                                                  //       )),
                                                  //   items: variants,
                                                  //   validator: (value) {
                                                  //     if (value == null) {
                                                  //       return selectvariantValidation(
                                                  //           value);
                                                  //     }
                                                  //   },
                                                  //   onChanged: (value) {
                                                  //     getModelVariantYear(
                                                  //         value);
                                                  //   },
                                                  // ),
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
                                  color: modyears.isNotEmpty
                                      ? whiteColor
                                      : lightGreyColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: DropdownButtonFormField2(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          key: _yearkey,
                                          decoration: InputDecoration(
                                            //Add isDense true and zero Padding.
                                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            focusedBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color: const Color(0xfffff),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                            lang.S.of(context).year + "*",
                                            style: montserratMedium.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.04),
                                          ),
                                          alignment: Alignment.center,
                                          buttonHeight: height * 0.075,
                                          buttonPadding: const EdgeInsets.only(
                                              left: 20, right: 10),
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          items: modyears,
                                          validator: (value) {
                                            if (value == null) {
                                              return selectyearValidation(
                                                  value);
                                            }
                                          },
                                          onChanged: (value) {
                                            yearselected = value.toString();
                                          },
                                        ),
                                        // DropdownButtonFormField(
                                        //   key: _yearkey,
                                        //   isExpanded: true,
                                        //   decoration: InputDecoration.collapsed(
                                        //       hintText: ''),
                                        //   hint: Align(
                                        //       alignment: Alignment.center,
                                        //       child: Text(
                                        //         lang.S.of(context).year + "*",
                                        //         style:
                                        //             montserratRegular.copyWith(
                                        //                 color: blackColor,
                                        //                 fontSize:
                                        //                     width * 0.034),
                                        //       )),
                                        //   items: modyears,
                                        //   validator: (value) {
                                        //     if (value == null) {
                                        //       return selectyearValidation(
                                        //           value);
                                        //     }
                                        //   },
                                        //   onChanged: (value) {
                                        //     yearselected = value.toString();
                                        //   },
                                        // ),
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
                                        child: Focus(
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            controller: plateNumberController,
                                            keyboardType: TextInputType.text,
                                            textAlign: TextAlign.center,
                                            maxLength: 10,
                                            style: montserratMedium.copyWith(
                                                color: blackColor,
                                                fontSize: width * 0.04),
                                            validator: (value) {
                                              return plateNumberValidation(
                                                  value);
                                            },
                                            decoration: InputDecoration(
                                                errorStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: warningcolor),
                                                counterText: "",
                                                filled: true,
                                                hintText: lang.S
                                                    .of(context)
                                                    .plate_number,
                                                hintStyle:
                                                    montserratMedium.copyWith(
                                                        color: !isFocused
                                                            ? blackColor
                                                            : greyColor,
                                                        fontSize: width * 0.04),
                                                border: InputBorder.none,
                                                fillColor: whiteColor),
                                          ),
                                          onFocusChange: (hasFocus) {
                                            if (hasFocus) {
                                              setState(() {
                                                isFocused = true;
                                              });
                                            } else {
                                              setState(() {
                                                isFocused = false;
                                              });
                                            }
                                          },
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
                                saveCustomerVehicle();
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
                                          lang.S.of(context).save.toUpperCase(),
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

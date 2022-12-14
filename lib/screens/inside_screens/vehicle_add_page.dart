import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/services/pre_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  var brandname, modelname, variantname, yearselected = '';
  final _formKey = GlobalKey<FormState>();
  bool isvariant = false;
  bool issubmitted = false;

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
      Navigator.pop(context);
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['brands'];
          brands = data
              .map((item) => DropdownMenuItem(
                  child: Text(item['veh_brand']),
                  value: item['veh_brand'].toString()))
              .toList();
          models = [];
          variants = [];
          modyears = [];
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, "Application error. Contact support",
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
      Navigator.pop(context);
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['models'];
          models = data
              .map((item) => DropdownMenuItem(
                  child: Text(item['veh_model']),
                  value: item['veh_model'].toString()))
              .toList();
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, "Application error. Contact support",
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
      Navigator.pop(context);
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['variants'];
          variants = data
              .map((item) => DropdownMenuItem(
                  child: Text(item['veh_variant']),
                  value: item['veh_variant'].toString()))
              .toList();
        });
      } else {
        // toasty(context, language!.lblPhoneErr);
      }
    }).catchError((e) {
      showCustomToast(context, "Application error. Contact support",
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
      Navigator.pop(context);
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
              .map((item) =>
                  DropdownMenuItem(child: Text(item), value: item.toString()))
              .toList();
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, "Application error. Contact support",
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
      Navigator.pop(context);
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
              .map((item) =>
                  DropdownMenuItem(child: Text(item), value: item.toString()))
              .toList();
        });
      }
    }).catchError((e) {
      showCustomToast(context, "Application error. Contact support",
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
          showCustomToast(context, "Vehicle Added Successfully",
              bgColor: blackColor, textColor: whiteColor);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBarScreen(
                index: 1,
              ),
            ),
            (route) => false,
          );
        });
      } else {
        if (value['ret_message'] == "duplicate") {
          setState(() => issubmitted = false);
          showCustomToast(context, "Vehicle already exist",
              bgColor: warningcolor, textColor: whiteColor);
        } else {
          showCustomToast(context, "Vehicle Added Successfully",
              bgColor: blackColor, textColor: whiteColor);
        }
      }
    }).catchError((e) {
      showCustomToast(context, "Application error. Contact support",
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
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: whiteColor,
          shadowColor: whiteColor,
          iconTheme: IconThemeData(color: blackColor),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
          ),
          actions: [
            Center(
              child: Row(
                children: [
                  Container(
                    color: whiteColor,
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: GestureDetector(
                      onTap: () async {
                        context
                            .read<LanguageChangeProvider>()
                            .changeLocale("en");
                        setState(() {});
                      },
                      child: Text(
                        'English',
                        textAlign: TextAlign.end,
                        style: montserratRegular.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(
                    color: whiteColor,
                    width: MediaQuery.of(context).size.width * 0.20,
                    padding: EdgeInsets.only(
                        right: width * 0.05, left: width * 0.05),
                    child: GestureDetector(
                      onTap: () async {
                        context
                            .read<LanguageChangeProvider>()
                            .changeLocale("ar");
                        setState(() {});
                      },
                      child: Text(
                        'عربي',
                        textAlign: TextAlign.end,
                        style: montserratRegular.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: whiteColor,
                      padding: EdgeInsets.all(20),
                      height: height - height * 0.12,
                      width: width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            ImageConst.signup_icon,
                            fit: BoxFit.contain,
                            width: 75,
                            height: 88,
                          ),
                          SizedBox(height: 20),
                          Text(
                            S.of(context).register_new_account,
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: 21),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.03),
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
                                        padding: EdgeInsets.only(
                                          left: width * 0.025,
                                          right: width * 0.025,
                                        ),
                                        child: DropdownButtonFormField(
                                          isExpanded: true,
                                          decoration: InputDecoration.collapsed(
                                              hintText: ''),
                                          hint: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Make",
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: blackColor,
                                                        fontSize: 14),
                                              )),
                                          items: data
                                              .map((item) => DropdownMenuItem(
                                                  child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        item['veh_brand'],
                                                        style: montserratLight
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 12),
                                                      )),
                                                  value: item['veh_brand']
                                                      .toString()))
                                              .toList(),
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
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: width * 0.025,
                                            left: width * 0.025),
                                        child: DropdownButtonFormField(
                                          key: modelKey,
                                          isExpanded: true,
                                          decoration: InputDecoration.collapsed(
                                              hintText: ''),
                                          hint: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Model",
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: blackColor,
                                                        fontSize: 14),
                                              )),
                                          items: data
                                              .map((item) => DropdownMenuItem(
                                                  child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        item['veh_model'],
                                                        style: montserratLight
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 12),
                                                      )),
                                                  value: item['veh_model']
                                                      .toString()))
                                              .toList(),
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ]),
                          SizedBox(height: height * 0.04),
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
                                            color: whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: width * 0.025,
                                                      left: width * 0.025),
                                                  child:
                                                      DropdownButtonFormField(
                                                    key: _varkey,
                                                    isExpanded: true,
                                                    decoration: InputDecoration
                                                        .collapsed(
                                                            hintText: ''),
                                                    hint: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "Variant",
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color:
                                                                      blackColor,
                                                                  fontSize: 14),
                                                        )),
                                                    items: data
                                                        .map((item) =>
                                                            DropdownMenuItem(
                                                                child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      item[
                                                                          'veh_variant'],
                                                                      style: montserratLight.copyWith(
                                                                          color:
                                                                              blackColor,
                                                                          fontSize:
                                                                              12),
                                                                    )),
                                                                value: item[
                                                                        'veh_variant']
                                                                    .toString()))
                                                        .toList(),
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
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                    ])
                              : Container(),
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
                                            color: whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: width * 0.025,
                                                      left: width * 0.025),
                                                  child:
                                                      DropdownButtonFormField(
                                                    key: _yearkey,
                                                    isExpanded: true,
                                                    decoration: InputDecoration
                                                        .collapsed(
                                                            hintText: ''),
                                                    hint: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "Year",
                                                          style: montserratRegular
                                                              .copyWith(
                                                                  color:
                                                                      blackColor,
                                                                  fontSize: 14),
                                                        )),
                                                    items: data
                                                        .map((item) =>
                                                            DropdownMenuItem(
                                                                child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      item,
                                                                      style: montserratLight.copyWith(
                                                                          color:
                                                                              blackColor,
                                                                          fontSize:
                                                                              12),
                                                                    )),
                                                                value: item
                                                                    .toString()))
                                                        .toList(),
                                                    validator: (value) {
                                                      if (value == null) {
                                                        return selectyearValidation(
                                                            value);
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      yearselected =
                                                          value.toString();
                                                    },
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
                                            right: width * 0.025),
                                        child: TextFormField(
                                          controller: plateNumberController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 15,
                                          style: montserratLight.copyWith(
                                              color: blackColor, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText:
                                                  S.of(context).mobile_number,
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: blackColor,
                                                      fontSize: 14),
                                              border: InputBorder.none,
                                              fillColor: whiteColor),
                                          validator: (value) {
                                            return mobileNumberValidation(
                                                value, context);
                                          },
                                          enabled: false,
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
                              setState(() {
                                Navigator.pushReplacementNamed(
                                    context, Routes.bottombar);
                              });
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
                                        blueColor,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    S.of(context).sign_up.toUpperCase(),
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
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

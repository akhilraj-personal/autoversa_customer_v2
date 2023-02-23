import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  final String countrycode;
  final String phone;
  const SignupPage({super.key, required this.countrycode, required this.phone});

  @override
  State<SignupPage> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  String emirates = '';
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode numberFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  List<DropdownMenuItem<String>> items = [];
  List data = List<String>.empty();
  bool isLoading = false;
  bool isoffline = false;
  StreamSubscription? internetconnection;

  @override
  void initState() {
    super.initState();
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isoffline = true;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NoInternetScreen()));
        });
      } else if (result == ConnectivityResult.mobile) {
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          isoffline = false;
        });
      }
    });
    init();
    Future.delayed(Duration.zero, () {
      _getStateList();
      numberController.text = widget.phone;
    });
  }

  Future<void> init() async {
    //
  }

  @override
  void dispose() {
    super.dispose();
    internetconnection!.cancel();
  }

  _getStateList() async {
    Map req = {
      "countryId": 1,
    };
    await getStateList(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['statelist'];
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  cust_signup() async {
    void hideKeyboard(context) =>
        FocusScope.of(context).requestFocus(FocusNode());
    setState(() {});
    var country;
    if (widget.countrycode == '+971') {
      country = "UAE";
    } else {
      country = "INDIA";
    }
    Map req = {
      "emiratesId": emirates,
      "fullname": userNameController.text.toString(),
      "email": emailController.text.toString() != ""
          ? emailController.text.toString()
          : "",
      "phone": widget.phone,
      "country_coded": widget.countrycode,
      "country": country
    };
    final prefs = await SharedPreferences.getInstance();
    await customerSignup(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() => isLoading = false);
        prefs.setString('name', value['cust_info']['name']);
        prefs.setString('email', value['cust_info']['email']);
        prefs.setString('emirate', value['cust_info']['emirate']);
        prefs.setString('language', value['cust_info']['language']);
        prefs.setString('credits', value['cust_info']['credits']);
        prefs.setBool('islogged', true);
        setState(() {
          Navigator.pushReplacementNamed(context, Routes.bottombar);
        });
      } else {
        setState(() => isLoading = false);
        showCustomToast(context, value['ret_data'],
            bgColor: warningcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      setState(() => isLoading = false);
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
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: whiteColor,
          shadowColor: whiteColor,
          leading: BackButton(onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.loginPage);
          }),
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
                            height: height * 0.12,
                            width: height * 0.12,
                          ),
                          SizedBox(height: 20),
                          Text(
                            ST.of(context).register_new_account,
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.05),
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
                                        // padding: EdgeInsets.only(
                                        //     left: width * 0.035),
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
                                            ST.of(context).emirates,
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
                                          items: data
                                              .map((item) => DropdownMenuItem(
                                                  child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        item['state_name'],
                                                        style: montserratMedium
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize:
                                                                    width *
                                                                        0.04),
                                                      )),
                                                  value: item['state_id']
                                                      .toString()))
                                              .toList(),
                                          validator: (value) {
                                            if (value == null) {
                                              return emirateValidation(
                                                  value, context);
                                            }
                                          },
                                          onChanged: (value) {
                                            emirates = value.toString();
                                          },
                                        ),
                                        //     DropdownButtonFormField(
                                        //   isExpanded: true,
                                        //   decoration: InputDecoration.collapsed(
                                        //       hintText: ''),
                                        //   hint: Align(
                                        //       alignment: Alignment.center,
                                        //       child: Text(
                                        //         ST.of(context).emirates,
                                        //         style:
                                        //             montserratRegular.copyWith(
                                        //                 color: greyColor,
                                        //                 fontSize:
                                        //                     width * 0.04),
                                        //       )),
                                        //   items: data
                                        //       .map((item) => DropdownMenuItem(
                                        //           child: Align(
                                        //               alignment:
                                        //                   Alignment.center,
                                        //               child: Text(
                                        //                 item['state_name'],
                                        //                 style: montserratLight
                                        //                     .copyWith(
                                        //                         color:
                                        //                             blackColor,
                                        //                         fontSize:
                                        //                             width *
                                        //                                 0.034),
                                        //               )),
                                        //           value: item['state_id']
                                        //               .toString()))
                                        //       .toList(),
                                        //   validator: (value) {
                                        //     if (value == null) {
                                        //       return emirateValidation(
                                        //           value, context);
                                        //     }
                                        //   },
                                        //   onChanged: (value) {
                                        //     emirates = value.toString();
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
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: width * 0.025,
                                            left: width * 0.025),
                                        child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          controller: userNameController,
                                          keyboardType: TextInputType.text,
                                          textAlign: TextAlign.center,
                                          maxLength: 50,
                                          style: montserratMedium.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.04),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText:
                                                  ST.of(context).full_name,
                                              hintStyle:
                                                  montserratMedium.copyWith(
                                                      color: userNameFocus
                                                              .hasFocus
                                                          ? greyColor
                                                              .withOpacity(0.6)
                                                          : blackColor,
                                                      fontSize: width * 0.04),
                                              border: InputBorder.none,
                                              fillColor: whiteColor),
                                          focusNode: userNameFocus,
                                          onFieldSubmitted: (value) {
                                            userNameFocus.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(emailFocus);
                                          },
                                          validator: (value) {
                                            return fullNameValidation(
                                                value, context);
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
                                        child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textAlign: TextAlign.center,
                                          maxLength: 80,
                                          style: montserratMedium.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.04),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: ST.of(context).email,
                                              hintStyle:
                                                  montserratMedium.copyWith(
                                                      color: emailFocus.hasFocus
                                                          ? greyColor
                                                              .withOpacity(0.6)
                                                          : blackColor,
                                                      fontSize: width * 0.04),
                                              border: InputBorder.none,
                                              fillColor: whiteColor),
                                          onFieldSubmitted: (value) {
                                            FocusScope.of(context)
                                                .requestFocus(numberFocus);
                                          },
                                          focusNode: emailFocus,
                                          validator: (value) {
                                            return emailValidation(
                                                value, context);
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
                                  color: lightGreyColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: width * 0.025,
                                          right: width * 0.025),
                                      child: Text(
                                        "AE +971",
                                        style: montserratMedium.copyWith(
                                            color: blackColor,
                                            fontSize: width * 0.04),
                                      ),
                                    ),
                                    Container(
                                      height: height * 0.075,
                                      width: 2.0,
                                      color: borderGreyColor,
                                      margin: EdgeInsets.only(
                                          left: width * 0.025,
                                          right: width * 0.025),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: width * 0.025),
                                        child: TextFormField(
                                          controller: numberController,
                                          keyboardType: TextInputType.number,
                                          focusNode: numberFocus,
                                          maxLength: 10,
                                          style: montserratMedium.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.04),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText:
                                                  ST.of(context).mobile_number,
                                              hintStyle:
                                                  montserratMedium.copyWith(
                                                      color: blackColor,
                                                      fontSize: width * 0.04),
                                              border: InputBorder.none,
                                              fillColor: lightGreyColor),
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
                                if (isLoading) return;
                                setState(() => isLoading = true);
                                await Future.delayed(
                                    Duration(milliseconds: 1000));
                                cust_signup();
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
                                  child: !isLoading
                                      ? Text(
                                          ST.of(context).sign_up.toUpperCase(),
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
                                                color: whiteColor,
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
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

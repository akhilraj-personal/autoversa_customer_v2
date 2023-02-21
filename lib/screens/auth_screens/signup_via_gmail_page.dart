import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/bottom_tab/bottomtab.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/services/pre_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupViaGmail extends StatefulWidget {
  final String name;
  final String email;
  const SignupViaGmail({super.key, required this.name, required this.email});

  @override
  State<SignupViaGmail> createState() => SignupViaGmailState();
}

class SignupViaGmailState extends State<SignupViaGmail> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode numberFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String emirates = '';
  var country_code = "+91";
  String otppin = '';
  List<DropdownMenuItem<String>> items = [];
  List data = List<String>.empty();
  bool isLoading = false;
  bool isVerifiedClicked = false;
  bool isVerifymeActive = true;
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
      userNameController.text = widget.name;
      emailController.text = widget.email;
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

  verify_submit_otp(pin) async {
    void hideKeyboard(context) =>
        FocusScope.of(context).requestFocus(FocusNode());
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;
    Map req = {
      "phone": numberController.text.toString(),
      "country_code": country_code,
      "otp": pin,
      "fcm_token": osUserID
    };
    if (pin == null || pin == "") {
      setState(() {
        isLoading = false;
      });
      showCustomToast(context, ST.of(context).otp_invalid_text,
          bgColor: warningcolor, textColor: whiteColor);
    } else {
      await verifyOtp(req).then((value) {
        if (value['ret_data'] == "success") {
          // prefs.setString('cust_id', value['customer']['id']);
          // prefs.setString('phone', value['customer']['phone']);
          // prefs.setString('country_code', value['customer']['country_code']);
          // prefs.setString('token', value['token']);
          // showCustomToast(context, "OTP verified",
          //     bgColor: blackColor, textColor: whiteColor);
        } else if (value['ret_data'] == "MaxAttempt") {
          setState(() => isLoading = false);
          showCustomToast(context, ST.of(context).max_otp_text,
              bgColor: warningcolor, textColor: whiteColor);
          otppin = "";
        } else {
          setState(() => isLoading = false);
          showCustomToast(context, value['message'],
              bgColor: warningcolor, textColor: whiteColor);
        }
      }).catchError((e) {
        setState(() => isLoading = false);
        showCustomToast(context, ST.of(context).toast_application_error,
            bgColor: errorcolor, textColor: whiteColor);
      });
    }
  }

  cust_signup() async {
    void hideKeyboard(context) =>
        FocusScope.of(context).requestFocus(FocusNode());
    setState(() {});
    var country;
    Map req = {
      "emiratesId": emirates,
      "fullname": widget.name.toString(),
      "email": widget.email.toString(),
      "phone": numberController.text.toString(),
      "country_coded": country_code.toString(),
      "country": "UAE",
      // "otp": pin,
    };
    final prefs = await SharedPreferences.getInstance();
    await customerSignup(req).then((value) {
      if (value['ret_data'] == "success") {
        prefs.setString('name', value['cust_info']['name']);
        prefs.setString('email', value['cust_info']['email']);
        prefs.setString('emirate', value['cust_info']['emirate']);
        prefs.setString('language', value['cust_info']['language']);
        prefs.setString('credits', value['cust_info']['credits']);
        setState(() {
          Navigator.pushReplacementNamed(context, Routes.bottombar);
        });
      } else {
        showCustomToast(context, value['ret_data'],
            bgColor: warningcolor, textColor: whiteColor);
        setState(() => isLoading = false);
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
                                                ST.of(context).emirates,
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
                                                        item['state_name'],
                                                        style: montserratLight
                                                            .copyWith(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 12),
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
                                          controller: userNameController,
                                          keyboardType: TextInputType.text,
                                          textAlign: TextAlign.center,
                                          maxLength: 50,
                                          style: montserratLight.copyWith(
                                              color: blackColor, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText:
                                                  ST.of(context).full_name,
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: blackColor,
                                                      fontSize: 14),
                                              border: InputBorder.none,
                                              fillColor: whiteColor),
                                          focusNode: userNameFocus,
                                          onFieldSubmitted: (value) {
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
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textAlign: TextAlign.center,
                                          maxLength: 80,
                                          style: montserratLight.copyWith(
                                              color: blackColor, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText: ST.of(context).email,
                                              hintStyle:
                                                  montserratRegular.copyWith(
                                                      color: blackColor,
                                                      fontSize: 14),
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
                                  color: whiteColor,
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
                                        style: montserratLight.copyWith(
                                            color: blackColor, fontSize: 14),
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
                                          style: montserratLight.copyWith(
                                              color: blackColor, fontSize: 14),
                                          decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: warningcolor),
                                              counterText: "",
                                              filled: true,
                                              hintText:
                                                  ST.of(context).mobile_number,
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
                          Text(
                            ST.of(context).send_verification_msg +
                                " " +
                                ST.of(context).to_mentioned_number +
                                "." +
                                ST.of(context).please_enter_the_code,
                            style: montserratLight.copyWith(
                                color: lightblackColor, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.02),
                          OtpTextField(
                            numberOfFields: 4,
                            fieldWidth: width * 0.14,
                            clearText: true,
                            focusedBorderColor: syanColor,
                            cursorColor: syanColor,
                            showFieldAsBox: true,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0)),
                            onCodeChanged: (String code) {
                              setState(() {
                                otppin = "";
                              });
                            },
                            onSubmit: (String verificationCode) {
                              setState(() {
                                otppin = verificationCode;
                              });
                            }, // end onSubmit
                          ),
                          SizedBox(height: height * 0.04),
                          isVerifymeActive
                              ? GestureDetector(
                                  onTap: () async {
                                    setState(() => isVerifiedClicked = true);
                                    setState(() => isVerifymeActive = false);
                                  },
                                  child: Stack(
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
                                                      syanColor.withOpacity(.6),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              syanColor,
                                              lightblueColor,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          "Verify Me",
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(),
                          // GestureDetector(
                          //   onTap: () async {
                          //     // if (_formKey.currentState!.validate()) {
                          //     //   if (issubmitted) return;
                          //     //   setState(() => issubmitted = true);
                          //     //   await Future.delayed(
                          //     //       Duration(milliseconds: 1000));
                          //     //   cust_signup();
                          //     // }
                          //     setState(() {
                          //       Navigator.pushReplacementNamed(
                          //           context, Routes.bottombar);
                          //     });
                          //   },
                          //   child: Stack(
                          //     alignment: Alignment.bottomCenter,
                          //     children: [
                          //       Container(
                          //         height: height * 0.045,
                          //         width: height * 0.37,
                          //         decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(14),
                          //             boxShadow: [
                          //               BoxShadow(
                          //                   blurRadius: 16,
                          //                   color: syanColor.withOpacity(.6),
                          //                   spreadRadius: 0,
                          //                   blurStyle: BlurStyle.outer,
                          //                   offset: Offset(0, 0)),
                          //             ]),
                          //       ),
                          //       Container(
                          //         height: height * 0.075,
                          //         width: height * 0.4,
                          //         alignment: Alignment.center,
                          //         decoration: BoxDecoration(
                          //           shape: BoxShape.rectangle,
                          //           borderRadius:
                          //               BorderRadius.all(Radius.circular(14)),
                          //           gradient: LinearGradient(
                          //             begin: Alignment.topLeft,
                          //             end: Alignment.bottomRight,
                          //             colors: [
                          //               syanColor,
                          //               lightblueColor,
                          //             ],
                          //           ),
                          //         ),
                          //         child: Text(
                          //           S.of(context).sign_up.toUpperCase(),
                          //           style: montserratSemiBold.copyWith(
                          //               color: Colors.white),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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

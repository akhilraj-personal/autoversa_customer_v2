import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/pre_auth_services.dart';
import '../../utils/common_utils.dart';

class LoginOTPVerification extends StatefulWidget {
  final String country_code;
  final String phone;
  final Map<String, dynamic> timer;
  const LoginOTPVerification(
      {super.key,
      required this.country_code,
      required this.phone,
      required this.timer});

  @override
  State<LoginOTPVerification> createState() => LoginOTPVerificationState();
}

class LoginOTPVerificationState extends State<LoginOTPVerification> {
  late Timer _timer;
  int OTPtimer = 0, click_count = 0;
  bool isResend = false;

  String otppin = '';

  @override
  void initState() {
    OTPtimer = int.parse(widget.timer['gs_reotp_time']);
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (OTPtimer < 1) {
            timer.cancel();
          } else {
            OTPtimer = OTPtimer - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  reSendOTP() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "phone": widget.phone,
      "country_code": widget.country_code,
    };
    await customerLoginService(req).then((value) {
      if (value['ret_data'] == "success") {
        isResend = false;
        OTPtimer = int.parse(value['timer']['gs_reotp_time']);
        click_count++;
        setState(() {});
        startTimer();
      } else {
        prefs.setBool('islogged', false);
        setState(() => isResend = false);
        showCustomToast(context, value['message'],
            bgColor: warningcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      setState(() => isResend = false);
      showCustomToast(context, "Application error. Contact support",
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  verifyViaCall() async {
    Map req = {
      "phone": widget.phone,
      "country_code": widget.country_code,
    };
    await customerOTPViaCall(req).then((value) {
      if (value['ret_data'] == "success") {
        isResend = false;
        OTPtimer = 30;
        click_count++;
        setState(() {});
        startTimer();
      } else {
        setState(() => isResend = false);
        showCustomToast(context, "Try another methode",
            bgColor: warningcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      setState(() => isResend = false);
      showCustomToast(context, "Application error. Contact support",
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  submit_otp(otpval) async {
    setState(() {
      FocusScope.of(context).unfocus();
    });
    // final prefs = await SharedPreferences.getInstance();
    // final status = await OneSignal.shared.getDeviceState();
    // final String? osUserID = status?.userId;
    // Map req = {
    //   "phone": widget.phone,
    //   "country_code": widget.countrycode,
    //   "otp": otpval,
    //   "fcm_token": osUserID
    // };
    // if (otpval == null || otpval == "") {
    //   setState(() => isOTPverifying = false);
    //   toasty(context, "Enter Valid OTP",
    //       bgColor: Color.fromARGB(255, 255, 47, 0),
    //       textColor: whiteColor,
    //       gravity: ToastGravity.BOTTOM,
    //       length: Toast.LENGTH_LONG);
    // } else {
    //   await verifyOtp(req).then((value) {
    //     if (value['ret_data'] == "success") {
    //       prefs.setBool('islogged', true);
    //       if (value['customer']['cust_type'] == "old") {
    //         prefs.setString('cust_id', value['customer']['id']);
    //         prefs.setString('name', value['customer']['name']);
    //         prefs.setString('email', value['customer']['email']);
    //         prefs.setString('phone', value['customer']['phone']);
    //         prefs.setString('country_code', value['customer']['country_code']);
    //         prefs.setString('emirate', value['customer']['emirate']);
    //         prefs.setString('language', value['customer']['language']);
    //         prefs.setString('credits', value['customer']['credits']);
    //         prefs.setString('token', value['token']);
    //         Navigator.pushAndRemoveUntil(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => AMDashScreen(
    //                 selectedindex: 0,
    //               )),
    //               (route) => false,
    //         );
    //       } else if (value['customer']['cust_type'] == "new") {
    //         prefs.setString('cust_id', value['customer']['id']);
    //         prefs.setString('phone', value['customer']['phone']);
    //         prefs.setString('country_code', value['customer']['country_code']);
    //         prefs.setString('token', value['token']);
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) => AMSignUpScreen(
    //                   countrycode: value['customer']['country_code'],
    //                   phone: value['customer']['phone'],
    //                 )));
    //       }
    //     } else if (value['ret_data'] == "MaxAttempt") {
    //       setState(() => isOTPverifying = false);
    //       toasty(context, "Maximum attempt reached. Please try again later.",
    //           bgColor: Color.fromARGB(255, 255, 47, 0),
    //           textColor: whiteColor,
    //           gravity: ToastGravity.BOTTOM,
    //           length: Toast.LENGTH_LONG);
    //       otppin = "";
    //     } else {
    //       setState(() => isOTPverifying = false);
    //       toasty(context, value['message'],
    //           bgColor: Color.fromARGB(255, 255, 47, 0),
    //           textColor: whiteColor,
    //           gravity: ToastGravity.BOTTOM,
    //           length: Toast.LENGTH_LONG);
    //     }
    //   }).catchError((e) {
    //     setState(() => isOTPverifying = false);
    //     toasty(context, e.toString(),
    //         bgColor: Color.fromARGB(255, 255, 47, 0),
    //         textColor: whiteColor,
    //         gravity: ToastGravity.BOTTOM,
    //         length: Toast.LENGTH_LONG);
    //   });
    // }
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
                      width: MediaQuery.of(context).size.width * 0.20,
                      color: whiteColor,
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
                          style:
                              montserratRegular.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
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
                          style:
                              montserratRegular.copyWith(color: Colors.black),
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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                Container(
                    padding: EdgeInsets.all(width * 0.08),
                    height: height - height * 0.12,
                    color: whiteColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageConst.verify_icon,
                          fit: BoxFit.contain,
                          height: height * 0.1,
                        ),
                        SizedBox(height: height * 0.05),
                        Text(
                          S.of(context).verify_mobile_number,
                          style: montserratSemiBold.copyWith(
                              color: blackColor, fontSize: width * 0.053),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.03),
                        Text(
                          S.of(context).we_have_send_a_6_digit_verification +
                              " +918129312321",
                          style: montserratLight.copyWith(
                              color: lightblackColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        Text('\n' + S.of(context).change_number,
                            style: montserratMedium.copyWith(
                                color: changenumberorange, fontSize: 14),
                            textAlign: TextAlign.end),
                        SizedBox(height: height * 0.03),
                        Text(
                          S.of(context).please_enter_the_code,
                          style: montserratRegular.copyWith(
                              color: blackColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.02),
                        OtpTextField(
                          numberOfFields: 6,
                          fieldWidth: width * 0.12,
                          clearText: true,
                          focusedBorderColor: syanColor,
                          cursorColor: syanColor,
                          showFieldAsBox: true,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                          onCodeChanged: (String code) {},
                          onSubmit:
                              (String verificationCode) {}, // end onSubmit
                        ),
                        SizedBox(height: 16),
                        Container(
                          child: OTPtimer == 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (isResend == false) {
                                          setState(() {
                                            isResend = true;
                                          });
                                          reSendOTP();
                                        }
                                      },
                                      child: Text(
                                          click_count >= 0
                                              ? S.of(context).resend_otp_text
                                              : "",
                                          style: montserratSemiBold.copyWith(
                                              color: lightblackColor,
                                              fontSize: 14)),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (isResend == false) {
                                          print("hi");
                                          verifyViaCall();
                                        }
                                      },
                                      child: Text(
                                        click_count >= 1
                                            ? S.of(context).verify_call_text
                                            : "",
                                        style: montserratSemiBold.copyWith(
                                            color: lightblackColor,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Text(OTPtimer.toString() +
                                          " " +
                                          S.of(context).seconds_text),
                                    ]),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pushReplacementNamed(
                                  context, Routes.gmailsignin);
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
                                  S.of(context).verify_me.toUpperCase(),
                                  style: montserratSemiBold.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ]))),
        ));
  }
}

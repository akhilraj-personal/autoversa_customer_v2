import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/auth_screens/signup_page.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
  int OTPtimer = 0, click_count = 0, verify_count = 0;
  bool isResend = false;
  bool isOtpVerifying = false;
  bool isoffline = false;
  StreamSubscription? internetconnection;

  String otppin = '';

  @override
  void initState() {
    OTPtimer = int.parse(widget.timer['gs_reotp_time']);
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
    internetconnection!.cancel();
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
        showCustomToast(context, "OTP Send Successfully",
            bgColor: toastgrey, textColor: whiteColor);
      } else {
        prefs.setBool('islogged', false);
        setState(() => isResend = false);
        showCustomToast(context, value['message'],
            bgColor: warningcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      setState(() => isResend = false);
      showCustomToast(context, ST.of(context).toast_application_error,
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
        showCustomToast(context, "Call initiated",
            bgColor: toastgrey, textColor: whiteColor);
      } else {
        setState(() => isResend = false);
        print(value);
        showCustomToast(context, ST.of(context).try_another_method,
            bgColor: warningcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      setState(() => isResend = false);
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  submit_otp(otpval) async {
    setState(() {
      FocusScope.of(context).unfocus();
    });
    if (otpval == null || otpval == "") {
      setState(() {
        isOtpVerifying = false;
      });
      showCustomToast(context, ST.of(context).otp_invalid_text,
          bgColor: warningcolor, textColor: whiteColor);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final status = await OneSignal.shared.getDeviceState();
      final String? osUserID = status?.userId;
      Map req = {
        "phone": widget.phone,
        "country_code": widget.country_code,
        "otp": otpval,
        "fcm_token": osUserID
      };
      await verifyOtp(req).then((value) {
        if (value['ret_data'] == "success") {
          verify_count++;
          prefs.setBool('islogged', true);
          if (value['customer']['cust_type'] == "old") {
            if (value['customer']['name'] == null ||
                value['customer']['emirate'] == null) {
              prefs.setString('cust_id', value['customer']['id']);
              prefs.setString('phone', value['customer']['phone']);
              prefs.setString(
                  'country_code', value['customer']['country_code']);
              prefs.setString('token', value['token']);
              setState(() => isOtpVerifying = false);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignupPage(
                            countrycode: value['customer']['country_code'],
                            phone: value['customer']['phone'],
                          )));
            } else {
              prefs.setString('cust_id', value['customer']['id']);
              prefs.setString('name', value['customer']['name']);
              prefs.setString('email', value['customer']['email']);
              prefs.setString('phone', value['customer']['phone']);
              prefs.setString(
                  'country_code', value['customer']['country_code']);
              prefs.setString('emirate', value['customer']['emirate']);
              prefs.setString('language', value['customer']['language']);
              prefs.setString('credits', value['customer']['credits']);
              prefs.setString('token', value['token']);
              setState(() => isOtpVerifying = false);
              setState(() {
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              });
            }
          } else if (value['customer']['cust_type'] == "new") {
            prefs.setString('cust_id', value['customer']['id']);
            prefs.setString('phone', value['customer']['phone']);
            prefs.setString('country_code', value['customer']['country_code']);
            prefs.setString('token', value['token']);
            setState(() => isOtpVerifying = false);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignupPage(
                          countrycode: value['customer']['country_code'],
                          phone: value['customer']['phone'],
                        )));
          }
        } else if (value['ret_data'] == "MaxAttempt") {
          verify_count++;
          setState(() => isOtpVerifying = false);
          showCustomToast(context, ST.of(context).max_otp_text,
              bgColor: warningcolor, textColor: whiteColor);
          otppin = "";
        } else {
          verify_count++;
          setState(() => isOtpVerifying = false);
          showCustomToast(context, value['message'],
              bgColor: warningcolor, textColor: whiteColor);
        }
      }).catchError((e) {
        setState(() => isOtpVerifying = false);
        print(e.toString());
        showCustomToast(context, ST.of(context).toast_application_error,
            bgColor: errorcolor, textColor: whiteColor);
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
                          ST.of(context).verify_mobile_number,
                          style: montserratSemiBold.copyWith(
                              color: blackColor, fontSize: width * 0.053),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.03),
                        Text(
                          ST.of(context).send_verification_msg +
                              widget.country_code +
                              widget.phone,
                          style: montserratLight.copyWith(
                              color: lightblackColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        Text('\n' + ST.of(context).change_number,
                            style: montserratMedium.copyWith(
                                color: changenumberorange, fontSize: 14),
                            textAlign: TextAlign.end),
                        SizedBox(height: height * 0.03),
                        Text(
                          ST.of(context).please_enter_the_code,
                          style: montserratRegular.copyWith(
                              color: blackColor, fontSize: 14),
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
                                          if (verify_count < 5) {
                                            reSendOTP();
                                          } else {
                                            showCustomToast(context,
                                                ST.of(context).max_otp_text,
                                                bgColor: warningcolor,
                                                textColor: whiteColor);
                                          }
                                        }
                                      },
                                      child: Text(
                                          click_count >= 0
                                              ? ST.of(context).resend_otp_text
                                              : "",
                                          style: montserratSemiBold.copyWith(
                                              color: lightblackColor,
                                              fontSize: 14)),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (isResend == false) {
                                          if (verify_count < 5) {
                                            verifyViaCall();
                                          } else {
                                            showCustomToast(context,
                                                ST.of(context).max_otp_text,
                                                bgColor: warningcolor,
                                                textColor: whiteColor);
                                          }
                                        }
                                      },
                                      child: Text(
                                        click_count >= 1
                                            ? ST.of(context).verify_call_text
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
                                      Text(ST.of(context).otp_resend_try +
                                          " " +
                                          OTPtimer.toString() +
                                          " " +
                                          ST.of(context).seconds_text),
                                    ]),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isOtpVerifying == false) {
                                isOtpVerifying = true;
                                submit_otp(otppin);
                              }
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
                                      lightblueColor,
                                    ],
                                  ),
                                ),
                                child: !isOtpVerifying
                                    ? Text(
                                        ST.of(context).verify_me.toUpperCase(),
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
                    )),
              ]))),
        ));
  }
}

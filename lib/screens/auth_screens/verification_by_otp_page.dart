import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/screens/auth_screens/signup_page.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';

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
  String otppin = '';

  late OTPTextEditController controller;
  late OTPInteractor _otpInteractor;

  @override
  void initState() {
    super.initState();
    startTimer();
    _otpInteractor = OTPInteractor();
    _otpInteractor
        .getAppSignature()
        .then((value) => print('signature - $value'));
    controller = OTPTextEditController(
      codeLength: 4,
      onCodeReceive: (code) => print('Your Application receive code - $code'),
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{4})');
          return exp.stringMatch(code ?? '') ?? '';
        },
        strategies: [],
      );
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
    controller.stopListen();
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
        showCustomToast(context, "OTP Sent Successfully",
            bgColor: toastgrey, textColor: whiteColor);
      } else if (value['ret_data'] ==
          "Maximum attempt reached. Please try again later") {
        prefs.setBool('islogged', false);
        setState(() => isResend = false);
        showCustomToast(context, value['ret_data'],
            bgColor: errorcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      print(e.toString());
      setState(() => isResend = false);
      showCustomToast(context, lang.S.of(context).toast_application_error,
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
      } else if (value['ret_data'] ==
          "Maximum attempt reached. Please try again later") {
        setState(() => isResend = false);
        showCustomToast(context, value['ret_data'],
            bgColor: errorcolor, textColor: whiteColor);
      }
    }).catchError((e) {
      print(e.toString());
      setState(() => isResend = false);
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    });
  }

  submit_otp(otpval) async {
    // setState(() {
    //   FocusScope.of(context).unfocus();
    // });
    if (otpval == null || otpval == "") {
      setState(() {
        isOtpVerifying = false;
      });
      showCustomToast(context, lang.S.of(context).otp_invalid_text,
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
              prefs.setBool('islogged', true);
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
          showCustomToast(context, lang.S.of(context).max_otp_text,
              bgColor: warningcolor, textColor: whiteColor);
          otppin = "";
        } else {
          verify_count++;
          setState(() => isOtpVerifying = false);
          showCustomToast(context, value['message'],
              bgColor: warningcolor, textColor: whiteColor);
        }
      }).catchError((e) {
        print(e.toString());
        setState(() => isOtpVerifying = false);
        showCustomToast(context, lang.S.of(context).toast_application_error,
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
                    height: height - height * 0.16,
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
                          lang.S.of(context).verify_mobile_number,
                          style: montserratSemiBold.copyWith(
                              color: blackColor, fontSize: width * 0.053),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.03),
                        Text(
                          lang.S.of(context).send_verification_msg +
                              widget.country_code +
                              widget.phone,
                          style: montserratLight.copyWith(
                              color: lightblackColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: () async {
                            Navigator.pushReplacementNamed(
                                context, Routes.loginPage);
                          },
                          child: Text('\n' + lang.S.of(context).change_number,
                              style: montserratMedium.copyWith(
                                  color: changenumberorange, fontSize: 14),
                              textAlign: TextAlign.end),
                        ),
                        SizedBox(height: height * 0.03),
                        Text(
                          lang.S.of(context).please_enter_the_code,
                          style: montserratRegular.copyWith(
                              color: blackColor, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height * 0.02),
                        Center(
                          child: PinCodeFields(
                            controller: controller,
                            length: 4,
                            fieldBorderStyle: FieldBorderStyle.square,
                            responsive: false,
                            fieldHeight: 53.0,
                            fieldWidth: 48.0,
                            borderWidth: 1.0,
                            activeBorderColor: syanColor,
                            activeBackgroundColor: syanColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.0),
                            keyboardType: TextInputType.number,
                            autoHideKeyboard: true,
                            fieldBackgroundColor:
                                Colors.black12.withOpacity(0.01),
                            borderColor: Colors.black38,
                            textStyle: montserratMedium.copyWith(
                                fontSize: 20.0, color: blackColor),
                            onComplete: (output) {
                              otppin = output;
                              print(otppin);
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          child: isResend
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Text("Sending..."),
                                    ])
                              : OTPtimer == 0
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
                                                setState(() {
                                                  isResend = false;
                                                });
                                                showCustomToast(
                                                    context,
                                                    lang.S
                                                        .of(context)
                                                        .max_otp_text,
                                                    bgColor: warningcolor,
                                                    textColor: whiteColor);
                                              }
                                            }
                                          },
                                          child: Text(
                                              click_count >= 0
                                                  ? lang.S
                                                      .of(context)
                                                      .resend_otp_text
                                                  : "",
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: lightblackColor,
                                                      fontSize: 14)),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            if (isResend == false) {
                                              setState(() {
                                                isResend = true;
                                              });
                                              if (verify_count < 5) {
                                                verifyViaCall();
                                              } else {
                                                setState(() {
                                                  isResend = false;
                                                });
                                                showCustomToast(
                                                    context,
                                                    lang.S
                                                        .of(context)
                                                        .max_otp_text,
                                                    bgColor: warningcolor,
                                                    textColor: whiteColor);
                                              }
                                            }
                                          },
                                          child: Text(
                                            click_count >= 1
                                                ? lang.S
                                                    .of(context)
                                                    .verify_call_text
                                                : "",
                                            style: montserratSemiBold.copyWith(
                                                color: lightblackColor,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Text(lang.S
                                                  .of(context)
                                                  .otp_resend_try +
                                              " " +
                                              OTPtimer.toString() +
                                              " " +
                                              lang.S.of(context).seconds_text),
                                        ]),
                        ),
                        SizedBox(height: 80),
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
                                        lang.S
                                            .of(context)
                                            .verify_me
                                            .toUpperCase(),
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

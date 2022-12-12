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

class LoginOTPVerification extends StatefulWidget {
  const LoginOTPVerification({super.key});

  @override
  State<LoginOTPVerification> createState() => LoginOTPVerificationState();
}

class LoginOTPVerificationState extends State<LoginOTPVerification> {
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
          body: SingleChildScrollView(
              child: Center(
                  child: Container(
                      height: height - 50,
                      width: width,
                      margin: const EdgeInsets.only(top: 50),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                height: 30,
                                width: width,
                                margin: EdgeInsets.only(
                                    left: width * 0.06, right: width * 0.06),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
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
                                          style: montserratRegular.copyWith(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
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
                                          style: montserratRegular.copyWith(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.all(width * 0.08),
                                height: height - 80,
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
                                          color: blackColor,
                                          fontSize: width * 0.053),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: height * 0.03),
                                    Text(
                                      S
                                              .of(context)
                                              .we_have_send_a_6_digit_verification +
                                          " +918129312321",
                                      style: montserratLight.copyWith(
                                          color: lightblackColor, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text('\n' + S.of(context).change_number,
                                        style: montserratMedium.copyWith(
                                            color: changenumberorange,
                                            fontSize: 14),
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
                                      autoFocus: true,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12.0)),
                                      onCodeChanged: (String code) {},
                                      onSubmit: (String
                                          verificationCode) {}, // end onSubmit
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 16, right: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {},
                                            child: Text(" ",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18)),
                                          ),
                                          Text("30 Seconds"),
                                          GestureDetector(
                                            onTap: () async {},
                                            child: Text(
                                              " ",
                                              style: montserratRegular.copyWith(
                                                  color: lightblackColor,
                                                  fontSize: width * 0.053),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          Navigator.pushReplacementNamed(
                                              context, Routes.signup);
                                        });
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
                                                      color: syanColor
                                                          .withOpacity(.6),
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.outer,
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
                                                  blueColor,
                                                ],
                                              ),
                                            ),
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .verify_me
                                                  .toUpperCase(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ])))),
        ));
  }
}

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
                                padding: EdgeInsets.all(20),
                                height: height - 90,
                                width: width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image.asset(
                                    //   'images/cp_otp_verification.png',
                                    //   width: 150,
                                    // ),
                                    SizedBox(height: 8),
                                    Text(
                                      S.of(context).verify_mobile_number,
                                      style: montserratBold.copyWith(
                                          color: blackColor,
                                          fontSize: width * 0.053),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      S
                                          .of(context)
                                          .we_have_send_a_6_digit_verification,
                                      style: montserratRegular.copyWith(
                                          color: blackColor,
                                          fontSize: width * 0.043),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text('\n' + S.of(context).change_number,
                                        style: montserratRegular.copyWith(
                                            color: Colors.orange,
                                            fontSize: width * 0.043),
                                        textAlign: TextAlign.end),
                                    SizedBox(height: 4),
                                    Text(
                                      S.of(context).please_enter_the_code,
                                      style: montserratRegular.copyWith(
                                          color: blackColor,
                                          fontSize: width * 0.043),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 12),
                                    OtpTextField(
                                      numberOfFields: 6,
                                      fieldWidth: 45,
                                      clearText: true,
                                      focusedBorderColor: Colors.lightBlue,
                                      showFieldAsBox: true,
                                      autoFocus: true,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12.0)),
                                      onCodeChanged: (String code) {},
                                      onSubmit: (String
                                          verificationCode) {}, // end onSubmit
                                    ),

                                    SizedBox(height: 16),
                                    // Container(
                                    //   margin:
                                    //       EdgeInsets.only(left: 16, right: 16),
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       GestureDetector(
                                    //         onTap: () async {},
                                    //         child: Text("Resend",
                                    //             style: const TextStyle(
                                    //                 color: Colors.black,
                                    //                 fontSize: 18)),
                                    //       ),
                                    //       Text("30 Seconds"),
                                    //       GestureDetector(
                                    //         onTap: () async {},
                                    //         child: Text(
                                    //           "Verify via call",
                                    //           style: montserratRegular.copyWith(
                                    //               color: blackColor,
                                    //               fontSize: width * 0.053),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
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
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 16,
                                                      color: Colors
                                                          .lightBlue[400]!,
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset: Offset(0, 0)),
                                                ]),
                                          ),
                                          Container(
                                            height: height * 0.065,
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
                                              style: montserratBold.copyWith(
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

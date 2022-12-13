import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  List<String> options = [
    'Emirates',
  ];
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode numberWordFocus = FocusNode();
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
          elevation: 1,
          backgroundColor: whiteColor,
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
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    height: height - 90,
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
                        SizedBox(height: height * 0.02),
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
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1),
                                            ),
                                            hintText: S.of(context).emirates,
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            filled: true,
                                            fillColor: whiteColor,
                                            isDense: false,
                                            contentPadding: EdgeInsets.fromLTRB(
                                                16, 8, 12, 8),
                                          ),
                                          items: options.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    value,
                                                    style: montserratLight
                                                        .copyWith(
                                                            color:
                                                                lightblackColor,
                                                            fontSize: 12),
                                                  )),
                                            );
                                          }).toList(),
                                          // validator: (value) {
                                          //   if (value == null) {
                                          //     return emirateValidation(
                                          //         value, context);
                                          //   }
                                          // },
                                          isDense: true,
                                          isExpanded: true,
                                          hint: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                options[0],
                                                style: montserratLight.copyWith(
                                                    color: lightblackColor,
                                                    fontSize: 12),
                                              )),
                                          onChanged: (_) {},
                                        )),
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
                                        keyboardType: TextInputType.text,
                                        textAlign: TextAlign.center,
                                        maxLength: 50,
                                        style: montserratLight.copyWith(
                                            color: lightblackColor,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                            counterText: "",
                                            filled: true,
                                            hintText: S.of(context).full_name,
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
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
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textAlign: TextAlign.center,
                                        maxLength: 10,
                                        style: montserratLight.copyWith(
                                            color: lightblackColor,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                            counterText: "",
                                            filled: true,
                                            hintText: S.of(context).email,
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            border: InputBorder.none,
                                            fillColor: whiteColor),
                                        onFieldSubmitted: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(numberWordFocus);
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
                                          color: lightblackColor, fontSize: 14),
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
                                      padding:
                                          EdgeInsets.only(right: width * 0.025),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        focusNode: numberWordFocus,
                                        maxLength: 10,
                                        style: montserratLight.copyWith(
                                            color: lightblackColor,
                                            fontSize: 12),
                                        decoration: InputDecoration(
                                            counterText: "",
                                            filled: true,
                                            hintText:
                                                S.of(context).mobile_number,
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
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
                          onTap: () {
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../constant/image_const.dart';
import '../../constant/text_style.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../provider/provider.dart';
import '../../utils/color_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

customerLogin() {}

class _LoginPageState extends State<LoginPage> {
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
                                height: height - 90,
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageConst.ai_icon,
                                      fit: BoxFit.contain,
                                      width: 115,
                                      height: 50,
                                    ),
                                    SizedBox(height: 50),
                                    Text(
                                      S.of(context).welcome_text,
                                      style: montserratSemiBold.copyWith(
                                          color: blackColor, fontSize: 21),
                                    ),
                                    SizedBox(height: 10),
                                    Stack(
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
                                                          .withOpacity(.5),
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.outer,
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
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 10),
                                                      child: Text("AE +971")),
                                                  Container(
                                                    height: height * 0.075,
                                                    width: 2.0,
                                                    color: borderGreyColor,
                                                    margin: EdgeInsets.only(
                                                        left: 10.0,
                                                        right: 10.0),
                                                  ),
                                                  Expanded(
                                                    child: TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      maxLength: 10,
                                                      style: TextStyle(
                                                          fontSize: 18.0),
                                                      decoration: InputDecoration(
                                                          counterText: "",
                                                          filled: true,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .fromLTRB(16,
                                                                      0, 16, 0),
                                                          hintText: S
                                                              .of(context)
                                                              .enter_mobile_text,
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 14),
                                                          border:
                                                              InputBorder.none,
                                                          fillColor:
                                                              whiteColor),
                                                      validator: (value) {},
                                                    ),
                                                  )
                                                ],
                                              ))
                                        ]),
                                    SizedBox(height: 20),
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
                                                  .sign_in
                                                  .toUpperCase(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      S.of(context).sign_in_alt,
                                      style: montserratRegular.copyWith(
                                          color: blackColor, fontSize: 12),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            decoration: BoxDecoration(
                                                color: Colors.greenAccent),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            decoration: BoxDecoration(
                                                color: Colors.yellow),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )),
                          ])))),
        ));
  }
}

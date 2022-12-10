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
                                    Text(
                                      S.of(context).welcome_text,
                                      style: montserratBold.copyWith(
                                          color: blackColor,
                                          fontSize: width * 0.053),
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
                                                      color: Colors
                                                          .lightBlue[400]!,
                                                      spreadRadius: 0,
                                                      blurStyle:
                                                          BlurStyle.outer,
                                                      offset: Offset(0, 0)),
                                                ]),
                                          ),
                                          Container(
                                              width: height * 0.37,
                                              margin: EdgeInsets.only(
                                                  bottom: height * 0.002),
                                              padding: EdgeInsets.only(
                                                left: width * 0.04,
                                                right: width * 0.08,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    whiteColor,
                                                    whiteColor,
                                                    whiteColor,
                                                    borderGreyColor,
                                                  ],
                                                ),
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  // CountryCodePicker(
                                                  //   initialSelection: '+971',
                                                  //   favorite: ['+971'],
                                                  //   padding: EdgeInsets.all(0),
                                                  //   showFlag: false,
                                                  // ),
                                                  Container(
                                                      child: Text("AE +971")),
                                                  Container(
                                                    height: 30.0,
                                                    width: 2.0,
                                                    color: greyColor,
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
                                                      decoration:
                                                          InputDecoration(
                                                        counterText: "",
                                                        filled: true,
                                                        contentPadding:
                                                            EdgeInsets.fromLTRB(
                                                                16, 0, 16, 0),
                                                        hintText:
                                                            "Mobile Number",
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      validator: (value) {},
                                                    ),
                                                  )
                                                ],
                                              ))
                                        ]),
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
                                                  .sign_in
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

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
          body: Center(
              child: Container(
                  height: height,
                  width: width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).welcome_text,
                          style: montserratBold.copyWith(
                              color: blackColor, fontSize: width * 0.053),
                        ),
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
                                          color: Colors.lightBlue[400]!,
                                          spreadRadius: 0,
                                          blurStyle: BlurStyle.outer,
                                          offset: Offset(0, 0)),
                                    ]),
                              ),
                              Container(
                                height: height * 0.065,
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
                                  S.of(context).sign_in.toUpperCase(),
                                  style: montserratBold.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              context
                                  .read<LanguageChangeProvider>()
                                  .changeLocale("ar");
                            },
                            child: Text("Arabic")),
                        ElevatedButton(
                            onPressed: () {
                              context
                                  .read<LanguageChangeProvider>()
                                  .changeLocale("en");
                            },
                            child: Text("English")),
                      ]))),
        ));
  }
}

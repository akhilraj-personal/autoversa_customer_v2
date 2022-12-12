import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
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
                                    style: montserratRegular.copyWith(
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.15,
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
                    ])),
          ),
        ),
      ),
    );
  }
}

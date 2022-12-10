import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    nextScreen();
    super.initState();
  }

  nextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? repeat = prefs.getBool('islogged');
    if (repeat == true) {
      Timer(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, Routes.bottombar);
      });
    } else {
      Timer(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, Routes.loginPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: blackColor,
        body: Center(
          child: Image.asset(
            ImageConst.splashImage,
            fit: BoxFit.contain,
            width: width * 0.6,
          ),
        ),
      ),
    );
  }
}

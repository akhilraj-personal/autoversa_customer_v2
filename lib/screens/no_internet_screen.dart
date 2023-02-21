import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/screens/splash_screen/splash_screen.dart';
import 'package:autoversa/utils/AppWidgets.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class NoInternetScreen extends StatefulWidget {
  static String tag = '/AMNoInternetScreen';

  @override
  NoInternetScreenState createState() => NoInternetScreenState();
}

class NoInternetScreenState extends State<NoInternetScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
        title: Text(
          "No Internet Connection",
          style: montserratSemiBold.copyWith(
            fontSize: width * 0.035,
            color: Colors.black,
          ),
        ),
      ),
      drawer: SplashScreen(),
      body: errorWidget(
        context,
        'assets/icons/no_internet_icon.png',
        'No Internet',
        'You are not connected to internet. Please connect to serve you better',
        showRetry: false,
        onRetry: () {
          showCustomToast(context, "Retrying",
              bgColor: white, textColor: Colors.black);
        },
      ),
    );
  }
}

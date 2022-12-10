import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constant/image_const.dart';
import '../constant/text_style.dart';
import '../utils/color_utils.dart';

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: whiteColor,
        iconTheme: IconThemeData(color: blackColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Center(
        child: Text(
          "Next Page.",
          style: montserratSemiBold.copyWith(
              color: blackColor, fontSize: width * 0.043),
        ),
      ),
    );
  }
}

import 'package:autoversa/constant/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'color_utils.dart';

void showCustomToast(
  BuildContext context,
  String? text, {
  ToastGravity? gravity,
  length = Toast.LENGTH_SHORT,
  Color? bgColor,
  Color? textColor,
  bool print = false,
  bool removeQueue = false,
  Duration? duration,
  BorderRadius? borderRadius,
  EdgeInsets? padding,
}) {
  FToast().init(context);
  if (removeQueue) FToast().removeCustomToast();

  FToast().showToast(
    child: Container(
      child: Text(text!, style: montserratSemiBold.copyWith(color: whiteColor)),
      decoration: BoxDecoration(
        color: bgColor ?? blackColor,
        boxShadow: [
          BoxShadow(
              blurRadius: 14,
              color: greyColor,
              spreadRadius: 0,
              blurStyle: BlurStyle.outer,
              offset: Offset(0, 0)),
        ],
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 30),
    ),
    gravity: gravity ?? ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 4),
  );
}

class RadiantGradientMask extends StatelessWidget {
  final Widget child;
  RadiantGradientMask({required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          lightblueColor,
          syanColor,
        ],
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: child,
    );
  }
}

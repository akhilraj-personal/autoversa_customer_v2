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
              blurRadius: 16,
              color: syanColor,
              spreadRadius: 0,
              blurStyle: BlurStyle.outer,
              offset: Offset(0, -7)),
        ],
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 30),
    ),
    gravity: gravity ?? ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 2),
  );
}

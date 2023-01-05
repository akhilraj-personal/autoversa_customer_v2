import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String convertDate(date) {
  try {
    return date != null
        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(date))
        : '';
  } catch (e) {
    print(e);
    return '';
  }
}

class CustomTheme extends StatelessWidget {
  final Widget? child;

  CustomTheme({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: syanColor,
        accentColor: syanColor,
        colorScheme: ColorScheme.light(primary: syanColor),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      ),
      child: child!,
    );
  }
}

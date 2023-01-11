import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({super.key});

  @override
  State<LanguageSelection> createState() => LanguageSelectionState();
}

class LanguageSelectionState extends State<LanguageSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: white,
          shadowColor: white,
          iconTheme: IconThemeData(color: white),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
          ),
          actions: [
            Center(
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: width,
                    height: height * 0.12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          lightblueColor,
                          syanColor,
                        ],
                      ),
                    ),
                    child: ClipPath(
                      clipper: SinCosineWaveClipper(
                        verticalPosition: VerticalPosition.top,
                      ),
                      child: Container(
                        height: height * 0.31,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            syanColor.withOpacity(0.3),
                            Color.fromARGB(255, 176, 205, 210),
                          ],
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        // body: LanguageListWidget(
        //   widgetType: WidgetType.LIST,
        //   onLanguageChange: (v) async {
        //     await v.languageCode!;
        //     setState(() {});
        //   },
        // ),
      ),
    );
  }
}

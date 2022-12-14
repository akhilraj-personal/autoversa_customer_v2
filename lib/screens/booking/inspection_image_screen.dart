import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/screens/booking/image_full_screen.dart';
import 'package:autoversa/screens/booking/image_size_widget.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nb_utils/nb_utils.dart';

class InspectionImageScreen extends StatefulWidget {
  final List<dynamic> img;
  const InspectionImageScreen({required this.img, super.key});

  @override
  State<InspectionImageScreen> createState() => InspectionImageScreenState();
}

class InspectionImageScreenState extends State<InspectionImageScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

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
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2),
          shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.img.length,
          itemBuilder: (context, index) {
            return InkWell(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 2,
                  top: 2,
                  right: 2,
                ),
                width: width,
                child: ImageWidget(
                  img: dotenv.env['aws_url']! + widget.img[index],
                ),
              ),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                ImageFullscreen(img: dotenv.env['aws_url']! + widget.img[index])
                    .launch(context);
              },
            );
          },
        ),
      ),
    );
  }
}

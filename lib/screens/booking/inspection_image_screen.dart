import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/model/model.dart';
import 'package:autoversa/screens/booking/image_full_screen.dart';
import 'package:autoversa/screens/booking/image_size_widget.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nb_utils/nb_utils.dart';

class InspectionImageScreen extends StatefulWidget {
  final List<MediaItem> img;
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
            flexibleSpace: Container(
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
            title: Text(
              "Vehicle Images",
              style: montserratRegular.copyWith(
                fontSize: width * 0.044,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 18,
            ),
          ),
          body: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            shrinkWrap: true,
            itemCount: widget.img.length,
            itemBuilder: (context, index) {
              double screenWidth = MediaQuery.of(context).size.width;
              double itemWidth = (screenWidth - 8.0 * 3) / 2;
              double itemHeight = itemWidth;
              return InkWell(
                child: Card(
                  color: Colors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: [
                        Container(
                          width: itemWidth,
                          height: itemHeight,
                          child: ImageWidget(
                            img: dotenv.env['aws_url']! + widget.img[index].url,
                          ),
                        ),
                        if (widget.img[index].type == "5") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Front View",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "3") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Right View",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "4") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Back View",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "2") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Left View",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "1") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Top View",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "0") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Additional\nImage",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "10" &&
                            widget.img[index].additionaltype == "5") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Odometer",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ] else if (widget.img[index].type == "10" &&
                            widget.img[index].additionaltype == "6") ...[
                          Positioned(
                            left: 8.0,
                            bottom: 20.0,
                            child: Text(
                              "Vin Number",
                              style: montserratSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  ImageFullscreen(
                    img: dotenv.env['aws_url']! + widget.img[index].url,
                  ).launch(context);
                },
              );
            },
          )),
    );
  }
}

import 'dart:async';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageFullscreen extends StatefulWidget {
  final String? img;
  const ImageFullscreen({this.img, super.key});

  @override
  State<ImageFullscreen> createState() => ImageFullscreenState();
}

class ImageFullscreenState extends State<ImageFullscreen> {
  bool isoffline = false;
  StreamSubscription? internetconnection;
  @override
  void initState() {
    super.initState();
    // internetconnection = Connectivity()
    //     .onConnectivityChanged
    //     .listen((ConnectivityResult result) {
    //   if (result == ConnectivityResult.none) {
    //     setState(() {
    //       isoffline = true;
    //       Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => NoInternetScreen()));
    //     });
    //   } else if (result == ConnectivityResult.mobile) {
    //     setState(() {
    //       isoffline = false;
    //     });
    //   } else if (result == ConnectivityResult.wifi) {
    //     setState(() {
    //       isoffline = false;
    //     });
    //   }
    // });
    init();
  }

  void init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void dispose() {
    super.dispose();
    internetconnection!.cancel();
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
            "Vehicle Image",
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3)),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: widget.img!,
                      height: 450.0,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

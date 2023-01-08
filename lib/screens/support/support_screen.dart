import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/screens/support/chat_screen.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:nb_utils/nb_utils.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => SupportState();
}

@override
void initState() {
  init();
}

Future<void> init() async {}

@override
void setState(fn) {}

@override
void dispose() {}

class SupportState extends State<Support> {
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
        body: Column(
          children: [
            Container(
              width: context.width(),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radiusOnly(topRight: 32),
                backgroundColor: white,
              ),
              child: Column(
                children: [
                  16.height,
                  Row(
                    children: [
                      8.width,
                      Text("Get in touch", style: montserratSemiBold.copyWith())
                          .expand(),
                      16.width,
                    ],
                  ).paddingOnly(right: 16, left: 16),
                  16.height,
                  Row(
                    children: [
                      8.width,
                      Text(
                        "Our advisor will be more than happy to help you. We are eager to discuss inquires. You may call us on number mentioned below during office hours for bookings and concern. Your happiness and saftey is our main priority. ",
                        style: montserratRegular.copyWith(
                            fontSize: 14, color: black),
                      ).expand(),
                      16.width,
                    ],
                  ).paddingOnly(right: 16, left: 16),
                  16.height,
                  Container(
                    margin: new EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(8)),
                                  Text(
                                    "Office Time",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14, color: black),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    ": 9:00AM - 6:00PM",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14, color: black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        8.height,
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(8)),
                                  Text(
                                    "Working Days",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14, color: black),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    ": Sunday - Thursday",
                                    style: montserratRegular.copyWith(
                                        fontSize: 14, color: black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: FloatingActionButton(
                            heroTag: '1',
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.call,
                              color: Colors.black,
                            ),
                            onPressed: () {}),
                      ),
                      16.width,
                      AppButton(
                          padding: EdgeInsets.all(12),
                          color: syanColor,
                          text: 'CALL',
                          height: 55,
                          textStyle: primaryTextStyle(
                              color: Colors.white, weight: FontWeight.bold),
                          onTap: () async {
                            const number =
                                '+971509766075'; //set the number here
                            bool? res =
                                await FlutterPhoneDirectCaller.callNumber(
                                    number);
                          }).expand()
                    ],
                  )).paddingAll(16),
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: FloatingActionButton(
                            heroTag: '2',
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.chat_bubble,
                              color: Colors.black,
                            ),
                            onPressed: () {}),
                      ),
                      16.width,
                      AppButton(
                          padding: EdgeInsets.all(12),
                          color: syanColor,
                          text: 'CHAT',
                          height: 55,
                          textStyle: primaryTextStyle(
                              color: Colors.white, weight: FontWeight.bold),
                          onTap: () {
                            // AMChatListScreen().launch(context,
                            //     pageRouteAnimation: PageRouteAnimation.Scale);
                            Chat(
                                    img: "images/automobile/serviceadvisor.jpg",
                                    name: "Support Agent")
                                .launch(context,
                                    pageRouteAnimation:
                                        PageRouteAnimation.Scale);
                          }).expand()
                    ],
                  )).paddingAll(16),
                ],
              ),
            ).flexible()
          ],
        ),
      ),
    );
  }
}

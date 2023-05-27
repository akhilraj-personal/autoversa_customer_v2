import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() => runApp(Wapp());

class Wapp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: TryoutPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class TryoutPage extends StatefulWidget {
  TryoutPage({required this.title, super.key});

  final String title;

  @override
  _TryoutPageState createState() => _TryoutPageState();
}

class _TryoutPageState extends State<TryoutPage> {
  void launchWhatsApp({
    required int phone,
    required String message,
  }) async {
    String url() {
      if (Platform.isAndroid) {
        // add the [https]
        return "https://wa.me/$phone/?text=${Uri.parse(message)}"; // new line
      } else {
        // add the [https]
        return "https://api.whatsapp.com/send?phone=$phone=${Uri.parse(message)}"; // new line
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Center(
          child: GestureDetector(
            onTap: () async {
              launchWhatsApp(phone: 918330070416, message: 'Hello');
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: height * 0.045,
                  width: height * 0.37,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 16,
                            color: syanColor.withOpacity(.6),
                            spreadRadius: 0,
                            blurStyle: BlurStyle.outer,
                            offset: Offset(0, 0)),
                      ]),
                ),
                Container(
                  height: height * 0.075,
                  width: height * 0.4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        syanColor,
                        lightblueColor,
                      ],
                    ),
                  ),
                  child: Text(
                    "GO",
                    style: montserratSemiBold.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

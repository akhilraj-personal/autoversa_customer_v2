// import 'package:autoversa/screens/home/home_screen.dart';
// import 'package:autoversa/utils/color_utils.dart';
// import 'package:flutter/material.dart';

// import '../../constant/image_const.dart';
// import 'common_BottomTab.dart';

// class BottomNavBarScreen extends StatefulWidget {
//   final int index;
//   const BottomNavBarScreen({
//     Key? key,
//     required this.index,
//   }) : super(key: key);
//   @override
//   _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
// }

// class _BottomNavBarScreenState extends State<BottomNavBarScreen>
//     with TickerProviderStateMixin {
//   int currentIndex = 1;

//   @override
//   void initState() {
//     currentIndex = widget.index;
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 400),
//       value: 1,
//     );
//     super.initState();
//   }

//   late final AnimationController _controller;

//   ///------- tab screen  ----------
//   final List<Widget> viewContainer = [
//     Container(),
//     HomeScreen(),
//     Container(),
//     Container(),
//     Container(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     height = MediaQuery.of(context).size.height;
//     width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       bottomNavigationBar: PersistanceBottomTab(
//           index: currentIndex,
//           onSuccess: (val) {
//             setState(() {
//               currentIndex = val;
//             });
//           }),

//       ///------- tab screen view ----------
//       body: viewContainer[currentIndex],
//     );
//   }
// }
import 'dart:async';

import 'package:autoversa/screens/home/home_screen.dart';
import 'package:autoversa/screens/service/service_list_screen.dart';
import 'package:autoversa/screens/settings/profile_screen.dart';
import 'package:autoversa/screens/support/support_screen.dart';
import 'package:autoversa/screens/vehicle/vehicle_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/image_const.dart';
import '../../provider/provider.dart';
import 'common_BottomTab.dart';

class BottomNavBarScreen extends StatefulWidget {
  final int index;
  const BottomNavBarScreen({
    Key? key,
    required this.index,
  }) : super(key: key);
  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  // int currentIndex = 1;

  @override
  void initState() {
    index();
    super.initState();
  }

  index() {
    Timer(const Duration(milliseconds: 100), () {
      final tabNotifier = Provider.of<TabNotifier>(context, listen: false);
      tabNotifier.setindex = widget.index;
    });
  }

  ///------- tab screen  ----------
  final List<Widget> viewContainer = [
    Support(),
    HomeScreen(),
    Vehiclelist(),
    ServiceList(click_id: 1),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    var tabNotifier = context.watch<TabNotifier>();
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: PersistanceBottomTab(
          index: tabNotifier.currentIndex,
          onSuccess: (val) {
            tabNotifier.currentIndex = val;
          }),

      ///------- tab screen view ----------
      body: viewContainer[tabNotifier.currentIndex],
    );
  }
}

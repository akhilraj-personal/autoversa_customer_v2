import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/image_const.dart';
import '../../provider/provider.dart';

bool isFromEventScreen = false;

class PersistanceBottomTab extends StatefulWidget {
  final int index;

  final Function onSuccess;
  const PersistanceBottomTab({
    Key? key,
    required this.index,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PersistanceBottomTab> createState() => _PersistanceBottomTabState();
}

class _PersistanceBottomTabState extends State<PersistanceBottomTab> {
  // int currentIndex = 0;
  @override
  void initState() {
    // index();
    super.initState();
  }

  index() {
    final tabNotifier = Provider.of<TabNotifier>(context, listen: false);
    tabNotifier.setindex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    var tabNotifier = context.watch<TabNotifier>();
    return BottomAppBar(
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderGreyColor))),
        height: height * 0.07,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ///------- Home -------------
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          tabNotifier.setindex = 1;

                          widget.onSuccess(tabNotifier.getindex);
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.only(
                              left: width * 0.03,
                              right: width * 0.03,
                              top: height * 0.01,
                              bottom: height * 0.01),
                          child: Image.asset(
                            tabNotifier.getindex == 1
                                ? ImageConst.home
                                : ImageConst.unSelect_home,
                            height: height * 0.027,
                            fit: BoxFit.contain,
                          ),
                        )),
                  ),

                  ///------- car -------------

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        tabNotifier.setindex = 2;
                        widget.onSuccess(tabNotifier.getindex);
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            left: width * 0.03,
                            right: width * 0.03,
                            top: height * 0.01,
                            bottom: height * 0.01),
                        child: Image.asset(
                          ImageConst.bottom_car,
                          height: height * 0.026,
                          fit: BoxFit.contain,
                          color:
                              tabNotifier.getindex == 2 ? syanColor : greyColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),

                  ///------- tool -------------
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        tabNotifier.setindex = 3;
                        widget.onSuccess(tabNotifier.getindex);
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            left: width * 0.03,
                            right: width * 0.03,
                            top: height * 0.01,
                            bottom: height * 0.01),
                        child: Image.asset(
                          ImageConst.tool,
                          height: height * 0.027,
                          fit: BoxFit.contain,
                          color:
                              tabNotifier.getindex == 3 ? syanColor : greyColor,
                        ),
                      ),
                    ),
                  ),

                  ///------- setting -------------
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // setState(() {

                        // });
                        tabNotifier.setindex = 4;
                        widget.onSuccess(tabNotifier.getindex);
                      },
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(
                            right: width * 0.03,
                            left: width * 0.03,
                            top: height * 0.01,
                            bottom: height * 0.01),
                        child: Image.asset(
                          ImageConst.setting,
                          height: height * 0.027,
                          fit: BoxFit.contain,
                          color:
                              tabNotifier.getindex == 4 ? syanColor : greyColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment(0, -20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    tabNotifier.setindex = 0;
                    widget.onSuccess(tabNotifier.getindex);
                  });
                },
                child: Container(
                  height: height * 0.065,
                  width: height * 0.065,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        blueColor,
                        syanColor,
                      ],
                    ),
                  ),
                  child: Image.asset(
                    ImageConst.music,
                    scale: 3.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:am_soft/automobile/screens/AMEstimateDetailsScreen.dart';
// import 'package:am_soft/automobile/screens/AMTryoutCodeScreen.dart';
// import 'package:am_soft/automobile/screens/AMWorkcardScreen.dart';
// import 'package:am_soft/automobile/utils/AMConstant.dart';
// import 'package:am_soft/automobile/utils/CPColors.dart';
// import 'package:am_soft/fullApps/coinPro/screen/CPSearchScreen.dart';
// import 'package:am_soft/main/utils/AppConstant.dart';
// import 'package:am_soft/main/utils/AppWidget.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:am_soft/fullApps/coinPro/model/CPModel.dart';
// import 'package:am_soft/fullApps/coinPro/screen/CPAllCoinList.dart';
// import 'package:am_soft/fullApps/coinPro/screen/CPMyWalletScreen.dart';
// import 'package:am_soft/fullApps/coinPro/screen/CPQrScannerScreen.dart';
// import 'package:am_soft/fullApps/coinPro/screen/CPStatisticScreen.dart';
// import 'package:am_soft/fullApps/coinPro/utils/CPDataProvider.dart';
// import 'package:am_soft/fullApps/coinPro/utils/CPImages.dart';
// import 'package:am_soft/fullApps/coinPro/utils/CPWidgets.dart';
// import 'package:am_soft/main.dart';

// import 'AMNotificationFragment.dart';

// class AMHomeFragment extends StatefulWidget {
//   @override
//   AMHomeFragmentState createState() => AMHomeFragmentState();
// }

// class AMHomeFragmentState extends State<AMHomeFragment> {
//   List<CPDataModel> tradeCrypto = getTradeCryptoDataModel();
//   List<CPDataModel> tradeCryptoName = getTradeCryptoNameDataModel();
//   List<CPDataModel> myPortFolio = getMyPortFolioDataModel();

//   int tradIndex = 0;
//   String _name = '';


//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   Future<void> init() async {
//     setStatusBarColor(Colors.transparent);
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _name = "Welcome " + prefs.getString('name')!;
//     });
//   }

//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     var categoryWidth = (width - 56) / 2;
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(_name, style: boldTextStyle(size: 18)),
//         centerTitle: false,
//         backgroundColor: context.cardColor,
//         automaticallyImplyLeading: false,
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 8.0),
//             child: IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => CPSearchScreen()));
//                 },
//                 icon: Icon(Icons.notifications_active_outlined,
//                     color: appStore.isDarkModeOn ? white : black, size: 20)),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Padding(
//                 padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.4),
//                         offset: Offset(0.1, 0.1),
//                         blurRadius: 0.2,
//                         spreadRadius: 0.2,
//                       ),
//                       BoxShadow(
//                           color: context.cardColor,
//                           offset: Offset(0.0, 0.0),
//                           blurRadius: 0.0,
//                           spreadRadius: 0.0),
//                     ],
//                     borderRadius: BorderRadius.circular(16.0),
//                   ),
//                   child: Stack(
//                     children: <Widget>[
//                       Container(
//                         padding: EdgeInsets.all(16),
//                         decoration: boxDecoration(bgColor: t12_cat2.withOpacity(0.1), radius: 16.0),
//                         child: Column(
//                           children: <Widget>[
//                             Row(
//                               children: <Widget>[
//                                 Image.asset(
//                                   'images/automobile/oil_png.png',
//                                   height: 50,
//                                   width: 60,
//                                   fit: BoxFit.cover,
//                                   alignment:  Alignment.center,
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     padding: EdgeInsets.only(left: 16),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: <Widget>[
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: <Widget>[
//                                             text("OIL SERVICE",
//                                                 textColor: CPPrimaryColor,
//                                                 fontFamily: 'Bold',
//                                                 fontSize: 20.0,
//                                                 maxLine: 2),
//                                             Container(
//                                               decoration:
//                                               BoxDecoration(
//                                                 color: CPPlusCoinPer,
//                                                 borderRadius:
//                                                 BorderRadius.circular(
//                                                         16.0),
//                                               ),
//                                               padding:
//                                               EdgeInsets.fromLTRB(
//                                                   8, 2, 8, 2),
//                                               child: Text("Within 4 Hours",
//                                                   style: TextStyle(
//                                                     color: white,
//                                                     fontSize: 10,
//                                                     fontWeight:
//                                                     FontWeight
//                                                         .bold,
//                                                   )),
//                                             ),
//                                             // text('Starting from AED300', textColor: appStore.textSecondaryColor, fontSize: textSizeMedium),
//                                           ],
//                                         ),
//                                         text('Starting from AED300',
//                                             fontSize: textSizeMedium,
//                                             textColor:
//                                                 appStore.textPrimaryColor,
//                                             fontFamily: fontMedium),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               ],
//                               mainAxisAlignment: MainAxisAlignment.start,
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Container(
//                       //   width: 4,
//                       //   height: 35,
//                       //   margin: EdgeInsets.only(top: 16),
//                       //   color: pos % 2 == 0 ? t1TextColorPrimary : t1_colorPrimary,
//                       // )
//                     ],
//                   ),
//                 )),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
//                       child:
//                       Container(
//                         width: categoryWidth,
//                         decoration: boxDecoration(bgColor: t12_cat1.withOpacity(0.1), radius: spacing_standard),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Image.asset(
//                               "images/automobile/minor_png.png",
//                               width: 140,
//                               height: 80,
//                               fit: BoxFit.contain,
//                               alignment:  Alignment.center,
//                             ),
//                             text("Minor Service", fontFamily: 'Bold',
//                                 fontSize: 18.0, textColor: appStore.textPrimaryColor),
//                             Text(
//                               "From AED 600",
//                               textAlign: TextAlign.start,
//                               overflow: TextOverflow.clip,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w400,
//                                 fontStyle: FontStyle.normal,
//                                 fontSize: 14,
//                                 color: Color(0xffa8a8a8),
//                               ),
//                             ),

//                             SizedBox(height: 10),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
//                       child:
//                       Container(
//                         width: categoryWidth,
//                         decoration: boxDecoration(bgColor: t12_cat3.withOpacity(0.1), radius: spacing_standard),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Image.asset(
//                               "images/automobile/major_png.png",
//                               width: 140,
//                               height: 80,
//                               fit: BoxFit.contain,
//                               alignment:  Alignment.center,
//                             ),
//                             text("Major Service", fontFamily: 'Bold',
//                                 fontSize: 18.0, textColor: appStore.textPrimaryColor),
//                             Text(
//                               "From AED 800",
//                               textAlign: TextAlign.start,
//                               overflow: TextOverflow.clip,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w400,
//                                 fontStyle: FontStyle.normal,
//                                 fontSize: 14,
//                                 color: Color(0xffa8a8a8),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//             Container(
//               margin: EdgeInsets.all(16),
//               padding: EdgeInsets.all(8),
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 color: Color(0xff2972ff),
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Text(
//                           "Your current balance",
//                           textAlign: TextAlign.start,
//                           overflow: TextOverflow.clip,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w400,
//                             fontStyle: FontStyle.normal,
//                             fontSize: 14,
//                             color: Color(0xfffffcfc),
//                           ),
//                         ),
//                         Icon(Icons.remove_red_eye_outlined,
//                                 color: Color(0xffffffff), size: 22)
//                             .onTap(
//                           () {
//                             AMWorkCard().launch(context,
//                                 pageRouteAnimation: PageRouteAnimation.Scale);
//                           },
//                         )
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       "\$235,554",
//                       textAlign: TextAlign.start,
//                       overflow: TextOverflow.clip,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontStyle: FontStyle.normal,
//                         fontSize: 18,
//                         color: Color(0xffffffff),
//                       ),
//                     ),
//                     SizedBox(height: 16, width: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         investType(icon: Icons.upgrade, text: "Deposit"),
//                         investType(
//                                 icon: Icons.download_outlined, text: "Estimate")
//                             .onTap(
//                           () {
//                             AMEstimateDetails().launch(context,
//                                 pageRouteAnimation: PageRouteAnimation.Scale);
//                           },
//                         ),
//                         investType(icon: Icons.refresh_outlined, text: "Tryout")
//                             .onTap(
//                           () {
//                             AMServiceHistoryDetailsNew().launch(context,
//                                 pageRouteAnimation: PageRouteAnimation.Scale);
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16, width: 16),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
//                   Text(
//                     "My Portfolio",
//                     textAlign: TextAlign.start,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       fontStyle: FontStyle.normal,
//                       fontSize: 16,
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       CPAllCoinList().launch(context,
//                           pageRouteAnimation:
//                               PageRouteAnimation.SlideBottomTop);
//                     },
//                     child: Text(
//                       "See all",
//                       textAlign: TextAlign.start,
//                       overflow: TextOverflow.clip,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontStyle: FontStyle.normal,
//                         fontSize: 14,
//                         color: Color(0xc42972ff),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 160,
//               alignment: Alignment.center,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: myPortFolio.length,
//                 shrinkWrap: true,
//                 padding: EdgeInsets.all(8),
//                 itemBuilder: (context, index) {
//                   CPDataModel data = myPortFolio[index];
//                   return Container(
//                     margin: EdgeInsets.all(8),
//                     padding: EdgeInsets.all(4),
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.4),
//                           offset: Offset(0.1, 0.1),
//                           blurRadius: 0.2,
//                           spreadRadius: 0.2,
//                         ),
//                         BoxShadow(
//                             color: context.cardColor,
//                             offset: Offset(0.0, 0.0),
//                             blurRadius: 0.0,
//                             spreadRadius: 0.0),
//                       ],
//                       borderRadius: BorderRadius.circular(16.0),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Container(
//                                 height: 35,
//                                 width: 35,
//                                 padding: EdgeInsets.all(8),
//                                 clipBehavior: Clip.antiAlias,
//                                 decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: data.bgColor),
//                                 child:
//                                     Image.asset(data.image!, fit: BoxFit.cover),
//                               ),
//                               SizedBox(width: 16),
//                               Text(
//                                 data.currencyUnit!,
//                                 textAlign: TextAlign.start,
//                                 overflow: TextOverflow.clip,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontStyle: FontStyle.normal,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Text(
//                                     data.totalAmount!,
//                                     textAlign: TextAlign.start,
//                                     overflow: TextOverflow.clip,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w800,
//                                       fontStyle: FontStyle.normal,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4, width: 16),
//                                   Text(
//                                     data.cardName!,
//                                     textAlign: TextAlign.start,
//                                     overflow: TextOverflow.clip,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w400,
//                                       fontStyle: FontStyle.normal,
//                                       fontSize: 14,
//                                       color: Color(0xffa8a8a8),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 16, width: 16),
//                               Image(
//                                   image: AssetImage(cp_chart),
//                                   height: 40,
//                                   width: 40,
//                                   fit: BoxFit.cover),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ).onTap(
//                     () {
//                       CPStatisticScreen(model: data).launch(context,
//                           pageRouteAnimation: PageRouteAnimation.Slide);
//                     },
//                     hoverColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     splashColor: Colors.transparent,
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16, width: 16),
//             Padding(
//               padding: EdgeInsets.only(left: 16),
//               child: Text(
//                 "Trade Crypto",
//                 textAlign: TextAlign.start,
//                 overflow: TextOverflow.clip,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontStyle: FontStyle.normal,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             Container(
//               height: 55,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: tradeCrypto.length,
//                 shrinkWrap: true,
//                 padding: EdgeInsets.only(left: 8, right: 8, top: 8),
//                 itemBuilder: (context, index) {
//                   CPDataModel data = tradeCrypto[index];
//                   return InkWell(
//                     onTap: () {
//                       tradIndex = index;
//                       setState(() {});
//                     },
//                     child: Container(
//                       margin: EdgeInsets.all(8),
//                       alignment: Alignment.center,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: tradIndex == index
//                             ? CPPrimaryColor
//                             : Colors.grey.withOpacity(0.1),
//                         shape: BoxShape.rectangle,
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Text(
//                         data.currencyUnit!,
//                         textAlign: TextAlign.center,
//                         overflow: TextOverflow.clip,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontStyle: FontStyle.normal,
//                           fontSize: 12,
//                           color: tradIndex == index
//                               ? Colors.white
//                               : appStore.isDarkModeOn
//                                   ? white
//                                   : Colors.black.withOpacity(0.6),
//                         ),
//                       ),
//                     ).onTap(
//                       () {
//                         tradIndex = index;
//                         setState(() {});
//                       },
//                       hoverColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                       splashColor: Colors.transparent,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             ListView.builder(
//               scrollDirection: Axis.vertical,
//               itemCount: tradeCryptoName.length,
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               padding: EdgeInsets.all(8),
//               itemBuilder: (context, index) {
//                 CPDataModel data = tradeCryptoName[index];
//                 return Slidable(
//                   actionPane: SlidableDrawerActionPane(),
//                   actionExtentRatio: 0.17,
//                   secondaryActions: [
//                     Image.asset(cp_eye, height: 20, width: 20)
//                   ],
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(16.0),
//                     splashColor: Colors.transparent,
//                     focusColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     onTap: () {
//                       CPStatisticScreen(model: data).launch(context,
//                           pageRouteAnimation: PageRouteAnimation.Slide);
//                     },
//                     child: Container(
//                       margin: EdgeInsets.all(8),
//                       padding: EdgeInsets.all(16),
//                       width: MediaQuery.of(context).size.width,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.rectangle,
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.4),
//                             offset: Offset(0.1, 0.1),
//                             blurRadius: 0.2,
//                             spreadRadius: 0.2,
//                           ), //BoxShadow
//                           BoxShadow(
//                             color: Colors.white,
//                             offset: Offset(0.0, 0.0),
//                             blurRadius: 0.0,
//                             spreadRadius: 0.0,
//                           ), //BoxShadow
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Container(
//                             height: 40,
//                             width: 40,
//                             padding: EdgeInsets.all(8),
//                             clipBehavior: Clip.antiAlias,
//                             decoration: BoxDecoration(
//                                 shape: BoxShape.circle, color: data.bgColor),
//                             child: Image.asset(data.image!, fit: BoxFit.cover),
//                           ),
//                           SizedBox(height: 16, width: 16),
//                           Expanded(
//                             flex: 1,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.max,
//                               children: [
//                                 Text(
//                                   data.currencyName!,
//                                   textAlign: TextAlign.start,
//                                   overflow: TextOverflow.clip,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontStyle: FontStyle.normal,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   data.currencyUnit!,
//                                   textAlign: TextAlign.start,
//                                   overflow: TextOverflow.clip,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontStyle: FontStyle.normal,
//                                     fontSize: 14,
//                                     color: Color(0xffacacac),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Text(
//                                 data.totalAmount!,
//                                 textAlign: TextAlign.start,
//                                 overflow: TextOverflow.clip,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontStyle: FontStyle.normal,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               SizedBox(height: 4, width: 16),
//                               Container(
//                                 width: 65,
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Color(0x1c969696),
//                                   shape: BoxShape.rectangle,
//                                   borderRadius: BorderRadius.circular(16.0),
//                                   border: Border.all(
//                                       color: Color(0x4dfffcfc), width: 1),
//                                 ),
//                                 child: Align(
//                                   alignment: Alignment(-0.1, 0.0),
//                                   child: Text(
//                                     data.percentage!,
//                                     textAlign: TextAlign.center,
//                                     overflow: TextOverflow.clip,
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w800,
//                                       fontStyle: FontStyle.normal,
//                                       fontSize: 12,
//                                       color: data.textColor,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
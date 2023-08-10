import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/screens/booking/resummery_screen.dart';
import 'package:autoversa/screens/package_screens/summery_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

class CouponListScreen extends StatefulWidget {
  final String clickid;
  final String packageid;
  var packid;
  var vehiclegroup;
  final Map<String, dynamic> bk_data;
  final String vehiclegroupid;
  final String totalamount;
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedveh;
  String currency;
  CouponListScreen(
      {required this.clickid,
      required this.packageid,
      required this.vehiclegroup,
      required this.packid,
      required this.vehiclegroupid,
      required this.bk_data,
      required this.totalamount,
      required this.package_id,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      super.key});

  @override
  State<CouponListScreen> createState() => CouponListScreenState();
}

class CouponListScreenState extends State<CouponListScreen> {
  late List couponList = [];
  final TextEditingController couponCodeController = TextEditingController();
  bool couponapplied = false;
  var appliedcouponid;
  var appliedcoupondiscounttype;
  var appliedcoupondiscount;
  var appliedcouponcode;
  var discount;
  late double netpayable = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getCouponList();
    });
  }

  getCouponList() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "cust_id": prefs.getString("cust_id"),
      "pack_id": widget.packageid,
      "vgroup_id": widget.vehiclegroupid,
      "totalamount": widget.totalamount,
    };
    print("holoooooo=====>");
    print(req);
    couponList = [];
    await getCouponsListForCustomer(req).then((value) {
      if (value['ret_data'] == "success") {
        couponList = value['coupons'];
        setState(() {});
      }
    }).catchError((e) {
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  appliedcoupon(couponid, coupondiscounttype, coupondiscount, couponcode,
      coupondiscountamount) {
    couponapplied = true;
    appliedcouponid = couponid;
    appliedcoupondiscounttype = coupondiscounttype;
    appliedcoupondiscount = coupondiscount;
    appliedcouponcode = couponcode;
    setState(() {});
    if (coupondiscounttype == "1") {
      couponapplied = true;
      netpayable = (double.parse(widget.totalamount).round()) -
          (double.parse(coupondiscountamount));
      discount = (double.parse(widget.totalamount).round() -
              double.parse(netpayable.toString()))
          .round();
      setState(() {});
    } else if (coupondiscounttype == "0") {
      couponapplied = true;
      netpayable = (double.parse(widget.totalamount).round()) -
          (double.parse(coupondiscountamount));
      discount = (double.parse(widget.totalamount).round() -
              double.parse(netpayable.toString()))
          .round();
      setState(() {});
    }
    if (widget.clickid == "direct") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SummeryPage(
                  package_id: widget.package_id,
                  custvehlist: widget.custvehlist,
                  selectedveh: widget.selectedveh,
                  currency: widget.currency,
                  couponid: appliedcouponid,
                  coupondiscounttype: appliedcoupondiscounttype,
                  coupondiscount: appliedcoupondiscount,
                  couponcode: appliedcouponcode,
                  couponapplied: couponapplied,
                  discountamount: discount,
                  netpayableamount: netpayable)));
    } else if (widget.clickid == "awaiting") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResummeryScreen(
                  bk_data: widget.bk_data,
                  custvehlist: widget.custvehlist,
                  selectedveh: widget.selectedveh,
                  currency: widget.currency,
                  couponid: appliedcouponid,
                  coupondiscounttype: appliedcoupondiscounttype,
                  coupondiscount: appliedcoupondiscount,
                  couponcode: appliedcouponcode,
                  discountamount: discount,
                  netpayableamount: netpayable,
                  couponapplied: couponapplied,
                  vehiclegroup: widget.vehiclegroup,
                  packid: widget.packid)));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  width: width,
                  height: height * 0.2,
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
                  child:
                      ////--------------- ClipPath for curv----------
                      ClipPath(
                    clipper: SinCosineWaveClipper(
                      verticalPosition: VerticalPosition.top,
                    ),
                    child: Container(
                      height: height * 0.1,
                      // padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            syanColor.withOpacity(0.2),
                            Color.fromARGB(255, 173, 175, 175),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.fromLTRB(
                          16.5, height * 0.07, height * 0.07, 16.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: width * 0.054,
                            ),
                          ),
                          SizedBox(width: width * 0.08),
                          Text(
                            "Apply Coupons",
                            style: montserratRegular.copyWith(
                              fontSize: width * 0.044,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form(
                    //   key: _formKey,
                    //   child: Container(
                    //     margin: EdgeInsets.only(left: 20, right: 20),
                    //     decoration: BoxDecoration(
                    //       color: white,
                    //       boxShadow: defaultBoxShadow(),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     child: Row(
                    //       children: <Widget>[
                    //         Expanded(
                    //           flex: 3,
                    //           child: TextFormField(
                    //             autovalidateMode:
                    //                 AutovalidateMode.onUserInteraction,
                    //             textCapitalization:
                    //                 TextCapitalization.characters,
                    //             controller: couponCodeController,
                    //             keyboardType: TextInputType.text,
                    //             textAlign: TextAlign.left,
                    //             maxLength: 20,
                    //             style: montserratMedium.copyWith(
                    //                 color: black, fontSize: width * 0.04),
                    //             decoration: InputDecoration(
                    //               contentPadding: EdgeInsets.all(14.0),
                    //               errorStyle: TextStyle(
                    //                   fontSize: 12, color: warningcolor),
                    //               counterText: "",
                    //               filled: true,
                    //               hintText: "Enter Coupon Code",
                    //               hintStyle: montserratMedium.copyWith(
                    //                   color: black, fontSize: width * 0.04),
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(10.0),
                    //                 borderSide: BorderSide.none,
                    //               ),
                    //               fillColor: white,
                    //             ),
                    //             validator: (value) {
                    //               return couponValidation(value, context);
                    //             },
                    //           ),
                    //         ),
                    //         Expanded(
                    //           flex: 1,
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               if (_formKey.currentState!.validate()) {
                    //                 couponCheck(couponCodeController.text);
                    //               }
                    //             },
                    //             child: Container(
                    //               padding: EdgeInsets.all(12.0),
                    //               decoration: BoxDecoration(
                    //                 color: white,
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //               child: TextButton(
                    //                 onPressed: () {
                    //                   if (_formKey.currentState!.validate()) {
                    //                     couponCheck(couponCodeController.text);
                    //                   }
                    //                 },
                    //                 child: Text(
                    //                   "Apply",
                    //                   style: montserratMedium.copyWith(
                    //                     fontSize: width * 0.04,
                    //                     color: warningcolor,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: couponList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    color: white),
                                padding: EdgeInsets.only(top: 8.0, bottom: 8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 35,
                                          width: 35,
                                          decoration:
                                              boxDecorationWithRoundedCorners(
                                            backgroundColor: syanColor,
                                            borderRadius: radius(10),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                ImageConst.coupon_icon,
                                                width: 25,
                                              ),
                                            ],
                                          ),
                                        ),
                                        14.width,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: couponList[index]
                                                                    [
                                                                    'coupon_discount_type'] ==
                                                                "1"
                                                            ? Text(
                                                                "Save " +
                                                                    couponList[
                                                                            index]
                                                                        [
                                                                        'coupon_discount'] +
                                                                    " % cashback using below code",
                                                                style: montserratMedium
                                                                    .copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.04),
                                                              )
                                                            : Text(
                                                                "Save AED " +
                                                                    couponList[
                                                                            index]
                                                                        [
                                                                        'coupon_discount'] +
                                                                    " cashback using below code",
                                                                style: montserratRegular
                                                                    .copyWith(
                                                                        fontSize:
                                                                            width *
                                                                                0.04),
                                                              ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          appliedcoupon(
                                                              couponList[index]
                                                                  ['coupon_id'],
                                                              couponList[index][
                                                                  'coupon_discount_type'],
                                                              couponList[index][
                                                                  'coupon_discount'],
                                                              couponList[index][
                                                                  'coupon_code'],
                                                              couponList[index][
                                                                  'discountamount']);
                                                        },
                                                        child: Text(
                                                          "Apply",
                                                          style:
                                                              montserratMedium
                                                                  .copyWith(
                                                            fontSize:
                                                                width * 0.04,
                                                            color: warningcolor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  DottedBorder(
                                                    color: blueColor,
                                                    strokeWidth: 1,
                                                    padding: EdgeInsets.all(2),
                                                    radius: Radius.circular(20),
                                                    child: ClipRRect(
                                                      child: Container(
                                                        width: width * 0.3,
                                                        color: white,
                                                        child: Text(
                                                                couponList[index]
                                                                        [
                                                                        'coupon_code']
                                                                    .toUpperCase(),
                                                                style: montserratSemiBold
                                                                    .copyWith(
                                                                        color:
                                                                            blueColor,
                                                                        fontSize:
                                                                            16))
                                                            .center(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ).expand(),
                                      ],
                                    ).paddingOnly(
                                        right: 16.0, left: 16.0, bottom: 16.0),
                                  ],
                                ),
                              ).paddingBottom(16.0),
                            ],
                          ),
                        );
                        // Customize the Coupon widget as needed
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class Coupon extends StatelessWidget {
//   late CouponModel model;

//   Coupon(CouponModel model, int pos) {
//     this.model = model;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     return Container(
//       margin: EdgeInsets.only(
//         left: 15.0,
//         right: 15.0,
//       ),
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.grey.shade300,
//                 width: 1.0,
//               ),
//             ),
//             padding: EdgeInsets.only(top: 8.0, bottom: 8),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       height: 35,
//                       width: 35,
//                       decoration: boxDecorationWithRoundedCorners(
//                         backgroundColor: blackthemeColor,
//                         borderRadius: radius(10),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             ImageConst.coupon_icon,
//                             width: 25,
//                           ),
//                         ],
//                       ),
//                     ),
//                     14.width,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Flexible(
//                                     child: model.couponDiscountType == "1"
//                                         ? Text(
//                                             "Save " +
//                                                 model.info +
//                                                 " % cashback using above code",
//                                             style: montserratMedium.copyWith(
//                                                 fontSize: width * 0.04),
//                                           )
//                                         : Text(
//                                             "Save AED " +
//                                                 model.info +
//                                                 " cashback using above code",
//                                             style: montserratRegular.copyWith(
//                                                 fontSize: width * 0.04),
//                                           ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {},
//                                     child: Text(
//                                       "Apply",
//                                       style: TextStyle(
//                                         fontSize: width * 0.04,
//                                         color: warningcolor,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               DottedBorder(
//                                 color: blueColor,
//                                 strokeWidth: 1,
//                                 padding: EdgeInsets.all(2),
//                                 radius: Radius.circular(20),
//                                 child: ClipRRect(
//                                   child: Container(
//                                     width: width * 0.3,
//                                     color: white,
//                                     child: Text(model.couponsCode.toUpperCase(),
//                                             style: montserratSemiBold.copyWith(
//                                                 color: blueColor, fontSize: 16))
//                                         .center(),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ).expand(),
//                   ],
//                 ).paddingOnly(right: 16.0, left: 16.0),
//               ],
//             ),
//           ).paddingBottom(16.0),
//         ],
//       ),
//     );
//   }
// }

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class ServiceList extends StatefulWidget {
  const ServiceList({super.key});

  @override
  State<ServiceList> createState() => ServiceListState();
}

class ServiceListState extends State<ServiceList> {
  // List<ServiceListdata> data = [];
  var bookingList = [];
  bool isActive = true;
  bool isoffline = false;
  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      getBookings();
    });
  }

  getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> send_data = {
      'custId': prefs.getString('cust_id'),
    };
    bookingList = [];
    await get_service_history(send_data).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          for (var bookings in value['book_list']) {
            bookingList.add(bookings);
          }
          for (var cancelled in value['cancelled_list']) {
            bookingList.add(cancelled);
          }
          isActive = false;
          setState(() {});
        });
      } else {
        isActive = false;
        setState(() {});
      }
    }).catchError((e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
    ;
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
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
        body: Container(
          child: Column(
            children: <Widget>[
              isActive
                  ? Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          padding:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey,
                              highlightColor: Colors.grey,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black, width: 1.0))),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 40),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 15, right: 10, top: 15),
                                          height: 80,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  height: 18,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 14,
                                                  width: 160,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 10,
                                                  width: 100,
                                                  color: Colors.grey,
                                                ),
                                              ]),
                                        ),
                                        Container(
                                          height: 10,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 15),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            );
                          }),
                    )
                  : Expanded(
                      child: bookingList.length > 0
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              itemCount: bookingList.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: 8.0, bottom: 8.0),
                                      padding: EdgeInsets.all(16.0),
                                      decoration:
                                          boxDecorationRoundedWithShadow(
                                        8,
                                        backgroundColor: black,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 65,
                                            width: 65,
                                            decoration:
                                                boxDecorationWithRoundedCorners(
                                              backgroundColor:
                                                  Colors.grey.shade50,
                                              borderRadius: radius(8),
                                            ),
                                            child: Image.asset(
                                                (ImageConst.default_pro_pic)
                                                    .validate(),
                                                fit: BoxFit.fill),
                                          ),
                                          8.width,
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bookingList[index]['pkg_name'],
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: black,
                                                        fontSize: 14),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                  bookingList[index]
                                                              ['cv_make'] !=
                                                          null
                                                      ? bookingList[index]
                                                              ['cv_make'] +
                                                          " " +
                                                          bookingList[index]
                                                              ['cv_model']
                                                      : "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize: 12)),
                                              8.height,
                                              Text(
                                                  bookingList[index]
                                                              ['cv_variant'] !=
                                                          null
                                                      ? bookingList[index]
                                                              ['cv_variant'] +
                                                          " (" +
                                                          bookingList[index]
                                                              ['cv_year'] +
                                                          ")"
                                                      : " (" +
                                                          bookingList[index]
                                                              ['cv_year'] +
                                                          ")",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: montserratRegular
                                                      .copyWith(
                                                          color: black,
                                                          fontSize: 12)),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                      'Date: ' +
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime
                                                                  .tryParse(
                                                            bookingList[index][
                                                                    'bk_booking_date']
                                                                .toString(),
                                                          )!),
                                                      style: montserratRegular
                                                          .copyWith()),
                                                  (bookingList[index]
                                                                  ['st_code'] !=
                                                              null &&
                                                          bookingList[index]
                                                                  ['st_code'] !=
                                                              '')
                                                      ? Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 2,
                                                                  vertical: 4),
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              boxDecorationWithRoundedCorners(
                                                            backgroundColor:
                                                                (bookingList[index]
                                                                            [
                                                                            'st_code'] ==
                                                                        "CANC")
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .green,
                                                            borderRadius:
                                                                radius(10),
                                                          ),
                                                          child: Text(
                                                            "Completed",
                                                            style: montserratRegular
                                                                .copyWith(
                                                                    color:
                                                                        black),
                                                          ).paddingOnly(
                                                              left: 8.0,
                                                              right: 8.0),
                                                        )
                                                      : Container(
                                                          width: 0, height: 0),
                                                ],
                                              ),
                                            ],
                                          ).expand(),
                                        ],
                                      ),
                                    )
                                    // Container(
                                    //   margin: EdgeInsets.only(top: 8.0),
                                    //   decoration:
                                    //       boxDecorationWithRoundedCorners(
                                    //     backgroundColor: Colors.grey.shade50,
                                    //     borderRadius: radius(12),
                                    //   ),
                                    //   child: Column(
                                    //     children: [
                                    //       20.height,
                                    //       Row(
                                    //         children: [
                                    //           Container(
                                    //             height: 75,
                                    //             width: 75,
                                    //             decoration:
                                    //                 boxDecorationWithRoundedCorners(
                                    //               backgroundColor: Colors.blue,
                                    //               borderRadius: radius(12),
                                    //             ),
                                    //             child: Column(
                                    //               mainAxisAlignment:
                                    //                   MainAxisAlignment.center,
                                    //               children: [
                                    //                 Text(
                                    //                     (DateFormat('d').format(
                                    //                         DateTime.tryParse(
                                    //                             bookingList[
                                    //                                     index][
                                    //                                 'bk_booking_date'])!)),
                                    //                     style: boldTextStyle(
                                    //                         size: 32,
                                    //                         color: white)),
                                    //                 Text(
                                    //                     (DateFormat('MMM').format(
                                    //                         DateTime.tryParse(
                                    //                             bookingList[
                                    //                                     index][
                                    //                                 'bk_booking_date'])!)),
                                    //                     style:
                                    //                         secondaryTextStyle(
                                    //                             color: white)),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //           8.width,
                                    //           Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment
                                    //                     .spaceBetween,
                                    //             children: [
                                    //               Column(
                                    //                 crossAxisAlignment:
                                    //                     CrossAxisAlignment
                                    //                         .start,
                                    //                 children: [
                                    //                   Text(
                                    //                       bookingList[index]
                                    //                           ['pkg_name'],
                                    //                       style: boldTextStyle(
                                    //                           size: 18)),
                                    //                   8.height,
                                    //                   Text(
                                    //                       bookingList[index]
                                    //                                   [
                                    //                                   'cv_make'] !=
                                    //                               null
                                    //                           ? bookingList[
                                    //                                       index]
                                    //                                   [
                                    //                                   'cv_make'] +
                                    //                               " " +
                                    //                               bookingList[
                                    //                                       index]
                                    //                                   [
                                    //                                   'cv_model']
                                    //                           : "",
                                    //                       overflow:
                                    //                           TextOverflow
                                    //                               .ellipsis,
                                    //                       style: TextStyle(
                                    //                           color: appStore
                                    //                                   .isDarkModeOn
                                    //                               ? white
                                    //                               : black,
                                    //                           fontSize: 13)),
                                    //                   8.height,
                                    //                   Text(
                                    //                       bookingList[index]
                                    //                                   [
                                    //                                   'cv_variant'] !=
                                    //                               null
                                    //                           ? bookingList[
                                    //                                       index]
                                    //                                   [
                                    //                                   'cv_variant'] +
                                    //                               " (" +
                                    //                               bookingList[
                                    //                                       index]
                                    //                                   [
                                    //                                   'cv_year'] +
                                    //                               ")"
                                    //                           : " (" +
                                    //                               bookingList[
                                    //                                       index]
                                    //                                   [
                                    //                                   'cv_year'] +
                                    //                               ")",
                                    //                       overflow:
                                    //                           TextOverflow
                                    //                               .ellipsis,
                                    //                       style: TextStyle(
                                    //                           color: appStore
                                    //                                   .isDarkModeOn
                                    //                               ? white
                                    //                               : black,
                                    //                           fontSize: 13)),
                                    //                   8.height,
                                    //                   Text(
                                    //                       'Date: ' +
                                    //                           DateFormat(
                                    //                                   'dd-MM-yyyy')
                                    //                               .format(DateTime
                                    //                                   .tryParse(
                                    //                             bookingList[index]
                                    //                                     [
                                    //                                     'bk_booking_date']
                                    //                                 .toString(),
                                    //                           )!),
                                    //                       style:
                                    //                           secondaryTextStyle()),
                                    //                   8.height,
                                    //                   Container(
                                    //                     decoration:
                                    //                         BoxDecoration(
                                    //                       color: bookingList[
                                    //                                       index]
                                    //                                   [
                                    //                                   'st_code'] ==
                                    //                               "CANC"
                                    //                           ? Colors.orange
                                    //                           : Colors.white,
                                    //                       borderRadius: const BorderRadius
                                    //                               .only(
                                    //                           bottomLeft:
                                    //                               Radius
                                    //                                   .circular(
                                    //                                       12.0),
                                    //                           topLeft:
                                    //                               Radius
                                    //                                   .circular(
                                    //                                       12.0),
                                    //                           bottomRight:
                                    //                               Radius
                                    //                                   .circular(
                                    //                                       12.0),
                                    //                           topRight: Radius
                                    //                               .circular(
                                    //                                   12.0)),
                                    //                     ),
                                    //                     padding:
                                    //                         EdgeInsets.fromLTRB(
                                    //                             10, 2, 10, 2),
                                    //                     child: bookingList[
                                    //                                     index][
                                    //                                 'st_code'] ==
                                    //                             "CANC"
                                    //                         ? Text("Cancelled",
                                    //                             style: primaryTextStyle(
                                    //                                 color:
                                    //                                     white,
                                    //                                 fontFamily:
                                    //                                     fontBold,
                                    //                                 size: 13))
                                    //                         : Row(),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ],
                                    //           ).expand(),
                                    //         ],
                                    //       ).paddingOnly(
                                    //           right: 16.0, left: 16.0),
                                    //       8.height,
                                    //       Divider(thickness: 0.5),
                                    //       8.height,
                                    //       Row(
                                    //         children: [
                                    //           Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment.end,
                                    //             children: [
                                    //               bookingList[index]
                                    //                           ['st_code'] ==
                                    //                       "CANC"
                                    //                   ? Text(
                                    //                       "Cancelled Details",
                                    //                       style:
                                    //                           secondaryTextStyle(
                                    //                               color: Colors
                                    //                                   .orange))
                                    //                   : Text(
                                    //                       language!
                                    //                           .lblServiceDetailsMessage,
                                    //                       style:
                                    //                           secondaryTextStyle(
                                    //                               color: Colors
                                    //                                   .blue)),
                                    //               4.width,
                                    //               bookingList[index]
                                    //                           ['st_code'] ==
                                    //                       "CANC"
                                    //                   ? Icon(
                                    //                       Icons.arrow_forward,
                                    //                       color: Colors.orange,
                                    //                       size: 16)
                                    //                   : Icon(
                                    //                       Icons.arrow_forward,
                                    //                       color: CPPrimaryColor,
                                    //                       size: 16),
                                    //             ],
                                    //           ).onTap(
                                    //             () {
                                    //               bookingList[index]
                                    //                           ['st_code'] ==
                                    //                       "CANC"
                                    //                   ? AMCancelledServiceHistoryDetails(
                                    //                           bk_id:
                                    //                               bookingList[
                                    //                                   index],
                                    //                           reason: bookingList[
                                    //                                   index][
                                    //                               'bkt_content'])
                                    //                       .launch(context)
                                    //                   : AMServiceHistoryDetails(
                                    //                           bk_id:
                                    //                               bookingList[
                                    //                                   index])
                                    //                       .launch(context);
                                    //             },
                                    //           ).expand()
                                    //         ],
                                    //       ).paddingOnly(
                                    //           right: 16.0, left: 16.0),
                                    //       16.height,
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                );
                              })
                          : Container(
                              height: context.height(),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    ImageConst.adrresslist_logo,
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ],
                              ),
                            ).center(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  final int click_id;
  const ServiceList({required this.click_id, super.key});

  @override
  State<ServiceList> createState() => ServiceListState();
}

class ServiceListState extends State<ServiceList> {
  var bookingList = [];
  bool isActive = true;
  bool isoffline = false;
  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      getBookings();
      print(widget.click_id);
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
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: lightGreyColor,
                              highlightColor: greyColor,
                              child: Container(
                                height: height * 0.220,
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    right: width * 0.05,
                                    top: height * 0.01,
                                    bottom: height * 0.01),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      white,
                                      white,
                                      white,
                                      borderGreyColor,
                                    ],
                                  ),
                                ),
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
                                        backgroundColor: white,
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
                                                (ImageConst
                                                        .default_service_list)
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
                                                    montserratSemiBold.copyWith(
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
                                                          .copyWith(
                                                              fontSize: 12,
                                                              color: black)),
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
                                  ],
                                );
                              })
                          : Container(
                              decoration: BoxDecoration(
                                color: white,
                              ),
                              height: context.height(),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    ImageConst.no_data_found,
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

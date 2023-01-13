import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/address/address_add_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => AddressListState();
}

class AddressListState extends State<AddressList> {
  late List custAddressList = [];
  late List stateList = [];
  List<String?> SelectAddressList = <String?>["Select Address"];
  List<String?> SelectCityList = <String?>["Select City"];
  bool isoffline = false;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      addressList();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  addressList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map req = {"customerId": prefs.getString('cust_id')};
      custAddressList = [];
      await getCustomerAddresses(req).then((value) {
        if (value['ret_data'] == "success") {
          custAddressList = value['cust_addressList'];
          for (var address in value['cust_addressList']) {
            SelectAddressList.add(address['cad_address'] +
                "\n" +
                address['city_name'] +
                ", " +
                address['state_name'] +
                ", " +
                address['country_code']);
          }
          setState(() {
            isActive = false;
          });
        } else {
          setState(() {
            isActive = false;
          });
        }
      });
      Map country = {
        "countryId": 1,
      };
      await getStateList(country).then((value) {
        if (value['ret_data'] == "success") {
          stateList = value['statelist'];
          for (var state in value['statelist']) {
            SelectCityList.add(state['state_name']);
          }
        }
      });
      setState(() {});
    } catch (e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    }
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
                      child: custAddressList.length > 0
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              itemCount: custAddressList.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.all(16.0),
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 0.1,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            SizedBox(width: 16.0),
                                            Image.asset(
                                                ImageConst.adrresslist_logo,
                                                width: width / 8,
                                                height: 50),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Flexible(
                                                        child: new Container(
                                                          padding:
                                                              new EdgeInsets
                                                                      .only(
                                                                  right: 13.0),
                                                          child: new Text(
                                                            custAddressList[index]
                                                                        [
                                                                        'cad_address'] !=
                                                                    null
                                                                ? custAddressList[
                                                                        index][
                                                                    'cad_address']
                                                                : "",
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 13.0,
                                                              color: black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  4.height,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                          custAddressList[index]
                                                                      [
                                                                      'state_name'] !=
                                                                  null
                                                              ? "City" +
                                                                  ": " +
                                                                  custAddressList[
                                                                          index]
                                                                      [
                                                                      'state_name']
                                                              : "",
                                                          style:
                                                              montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12)),
                                                    ],
                                                  ),
                                                  4.height,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                          custAddressList[index]
                                                                      [
                                                                      'city_name'] !=
                                                                  null
                                                              ? "Area" +
                                                                  ": " +
                                                                  custAddressList[
                                                                          index]
                                                                      [
                                                                      'city_name']
                                                              : "",
                                                          style:
                                                              montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12)),
                                                    ],
                                                  ),
                                                  4.height,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                          custAddressList[index]
                                                                      [
                                                                      'cad_landmark'] !=
                                                                  null
                                                              ? "Building Name/Flat No" +
                                                                  ": " +
                                                                  custAddressList[
                                                                          index]
                                                                      [
                                                                      'cad_landmark']
                                                              : "",
                                                          maxLines: 5,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style:
                                                              montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12)),
                                                    ],
                                                  ),
                                                  4.height,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                          custAddressList[index]
                                                                      [
                                                                      'cad_address_type'] !=
                                                                  null
                                                              ? "Type" +
                                                                  ": " +
                                                                  custAddressList[
                                                                          index]
                                                                      [
                                                                      'cad_address_type']
                                                              : "",
                                                          style:
                                                              montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          13)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                );
                              })
                          : Container(
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
        floatingActionButton: FloatingActionButton(
          child: Container(
            width: 60,
            height: 60,
            child: Icon(
              Icons.add,
            ),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [lightblueColor, syanColor])),
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddressAdd()));
          },
          heroTag: 'Add Address',
        ),
      ),
    );
  }
}

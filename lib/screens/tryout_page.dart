import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/address/address_add_screen.dart';
import 'package:autoversa/screens/settings/profile_screen.dart';
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
          setState(() {
            isActive = false;
          });
        } else {
          setState(() {
            isActive = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isActive = false;
      });
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    }
  }

  address_delete(id) async {
    Map delreq = {"cad_id": id};
    print(delreq);
    await deleteCustomerAddress(delreq).then((value) {
      if (value['ret_data'] == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddressList();
            },
          ),
        );
        showCustomToast(context, "Address Deleted",
            bgColor: Colors.black, textColor: Colors.white);
      } else {
        print(value);
      }
    }).catchError((e) {
      print(e.toString());
      setState(() {
        isActive = false;
      });
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    });
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
            "Address List",
            style: myriadproregular.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ProfilePage();
                  },
                ),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 18,
          ),
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
                      child: custAddressList.length > 0
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              itemCount: custAddressList.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(17.5),
                                          padding: EdgeInsets.all(8.5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 12,
                                                    color: syanColor
                                                        .withOpacity(.9),
                                                    spreadRadius: 0,
                                                    blurStyle: BlurStyle.outer,
                                                    offset: Offset(0, 0)),
                                              ]),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(12.0),
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white,
                                                blurRadius: 0.1,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.19)),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Image.asset(
                                                    ImageConst.adrresslist_logo,
                                                    width: width / 8,
                                                    height: 50),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Flexible(
                                                          child: Container(
                                                            child: Text(
                                                              custAddressList[
                                                                      index][
                                                                  'cad_address'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style:
                                                                  montserratSemiBold
                                                                      .copyWith(
                                                                fontSize: 14,
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
                                                        Flexible(
                                                          child: Container(
                                                            child: Text(
                                                                custAddressList[index]
                                                                            [
                                                                            'state_name'] !=
                                                                        null
                                                                    ? "City" +
                                                                        ": " +
                                                                        custAddressList[index]
                                                                            [
                                                                            'state_name']
                                                                    : "",
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                style: montserratRegular
                                                                    .copyWith(
                                                                        color:
                                                                            black,
                                                                        fontSize:
                                                                            12)),
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
                                                        Flexible(
                                                          child: Container(
                                                            child: Text(
                                                                custAddressList[index]
                                                                            [
                                                                            'city_name'] !=
                                                                        null
                                                                    ? "Area" +
                                                                        ": " +
                                                                        custAddressList[index]
                                                                            [
                                                                            'city_name']
                                                                    : "",
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                style: montserratRegular
                                                                    .copyWith(
                                                                        color:
                                                                            black,
                                                                        fontSize:
                                                                            12)),
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
                                                        Flexible(
                                                          child: Container(
                                                            child: Text(
                                                                custAddressList[index]
                                                                            [
                                                                            'cad_landmark'] !=
                                                                        null
                                                                    ? "Building Name/Flat No" +
                                                                        ": " +
                                                                        custAddressList[index]
                                                                            [
                                                                            'cad_landmark']
                                                                    : "",
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                style: montserratRegular
                                                                    .copyWith(
                                                                        color:
                                                                            black,
                                                                        fontSize:
                                                                            12)),
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
                                                                        'cad_address_type'] !=
                                                                    null
                                                                ? "Type" +
                                                                    ": " +
                                                                    custAddressList[
                                                                            index]
                                                                        [
                                                                        'cad_address_type']
                                                                : "",
                                                            style: montserratRegular
                                                                .copyWith(
                                                                    color:
                                                                        black,
                                                                    fontSize:
                                                                        12)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showConfirmDialogCustom(
                                                      context,
                                                      title:
                                                          'Are you sure you want to delete this address.?',
                                                      primaryColor: syanColor,
                                                      customCenterWidget:
                                                          Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 8),
                                                        child: Image.asset(
                                                            "assets/icons/address_list_icon.png",
                                                            height: 80),
                                                      ),
                                                      onAccept: (v) {
                                                        address_delete(
                                                            custAddressList[
                                                                    index]
                                                                ['cad_id']);
                                                      },
                                                    );
                                                  },
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 8,
                                                      ),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: black,
                                                        size: 22,
                                                      )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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

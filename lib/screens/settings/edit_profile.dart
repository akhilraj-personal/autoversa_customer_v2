import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class Editprofie extends StatefulWidget {
  const Editprofie({super.key});

  @override
  State<Editprofie> createState() => EditprofieState();
}

class EditprofieState extends State<Editprofie> {
  late Map<String, dynamic> custdetails = {};
  TextEditingController fullNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController alternateNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FocusNode fullNameFocusNode = FocusNode();
  FocusNode contactNumberFocusNode = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode alternatenumberFocusNode = FocusNode();
  File? profileImage;
  var viewprofilepic;
  var givenprofilepic;
  bool issubmitted = false;
  String emirates = '';
  List<DropdownMenuItem<String>> items = [];
  List data = List<String>.empty();
  final _formKey = GlobalKey<FormState>();
  bool isoffline = false;
  StreamSubscription? internetconnection;
  int MobileLength = 0;
  File? imagePicked;
  bool profilepicturechanged = false;

  @override
  void initState() {
    super.initState();
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isoffline = true;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NoInternetScreen()));
        });
      } else if (result == ConnectivityResult.mobile) {
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          isoffline = false;
        });
      }
    });
    init();
    getProfileDetails();
    _getStateList();
  }

  @override
  void dispose() {
    super.dispose();
    internetconnection!.cancel();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  _getStateList() async {
    Map req = {
      "countryId": 1,
    };
    await getStateList(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          data = value['statelist'];
          items = data
              .map((item) => DropdownMenuItem(
                  child: Text(item['state_name']),
                  value: item['state_id'].toString()))
              .toList();
        });
      } else {}
    }).catchError((e) {
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  getProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      "cust_id":
          base64.encode(utf8.encode(prefs.getString("cust_id").toString()))
    };
    await getprofiledetails(req)
        .then((value) => {
              if (value['ret_data'] == "success")
                {
                  setState(() {
                    custdetails = value['cust_info'];
                    fullNameController.text =
                        custdetails['cust_fullname'] != null
                            ? custdetails['cust_fullname']
                            : "";
                    contactNumberController.text =
                        custdetails['cust_phone'] != null
                            ? custdetails['cust_phone']
                            : "";
                    emailController.text = custdetails['cust_email'] != null
                        ? custdetails['cust_email']
                        : "";
                    alternateNumberController.text =
                        custdetails['cust_mobile'] != null
                            ? custdetails['cust_mobile']
                            : "";
                    givenprofilepic = custdetails['cust_profile_pic'];
                  }),
                }
              else
                {}
            })
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<File?> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,
      rotate: 0,
    );
    return result;
  }

  _onChanged(String value) {
    setState(() {});
  }

  onProfileUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    Map req = {
      'cust_id': prefs.getString('cust_id'),
      'fullname': fullNameController.text.toString() != null
          ? fullNameController.text.toString()
          : "",
      'custphone': contactNumberController.text.toString() != null
          ? contactNumberController.text.toString()
          : "",
      'cust_mobile': alternateNumberController.text.toString() != null
          ? alternateNumberController.text.toString()
          : "",
      'email': emailController.text.toString() != null
          ? emailController.text.toString()
          : "",
      'cust_profile_pic': custdetails['cust_profile_pic'] != null
          ? viewprofilepic != null
              ? dotenv.env['aws_url']! + viewprofilepic
              : dotenv.env['aws_url']! + custdetails['cust_profile_pic']
          : "",
      'emiratesId': emirates != null ? emirates : custdetails['state_id'],
    };
    print("====>");
    print(req);
    await profile_update(req).then((value) {
      if (value['ret_data'] == "success") {
        showCustomToast(context, "Profile Details Updated",
            bgColor: Colors.black, textColor: Colors.white);
        Navigator.pushReplacementNamed(context, Routes.bottombar);
        setState(() => issubmitted = false);
      } else {
        setState(() => issubmitted = false);
        showCustomToast(context, value['ret_data'],
            bgColor: warningcolor, textColor: Colors.white);
      }
    }).catchError((e) {
      setState(() => issubmitted = false);
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    });
  }

  void profilepictureclick() {
    Widget mOption(var icon, var value) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: syanColor,
            ),
            SizedBox(
              width: 16,
            ),
            Text(value,
                style: montserratRegular.copyWith(
                    fontSize: width * 0.034, color: Colors.black))
          ],
        ),
      );
    }

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        builder: (builder) {
          return Container(
            height: 140.0,
            color: Colors.transparent,
            child: Column(
              children: [
                mOption(Icons.camera, "Camera").onTap(() {
                  cameraImage();
                  finish(context);
                }),
                mOption(Icons.image, "Gallery").onTap(() {
                  gallaryImage();
                  finish(context);
                }),
              ],
            ),
          );
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
          centerTitle: true,
          flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            width: width,
            height: height * 0.31,
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
            "Edit Profile",
            style: montserratSemiBold.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 18,
          ),
        ),
        body: Container(
          height: height,
          width: width,
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: 110),
                padding:
                    EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
                width: context.width(),
                height: context.height(),
                decoration: boxDecorationWithShadow(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Personal Information",
                          style: montserratSemiBold.copyWith(
                              fontSize: 16, color: Colors.black)),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Full Name" + " *",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: Colors.black)),
                              SizedBox(height: 4),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: height * 0.045,
                                      width: height * 0.37,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color:
                                                    syanColor.withOpacity(.5),
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, 0)),
                                          ]),
                                    ),
                                    Container(
                                        height: height * 0.075,
                                        width: height * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderGreyColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    right: width * 0.025,
                                                    left: width * 0.025),
                                                child: TextFormField(
                                                  controller:
                                                      fullNameController,
                                                  obscureText: false,
                                                  maxLength: 50,
                                                  textAlign: TextAlign.left,
                                                  maxLines: 1,
                                                  onFieldSubmitted: (value) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            emailFocus);
                                                  },
                                                  focusNode: fullNameFocusNode,
                                                  style:
                                                      montserratLight.copyWith(
                                                          color: Colors.black,
                                                          fontSize:
                                                              width * 0.034),
                                                  decoration: InputDecoration(
                                                      errorStyle: TextStyle(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: warningcolor),
                                                      counterText: "",
                                                      filled: true,
                                                      hintText: "Full Name",
                                                      hintStyle:
                                                          montserratRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      width *
                                                                          0.034),
                                                      border: InputBorder.none,
                                                      fillColor: Colors.white),
                                                  validator: (value) {
                                                    return fullNameValidation(
                                                        value, context);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]),
                              SizedBox(height: 12),
                              Text("Email",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: Colors.black)),
                              SizedBox(
                                height: 8,
                              ),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: height * 0.045,
                                      width: height * 0.37,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color:
                                                    syanColor.withOpacity(.5),
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, 0)),
                                          ]),
                                    ),
                                    Container(
                                        height: height * 0.075,
                                        width: height * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderGreyColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    right: width * 0.025,
                                                    left: width * 0.025),
                                                child: TextFormField(
                                                  controller: emailController,
                                                  obscureText: false,
                                                  maxLength: 80,
                                                  textAlign: TextAlign.left,
                                                  maxLines: 1,
                                                  onFieldSubmitted: (value) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            alternatenumberFocusNode);
                                                  },
                                                  focusNode: emailFocus,
                                                  style:
                                                      montserratLight.copyWith(
                                                          color: Colors.black,
                                                          fontSize:
                                                              width * 0.034),
                                                  decoration: InputDecoration(
                                                      errorStyle: TextStyle(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: warningcolor),
                                                      counterText: "",
                                                      filled: true,
                                                      hintText: "Email Id",
                                                      hintStyle:
                                                          montserratRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      width *
                                                                          0.034),
                                                      border: InputBorder.none,
                                                      fillColor: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]),
                              SizedBox(height: 12),
                              Text("Emirates" + " *",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: Colors.black)),
                              SizedBox(
                                height: 8,
                              ),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: height * 0.045,
                                      width: height * 0.37,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color:
                                                    syanColor.withOpacity(.5),
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, 0)),
                                          ]),
                                    ),
                                    Container(
                                        height: height * 0.075,
                                        width: height * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderGreyColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    right: width * 0.025,
                                                    left: width * 0.025),
                                                child: DropdownButtonFormField(
                                                  isExpanded: true,
                                                  value:
                                                      custdetails['state_id'],
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                          hintText: ''),
                                                  hint: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        ST.of(context).emirates,
                                                        style: montserratRegular
                                                            .copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize:
                                                                    width *
                                                                        0.034),
                                                      )),
                                                  items: items,
                                                  validator: (value) {
                                                    if (value == null) {
                                                      return emirateValidation(
                                                          value, context);
                                                    }
                                                  },
                                                  onChanged: (value) {
                                                    emirates = value.toString();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]),
                              SizedBox(
                                height: 12,
                              ),
                              Text("Contact" + " *",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: Colors.black)),
                              SizedBox(
                                height: 8,
                              ),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: height * 0.045,
                                      width: height * 0.37,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color:
                                                    syanColor.withOpacity(.5),
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, 0)),
                                          ]),
                                    ),
                                    Container(
                                        height: height * 0.075,
                                        width: height * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderGreyColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: width * 0.025,
                                                  right: width * 0.025),
                                              child: Text(
                                                "AE +971",
                                                style: montserratLight.copyWith(
                                                    color: Colors.black,
                                                    fontSize: width * 0.034),
                                              ),
                                            ),
                                            Container(
                                              height: height * 0.075,
                                              width: 2.0,
                                              color: borderGreyColor,
                                              margin: EdgeInsets.only(
                                                  left: width * 0.025,
                                                  right: width * 0.025),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    right: width * 0.025),
                                                child: TextField(
                                                  controller:
                                                      contactNumberController,
                                                  enabled: false,
                                                  textAlign: TextAlign.left,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLines: 1,
                                                  onSubmitted: (value) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            contactNumberFocusNode);
                                                  },
                                                  focusNode:
                                                      contactNumberFocusNode,
                                                  style:
                                                      montserratLight.copyWith(
                                                          color: Colors.black,
                                                          fontSize:
                                                              width * 0.034),
                                                  decoration: InputDecoration(
                                                      errorStyle: TextStyle(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: warningcolor),
                                                      counterText: "",
                                                      filled: true,
                                                      hintText: ST
                                                          .of(context)
                                                          .mobile_number,
                                                      hintStyle:
                                                          montserratRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      width *
                                                                          0.034),
                                                      border: InputBorder.none,
                                                      fillColor: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]),
                              SizedBox(
                                height: 12,
                              ),
                              Text("Alternate Contact" + " *",
                                  style: montserratSemiBold.copyWith(
                                      fontSize: width * 0.034,
                                      color: Colors.black)),
                              SizedBox(
                                height: 8,
                              ),
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: height * 0.045,
                                      width: height * 0.37,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color:
                                                    syanColor.withOpacity(.5),
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                offset: Offset(0, 0)),
                                          ]),
                                    ),
                                    Container(
                                        height: height * 0.075,
                                        width: height * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderGreyColor),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: width * 0.025,
                                                  right: width * 0.025),
                                              child: Text(
                                                "AE +971",
                                                style: montserratLight.copyWith(
                                                    color: Colors.black,
                                                    fontSize: width * 0.034),
                                              ),
                                            ),
                                            Container(
                                              height: height * 0.075,
                                              width: 2.0,
                                              color: borderGreyColor,
                                              margin: EdgeInsets.only(
                                                  left: width * 0.025,
                                                  right: width * 0.025),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    right: width * 0.025),
                                                child: TextFormField(
                                                  controller:
                                                      alternateNumberController,
                                                  obscureText: false,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 10,
                                                  textAlign: TextAlign.left,
                                                  focusNode:
                                                      alternatenumberFocusNode,
                                                  style:
                                                      montserratLight.copyWith(
                                                          color: Colors.black,
                                                          fontSize:
                                                              width * 0.034),
                                                  decoration: InputDecoration(
                                                      errorStyle: TextStyle(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: warningcolor),
                                                      counterText: "",
                                                      filled: true,
                                                      hintText:
                                                          "Alternate Number",
                                                      hintStyle:
                                                          montserratRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      width *
                                                                          0.034),
                                                      border: InputBorder.none,
                                                      fillColor: Colors.white),
                                                  onChanged: _onChanged,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]),
                              SizedBox(height: height * 0.04),
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (issubmitted) return;
                                    setState(() => issubmitted = true);
                                    await Future.delayed(
                                        Duration(milliseconds: 1000));
                                    onProfileUpdate();
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: height * 0.045,
                                      width: height * 0.37,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 16,
                                                color:
                                                    syanColor.withOpacity(.6),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(14)),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            syanColor,
                                            lightblueColor,
                                          ],
                                        ),
                                      ),
                                      child: !issubmitted
                                          ? Text(
                                              "UPDATE",
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: Colors.white),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Transform.scale(
                                                  scale: 0.7,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8, top: 24),
                    height: 135,
                    width: 135,
                    child: profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(
                              profileImage!,
                              width: 135.0,
                              height: 135.0,
                              fit: BoxFit.fill,
                            ),
                          ).paddingTop(5)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: custdetails['cust_profile_pic'] != null
                                ? CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        Transform.scale(
                                      scale: 0.5,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                    imageUrl: dotenv.env['aws_url']! +
                                        custdetails['cust_profile_pic'],
                                    fit: BoxFit.cover,
                                    width: 135.0,
                                    height: 135.0,
                                  )
                                : Image.asset(
                                    ImageConst.default_pro_pic,
                                    height: width * 0.35,
                                  ),
                          ).paddingTop(5),
                  ),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      child: IconButton(
                          icon: Image.asset(
                            ImageConst.camera,
                            width: 20,
                            height: 20,
                            fit: BoxFit.fill,
                            color: white,
                          ),
                          onPressed: () async {
                            profilepictureclick();
                          }),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              lightblueColor,
                              syanColor,
                            ],
                          ),
                          shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void cameraImage() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final picker = ImagePicker();
      final pickedImage =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      final pickedImageFile = File(pickedImage!.path);
      if (pickedImage == null) return;
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path + '/temp.jpg';
      await compressAndGetFile(File(pickedImage.path), targetPath);

      var formData = FormData.fromMap({
        'customerImage': await MultipartFile.fromFile(targetPath,
            filename: prefs.getString("cust_id")! + 'profilepic.png'),
        'cust_id': prefs.getString('cust_id'),
      });
      String? token = prefs.getString('token');
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer ${token}";
      var response = await dio.post(
        dotenv.env['API_URL']! + 'Customer/CustomerController/imageupload',
        data: formData,
      );
      var retdata = jsonDecode(response.toString());
      print("---" + response.toString());
      if (retdata['ret_data'] == "success") {
        setState(() {
          profilepicturechanged = false;
        });
        viewprofilepic = dotenv.env['aws_url']! + retdata['cust_profile_pic'];
        setState(() => profileImage = File(pickedImage.path));
      }
    } on PlatformException catch (e) {
      setState(() {
        profilepicturechanged = false;
      });
      print('Failed: $e');
    }
  }

  void gallaryImage() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final picker = ImagePicker();
      final pickedImage =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      final pickedImageFile = File(pickedImage!.path);
      if (pickedImage == null) return;
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path + '/temp.jpg';
      await compressAndGetFile(File(pickedImage.path), targetPath);
      var formData = FormData.fromMap({
        'customerImage': await MultipartFile.fromFile(targetPath,
            filename: prefs.getString("cust_id")! + 'profilepic.png'),
        'cust_id': prefs.getString('cust_id'),
      });
      String? token = prefs.getString('token');
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer ${token}";
      var response = await dio.post(
        dotenv.env['API_URL']! + 'Customer/CustomerController/imageupload',
        data: formData,
      );
      var retdata = jsonDecode(response.toString());
      if (retdata['ret_data'] == "success") {
        setState(() {
          profilepicturechanged = true;
        });
        viewprofilepic = dotenv.env['aws_url']! + retdata['cust_profile_pic'];
        setState(() => profileImage = File(pickedImage.path));
      }
    } on PlatformException catch (e) {
      setState(() {
        profilepicturechanged = false;
      });
      print('Failed: $e');
    }
  }
}

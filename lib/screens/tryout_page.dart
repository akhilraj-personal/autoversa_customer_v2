// import 'dart:async';
// import 'package:autoversa/constant/image_const.dart';
// import 'package:autoversa/constant/text_style.dart';
// import 'package:autoversa/services/post_auth_services.dart';
// import 'package:autoversa/utils/color_utils.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:nb_utils/nb_utils.dart';

// class Tryout extends StatefulWidget {
//   const Tryout({super.key});

//   @override
//   State<Tryout> createState() => TryoutState();
// }

// class TryoutState extends State<Tryout> {
//   List<DropdownMenuItem<String>> brands = [];
//   List<DropdownMenuItem<String>> models = [];
//   List<DropdownMenuItem<String>> variants = [];
//   List<DropdownMenuItem<String>> modyears = [];

//   List data = List<String>.empty();
//   final GlobalKey<FormFieldState> modelKey = GlobalKey<FormFieldState>();
//   final GlobalKey<FormFieldState> _varkey = GlobalKey<FormFieldState>();
//   final GlobalKey<FormFieldState> _yearkey = GlobalKey<FormFieldState>();

//   TextEditingController plateNumberController = TextEditingController();
//   TextEditingController vinNumberController = TextEditingController();
//   final TextEditingController textEditingController = TextEditingController();

//   var brandname, modelname, variantname, yearselected = '';
//   final _formKey = GlobalKey<FormState>();
//   bool isvariant = false;
//   bool issubmitted = false;
//   bool isFocused = false;

//   @override
//   void initState() {
//     super.initState();
//     this._getMakeList();
//     init();
//   }

//   Future<void> init() async {}

//   _getMakeList() async {
//     await getVehicleBrands().then((value) {
//       if (value['ret_data'] == "success") {
//         setState(() {
//           data = value['brands'];
//           brands = data
//               .map((item) => DropdownMenuItem(
//                   child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         item['veh_brand'],
//                         style: montserratMedium.copyWith(
//                             color: black, fontSize: width * 0.04),
//                       )),
//                   value: item['veh_brand'].toString()))
//               .toList();
//           models = [];
//           variants = [];
//           modyears = [];
//         });
//       } else {}
//     }).catchError((e) {
//       print(e.toString());
//     });
//   }

//   getVehicleModel(brand) async {
//     data = List<String>.empty();
//     modelKey.currentState!.reset();
//     brandname = brand;
//     setState(() {
//       models = [];
//       variants = [];
//       modyears = [];
//     });
//     Map req = {
//       "brand": brand,
//     };
//     await getVehicleModels(req).then((value) {
//       if (value['ret_data'] == "success") {
//         setState(() {
//           data = value['models'];
//           models = data
//               .map((item) => DropdownMenuItem(
//                   child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         item['veh_model'],
//                         style: montserratMedium.copyWith(
//                             color: black, fontSize: width * 0.04),
//                       )),
//                   value: item['veh_model'].toString()))
//               .toList();
//         });
//       } else {}
//     }).catchError((e) {
//       print(e.toString());
//     });
//   }

//   getVariant(smodel) async {
//     data = List<String>.empty();
//     modelname = smodel;
//     setState(() {
//       _varkey.currentState?.reset();
//       variants = [];
//       modyears = [];
//     });
//     Map req = {
//       "brand": brandname,
//       "model": smodel,
//     };
//     await getVehicleVariants(req).then((value) {
//       if (value['ret_data'] == "success") {
//         setState(() {
//           data = value['variants'];
//           variants = data
//               .map((item) => DropdownMenuItem(
//                   child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         item['veh_variant_master'],
//                         style: montserratMedium.copyWith(
//                             color: black, fontSize: width * 0.04),
//                       )),
//                   value: item['veh_variant_master'].toString()))
//               .toList();
//         });
//       }
//     }).catchError((e) {
//       print(e.toString());
//     });
//   }

//   getModelyear(smodel) async {
//     data = List<String>.empty().toList();
//     _yearkey.currentState!.reset();
//     modelname = smodel;
//     Map req = {
//       "brand": brandname,
//       "model": smodel,
//     };
//     await getVehicleModelYears(req).then((value) {
//       if (value['ret_data'] == "success") {
//         setState(() {
//           var last_year = 0;
//           if (value['year'][0]['to_year'] == "9999") {
//             final now = DateTime.now();
//             final presentYear = DateTime.parse(now.toString());
//             last_year = presentYear.year;
//           } else {
//             last_year = int.parse(value['year'][0]['to_year']);
//           }
//           for (var i = int.parse(value['year'][0]['from_year']);
//               i <= last_year;
//               i++) {
//             data.add(i.toString());
//           }
//           modyears = data
//               .map((item) => DropdownMenuItem(
//                   child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         item,
//                         style: montserratMedium.copyWith(
//                             color: black, fontSize: width * 0.04),
//                       )),
//                   value: item.toString()))
//               .toList();
//         });
//       } else {}
//     }).catchError((e) {
//       print(e.toString());
//     });
//   }

//   getModelVariantYear(svariant) async {
//     variantname = svariant;
//     data = List<String>.empty().toList();
//     setState(() {
//       _yearkey.currentState?.reset();
//     });
//     Map req = {
//       "brand": brandname,
//       "model": modelname,
//       "varient": svariant,
//     };
//     await getVehicleModelVariantYears(req).then((value) {
//       if (value['ret_data'] == "success") {
//         setState(() {
//           var end_year = 0;
//           if (value['years'][0]['to_year'] == "9999") {
//             final now = DateTime.now();
//             final currentyear = DateTime.parse(now.toString());
//             end_year = currentyear.year;
//           } else {
//             end_year = int.parse(value['years'][0]['to_year']);
//           }
//           for (var i = int.parse(value['years'][0]['from_year']);
//               i <= end_year;
//               i++) {
//             data.add(i.toString());
//           }
//           modyears = data
//               .map((item) => DropdownMenuItem(
//                   child: Align(
//                       alignment: Alignment.center,
//                       child: Text(
//                         item,
//                         style: montserratMedium.copyWith(
//                             color: black, fontSize: width * 0.04),
//                       )),
//                   value: item.toString()))
//               .toList();
//         });
//       }
//     }).catchError((e) {
//       print(e.toString());
//     });
//   }

//   saveVehicleDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     Map<String, dynamic> packdata = {
//       "customer_id": prefs.getString("cust_id"),
//       "service_request_vehicle_brand": brandname,
//       "service_request_vehicle_model": modelname,
//       "service_request_vehicle_variant": variantname,
//       "service_request_vehicle_year_id": yearselected,
//       "service_request_vehicle_registration_no":
//           plateNumberController.text.toString(),
//       "service_request_vin_no": vinNumberController.text.toString(),
//     };
//     print("req=================>");
//     print(packdata);
//   }

//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion(
//       value: SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//         statusBarColor: syanColor,
//         systemNavigationBarColor: Colors.white,
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           backgroundColor: Colors.black,
//           title: Text("Service Request"),
//         ),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(top: 20, left: 40),
//                       child: Text(
//                         "Create a new Service Request",
//                         style: boldTextStyle(),
//                       ),
//                     ),
//                     Container(
//                       color: white,
//                       padding: EdgeInsets.all(20),
//                       height: height - height * 0.12,
//                       width: width,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Stack(alignment: Alignment.bottomCenter, children: [
//                             Container(
//                                 height: height * 0.075,
//                                 width: height * 0.4,
//                                 decoration: BoxDecoration(
//                                   color: white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: borderGreyColor),
//                                 ),
//                                 child: Row(
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: Container(
//                                         child: DropdownButtonFormField2(
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           decoration: InputDecoration(
//                                             isDense: true,
//                                             contentPadding: EdgeInsets.zero,
//                                             focusedBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             focusedErrorBorder:
//                                                 OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             errorBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color: const Color(0xfffff),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             errorStyle: TextStyle(
//                                               fontSize: 12,
//                                               color: warningcolor,
//                                             ),
//                                           ),
//                                           isExpanded: true,
//                                           hint: Text(
//                                             "Select Make*",
//                                           ),
//                                           alignment: Alignment.center,
//                                           buttonHeight: height * 0.075,
//                                           buttonPadding: const EdgeInsets.only(
//                                               left: 20, right: 10),
//                                           dropdownDecoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                           ),
//                                           items: brands,
//                                           validator: (value) {},
//                                           onChanged: (value) {
//                                             getVehicleModel(value);
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ))
//                           ]),
//                           SizedBox(height: height * 0.04),
//                           Stack(alignment: Alignment.bottomCenter, children: [
//                             Container(
//                                 height: height * 0.075,
//                                 width: height * 0.4,
//                                 decoration: BoxDecoration(
//                                   color: models.isNotEmpty
//                                       ? white
//                                       : lightGreyColor,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: borderGreyColor),
//                                 ),
//                                 child: Row(
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: Container(
//                                         child: DropdownButtonFormField2(
//                                           key: modelKey,
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           decoration: InputDecoration(
//                                             isDense: true,
//                                             contentPadding: EdgeInsets.zero,
//                                             focusedBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             focusedErrorBorder:
//                                                 OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             errorBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color: const Color(0xfffff),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             errorStyle: TextStyle(
//                                               fontSize: 12,
//                                               color: warningcolor,
//                                             ),
//                                           ),
//                                           isExpanded: true,
//                                           hint: Text("Select Model*"),
//                                           alignment: Alignment.center,
//                                           buttonHeight: height * 0.075,
//                                           buttonPadding: const EdgeInsets.only(
//                                               left: 20, right: 10),
//                                           dropdownDecoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                           ),
//                                           items: models,
//                                           validator: (value) {},
//                                           onChanged: (value) {
//                                             brandname == 'Mercedes Benz' ||
//                                                     brandname == 'BMW'
//                                                 ? getVariant(value)
//                                                 : getModelyear(value);
//                                             setState(() {
//                                               brandname == 'Mercedes Benz' ||
//                                                       brandname == 'BMW'
//                                                   ? isvariant = true
//                                                   : isvariant = false;
//                                             });
//                                           },
//                                           dropdownMaxHeight: height * 0.5,
//                                           searchController:
//                                               textEditingController,
//                                           searchInnerWidgetHeight:
//                                               height * 0.07,
//                                           searchInnerWidget: Container(
//                                             height: height * 0.07,
//                                             padding: const EdgeInsets.only(
//                                               top: 8,
//                                               bottom: 4,
//                                               right: 8,
//                                               left: 8,
//                                             ),
//                                             child: TextFormField(
//                                               expands: true,
//                                               maxLines: null,
//                                               controller: textEditingController,
//                                               decoration: InputDecoration(
//                                                 isDense: true,
//                                                 contentPadding:
//                                                     const EdgeInsets.symmetric(
//                                                   horizontal: 10,
//                                                   vertical: 8,
//                                                 ),
//                                                 hintText: 'Search model...',
//                                                 hintStyle: const TextStyle(
//                                                     fontSize: 12),
//                                                 border: OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   borderSide: BorderSide(
//                                                       color: syanColor,
//                                                       width: 0.0),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           searchMatchFn: (item, searchValue) {
//                                             return (item.value
//                                                 .toString()
//                                                 .toLowerCase()
//                                                 .contains(
//                                                     searchValue.toLowerCase()));
//                                           },
//                                           onMenuStateChange: (isOpen) {
//                                             if (!isOpen) {
//                                               textEditingController.clear();
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ))
//                           ]),
//                           isvariant
//                               ? SizedBox(height: height * 0.04)
//                               : SizedBox(height: height * 0.001),
//                           isvariant
//                               ? Stack(
//                                   alignment: Alignment.bottomCenter,
//                                   children: [
//                                       Container(
//                                           height: height * 0.075,
//                                           width: height * 0.4,
//                                           decoration: BoxDecoration(
//                                             color: variants.isNotEmpty
//                                                 ? white
//                                                 : lightGreyColor,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             border: Border.all(
//                                                 color: borderGreyColor),
//                                           ),
//                                           child: Row(
//                                             children: <Widget>[
//                                               Expanded(
//                                                 child: Container(
//                                                   child:
//                                                       DropdownButtonFormField2(
//                                                     key: _varkey,
//                                                     autovalidateMode:
//                                                         AutovalidateMode
//                                                             .onUserInteraction,
//                                                     decoration: InputDecoration(
//                                                       isDense: true,
//                                                       contentPadding:
//                                                           EdgeInsets.zero,
//                                                       focusedBorder:
//                                                           OutlineInputBorder(
//                                                         borderSide:
//                                                             const BorderSide(
//                                                                 color: const Color(
//                                                                     0xffCCCCCC),
//                                                                 width: 0.0),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(12),
//                                                       ),
//                                                       focusedErrorBorder:
//                                                           OutlineInputBorder(
//                                                         borderSide:
//                                                             const BorderSide(
//                                                                 color: const Color(
//                                                                     0xffCCCCCC),
//                                                                 width: 0.0),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(12),
//                                                       ),
//                                                       enabledBorder:
//                                                           OutlineInputBorder(
//                                                         borderSide:
//                                                             const BorderSide(
//                                                                 color: const Color(
//                                                                     0xffCCCCCC),
//                                                                 width: 0.0),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(12),
//                                                       ),
//                                                       errorBorder:
//                                                           OutlineInputBorder(
//                                                         borderSide:
//                                                             const BorderSide(
//                                                                 color:
//                                                                     const Color(
//                                                                         0xfffff),
//                                                                 width: 0.0),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(12),
//                                                       ),
//                                                       errorStyle: TextStyle(
//                                                         fontSize: 12,
//                                                         color: warningcolor,
//                                                       ),
//                                                     ),
//                                                     isExpanded: true,
//                                                     hint:
//                                                         Text("Select Variant*"),
//                                                     alignment: Alignment.center,
//                                                     buttonHeight:
//                                                         height * 0.075,
//                                                     buttonPadding:
//                                                         const EdgeInsets.only(
//                                                             left: 20,
//                                                             right: 10),
//                                                     dropdownDecoration:
//                                                         BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15),
//                                                     ),
//                                                     items: variants,
//                                                     validator: (value) {},
//                                                     onChanged: (value) {
//                                                       getModelVariantYear(
//                                                           value);
//                                                     },
//                                                     dropdownMaxHeight:
//                                                         height * 0.5,
//                                                     searchController:
//                                                         textEditingController,
//                                                     searchInnerWidgetHeight:
//                                                         height * 0.07,
//                                                     searchInnerWidget:
//                                                         Container(
//                                                       height: height * 0.07,
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                         top: 8,
//                                                         bottom: 4,
//                                                         right: 8,
//                                                         left: 8,
//                                                       ),
//                                                       child: TextFormField(
//                                                         expands: true,
//                                                         maxLines: null,
//                                                         controller:
//                                                             textEditingController,
//                                                         decoration:
//                                                             InputDecoration(
//                                                           isDense: true,
//                                                           contentPadding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                             horizontal: 10,
//                                                             vertical: 8,
//                                                           ),
//                                                           hintText:
//                                                               'Search variant...',
//                                                           hintStyle:
//                                                               const TextStyle(
//                                                                   fontSize: 12),
//                                                           border:
//                                                               OutlineInputBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         12),
//                                                             borderSide:
//                                                                 BorderSide(
//                                                                     color:
//                                                                         syanColor,
//                                                                     width: 0.0),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     searchMatchFn:
//                                                         (item, searchValue) {
//                                                       return (item.value
//                                                           .toString()
//                                                           .toLowerCase()
//                                                           .contains(searchValue
//                                                               .toLowerCase()));
//                                                     },
//                                                     onMenuStateChange:
//                                                         (isOpen) {
//                                                       if (!isOpen) {
//                                                         textEditingController
//                                                             .clear();
//                                                       }
//                                                     },
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ))
//                                     ])
//                               : Container(),
//                           SizedBox(height: height * 0.04),
//                           Stack(alignment: Alignment.bottomCenter, children: [
//                             Container(
//                                 height: height * 0.075,
//                                 width: height * 0.4,
//                                 decoration: BoxDecoration(
//                                   color: modyears.isNotEmpty
//                                       ? white
//                                       : lightGreyColor,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: borderGreyColor),
//                                 ),
//                                 child: Row(
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: Container(
//                                         child: DropdownButtonFormField2(
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           key: _yearkey,
//                                           decoration: InputDecoration(
//                                             isDense: true,
//                                             contentPadding: EdgeInsets.zero,
//                                             focusedBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             focusedErrorBorder:
//                                                 OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color:
//                                                       const Color(0xffCCCCCC),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             errorBorder: OutlineInputBorder(
//                                               borderSide: const BorderSide(
//                                                   color: const Color(0xfffff),
//                                                   width: 0.0),
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             errorStyle: TextStyle(
//                                               fontSize: 12,
//                                               color: warningcolor,
//                                             ),
//                                           ),
//                                           isExpanded: true,
//                                           hint: Text("Select Year*"),
//                                           alignment: Alignment.center,
//                                           buttonHeight: height * 0.075,
//                                           buttonPadding: const EdgeInsets.only(
//                                               left: 20, right: 10),
//                                           dropdownDecoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                           ),
//                                           items: modyears,
//                                           validator: (value) {},
//                                           onChanged: (value) {
//                                             yearselected = value.toString();
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ))
//                           ]),
//                           SizedBox(height: height * 0.04),
//                           Stack(alignment: Alignment.bottomCenter, children: [
//                             Container(
//                                 height: height * 0.075,
//                                 width: height * 0.4,
//                                 decoration: BoxDecoration(
//                                   color: white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: borderGreyColor),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: Container(
//                                         padding: EdgeInsets.only(
//                                             right: width * 0.025,
//                                             left: width * 0.025),
//                                         child: Focus(
//                                           child: TextFormField(
//                                             textCapitalization:
//                                                 TextCapitalization.characters,
//                                             controller: plateNumberController,
//                                             keyboardType: TextInputType.text,
//                                             textAlign: TextAlign.center,
//                                             maxLength: 12,
//                                             style: montserratMedium.copyWith(
//                                                 color: black,
//                                                 fontSize: width * 0.04),
//                                             validator: (value) {},
//                                             decoration: InputDecoration(
//                                                 errorStyle: TextStyle(
//                                                     fontSize: 12,
//                                                     color: warningcolor),
//                                                 counterText: "",
//                                                 filled: true,
//                                                 hintText: "Registration Number",
//                                                 border: InputBorder.none,
//                                                 fillColor: white),
//                                           ),
//                                           onFocusChange: (hasFocus) {
//                                             if (hasFocus) {
//                                               setState(() {
//                                                 isFocused = true;
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 isFocused = false;
//                                               });
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ))
//                           ]),
//                           SizedBox(height: height * 0.04),
//                           Stack(alignment: Alignment.bottomCenter, children: [
//                             Container(
//                                 height: height * 0.075,
//                                 width: height * 0.4,
//                                 decoration: BoxDecoration(
//                                   color: white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(color: borderGreyColor),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: Container(
//                                         padding: EdgeInsets.only(
//                                             right: width * 0.025,
//                                             left: width * 0.025),
//                                         child: Focus(
//                                           child: TextFormField(
//                                             textCapitalization:
//                                                 TextCapitalization.characters,
//                                             controller: vinNumberController,
//                                             keyboardType: TextInputType.text,
//                                             textAlign: TextAlign.center,
//                                             maxLength: 17,
//                                             style: montserratMedium.copyWith(
//                                                 color: black,
//                                                 fontSize: width * 0.04),
//                                             validator: (value) {},
//                                             decoration: InputDecoration(
//                                                 errorStyle: TextStyle(
//                                                     fontSize: 12,
//                                                     color: warningcolor),
//                                                 counterText: "",
//                                                 filled: true,
//                                                 hintText:
//                                                     "VIN / Chassis Number",
//                                                 border: InputBorder.none,
//                                                 fillColor: white),
//                                           ),
//                                           onFocusChange: (hasFocus) {
//                                             if (hasFocus) {
//                                               setState(() {
//                                                 isFocused = true;
//                                               });
//                                             } else {
//                                               setState(() {
//                                                 isFocused = false;
//                                               });
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ))
//                           ]),
//                           SizedBox(height: height * 0.04),
//                           GestureDetector(
//                             onTap: () async {
//                               if (_formKey.currentState!.validate()) {
//                                 if (issubmitted) return;
//                                 setState(() => issubmitted = true);
//                                 await Future.delayed(
//                                     Duration(milliseconds: 1000));
//                                 saveVehicleDetails();
//                               }
//                             },
//                             child: Stack(
//                               alignment: Alignment.bottomCenter,
//                               children: [
//                                 Container(
//                                   height: height * 0.075,
//                                   width: height * 0.4,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.rectangle,
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(14)),
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                       colors: [
//                                         black,
//                                         black,
//                                       ],
//                                     ),
//                                   ),
//                                   child: issubmitted
//                                       ? Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Transform.scale(
//                                               scale: 0.7,
//                                               child: CircularProgressIndicator(
//                                                 color: white,
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       : Text("CONTINUE",
//                                           style: boldTextStyle(
//                                               color: Colors.white)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Tryout extends StatefulWidget {
  const Tryout({super.key});

  @override
  State<Tryout> createState() => _TryoutState();
}

class _TryoutState extends State<Tryout> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

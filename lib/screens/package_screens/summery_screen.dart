import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/package_screens/sound_player_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummeryPage extends StatefulWidget {
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedveh;
  String currency;
  SummeryPage(
      {required this.package_id,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      super.key});

  @override
  State<SummeryPage> createState() => SummeryPageState();
}

class SummeryPageState extends State<SummeryPage> {
  late Map<String, dynamic> packdata = {};
  late double totalamount = 0.0;
  bool isproceeding = false;
  bool isLoading = false;
  int bookId = 0;
  var audiofile;
  var trnxId;
  var slot;
  var complaint;
  var bookingdate;
  final player = SoundPlayer();
  TextEditingController additionalcommentsController = TextEditingController();
  var packdataaudio;

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      _setdatas();
    });
  }

  _setdatas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      packdata = json.decode(prefs.get("booking_data").toString());
      additionalcommentsController.text =
          packdata['complaint'] != null ? packdata['complaint'] : "";
      packdataaudio = prefs.getString('comp_audio') != null
          ? prefs.getString('comp_audio')
          : null;
      if (packdata['package_cost'] != null) {
        totalamount = double.parse(packdata['package_cost'].toString()) +
            double.parse(packdata['pick_up_price'].toString());
      } else {
        totalamount = double.parse(packdata['pick_up_price'].toString());
      }
    });
  }

  Future<void> init() async {
    player.init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    // internetconnection!.cancel();
  }

  createBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var audio;
      if (prefs.getString('comp_audio') != null) {
        audio = await MultipartFile.fromFile(prefs.getString('comp_audio')!,
            filename: 'audio_test.aac');
      } else {
        audio = "";
      }
      var formData = FormData.fromMap({
        'bookingattachment': audio,
        "custId": prefs.getString('cust_id'),
        "cust_name": prefs.getString('name'),
        "vehId": packdata['vehicle_id'],
        "bkurl": packdata['audio_location'],
        "pickupaddress": packdata['pick_up_location_id'],
        "dropaddress": packdata['drop_location_id'],
        "bookingdate": packdata['selected_date'],
        "sub_packages": packdata['sub_packages'],
        "services": packdata['services'],
        "expenses": [],
        "packid": packdata['package_id'],
        "packtype": packdata['packtype'],
        "packprice": (packdata['package_cost'] - packdata['pack_vat'])
            .toStringAsFixed(2),
        "pack_vat": packdata['pack_vat'].toStringAsFixed(2),
        "pickup_vat": packdata['pickup_vat'].toStringAsFixed(2),
        "gs_vat": packdata['gs_vat'].toStringAsFixed(2),
        "veh_groupid": packdata['veh_groupid'],
        "total_amount": totalamount.round(),
        "advance": "0",
        "discount": "0",
        "bk_branchid": 1,
        'complaint': additionalcommentsController.text.toString(),
        "slot": packdata['selected_timeid'],
        "pickuptype": packdata['pick_type_id'],
        "sourcetype": "MOB",
        "bk_pickup_cost":
            (double.parse(packdata['pick_up_price']) - packdata['pickup_vat'])
                .toStringAsFixed(2),
      });
      Map req = {
        'bookingattachment': audio,
        "custId": prefs.getString('cust_id'),
        "cust_name": prefs.getString('name'),
        "vehId": packdata['vehicle_id'],
        "bkurl": packdata['audio_location'],
        "pickupaddress": packdata['pick_up_location_id'],
        "dropaddress": packdata['drop_location_id'],
        "bookingdate": packdata['selected_date'],
        "sub_packages": packdata['sub_packages'],
        "services": packdata['services'],
        "expenses": [],
        "packid": packdata['package_id'],
        "packtype": packdata['packtype'],
        "packprice": (packdata['package_cost'] - packdata['pack_vat'])
            .toStringAsFixed(2),
        "pack_vat": packdata['pack_vat'].toStringAsFixed(2),
        "pickup_vat": packdata['pickup_vat'].toStringAsFixed(2),
        "gs_vat": packdata['gs_vat'].toStringAsFixed(2),
        "veh_groupid": packdata['veh_groupid'],
        "total_amount": totalamount.round(),
        "advance": "0",
        "discount": "0",
        "bk_branchid": 1,
        'complaint': additionalcommentsController.text.toString(),
        "slot": packdata['selected_timeid'],
        "pickuptype": packdata['pick_type_id'],
        "sourcetype": "MOB",
        "bk_pickup_cost":
            (double.parse(packdata['pick_up_price']) - packdata['pickup_vat'])
                .toStringAsFixed(2),
      };
      String? token = prefs.getString('token');
      var dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer ${token}";
      var response = await dio.post(
        dotenv.env['API_URL']! + 'Booking/BookingController/create',
        data: formData,
        options: Options(
          followRedirects: false,
          // will not throw errors
          validateStatus: (status) => true,
        ),
      );
      var retdata = jsonDecode(response.toString());
      if (retdata['ret_data'] == "success") {
        createPayment(retdata['booking_id'], retdata['payment_details']);
        bookId = retdata['booking_id'];
        audiofile = retdata['audio_file'];
        trnxId = retdata['payment_details']['id'];
        slot = packdata['selected_timeid'];
        complaint = additionalcommentsController.text.toString();
        bookingdate = packdata['selected_date'];
        await prefs.remove("booking_data");
      } else {
        print("error===>1");
        print(retdata);
        showCustomToast(context, "Couldn't complete booking",
            bgColor: errorcolor, textColor: whiteColor);
      }
    } catch (e) {
      print("error===>2");
      print(e.toString());
      setState(() {
        isproceeding = false;
      });
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    }
  }

  createPayment(data, payment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var billingDetails = BillingDetails(
      name: prefs.getString('name'),
      email: prefs.getString('email'),
      phone: prefs.getString('phone'),
      address: Address(
        city: 'Abu Dhabi',
        country: 'AE',
        line1: 'Mussafah',
        line2: '',
        state: 'Abu Dhabi',
        postalCode: '',
      ),
    );
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        // Main params
        paymentIntentClientSecret: payment['client_secret'],
        merchantDisplayName: 'AutoVersa',
        // Customer params
        customerId: payment['customer'],
        customerEphemeralKeySecret: payment['ephemeralKey']['secret'],
        // Extra params
        style: ThemeMode.light,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
              background: Colors.white,
              primary: Color(0xff31BBAC),
              componentBorder: Color(0xff3186AC),
              primaryText: Colors.black,
              secondaryText: Colors.black,
              componentBackground: Colors.white,
              placeholderText: Colors.black87,
              componentText: Colors.black87,
              icon: Colors.black87),
          shapes: PaymentSheetShape(
            borderWidth: 4,
            borderRadius: 10.00,
            shadow: PaymentSheetShadowParams(color: Color(0xff31BBAC)),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            shapes: PaymentSheetPrimaryButtonShape(blurRadius: 16),
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xff31BBAC),
                text: Colors.white,
                border: Color(0xff31BBAC),
              ),
            ),
          ),
        ),
        billingDetails: billingDetails,
      ),
    );
    try {
      await Stripe.instance.presentPaymentSheet();
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> booking = {
        'custId': prefs.getString('cust_id'),
        'book_id': bookId,
        'tot_amount': totalamount.round(),
        'trxn_id': trnxId,
        'audiofile': audiofile,
        'slot': slot,
        'bookingdate': bookingdate,
        'complaint': complaint
      };
      await confirmbookingpayment(booking).then((value) {
        if (value['ret_data'] == "success") {
        } else {
          setState(() => isproceeding = false);
          showCustomToast(context, value['ret_data'],
              bgColor: errorcolor, textColor: whiteColor);
        }
      });

      setState(() {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomSuccess(),
        );
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        setState(() => isproceeding = false);
        setState(() {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomWarning(),
          );
        });
      } else {
        setState(() => isproceeding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: ${e}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = player.isPlaying;
    final playrecordicon = isPlaying
        ? Icons.stop_circle_outlined
        : Icons.play_circle_outline_sharp;
    final playrecordtext = isPlaying ? "Stop Playing" : "Play Recording";
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
                          syanColor.withOpacity(0.3),
                          Color.fromARGB(255, 176, 205, 210),
                        ],
                      )),
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
                            widget.package_id['pkg_name'],
                            style: montserratRegular.copyWith(
                              fontSize: width * 0.044,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 12,
                                    color: syanColor.withOpacity(.5),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.outer,
                                    offset: Offset(0, 0)),
                              ]),
                        ),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(8),
                          width: width * 1.85,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(top: 16, left: 8)),
                              if (widget.custvehlist[widget.selectedveh]
                                      ['cv_make'] ==
                                  'Mercedes Benz') ...[
                                Image.asset(
                                  ImageConst.benz_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (widget.custvehlist[widget.selectedveh]
                                      ['cv_make'] ==
                                  'BMW') ...[
                                Image.asset(
                                  ImageConst.bmw_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (widget.custvehlist[widget.selectedveh]
                                      ['cv_make'] ==
                                  'Skoda') ...[
                                Image.asset(
                                  ImageConst.skod_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (widget.custvehlist[widget.selectedveh]
                                      ['cv_make'] ==
                                  'Audi') ...[
                                Image.asset(
                                  ImageConst.aud_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (widget.custvehlist[widget.selectedveh]
                                      ['cv_make'] ==
                                  'Porsche') ...[
                                Image.asset(
                                  ImageConst.porsche_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (widget.custvehlist[widget.selectedveh]
                                      ['cv_make'] ==
                                  'Volkswagen') ...[
                                Image.asset(
                                  ImageConst.volkswagen_icon,
                                  width: width * 0.12,
                                ),
                              ] else ...[
                                Image.asset(
                                  ImageConst.defcar_ico,
                                  width: width * 0.12,
                                ),
                              ],
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 8),
                                      widget.custvehlist[widget.selectedveh]
                                                      ['cv_plate_number'] !=
                                                  "" &&
                                              widget.custvehlist[
                                                          widget.selectedveh]
                                                      ['cv_plate_number'] !=
                                                  null
                                          ? Text(
                                              widget.custvehlist[
                                                      widget.selectedveh]
                                                      ['cv_plate_number']
                                                  .toUpperCase(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: blackColor,
                                                      fontSize: width * 0.04),
                                              maxLines: 2)
                                          : SizedBox(),
                                      widget.custvehlist[widget.selectedveh]['cv_variant'] != "" && widget.custvehlist[widget.selectedveh]['cv_variant'] != null
                                          ? Text(
                                              widget.custvehlist[widget.selectedveh]['cv_make'] +
                                                  " " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_model'] +
                                                  " " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_variant'] +
                                                  " ( " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_year'] +
                                                  " )",
                                              style: montserratMedium.copyWith(
                                                  color: blackColor,
                                                  fontSize: width * 0.034),
                                              overflow: TextOverflow.clip,
                                              maxLines: 5)
                                          : Text(
                                              widget.custvehlist[widget.selectedveh]['cv_make'] +
                                                  " " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_model'] +
                                                  " ( " +
                                                  widget.custvehlist[widget.selectedveh]
                                                      ['cv_year'] +
                                                  " )",
                                              style: montserratMedium.copyWith(color: blackColor, fontSize: width * 0.034),
                                              overflow: TextOverflow.clip,
                                              maxLines: 5),
                                      Divider(),
                                      Text(widget.package_id['pkg_name'],
                                          overflow: TextOverflow.ellipsis,
                                          style: montserratSemiBold.copyWith(
                                              color: blackColor,
                                              fontSize: width * 0.04)),
                                      Text(
                                        packdata['package_cost'] != 0
                                            ? widget.currency +
                                                " " +
                                                (packdata['package_cost']
                                                        .round())
                                                    .toString()
                                            : "Based on Quotation",
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.034),
                                      ),
                                      Divider(),
                                      Text(
                                        packdata['pick_type_name'] ?? "",
                                        style: montserratSemiBold.copyWith(
                                            color: blackColor,
                                            fontSize: width * 0.04),
                                      ),
                                      Text(
                                        packdata['pick_up_price'] != null
                                            ? packdata['pick_up_price'] != "0"
                                                ? "AED " +
                                                    (double.parse(packdata[
                                                                'pick_up_price'])
                                                            .round())
                                                        .toString()
                                                : "FREE"
                                            : "",
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.034),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Pickup Location",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.location_icon,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                packdata['pick_up_location']['cad_landmark']
                                        .toUpperCase() +
                                    " (" +
                                    packdata['pick_up_location']['cad_city'] +
                                    ")",
                                style: montserratMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: width * 0.04),
                              ),
                              Text(
                                packdata['pick_up_location']['cad_address'],
                                maxLines: 2,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: montserratMedium.copyWith(
                                    color: toastgrey, fontSize: width * 0.03),
                              ),
                            ],
                          ))
                          // Flexible(
                          //   child: Container(
                          //     child: Text(
                          //       packdata['pick_up_location']['cad_address'] ??
                          //           "",
                          //       overflow: TextOverflow.clip,
                          //       style: montserratMedium.copyWith(
                          //           color: blackColor, fontSize: width * 0.04),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Drop Location",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.location_icon,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                packdata['drop_location']['cad_landmark']
                                        .toUpperCase() +
                                    " (" +
                                    packdata['drop_location']['cad_city'] +
                                    ")",
                                style: montserratMedium.copyWith(
                                    color: Colors.black,
                                    fontSize: width * 0.04),
                              ),
                              Text(
                                packdata['drop_location']['cad_address'],
                                maxLines: 2,
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: montserratMedium.copyWith(
                                    color: toastgrey, fontSize: width * 0.03),
                              ),
                            ],
                          ))
                          // Flexible(
                          //   child: Container(
                          //     child: Text(
                          //       packdata['drop_location']['cad_address'] ?? "",
                          //       overflow: TextOverflow.clip,
                          //       style: montserratMedium.copyWith(
                          //         color: blackColor,
                          //         fontSize: width * 0.04,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Selected Date & Time",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.date_icon,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            packdata['selected_date'] != null
                                ? DateFormat('LLLL').format(
                                    DateTime.parse(packdata['selected_date']))
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            packdata['selected_date'] != null
                                ? DateFormat('d').format(
                                    DateTime.parse(packdata['selected_date']))
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height * 0.050,
                            width: height * 0.050,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomRight,
                                colors: [
                                  lightblueColor,
                                  syanColor,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              ImageConst.time,
                              scale: 4.5,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            packdata['selected_timeslot'] != null
                                ? packdata['selected_timeslot'].split('- ')[0] +
                                    "-"
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                          Text(
                            packdata['selected_timeslot'] != null
                                ? " " +
                                    packdata['selected_timeslot'].split('- ')[1]
                                : "",
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Additional Comments",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            color: whiteColor),
                        child: TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 230,
                            controller: additionalcommentsController,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                                counterText: "",
                                hintText: ST.of(context).your_message_here,
                                hintStyle: montserratMedium.copyWith(
                                    color: blackColor, fontSize: width * 0.04),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: greyColor, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: greyColor, width: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ))),
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Recordings",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.034),
                          ),
                        ],
                      ),
                    ),
                    packdataaudio != null
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 20, 0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        14.0, 0, 0, 0),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: 0.1,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                      border: Border.all(
                                          color: greyColor.withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.all(4)),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    lightblueColor,
                                                    syanColor,
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                  Icons
                                                      .record_voice_over_outlined,
                                                  color: Colors.white,
                                                  size: 20),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(playrecordtext,
                                                    style: montserratRegular
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width * 0.034)),
                                              ],
                                            )
                                          ],
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.white,
                                          child: IconButton(
                                            icon: Icon(playrecordicon,
                                                color: Colors.black),
                                            onPressed: () async {
                                              await player.togglePlaying(
                                                  whenFinished: () =>
                                                      setState(() {}));
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.fromLTRB(30, 8, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("No Recordings",
                                    style: montserratRegular.copyWith(
                                      fontSize: width * 0.04,
                                      color: blackColor,
                                    )),
                              ],
                            ),
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(
                        color: divider_grey_color,
                        thickness: 1.5,
                        indent: 20,
                        endIndent: 20),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Grand Total: ",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.034),
                          ),
                          Text(
                            widget.currency +
                                " " +
                                (totalamount.round()).toString(),
                            style: montserratSemiBold.copyWith(
                                color: warningcolor, fontSize: width * 0.04),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (isproceeding) return;
                        setState(() => isproceeding = true);
                        await Future.delayed(Duration(milliseconds: 1000));
                        createBooking();
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            height: height * 0.045,
                            width: height * 0.37,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 16,
                                      color: syanColor.withOpacity(.6),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  syanColor,
                                  lightblueColor,
                                ],
                              ),
                            ),
                            child: !isproceeding
                                ? Text(
                                    "PROCEED TO PAY",
                                    style: montserratSemiBold.copyWith(
                                        color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ],
            ),
          )),
        ));
  }
}

class CustomWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: whiteColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0)),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      lightorangeColor,
                      holdorangeColor,
                    ],
                  )),
                ),
                // Container(height: 130, color: warningcolor),
                Column(
                  children: [
                    Image.asset(
                      ImageConst.warning,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Awaiting Payment",
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: whiteColor)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                    "Please check dashboard to complete payment for further proceedings.",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.034, color: blackColor))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        lightorangeColor,
                        holdorangeColor,
                      ],
                    )),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('OK',
                    style: montserratSemiBold.copyWith(color: whiteColor)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: whiteColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0)),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      lightblueColor,
                      syanColor,
                    ],
                  )),
                ),
                // Container(height: 130, color: blackColor),
                Column(
                  children: [
                    Image.asset(
                      ImageConst.success,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Booking Successfull",
                        textAlign: TextAlign.center,
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: whiteColor)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text("Please check dashboard for booking status",
                    textAlign: TextAlign.center,
                    style: montserratRegular.copyWith(
                        fontSize: width * 0.034, color: blackColor))),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                // Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, Routes.bottombar);
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        lightblueColor,
                        syanColor,
                      ],
                    )),
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('OK',
                    style: montserratSemiBold.copyWith(color: whiteColor)),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

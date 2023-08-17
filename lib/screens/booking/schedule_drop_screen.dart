import 'dart:async';
import 'dart:convert';

import 'package:autoversa/services/location_controller.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constant/image_const.dart';
import '../../constant/text_style.dart';
import '../../generated/l10n.dart' as lang;
import '../../main.dart';
import '../../services/post_auth_services.dart';
import '../../utils/AppWidgets.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_utils.dart';
import '../address/address_add_gmap_screen.dart';
import 'booking_status_flow_page.dart';

class ScheduleDropScreen extends StatefulWidget {
  final String bk_id;
  final String vehname;
  final String make;
  final int click_id;
  const ScheduleDropScreen(
      {required this.bk_id,
      required this.vehname,
      required this.make,
      required this.click_id,
      super.key});

  @override
  State<ScheduleDropScreen> createState() => ScheduleDropScreenState();
}

class ScheduleDropScreenState extends State<ScheduleDropScreen> {
  late Map<String, dynamic> currentBooking = {},
      currentDropDetails = {},
      currentDropType = {};
  bool isLoaded = false,
      isSubmitted = false,
      isExpanded = false,
      isProceeding = false;

  List custAddressList = [];
  List timeslots = [];
  List pickup_options = [];
  List<String?> SelectAddressList = <String?>["Select Address"];
  List temppickup_options = [];
  var freeservicedistance = 0;
  var servicedistance = 0;
  var max_days = 0;
  var selected_address = 0;
  var selected_distance = "0";
  var selected_drop = "";
  var selected_timeslot = "";
  var selected_timeid = 0;
  var isTimeCheck;
  var pending_payment = 0.00;
  var new_selected_drop = 0;
  var trnxId;
  var gs_vat = 0;
  var gs_isvat = 0;
  double paid_amount = 0.0;
  final GlobalKey<FormFieldState> drop_city = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> drop_area = GlobalKey<FormFieldState>();
  final TextEditingController textEditingController = TextEditingController();
  FocusNode addressFocus = FocusNode();
  FocusNode landmarkFocusNode = FocusNode();
  bool isDefaultAddressChecked = true;
  var buffertime = "0";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getBookingDetailsByID();
    });
  }

  getBookingDetailsByID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_id))};
    print(req);
    await getbookingdetails(req).then((value) async {
      if (value['ret_data'] == "success") {
        setState(() {
          currentBooking = value['booking'];
          currentDropDetails = value['booking']['drop_address'];
          new_selected_drop =
              int.parse(value['booking']['drop_address']['cad_id']);
          currentDropType = value['booking']['pickup_type'];
          _fetchdatas(0, 'd');
        });
      }
    });
  }

  dropAddressChange(drop_address) {
    if (drop_address - 1 == -1) {
      new_selected_drop = 0;
      showCustomToast(context, "Please select drop location",
          bgColor: errorcolor, textColor: white);
    } else {
      new_selected_drop =
          int.parse(custAddressList[drop_address - 1]['cad_id']);
      var serviceDistance =
          int.parse(custAddressList[drop_address - 1]['cad_distance']);
      var new_distance = serviceDistance - double.parse(selected_distance);
      if (new_distance < 0) {
        new_distance = 0;
      }
      pickup_options = [];
      for (var ptype in temppickup_options) {
        var tempCost = '0';
        var min_cost = ptype['pk_min_cost'];
        var tempCostVat = 0.0;
        var min_cost_vat = 0.0;
        selected_drop = "";
        setState(() {});
        ptype['pk_id'] == currentDropType['pk_id'] && new_distance == 0
            ? tempCost = "0"
            : ptype['pk_freeFlag'] != "1"
                ? tempCost =
                    (double.parse(ptype['pk_cost']) * new_distance).toString()
                : tempCost = "0";
        if (gs_isvat == 1 && double.parse(tempCost) > 0) {
          tempCostVat = (double.parse(tempCost) * (gs_vat / 100));
          min_cost_vat = (double.parse(min_cost) * (gs_vat / 100));
          tempCost = ((double.parse(tempCost) +
                      (double.parse(tempCost) * (gs_vat / 100)))
                  .round())
              .toString();
          min_cost = ((double.parse(min_cost) +
                      (double.parse(min_cost) * (gs_vat / 100)))
                  .round())
              .toString();
          ;
        }
        // if (ptype['pk_id'] == currentDropType['pk_id']) {
        //   selected_drop = ptype['pk_id'];
        // }
        double.parse(tempCost) - paid_amount > 0
            ? tempCost = (double.parse(tempCost) - paid_amount).toString()
            : tempCost = "0";
        // ptype['pk_id'] == currentDropType['pk_id'] && new_distance == 0
        //     ? tempCost = "0"
        //     : ptype['pk_freeFlag'] != "1"
        //         ? tempCost =
        //             (double.parse(ptype['pk_cost']) * (new_distance)).toString()
        //         : tempCost = "0";
        // if (ptype['pk_id'] == currentDropType['pk_id']) {
        //   pending_payment = double.parse(tempCost);
        // }
        var temp = {
          "pk_id": ptype['pk_freeFlag'] == "1" &&
                  double.parse(selected_distance) > freeservicedistance
              ? "0"
              : ptype['pk_id'],
          "pk_name": ptype['pk_name'],
          "pk_cost": ptype['pk_id'] == currentDropType['pk_id'] &&
                  double.parse(tempCost) == 0
              ? "PAID"
              : ptype['pk_freeFlag'] == "1" &&
                      double.parse(selected_distance) > freeservicedistance
                  ? "Not Available"
                  : (double.parse(tempCost) <
                              double.parse(ptype['pk_min_cost']) &&
                          ptype['pk_freeFlag'] != "1" &&
                          double.parse(tempCost) > 0)
                      ? ("AED" + " " + min_cost)
                      : ("AED" + " " + tempCost),
          "pk_cost_value": ptype['pk_id'] == currentDropType['pk_id'] &&
                  double.parse(tempCost) == 0
              ? "0"
              : double.parse(tempCost) < double.parse(ptype['pk_min_cost'])
                  ? ptype['pk_freeFlag'] == "1"
                      ? '0'
                      : min_cost
                  : tempCost,
          "pk_vat_value": double.parse(tempCost) < double.parse(min_cost)
              ? ptype['pk_freeFlag'] == "1"
                  ? 0.0
                  : min_cost_vat
              : tempCostVat
        };
        pickup_options.add(temp);
        setState(() {});
      }
    }
  }

  newDropAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map req = {"customerId": prefs.getString('cust_id')};
      custAddressList = [];
      pickup_options = [];
      SelectAddressList = <String?>["Select Address"];
      selected_address = 0;
      setState(() {});
      await getCustomerAddresses(req).then((value) {
        if (value['ret_data'] == "success") {
          custAddressList = value['cust_addressList'];
          var ind = 1;
          for (var add in value['cust_addressList']) {
            SelectAddressList.add(
                "#" + ind.toString() + ". " + add['cad_address']);
            ind++;
          }
          setState(() {});
        }
      });
      selected_address = SelectAddressList.length - 1;
      new_selected_drop =
          int.parse(custAddressList[SelectAddressList.length - 2]['cad_id']);
      var serviceDistance = int.parse(
          custAddressList[SelectAddressList.length - 2]['cad_distance']);
      var new_distance = serviceDistance - int.parse(selected_distance);
      if (new_distance < 0) {
        new_distance = 0;
      }
      for (var ptype in temppickup_options) {
        var tempCost = '0';
        ptype['pk_id'] == currentDropType['pk_id'] && new_distance == 0
            ? tempCost = "0"
            : ptype['pk_freeFlag'] != "1"
                ? tempCost =
                    (double.parse(ptype['pk_cost']) * (new_distance)).toString()
                : tempCost = "0";
        if (ptype['pk_id'] == currentDropType['pk_id']) {
          pending_payment = double.parse(tempCost);
        }
        var temp = {
          "pk_id": ptype['pk_freeFlag'] == "1" &&
                  serviceDistance > freeservicedistance
              ? "0"
              : ptype['pk_id'],
          "pk_name": ptype['pk_name'],
          "pk_cost":
              ptype['pk_id'] == currentDropType['pk_id'] && new_distance == 0
                  ? "PAID"
                  : ptype['pk_freeFlag'] == "1" &&
                          serviceDistance > freeservicedistance
                      ? "Not Available"
                      : (double.parse(tempCost) <
                                  double.parse(ptype['pk_min_cost']) &&
                              ptype['pk_freeFlag'] != "1")
                          ? ("AED" + " " + ptype['pk_min_cost'])
                          : ("AED" + " " + tempCost),
          "pk_cost_value": ptype['pk_id'] == currentDropType['pk_id']
              ? "0"
              : double.parse(tempCost) < double.parse(ptype['pk_min_cost'])
                  ? ptype['pk_freeFlag'] == "1"
                      ? '0'
                      : (ptype['pk_min_cost'])
                  : tempCost
        };
        pickup_options.add(temp);
        setState(() {});
      }
    } catch (e) {
      setState(() => isSubmitted = false);
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    }
  }

  _fetchdatas(address_index, type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map req = {"customerId": prefs.getString('cust_id')};
      custAddressList = [];
      pickup_options = [];
      SelectAddressList = <String?>["Select Address"];
      await getCustomerAddresses(req).then((value) {
        if (value['ret_data'] == "success") {
          custAddressList = value['cust_addressList'];
          var ind = 1;
          for (var add in value['cust_addressList']) {
            SelectAddressList.add(
                "#" + ind.toString() + ". " + add['cad_address']);
            if (currentDropDetails['cad_id'] == add['cad_id']) {
              selected_address = ind;
              selected_distance = add['cad_distance'];
            }
            ind++;
          }
        }
      });
      await getPickupOptions().then((value) {
        gs_vat = int.parse(value['settings']['gs_vat']);
        gs_isvat = int.parse(value['settings']['gs_isvat']);
        freeservicedistance =
            int.parse(value['settings']['gs_freeservicearea']);
        servicedistance = int.parse(value['settings']['gs_service_area']);
        if (currentDropDetails['cad_distance'] != "") {
          if (int.parse(currentDropDetails['cad_distance']) >
              freeservicedistance) {
            paid_amount = double.parse(currentDropDetails['cad_distance']) *
                double.parse(currentDropType['pk_cost']);
          } else {
            paid_amount = double.parse(currentDropType['pk_min_cost']);
          }
        }
        if (gs_isvat == "1") {
          paid_amount = paid_amount + (paid_amount * (gs_vat / 100));
        }
        max_days = int.parse(value['settings']['gs_nofdays']);
        if (value['ret_data'] == "success") {
          temppickup_options = value['active_pickuptype_list'];
          for (var ptype in value['active_pickuptype_list']) {
            if (ptype['pk_id'] == currentDropType['pk_id']) {
              selected_drop = ptype['pk_id'];
            }
            var tempCost = '0';
            var min_cost = ptype['pk_min_cost'];
            var tempCostVat = 0.0;
            var min_cost_vat = 0.0;
            ptype['pk_freeFlag'] != "1"
                ? tempCost = (double.parse(ptype['pk_cost']) *
                        double.parse(selected_distance))
                    .toString()
                : tempCost = "0";
            if (gs_isvat == 1 && double.parse(tempCost) > 0) {
              tempCostVat = (double.parse(tempCost) * (gs_vat / 100));
              min_cost_vat = (double.parse(min_cost) * (gs_vat / 100));
              tempCost = ((double.parse(tempCost) +
                          (double.parse(tempCost) * (gs_vat / 100)))
                      .round())
                  .toString();
              min_cost = ((double.parse(min_cost) +
                          (double.parse(min_cost) * (gs_vat / 100)))
                      .round())
                  .toString();
              ;
            }
            ptype['pk_id'] == currentDropType['pk_id']
                ? tempCost = "0"
                : tempCost = tempCost;
            double.parse(tempCost) - paid_amount > 0
                ? tempCost = (double.parse(tempCost) - paid_amount).toString()
                : tempCost = "0";
            var temp = {
              "pk_id": ptype['pk_freeFlag'] == "1" &&
                      double.parse(selected_distance) > freeservicedistance
                  ? "0"
                  : ptype['pk_id'],
              "pk_name": ptype['pk_name'],
              "pk_cost": ptype['pk_id'] == currentDropType['pk_id']
                  ? "PAID"
                  : ptype['pk_freeFlag'] == "1" &&
                          double.parse(selected_distance) > freeservicedistance
                      ? "Not Available"
                      : (double.parse(tempCost) <
                                  double.parse(ptype['pk_min_cost']) &&
                              ptype['pk_freeFlag'] != "1" &&
                              double.parse(tempCost) > 0)
                          ? ("AED" + " " + min_cost)
                          : ("AED" + " " + tempCost),
              "pk_cost_value": ptype['pk_id'] == currentDropType['pk_id']
                  ? "0"
                  : double.parse(tempCost) <
                              double.parse(ptype['pk_min_cost']) &&
                          paid_amount < double.parse(min_cost)
                      ? ptype['pk_freeFlag'] == "1"
                          ? '0'
                          : min_cost
                      : tempCost,
              "pk_vat_value": double.parse(tempCost) < double.parse(min_cost) &&
                      paid_amount > double.parse(min_cost)
                  ? ptype['pk_freeFlag'] == "1"
                      ? 0.0
                      : min_cost_vat
                  : tempCostVat
            };
            pickup_options.add(temp);
          }
        }
      });
      getTimeSlots(new DateTime.now());
      isLoaded = true;
      setState(() {});
    } catch (e) {
      setState(() => isSubmitted = false);
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    }
  }

  int calculateDifference(DateTime selectedDate) {
    DateTime now = DateTime.now();
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  String getCurrentTime() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('h:mm a');
    return formatter.format(now);
  }

  getTimeSlots(pickdate) async {
    Map req = {
      "day": DateFormat('EEEE').format(pickdate),
      "date": DateFormat('dd-MM-yyyy').format(pickdate).toString(),
      "branch_id": 1
    };
    try {
      await getTimeSlotsForBooking(req).then((value) {
        buffertime = value['settings']['gs_bookingbuffer_time'];
        timeslots = [];
        if (value['ret_data'] == "success") {
          if (calculateDifference(selectedDate) == 0) {
            final DateTime now = DateTime.now();
            DateTime newTime =
                now.add(Duration(minutes: int.parse(buffertime)));
            DateFormat formatter = DateFormat('HH:mm');
            String formattedTime = formatter.format(newTime);
            for (var bslots in value['time_slots']) {
              String startTime = bslots['tm_start_time'];
              if (startTime.compareTo(formattedTime) >= 0) {
                var count = value['assigned_emp']
                    .where((c) => c['tem_slotid'] == bslots['tm_id'])
                    .toList()
                    .length;
                if (count == value['driver_count']) {
                  var slotemp = {
                    "tm_id": bslots['tm_id'],
                    "tm_start_time": bslots['tm_start_time'],
                    "tm_end_time": bslots['tm_end_time'],
                    "active_flag": 1
                  };
                  timeslots.add(slotemp);
                  timeslots.sort((a, b) =>
                      a['tm_start_time'].compareTo(b['tm_start_time']));
                } else {
                  var slotemp = {
                    "tm_id": bslots['tm_id'],
                    "tm_start_time": bslots['tm_start_time'],
                    "tm_end_time": bslots['tm_end_time'],
                    "active_flag": 0
                  };
                  timeslots.add(slotemp);
                  timeslots.sort((a, b) =>
                      a['tm_start_time'].compareTo(b['tm_start_time']));
                }
              }
            }
          } else if (calculateDifference(selectedDate) > 0) {
            for (var bslots in value['time_slots']) {
              var count = value['assigned_emp']
                  .where((c) => c['tem_slotid'] == bslots['tm_id'])
                  .toList()
                  .length;

              if (count == value['driver_count']) {
                var slotemp = {
                  "tm_id": bslots['tm_id'],
                  "tm_start_time": bslots['tm_start_time'],
                  "tm_end_time": bslots['tm_end_time'],
                  "active_flag": 1
                };
                timeslots.add(slotemp);
                timeslots.sort(
                    (a, b) => a['tm_start_time'].compareTo(b['tm_start_time']));
              } else {
                var slotemp = {
                  "tm_id": bslots['tm_id'],
                  "tm_start_time": bslots['tm_start_time'],
                  "tm_end_time": bslots['tm_end_time'],
                  "active_flag": 0
                };
                timeslots.add(slotemp);
                timeslots.sort(
                    (a, b) => a['tm_start_time'].compareTo(b['tm_start_time']));
              }
            }
          }
        }
      });
      setState(() {});
    } catch (e) {
      // print(e.toString());
    }
  }

  createPaymentIntent(data, payment) async {
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
      setState(() {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CustomSuccess(),
        );
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        setState(() => isProceeding = false);
        setState(() {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => CustomWarning(),
          );
        });
      } else {
        setState(() => isProceeding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: ${e}'),
          ),
        );
      }
    }
  }

  scheduleDrop() async {
    if (new_selected_drop == 0) {
      setState(() => isProceeding = false);
      showCustomToast(context, "Choose a drop location",
          bgColor: errorcolor, textColor: white);
    } else if (selected_drop == "") {
      setState(() => isProceeding = false);
      showCustomToast(context, "Choose a drop type",
          bgColor: errorcolor, textColor: white);
    } else if (selected_timeid == 0) {
      setState(() => isProceeding = false);
      showCustomToast(context, "Choose a time slot",
          bgColor: errorcolor, textColor: white);
    } else {
      if (pending_payment > 0) {
        final prefs = await SharedPreferences.getInstance();
        Map<String, dynamic> pay_data = {
          'custId': prefs.getString('cust_id'),
          'booking_id': widget.bk_id,
          'tot_amount': pending_payment.toString(),
        };
        await create_workcard_payment(pay_data).then((value) {
          if (value['ret_data'] == "success") {
            trnxId = value['payment_details']['id'];
            createPaymentIntent(widget.bk_id, value['payment_details']);
          }
        }).catchError((e) {
          print(e.toString());
          showCustomToast(context, lang.S.of(context).toast_application_error,
              bgColor: errorcolor, textColor: Colors.white);
        });
        // createPayment();
      } else {
        scheduleDropFinalize();
      }
    }
  }

  scheduleDropFinalize() async {
    late Map<String, dynamic> packdata = {};
    packdata['drop_location_id'] = new_selected_drop;
    packdata['booking_id'] = widget.bk_id;
    packdata['selected_date'] = selectedDate.toString();
    packdata['selected_timeid'] = selected_timeid;
    packdata['selected_timeslot'] = selected_timeslot;
    await submitdeliverydrop(packdata).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          showCustomToast(context, "Drop Details Saved Successfully",
              bgColor: Colors.black, textColor: white);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookingStatusFlow(
                        bk_id: widget.bk_id,
                        vehname: widget.vehname,
                        make: widget.make,
                      )));
        });
      } else {
        setState(() => isProceeding = false);
      }
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
            "Schedule Drop",
            style: montserratRegular.copyWith(
              fontSize: width * 0.044,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              widget.click_id == 1
                  ? Navigator.pop(context)
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingStatusFlow(
                                bk_id: widget.bk_id,
                                vehname: widget.vehname,
                                make: widget.make,
                              )));
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 18,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(16.5, height * 0.02, 16.5, 16.5),
            child: Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoaded
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(4)),
                                    if (currentBooking['vehicle']['cv_make'] ==
                                        'Mercedes Benz') ...[
                                      Image.asset(
                                        ImageConst.benz_ico,
                                        width: width * 0.12,
                                      ),
                                    ] else if (currentBooking['vehicle']
                                            ['cv_make'] ==
                                        'BMW') ...[
                                      Image.asset(
                                        ImageConst.bmw_ico,
                                        width: width * 0.12,
                                      ),
                                    ] else if (currentBooking['vehicle']
                                            ['cv_make'] ==
                                        'Skoda') ...[
                                      Image.asset(
                                        ImageConst.skod_ico,
                                        width: width * 0.12,
                                      ),
                                    ] else if (currentBooking['vehicle']
                                            ['cv_make'] ==
                                        'Audi') ...[
                                      Image.asset(
                                        ImageConst.aud_ico,
                                        width: width * 0.12,
                                      ),
                                    ] else if (currentBooking['vehicle']
                                            ['cv_make'] ==
                                        'Porsche') ...[
                                      Image.asset(
                                        ImageConst.porsche_ico,
                                        width: width * 0.12,
                                      ),
                                    ] else if (currentBooking['vehicle']
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
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                      currentBooking['booking_package']
                                                                  [
                                                                  'pkg_name'] !=
                                                              null
                                                          ? currentBooking[
                                                                      'booking_package']
                                                                  ['pkg_name'] +
                                                              " (" +
                                                              currentBooking[
                                                                  'bk_number'] +
                                                              ")"
                                                          : "",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: montserratSemiBold
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: width *
                                                                  0.04)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Container(
                                                        child: Text(
                                                          currentBooking[
                                                                      'bk_booking_date'] !=
                                                                  null
                                                              ? "Booking Date: " +
                                                                  DateFormat(
                                                                          'dd-MM-yyyy')
                                                                      .format(DateTime
                                                                          .tryParse(
                                                                              currentBooking['bk_booking_date'])!)
                                                              : "",
                                                          overflow:
                                                              TextOverflow.clip,
                                                          style: montserratMedium
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      width *
                                                                          0.034),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                child: Container(
                                                  child: Text(
                                                    currentBooking['vehicle']
                                                            ['cv_make'] +
                                                        currentBooking[
                                                                'vehicle']
                                                            ['cv_model'] +
                                                        " (" +
                                                        currentBooking[
                                                                'vehicle']
                                                            ['cv_year'] +
                                                        ")",
                                                    overflow: TextOverflow.clip,
                                                    style: montserratMedium
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontSize:
                                                                width * 0.034),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: height * 0.02),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Current Drop Location",
                              textAlign: TextAlign.start,
                              style: montserratSemiBold.copyWith(
                                fontSize: width * 0.034,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                PermissionStatus locationStatus =
                                    await Permission.location.request();
                                if (locationStatus == PermissionStatus.denied) {
                                  showCustomToast(context,
                                      "This Permission is recommended for location access.",
                                      bgColor: errorcolor, textColor: white);
                                }
                                if (locationStatus ==
                                    PermissionStatus.permanentlyDenied) {
                                  openAppSettings();
                                }
                                if (locationStatus ==
                                    PermissionStatus.granted) {
                                  Get.put(LocationController());
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddAddressViaGmap(
                                                pack_type: 0,
                                                click_id: 4,
                                                package_id: {},
                                                custvehlist: [],
                                                currency: "",
                                                selectedveh: 0,
                                                pickup_loc: 0,
                                                drop_loc: selected_address,
                                                drop_flag: true,
                                                bk_id: widget.bk_id,
                                                vehname: widget.vehname,
                                                make: widget.make,
                                              )));
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).add_address + " ",
                                    style: montserratSemiBold.copyWith(
                                        color: Colors.black,
                                        fontSize: width * 0.034),
                                  ),
                                  Container(
                                    child: Image.asset(
                                      ImageConst.add_black,
                                      scale: 4.8,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ]),
                      SizedBox(height: height * 0.02),
                      Stack(alignment: Alignment.bottomCenter, children: [
                        Container(
                          height: height * 0.035,
                          width: height * 0.37,
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 16,
                                    color: syanColor.withOpacity(.5),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.outer,
                                    offset: Offset(0, 0)),
                              ]),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderGreyColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: DropdownButtonFormField2(
                                      value: selected_address > 0
                                          ? SelectAddressList[selected_address]
                                          : null,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        //Add isDense true and zero Padding.
                                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        focusedBorder: OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderSide: const BorderSide(
                                              color: const Color(0xffCCCCCC),
                                              width: 0.0),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderSide: const BorderSide(
                                              color: const Color(0xffCCCCCC),
                                              width: 0.0),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderSide: const BorderSide(
                                              color: const Color(0xffCCCCCC),
                                              width: 0.0),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderSide: const BorderSide(
                                              color: const Color(0xfffff),
                                              width: 0.0),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        errorStyle: montserratRegular.copyWith(
                                          fontSize: 12,
                                          color: warningcolor,
                                        ),
                                        //Add more decoration as you want here
                                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                      ),
                                      isExpanded: true,
                                      hint: Text(
                                        "Select Address" + "*",
                                        style: montserratMedium.copyWith(
                                            color: Colors.black,
                                            fontSize: width * 0.04),
                                      ),
                                      buttonHeight: height * 0.095,
                                      buttonPadding: const EdgeInsets.all(4),
                                      itemHeight: height * 0.08,
                                      dropdownDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      icon: RadiantGradientMask(
                                        child: Icon(Icons.keyboard_arrow_down,
                                            color: white, size: 30),
                                      ),
                                      items: SelectAddressList.map(
                                          (String? value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  color: syanColor,
                                                  size: width * 0.08,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      value!,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: montserratMedium
                                                          .copyWith(
                                                              color: toastgrey,
                                                              fontSize:
                                                                  width * 0.03),
                                                    ),
                                                  ],
                                                ))
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          dropAddressChange(
                                              SelectAddressList.indexOf(
                                                  value.toString()));
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ))
                      ]),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Text(
                        "Drop Type" + "*",
                        textAlign: TextAlign.start,
                        style: montserratSemiBold.copyWith(
                            color: Colors.black, fontSize: width * 0.034),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pickup_options.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Theme(
                                            data: pickup_options[index]
                                                        ['pk_id'] ==
                                                    "0"
                                                ? Theme.of(context).copyWith(
                                                    unselectedWidgetColor:
                                                        Colors.grey[350])
                                                : Theme.of(context).copyWith(
                                                    unselectedWidgetColor:
                                                        Colors.black),
                                            child: pickup_options[index]
                                                        ['pk_id'] ==
                                                    "0"
                                                ? Radio(
                                                    fillColor:
                                                        MaterialStateColor
                                                            .resolveWith(
                                                                (states) =>
                                                                    syanColor),
                                                    value: pickup_options[index]
                                                        ['pk_id'],
                                                    groupValue: selected_drop,
                                                    onChanged: (dynamic value) {
                                                      setState(() {
                                                        value = null;
                                                      });
                                                    },
                                                  )
                                                : Radio(
                                                    fillColor:
                                                        MaterialStateColor
                                                            .resolveWith(
                                                                (states) =>
                                                                    syanColor),
                                                    value: pickup_options[index]
                                                        ['pk_id'],
                                                    groupValue: selected_drop,
                                                    onChanged: (dynamic value) {
                                                      setState(() {
                                                        selected_drop = value;
                                                        pending_payment = double
                                                            .parse(pickup_options[
                                                                    index][
                                                                'pk_cost_value']);
                                                        // pickup_name =
                                                        //     pickup_options[
                                                        //             index]
                                                        //         ['pk_name'];
                                                        // pickup_cost =
                                                        //     pickup_options[
                                                        //             index][
                                                        //         'pk_cost_value'];
                                                      });
                                                    },
                                                  ),
                                          ),
                                          pickup_options[index]['pk_id'] == "0"
                                              ? Text(
                                                  pickup_options[index]
                                                      ['pk_name'],
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color:
                                                              Colors.grey[350],
                                                          fontSize:
                                                              width * 0.04),
                                                )
                                              : Text(
                                                  pickup_options[index]
                                                      ['pk_name'],
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      montserratMedium.copyWith(
                                                          color: Colors.black,
                                                          fontSize:
                                                              width * 0.04),
                                                ),
                                        ]),
                                    pickup_options[index]['pk_id'] == "0"
                                        ? Text(
                                            pickup_options[index]['pk_cost'] ==
                                                    "AED 0"
                                                ? lang.S.of(context).free
                                                : pickup_options[index]
                                                    ['pk_cost'],
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.clip,
                                            style: montserratMedium.copyWith(
                                                color: pickup_options[index]
                                                            ['pk_cost'] !=
                                                        "PAID"
                                                    ? Colors.black
                                                    : Colors.green,
                                                fontSize: width * 0.034),
                                          )
                                        : Text(
                                            pickup_options[index]['pk_cost'] ==
                                                    "AED 0"
                                                ? lang.S.of(context).free
                                                : pickup_options[index]
                                                    ['pk_cost'],
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.clip,
                                            style: montserratMedium.copyWith(
                                                color: pickup_options[index]
                                                            ['pk_cost'] !=
                                                        "PAID"
                                                    ? warningcolor
                                                    : Colors.green,
                                                fontSize: width * 0.034),
                                          ),
                                  ],
                                ),
                              ],
                            );
                          }),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Row(
                        children: [
                          Padding(padding: EdgeInsets.all(2)),
                          Text(
                            "Select Drop Date" + "*",
                            style: montserratSemiBold.copyWith(
                                fontSize: width * 0.034, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                              side: BorderSide(width: 1, color: Colors.black)),
                          elevation: 4,
                          child: ListTile(
                            trailing: RadiantGradientMask(
                              child: IconButton(
                                icon: Icon(
                                  Icons.date_range,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _selectDate(context);
                                },
                              ),
                            ),
                            onTap: () {
                              _selectDate(context);
                            },
                            title: Text(
                              'Select your Drop date',
                              style: montserratMedium.copyWith(
                                  color: Colors.black, fontSize: width * 0.04),
                            ),
                            subtitle: Text(
                              DateFormat('dd-MM-yyyy').format(selectedDate),
                              style: montserratSemiBold.copyWith(
                                  color: Colors.black, fontSize: width * 0.04),
                            ),
                          )),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Text(
                        "Select Drop Time Slot*",
                        style: montserratSemiBold.copyWith(
                            fontSize: width * 0.034, color: Colors.black),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Container(
                        margin: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: radius(10),
                          color: context.cardColor,
                          border: Border.all(
                            color: black,
                          ),
                        ),
                        child: ExpansionTile(
                          childrenPadding: EdgeInsets.all(2),
                          leading: Container(
                              width: 25,
                              height: 25,
                              child: RadiantGradientMask(
                                child: Icon(Icons.av_timer_outlined,
                                    color: white, size: 28),
                              )),
                          title: Text("Select a Time Slot" + "*",
                              overflow: TextOverflow.clip,
                              style: montserratMedium.copyWith(
                                  color: black, fontSize: width * 0.04),
                              maxLines: 3),
                          subtitle: Text(
                            selected_timeslot == ""
                                ? "Time Slot"
                                : selected_timeslot,
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.04),
                          ),
                          textColor: black,
                          trailing: isExpanded
                              ? Container(
                                  child: Icon(Icons.keyboard_arrow_up,
                                      color: syanColor, size: 30),
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      borderRadius: radius(100),
                                      color: context.accentColor.withAlpha(32)),
                                )
                              : Icon(Icons.keyboard_arrow_down,
                                  color: syanColor, size: 30),
                          onExpansionChanged: (t1) {
                            isExpanded = !isExpanded;
                            setState(() {});
                          },
                          children: [
                            Container(
                              decoration: boxDecorationDefault(
                                  color: white, boxShadow: null),
                              padding: EdgeInsets.all(2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  timeslots.length > 0
                                      ? ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.only(
                                              top: 16, bottom: 16),
                                          itemCount: timeslots.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: <Widget>[
                                                Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                          unselectedWidgetColor:
                                                              syanColor),
                                                  child: Radio(
                                                    value: timeslots[index]
                                                            ['tm_start_time'] +
                                                        " - " +
                                                        timeslots[index]
                                                            ['tm_end_time'],
                                                    groupValue: isTimeCheck,
                                                    fillColor:
                                                        MaterialStateColor
                                                            .resolveWith(
                                                                (states) =>
                                                                    syanColor),
                                                    onChanged: (dynamic value) {
                                                      timeslots[index][
                                                                  'active_flag'] ==
                                                              1
                                                          ? value = 0
                                                          : setState(() {
                                                              isTimeCheck =
                                                                  value;
                                                              selected_timeid =
                                                                  int.parse(timeslots[
                                                                          index]
                                                                      [
                                                                      'tm_id']);
                                                              selected_timeslot = timeFormatter(
                                                                      timeslots[
                                                                              index]
                                                                          [
                                                                          'tm_start_time']) +
                                                                  " - " +
                                                                  timeFormatter(
                                                                      timeslots[
                                                                              index]
                                                                          [
                                                                          'tm_end_time']);
                                                            });
                                                    },
                                                  ),
                                                ),
                                                timeslots[index]
                                                            ['active_flag'] ==
                                                        1
                                                    ? Text(
                                                        timeFormatter(timeslots[
                                                                    index][
                                                                'tm_start_time']) +
                                                            " - " +
                                                            timeFormatter(
                                                                timeslots[index]
                                                                    [
                                                                    'tm_end_time']) +
                                                            "\n" +
                                                            "Slot Is Full",
                                                        style: montserratRegular
                                                            .copyWith(
                                                          fontSize:
                                                              width * 0.032,
                                                          color: errorcolor,
                                                        ),
                                                      )
                                                    : Text(
                                                        timeFormatter(timeslots[
                                                                    index][
                                                                'tm_start_time']) +
                                                            " - " +
                                                            timeFormatter(
                                                                timeslots[index]
                                                                    [
                                                                    'tm_end_time']),
                                                        style: montserratRegular
                                                            .copyWith(
                                                          fontSize:
                                                              width * 0.034,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                              ],
                                            );
                                          })
                                      : Text(
                                          "No time Slot",
                                          style: montserratRegular.copyWith(
                                            fontSize: width * 0.034,
                                            color: Colors.black,
                                          ),
                                        ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (isProceeding) return;
                          setState(() => isProceeding = true);
                          // await Future.delayed(Duration(milliseconds: 1000));
                          scheduleDrop();
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
                              width: width,
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
                              child: !isProceeding
                                  ? pending_payment == 0.00
                                      ? Text(
                                          "SCHEDULE",
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white),
                                        )
                                      : Text(
                                          "PAY AED " +
                                              pending_payment.toString(),
                                          style: montserratSemiBold.copyWith(
                                              color: Colors.white),
                                        )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Transform.scale(
                                          scale: 0.7,
                                          child: CircularProgressIndicator(
                                            color: white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    var last_date = DateTime.now().add(Duration(days: 5));
    final DateTime? picked = await showDatePicker(
        helpText: "Select Booking Date",
        cancelText: 'Not Now',
        confirmText: "Confirm",
        fieldLabelText: 'Booking Date',
        fieldHintText: 'Month/Date/Year',
        errorFormatText: 'Enter valid date',
        errorInvalidText: 'Enter date in valid range',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        context: context,
        builder: (BuildContext context, Widget? child) {
          return CustomTheme(
            child: child,
          );
        },
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(new Duration(days: max_days)));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        // selected_timeslot = "";
        // selected_timeid = 0;
        // isTimeCheck = "";
        getTimeSlots(picked);
      });
    }
    setState(() {
      // selected_timeslot = "";
      // selected_timeid = 0;
      // isTimeCheck = "";
    });
  }

  timeFormatter(date_data) {
    var time = date_data;
    var temp = int.parse(time.split(':')[0]);
    String? t;
    if (temp >= 12 && temp < 24) {
      t = " PM";
    } else {
      t = " AM";
    }
    if (temp > 12) {
      temp = temp - 12;
      if (temp < 10) {
        time = time.replaceRange(0, 2, "0$temp");
        time += t;
      } else {
        time = time.replaceRange(0, 2, "$temp");
        time += t;
      }
    } else if (temp == 00) {
      time = time.replaceRange(0, 2, '12');
      time += t;
    } else {
      time += t;
    }
    return time;
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
          color: Colors.white,
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
                Container(height: 130, color: warningcolor),
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
                            fontSize: width * 0.034, color: Colors.white)),
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
                        fontSize: width * 0.034, color: Colors.black))),
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
                    style: montserratSemiBold.copyWith(color: Colors.white)),
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
          color: Colors.white,
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
                            fontSize: width * 0.034, color: Colors.white)),
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
                        fontSize: width * 0.034, color: Colors.black))),
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
                    style: montserratSemiBold.copyWith(color: Colors.white)),
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

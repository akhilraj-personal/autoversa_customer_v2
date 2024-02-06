import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart' as lang;
import 'package:autoversa/screens/package_screens/car_repair_screen.dart';
import 'package:autoversa/screens/package_screens/package_details_screen.dart';
import 'package:autoversa/screens/package_screens/summery_screen.dart';
import 'package:autoversa/services/location_controller.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/AppWidgets.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../address/address_add_gmap_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedveh;
  String currency;
  int pickup_loc;
  int drop_loc;
  final int click_id;
  final int pack_type;
  final List<dynamic> booking_list;
  ScheduleScreen(
      {required this.package_id,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      required this.pickup_loc,
      required this.drop_loc,
      required this.click_id,
      required this.pack_type,
      required this.booking_list,
      super.key});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  late int package_price = 0;
  late List custAddressList = [];
  late List pickup_options = [];
  late List temppickup_options = [];
  late List timeslots = [];
  List<Map<String, dynamic>> SelectAddressList = [];
  var selected_address = null;
  var selected_drop_address = null;
  var plocdistance = 0;
  var dlocdistance = 0;
  var selected_timeslot = "";
  var selected_timeid = 0;
  var ptempdata = "";
  var dtempdata = "";
  var isTimeCheck;
  var freeservicedistance = 0;
  var servicedistance = 0;
  var gs_vat = 0;
  var gs_isvat = 0;
  bool isdroplocation = false;
  bool isLocationCheck = true;
  bool isserviceble = false;
  var pickupoption;
  var pickup_name = "";
  var pickup_cost = "";
  var pickup_vat = 0.0;
  var max_days = 0;
  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;
  bool isproceeding = false;
  var buffertime = "0";
  var payment_flag;

  _setdatas() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> packdata =
        json.decode(prefs.get("booking_data").toString());
    package_price = packdata['package_cost'].round();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      _setdatas();
      _fetchdatas(0, 'p&d');
    });
    setState(() => isserviceble = true);
  }

  dropCostCalculation(
      totalDistance, serviceAvailability, message, freeFlag, rangestatus) {
    pickup_options = [];
    for (var ptemp in temppickup_options) {
      var tempCost = '0';
      var min_cost = ptemp['pk_min_cost'];
      var tempCostVat = 0.0;
      var min_cost_vat = 0.0;
      freeFlag
          ? ptemp['pk_freeFlag'] != "1"
              ? tempCost =
                  (int.parse(ptemp['pk_cost']) * totalDistance).toString()
              : tempCost = "0"
          : tempCost = (int.parse(ptemp['pk_cost']) * totalDistance).toString();
      if (gs_isvat == 1) {
        tempCostVat = (int.parse(tempCost) * (gs_vat / 100)).toDouble();
        min_cost_vat = (int.parse(min_cost) * (gs_vat / 100)).toDouble();
        tempCost =
            ((int.parse(tempCost) + (int.parse(tempCost) * (gs_vat / 100)))
                    .round())
                .toString();
        min_cost =
            ((int.parse(min_cost) + (int.parse(min_cost) * (gs_vat / 100)))
                    .round())
                .toString();
        ;
      }
      var temp = {
        "pk_id":
            ptemp['pk_freeFlag'] == "1" && rangestatus ? "0" : ptemp['pk_id'],
        "pk_name": ptemp['pk_name'],
        "pk_mulkiyaflag": ptemp['pk_mulkiyaflag'],
        "pk_cost": ptemp['pk_freeFlag'] == "1" && rangestatus
            ? "Location not\nserviceable"
            : serviceAvailability
                ? (int.parse(tempCost) < int.parse(min_cost) &&
                        ptemp['pk_freeFlag'] != "1")
                    ? (widget.currency + " " + min_cost)
                    : (widget.currency + " " + tempCost)
                : message,
        "pk_cost_value": int.parse(tempCost) < int.parse(min_cost)
            ? ptemp['pk_freeFlag'] == "1"
                ? '0'
                : (min_cost)
            : tempCost,
        "pk_vat_value": int.parse(tempCost) < int.parse(min_cost)
            ? ptemp['pk_freeFlag'] == "1"
                ? 0.0
                : (min_cost_vat)
            : tempCostVat
      };
      pickup_options.add(temp);
    }
    isserviceble = serviceAvailability;
    setState(() {});
  }

  pickupaddresschange(pick_address) {
    setState(() {
      pickupoption = "";
      isTimeCheck = "";
      ptempdata = custAddressList[pick_address]['cad_id'];
      selected_address = pick_address;
      plocdistance = int.parse(custAddressList[pick_address]['cad_distance']);
    });
    setState(() {});
    if (isLocationCheck) {
      dlocdistance = plocdistance;
      dtempdata = ptempdata;
      selected_drop_address = pick_address;
      setState(() {});
      if (servicedistance > plocdistance) {
        if (freeservicedistance > plocdistance) {
          dropCostCalculation(plocdistance * 2, true, "", true, false);
          setState(() {});
        } else {
          dropCostCalculation(plocdistance * 2, true, "", false, false);
          setState(() {});
        }
      } else {
        dropCostCalculation(plocdistance * 2, true, "", false, true);
        setState(() {});
        // dropCostCalculation(0, false, "No Service", false);
        // toast("Service not available in this location");
      }
    } else if (dtempdata != "") {
      if (servicedistance > plocdistance && servicedistance > dlocdistance) {
        if (freeservicedistance > plocdistance &&
            freeservicedistance > dlocdistance) {
          pickup_options = [];
          dropCostCalculation(
              (plocdistance + dlocdistance), true, "", true, false);
          setState(() {});
        } else {
          dropCostCalculation(
              (plocdistance + dlocdistance), true, "", false, false);
          setState(() {});
        }
      } else {
        pickup_options = [];
        dropCostCalculation(
            (plocdistance + dlocdistance), true, "", false, true);
        setState(() {});
        // dropCostCalculation((plocdistance + dlocdistance), true, "", true);
        // dropCostCalculation(0, false, "No Service", false);
        // toast("Service not available in this location");
      }
    } else {
      dropCostCalculation(0, false, "Select Drop", false, false);
      showCustomToast(context, "Please select drop location",
          bgColor: errorcolor, textColor: white);
      setState(() {});
    }
  }

  dropaddresschange(drop_address) {
    setState(() {
      pickupoption = "";
      isTimeCheck = "";
      dtempdata = custAddressList[drop_address]['cad_id'];
      selected_drop_address = drop_address;
      dlocdistance = int.parse(custAddressList[drop_address]['cad_distance']);
    });
    setState(() {});
    var tdistance = 0;
    if (plocdistance != "") {
      if (servicedistance > dlocdistance && servicedistance > plocdistance) {
        if (freeservicedistance > dlocdistance &&
            freeservicedistance > plocdistance) {
          pickup_options = [];
          tdistance = plocdistance + dlocdistance;
          dropCostCalculation(tdistance, true, "", true, false);
          setState(() {});
        } else {
          pickup_options = [];
          tdistance = plocdistance + dlocdistance;
          dropCostCalculation(tdistance, true, "", false, false);
          setState(() {});
        }
      } else {
        // toast("Service not available in this location");
        // dropCostCalculation(0, false, "No Service", false);
        pickup_options = [];
        tdistance = plocdistance + dlocdistance;
        dropCostCalculation(tdistance, true, "", false, true);
        setState(() {});
      }
    } else {
      dropCostCalculation(0, false, "Select Pickup", false, false);
      showCustomToast(context, "Please select pickup location",
          bgColor: errorcolor, textColor: white);
      setState(() {});
    }
  }

  _fetchdatas(address_index, type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map req = {"customerId": prefs.getString('cust_id')};
      custAddressList = [];
      pickup_options = [];
      SelectAddressList = [];
      await getCustomerAddresses(req).then((value) {
        if (value['ret_data'] == "success") {
          custAddressList = value['cust_addressList'];
          for (var add in value['cust_addressList']) {
            SelectAddressList.add(add);
          }
          setState(() {});
          // if (widget.pickup_loc == -1) {
          //   selected_address = SelectAddressList.length - 1;
          //   selected_drop_address = 0;
          // } else if (widget.drop_loc == -1) {
          //   selected_address = widget.pickup_loc;
          //   selected_drop_address = SelectAddressList.length - 1;
          // }
          // setState(() {});
        }
      });
      await getPickupOptions().then((value) {
        gs_vat = int.parse(value['settings']['gs_vat']);
        payment_flag = value['settings']['gs_ispayment'];
        gs_isvat = int.parse(value['settings']['gs_isvat']);
        freeservicedistance =
            int.parse(value['settings']['gs_freeservicearea']);
        servicedistance = int.parse(value['settings']['gs_service_area']);
        max_days = int.parse(value['settings']['gs_nofdays']);
        if (value['ret_data'] == "success") {
          temppickup_options = value['active_pickuptype_list'];
          for (var ptype in value['active_pickuptype_list']) {
            var temp = {
              "pk_id": ptype['pk_id'],
              "pk_name": ptype['pk_name'],
              "pk_mulkiyaflag": ptype['pk_mulkiyaflag'],
              "pk_cost": 'Select Address',
              "pk_cost_value": '0'
            };
            pickup_options.add(temp);
          }
        }
      });
      if (widget.pickup_loc == -1 && isLocationCheck) {
        selected_address = SelectAddressList.length - 1;
        selected_drop_address = SelectAddressList.length - 1;
        setState(() {});
        pickupaddresschange(selected_address);
      } else if (widget.drop_loc == -1) {
        selected_address = widget.pickup_loc;
        selected_drop_address = SelectAddressList.length - 1;
        setState(() {});
      }
      // var temp_address = selected_address;
      // var temp_drop_address = selected_drop_address;
      // selected_address = 0;
      // selected_drop_address = 0;
      //
      //
      // setState(() {});
      // if (address_index == 0) {
      //   // selected_address = selected_address;
      //   // selected_drop_address = 0;
      // } else {
      //   if (type == 'p' && isLocationCheck) {
      //     selected_address = SelectAddressList.length - 1;
      //     selected_drop_address = temp_drop_address;
      //     pickupaddresschange(SelectAddressList.length - 1);
      //   } else if (type == 'd') {
      //     selected_address = temp_address;
      //     selected_drop_address = SelectAddressList.length - 1;
      //     dropaddresschange(SelectAddressList.length - 1);
      //   } else {
      //     selected_address = temp_address;
      //     selected_drop_address = temp_drop_address;
      //   }
      // }
      // if (widget.pickup_loc == -1 || widget.drop_loc == -1) {
      //   pickupaddresschange(selected_address);
      // }
      getTimeSlots(new DateTime.now());
    } catch (e) {
      print(e.toString());
      showCustomToast(context, lang.S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: white);
    }
  }

  Future<void> init() async {}

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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
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
    selected_timeslot = "";
    selected_timeid = 0;
    isTimeCheck = "";
    setState(() {});
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
      print(e.toString());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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
        selected_timeslot = "";
        selected_timeid = 0;
        isTimeCheck = "";
        getTimeSlots(picked);
      });
    }
    setState(() {
      selected_timeslot = "";
      selected_timeid = 0;
      isTimeCheck = "";
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hold On",
                style: montserratSemiBold.copyWith(
                    fontSize: width * 0.04, color: black),
              ),
              16.height,
              Text(
                'Please read before proceeding.\n',
                style: montserratMedium.copyWith(
                    fontSize: width * 0.035, color: black),
              ),
              8.height,
              Text(
                '● Registration card should not be expired',
                style: montserratMedium.copyWith(
                    fontSize: width * 0.035, color: black),
              ),
              4.height,
              Text(
                '● Be careful not to keep anything illicit inside the car',
                style: montserratMedium.copyWith(
                    fontSize: width * 0.035, color: black),
              ),
              16.height,
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          syanColor,
                          lightblueColor,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      "OK",
                      style: montserratSemiBold.copyWith(
                          fontSize: width * 0.035, color: white),
                    ),
                  ),
                ),
              )
            ],
          ),
          contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12))),
        );
      },
    );
  }

  proceedToSummaryClick() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> packdata =
        json.decode(prefs.get("booking_data").toString());
    if (isLocationCheck) {
      if (ptempdata == "" && dtempdata == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a location",
            bgColor: errorcolor, textColor: white);
      } else if (pickup_name == "" || pickupoption == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a pickup type",
            bgColor: errorcolor, textColor: white);
      } else if (selected_timeid == 0) {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a time slot",
            bgColor: errorcolor, textColor: white);
      } else {
        packdata['payment_flag'] = payment_flag;
        packdata['pick_up_location'] = SelectAddressList[selected_address];
        packdata['pick_up_location_id'] = ptempdata;
        packdata['drop_location_id'] = dtempdata;
        !isLocationCheck
            ? packdata['drop_location'] =
                SelectAddressList[selected_drop_address]
            : packdata['drop_location'] = SelectAddressList[selected_address];

        packdata['pick_up_price'] = pickup_cost;
        packdata['pickup_vat'] = pickup_vat;
        packdata['pick_type_id'] = pickupoption.toString();
        packdata['pick_type_name'] = pickup_name;
        packdata['selected_date'] = selectedDate.toString();
        packdata['selected_timeid'] = selected_timeid;
        packdata['selected_timeslot'] = selected_timeslot;

        prefs.setString("booking_data", json.encode(packdata));
        print("booking_data");
        print(packdata);
        pickupoption = "";
        setState(() => isproceeding = false);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SummeryPage(
                    package_id: widget.package_id,
                    custvehlist: widget.custvehlist,
                    selectedveh: widget.selectedveh,
                    currency: widget.currency,
                    couponid: null,
                    coupondiscounttype: null,
                    coupondiscount: null,
                    couponcode: null,
                    discountamount: null,
                    netpayableamount: null,
                    couponapplied: false)));
      }
    } else {
      if (ptempdata == "" || dtempdata == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a location",
            bgColor: errorcolor, textColor: white);
      } else if (pickup_name == "" || pickupoption == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a pickup type",
            bgColor: errorcolor, textColor: white);
      } else if (selected_timeid == 0) {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a time slot",
            bgColor: errorcolor, textColor: white);
      } else {
        packdata['payment_flag'] = payment_flag;
        packdata['pick_up_location'] = SelectAddressList[selected_address];
        packdata['pick_up_location_id'] = ptempdata;
        packdata['drop_location_id'] = dtempdata;
        packdata['drop_location'] = SelectAddressList[selected_drop_address];
        packdata['pick_up_price'] = pickup_cost;
        if (pickup_name == "") {
          setState(() => isproceeding = false);
          showCustomToast(context, "Choose a pickup type",
              bgColor: errorcolor, textColor: white);
        } else {
          packdata['pick_type_id'] = pickupoption.toString();
          packdata['pick_type_name'] = pickup_name;
          packdata['selected_date'] = selectedDate.toString();
          if (selected_timeid != 0) {
            packdata['selected_timeid'] = selected_timeid;
            packdata['selected_timeslot'] = selected_timeslot;
            packdata['payment_flag'] = payment_flag;
            prefs.setString("booking_data", json.encode(packdata));
            print("booking_data");
            print(packdata);
            pickupoption = "";
            setState(() => isproceeding = false);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SummeryPage(
                        package_id: widget.package_id,
                        custvehlist: widget.custvehlist,
                        selectedveh: widget.selectedveh,
                        currency: widget.currency,
                        couponid: null,
                        coupondiscounttype: null,
                        coupondiscount: null,
                        couponcode: null,
                        discountamount: null,
                        netpayableamount: null,
                        couponapplied: false)));
            setState(() => isproceeding = false);
          } else {
            setState(() => isproceeding = false);
            showCustomToast(context, "Choose a time slot",
                bgColor: errorcolor, textColor: white);
          }
        }
      }
    }
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
                              if (widget.click_id == 1 &&
                                  widget.pack_type == 1) {
                                Navigator.of(context).pop();
                              } else if (widget.click_id == 2 &&
                                  widget.pack_type == 1) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PackageDetails(
                                              package_id: widget.package_id,
                                              custvehlist: widget.custvehlist,
                                              currency: widget.currency,
                                              selectedVeh: widget.selectedveh,
                                              booking_list: widget.booking_list,
                                              pack_type: 1,
                                            )));
                              } else if (widget.click_id == 1 &&
                                  widget.pack_type == 2) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CarRepair(
                                              package_id: widget.package_id,
                                              custvehlist: widget.custvehlist,
                                              currency: widget.currency,
                                              selectedVeh: widget.selectedveh,
                                              booking_list: widget.booking_list,
                                              pack_type: 2,
                                            )));
                              } else if (widget.click_id == 2 &&
                                  widget.pack_type == 2) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CarRepair(
                                              package_id: widget.package_id,
                                              custvehlist: widget.custvehlist,
                                              currency: widget.currency,
                                              selectedVeh: widget.selectedveh,
                                              booking_list: widget.booking_list,
                                              pack_type: 2,
                                            )));
                              }
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
                          margin: EdgeInsets.fromLTRB(
                              16.0, height * 0.01, 16.0, 16.0),
                          padding: EdgeInsets.all(12),
                          height: height * 0.045,
                          width: height * 0.37,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                          margin: EdgeInsets.fromLTRB(
                              16.0, height * 0.01, 16.0, 16.0),
                          padding: EdgeInsets.all(8),
                          width: width * 1.85,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(8)),
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
                                  padding: const EdgeInsets.only(left: 8),
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
                                                      color: black,
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
                                                  color: black,
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
                                              style: montserratMedium.copyWith(color: black, fontSize: width * 0.034),
                                              overflow: TextOverflow.clip,
                                              maxLines: 5),
                                      Text(
                                        widget.currency +
                                            " " +
                                            package_price.toStringAsFixed(2),
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.04),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16.0, left: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            custAddressList.length != 0
                                ? "Pickup & Drop"
                                : "Add Address",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                          custAddressList.length != 0
                              ? GestureDetector(
                                  onTap: () async {
                                    PermissionStatus locationStatus =
                                        await Permission.location.request();
                                    if (locationStatus ==
                                        PermissionStatus.denied) {
                                      showCustomToast(context,
                                          "This Permission is recommended for location access.",
                                          bgColor: errorcolor,
                                          textColor: white);
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
                                                    pack_type: widget.pack_type,
                                                    click_id: 2,
                                                    package_id:
                                                        widget.package_id,
                                                    custvehlist:
                                                        widget.custvehlist,
                                                    currency: widget.currency,
                                                    selectedveh:
                                                        widget.selectedveh,
                                                    pickup_loc:
                                                        selected_address != null
                                                            ? selected_address
                                                            : 0,
                                                    drop_loc:
                                                        selected_drop_address !=
                                                                null
                                                            ? selected_drop_address
                                                            : 0,
                                                    drop_flag: isLocationCheck,
                                                    bk_id: "",
                                                    vehname: "",
                                                    make: "",
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
                                            color: black,
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
                                )
                              : Row(),
                        ],
                      ),
                    ),
                    custAddressList.length != 0
                        ? SizedBox(height: width * 0.025)
                        : SizedBox(height: 0),
                    custAddressList.length != 0
                        ? Stack(alignment: Alignment.bottomCenter, children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
                              height: height * 0.045,
                              width: height * 0.37,
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
                            Padding(
                                padding: EdgeInsets.all(16),
                                child: Container(
                                    height: height * 0.095,
                                    width: height * 0.46,
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: borderGreyColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: DropdownButtonFormField2(
                                              value: selected_address != null
                                                  ? SelectAddressList[
                                                      selected_address]
                                                  : null,
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: const Color(
                                                          0xffCCCCCC),
                                                      width: 0.0),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: const Color(
                                                          0xffCCCCCC),
                                                      width: 0.0),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: const Color(
                                                          0xffCCCCCC),
                                                      width: 0.0),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color:
                                                          const Color(0xfffff),
                                                      width: 0.0),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                errorStyle:
                                                    montserratRegular.copyWith(
                                                  fontSize: 12,
                                                  color: warningcolor,
                                                ),
                                              ),
                                              isExpanded: true,
                                              hint: Text(
                                                "Select Address" + "*",
                                                style:
                                                    montserratMedium.copyWith(
                                                        color: Colors.black,
                                                        fontSize: width * 0.04),
                                              ),
                                              buttonHeight: height * 0.095,
                                              buttonPadding: EdgeInsets.all(4),
                                              dropdownDecoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              itemHeight: height * 0.1,
                                              icon: RadiantGradientMask(
                                                child: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: white,
                                                    size: 30),
                                              ),
                                              items: SelectAddressList.map(
                                                  (value) {
                                                return DropdownMenuItem<
                                                        Map<String, dynamic>>(
                                                    value: value,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            color: syanColor,
                                                            size: width * 0.08,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Flexible(
                                                              child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                value['cad_landmark']
                                                                        .toUpperCase() +
                                                                    " (" +
                                                                    value[
                                                                        'cad_city'] +
                                                                    ")",
                                                                maxLines: 1,
                                                                style: montserratMedium.copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        width *
                                                                            0.04),
                                                              ),
                                                              Text(
                                                                value[
                                                                    'cad_address'],
                                                                maxLines: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: montserratMedium.copyWith(
                                                                    color:
                                                                        toastgrey,
                                                                    fontSize:
                                                                        width *
                                                                            0.03),
                                                              ),
                                                            ],
                                                          ))
                                                        ],
                                                      ),
                                                    ));
                                              }).toList(),
                                              onChanged: (selected) {
                                                setState(() {
                                                  pickupaddresschange(
                                                      SelectAddressList
                                                          .indexWhere((element) =>
                                                              element[
                                                                  'cad_id'] ==
                                                              selected![
                                                                  'cad_id']));
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))),
                          ])
                        : GestureDetector(
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
                              if (locationStatus == PermissionStatus.granted) {
                                Get.put(LocationController());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddAddressViaGmap(
                                              pack_type: widget.pack_type,
                                              click_id: 2,
                                              package_id: widget.package_id,
                                              custvehlist: widget.custvehlist,
                                              currency: widget.currency,
                                              selectedveh: widget.selectedveh,
                                              pickup_loc:
                                                  selected_address != null
                                                      ? selected_address
                                                      : 0,
                                              drop_loc:
                                                  selected_drop_address != null
                                                      ? selected_drop_address
                                                      : 0,
                                              drop_flag: isLocationCheck,
                                              bk_id: "",
                                              vehname: "",
                                              make: "",
                                            )));
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                  16.0, height * 0.01, 16.0, 16.0),
                              padding: EdgeInsets.all(8),
                              width: width * 1.85,
                              height: width * 0.2,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Add new address",
                                    style: montserratSemiBold.copyWith(
                                        color: black, fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: greyColor,
                                    size: height * 0.04,
                                    semanticLabel: 'Add Address',
                                  ),
                                ],
                              ),
                            ),
                          ),
                    custAddressList.length != 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(2)),
                              Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  value: isLocationCheck,
                                  fillColor:
                                      MaterialStateProperty.all(syanColor),
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        isLocationCheck = value!;
                                        if (value != true) {
                                          isdroplocation = true;
                                          selected_drop_address = null;
                                          dropCostCalculation(0, false,
                                              "Select Drop", false, false);
                                        } else {
                                          isdroplocation = false;
                                          selected_drop_address =
                                              selected_address;
                                          pickupaddresschange(selected_address);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              Text(
                                lang.S.of(context).drop_location_same,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.clip,
                                style: montserratMedium.copyWith(
                                    color: black, fontSize: width * 0.034),
                              ),
                            ],
                          )
                        : Row(),
                    isdroplocation
                        ? SizedBox(
                            height: 4,
                          )
                        : SizedBox(),
                    isdroplocation
                        ? Container(
                            margin: EdgeInsets.only(right: 16.0, left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).select_drop_address + "*",
                                  textAlign: TextAlign.start,
                                  style: montserratSemiBold.copyWith(
                                      color: black, fontSize: width * 0.034),
                                ),
                                custAddressList.length != 0
                                    ? GestureDetector(
                                        onTap: () async {
                                          PermissionStatus locationStatus =
                                              await Permission.location
                                                  .request();
                                          if (locationStatus ==
                                              PermissionStatus.denied) {
                                            showCustomToast(context,
                                                "This Permission is recommended for location access.",
                                                bgColor: errorcolor,
                                                textColor: white);
                                          }
                                          if (locationStatus ==
                                              PermissionStatus
                                                  .permanentlyDenied) {
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
                                                          pack_type:
                                                              widget.pack_type,
                                                          click_id: 2,
                                                          package_id:
                                                              widget.package_id,
                                                          custvehlist: widget
                                                              .custvehlist,
                                                          currency:
                                                              widget.currency,
                                                          selectedveh: widget
                                                              .selectedveh,
                                                          pickup_loc:
                                                              selected_address !=
                                                                      null
                                                                  ? selected_address
                                                                  : 0,
                                                          drop_loc:
                                                              selected_drop_address !=
                                                                      null
                                                                  ? selected_drop_address
                                                                  : 0,
                                                          drop_flag: false,
                                                          bk_id: "",
                                                          vehname: "",
                                                          make: "",
                                                        )));
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              lang.S.of(context).add_address +
                                                  " ",
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: black,
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
                                      )
                                    : Row(),
                              ],
                            ),
                          )
                        : Row(),
                    isdroplocation
                        ? SizedBox(
                            height: 4,
                          )
                        : SizedBox(),
                    isdroplocation
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(16),
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
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Container(
                                          height: height * 0.095,
                                          width: height * 0.46,
                                          decoration: BoxDecoration(
                                            color: white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: borderGreyColor),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  child:
                                                      DropdownButtonFormField2(
                                                    value: selected_drop_address !=
                                                            null
                                                        ? SelectAddressList[
                                                            selected_drop_address]
                                                        : null,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: const Color(
                                                                    0xffCCCCCC),
                                                                width: 0.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: const Color(
                                                                    0xffCCCCCC),
                                                                width: 0.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: const Color(
                                                                    0xffCCCCCC),
                                                                width: 0.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    const Color(
                                                                        0xfffff),
                                                                width: 0.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      errorStyle:
                                                          montserratRegular
                                                              .copyWith(
                                                        fontSize: 12,
                                                        color: warningcolor,
                                                      ),
                                                    ),
                                                    isExpanded: true,
                                                    hint: Text(
                                                      "Select Address" + "*",
                                                      style: montserratMedium
                                                          .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  width * 0.04),
                                                    ),
                                                    buttonHeight:
                                                        height * 0.095,
                                                    buttonPadding:
                                                        const EdgeInsets.all(4),
                                                    itemHeight: height * 0.08,
                                                    dropdownDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    icon: RadiantGradientMask(
                                                      child: Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: white,
                                                          size: 30),
                                                    ),
                                                    items:
                                                        SelectAddressList.map(
                                                            (value) {
                                                      return DropdownMenuItem<
                                                              Map<String,
                                                                  dynamic>>(
                                                          value: value,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on_outlined,
                                                                  color:
                                                                      syanColor,
                                                                  size: width *
                                                                      0.08,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Flexible(
                                                                    child:
                                                                        Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      value['cad_landmark']
                                                                              .toUpperCase() +
                                                                          " (" +
                                                                          value[
                                                                              'cad_city'] +
                                                                          ")",
                                                                      maxLines:
                                                                          1,
                                                                      style: montserratMedium.copyWith(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              width * 0.04),
                                                                    ),
                                                                    Text(
                                                                      value[
                                                                          'cad_address'],
                                                                      maxLines:
                                                                          2,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: montserratMedium.copyWith(
                                                                          color:
                                                                              toastgrey,
                                                                          fontSize:
                                                                              width * 0.03),
                                                                    ),
                                                                  ],
                                                                ))
                                                              ],
                                                            ),
                                                          ));
                                                    }).toList(),
                                                    onChanged: (selected) {
                                                      setState(() {
                                                        dropaddresschange(SelectAddressList
                                                            .indexWhere((element) =>
                                                                element[
                                                                    'cad_id'] ==
                                                                selected![
                                                                    'cad_id']));
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                    )
                                  ]),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 12,
                    ),
                    // isserviceble
                    //     ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(8)),
                        Text(
                          lang.S.of(context).pickup_options + "*",
                          textAlign: TextAlign.start,
                          style: montserratSemiBold.copyWith(
                              color: black, fontSize: width * 0.034),
                        ),
                      ],
                    ),
                    // : Row(),
                    // isserviceble
                    //     ?
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding:
                            EdgeInsets.only(top: 16, bottom: 16, right: 16),
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
                                                  unselectedWidgetColor: black),
                                          child: pickup_options[index]
                                                      ['pk_id'] ==
                                                  "0"
                                              ? Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          syanColor),
                                                  value: pickup_options[index]
                                                      ['pk_id'],
                                                  groupValue: pickupoption,
                                                  onChanged: (dynamic value) {
                                                    setState(() {
                                                      value = null;
                                                    });
                                                  },
                                                )
                                              : Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          syanColor),
                                                  value: pickup_options[index]
                                                      ['pk_id'],
                                                  groupValue: pickupoption,
                                                  onChanged: (dynamic value) {
                                                    if (ptempdata == "" &&
                                                        dtempdata == "") {
                                                      showCustomToast(context,
                                                          "Choose a location",
                                                          bgColor: errorcolor,
                                                          textColor: white);
                                                    } else {
                                                      if (pickup_options[index][
                                                              'pk_mulkiyaflag'] !=
                                                          "0") {
                                                        _showMyDialog();
                                                        setState(() {
                                                          pickupoption = value;
                                                          pickup_name =
                                                              pickup_options[
                                                                      index]
                                                                  ['pk_name'];
                                                          pickup_cost =
                                                              pickup_options[
                                                                      index][
                                                                  'pk_cost_value'];
                                                          pickup_vat =
                                                              pickup_options[
                                                                      index][
                                                                  'pk_vat_value'];
                                                        });
                                                      } else {
                                                        setState(() {
                                                          pickupoption = value;
                                                          pickup_name =
                                                              pickup_options[
                                                                      index]
                                                                  ['pk_name'];
                                                          pickup_cost =
                                                              pickup_options[
                                                                      index][
                                                                  'pk_cost_value'];
                                                          pickup_vat =
                                                              pickup_options[
                                                                      index][
                                                                  'pk_vat_value'];
                                                        });
                                                      }
                                                      // setState(() {
                                                      //   pickupoption = value;
                                                      //   pickup_name =
                                                      //       pickup_options[
                                                      //               index]
                                                      //           ['pk_name'];
                                                      //   pickup_cost =
                                                      //       pickup_options[
                                                      //               index][
                                                      //           'pk_cost_value'];
                                                      //   pickup_vat =
                                                      //       pickup_options[
                                                      //               index][
                                                      //           'pk_vat_value'];
                                                      // });
                                                    }
                                                  },
                                                ),
                                        ),
                                        pickup_options[index]['pk_id'] == "0"
                                            ? Text(
                                                pickup_options[index]
                                                    ['pk_name'],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    montserratMedium.copyWith(
                                                        color: Colors.grey[350],
                                                        fontSize: width * 0.04),
                                              )
                                            : Text(
                                                pickup_options[index]
                                                    ['pk_name'],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    montserratMedium.copyWith(
                                                        color: black,
                                                        fontSize: width * 0.04),
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
                                              color: black,
                                              fontSize: width * 0.04),
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
                                              color: warningcolor,
                                              fontSize: width * 0.04),
                                        ),
                                ],
                              ),
                            ],
                          );
                        }),

                    8.height,
                    // : Row(),
                    // isserviceble
                    //     ?
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(12)),
                        Text(
                          lang.S.of(context).select_booking_date + "*",
                          style: montserratSemiBold.copyWith(
                              fontSize: width * 0.034, color: black),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(12),
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
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      width: 1, color: Colors.black)),
                              elevation: 4,
                              child: ListTile(
                                trailing: RadiantGradientMask(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.date_range,
                                      color: white,
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
                                    lang.S.of(context).select_booking_date +
                                        " ",
                                    style: montserratMedium.copyWith(
                                        color: black, fontSize: width * 0.04),
                                    maxLines: 3),
                                subtitle: Text(
                                  selectedDate == " "
                                      ? " "
                                      : DateFormat('dd-MM-yyyy')
                                          .format(selectedDate),
                                  style: montserratSemiBold.copyWith(
                                      color: black, fontSize: width * 0.04),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(12)),
                        Text(
                          lang.S.of(context).select_a_time_slot + "*",
                          style: montserratSemiBold.copyWith(
                              fontSize: width * 0.034, color: black),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(12),
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
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: white,
                              border: Border.all(
                                color: black,
                              ),
                            ),
                            child: ExpansionTile(
                              childrenPadding: EdgeInsets.all(8),
                              leading: Container(
                                width: 30,
                                height: 30,
                                child: RadiantGradientMask(
                                  child: Icon(Icons.av_timer_outlined,
                                      color: white, size: 28),
                                ),
                              ),
                              title: Text(lang.S.of(context).select_a_time_slot,
                                  overflow: TextOverflow.ellipsis,
                                  style: montserratMedium.copyWith(
                                      color: black, fontSize: width * 0.04),
                                  maxLines: 3),
                              subtitle: Text(
                                  selected_timeslot == ""
                                      ? "Choose time slot"
                                      : selected_timeslot,
                                  style: montserratSemiBold.copyWith(
                                      color: black,
                                      fontSize: selected_timeslot == ""
                                          ? width * 0.034
                                          : width * 0.04)),
                              textColor: black,
                              trailing: isExpanded
                                  ? Container(
                                      child: RadiantGradientMask(
                                        child: Icon(Icons.keyboard_arrow_up,
                                            color: white, size: 30),
                                      ),
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: white.withAlpha(32)),
                                    )
                                  : RadiantGradientMask(
                                      child: Icon(Icons.keyboard_arrow_down,
                                          color: white, size: 30),
                                    ),
                              onExpansionChanged: (t1) {
                                isExpanded = !isExpanded;
                                setState(() {});
                              },
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: white, boxShadow: null),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                                  black),
                                                      child: Radio(
                                                        value: timeslots[index][
                                                                'tm_start_time'] +
                                                            " - " +
                                                            timeslots[index]
                                                                ['tm_end_time'],
                                                        groupValue: isTimeCheck,
                                                        fillColor:
                                                            MaterialStateColor
                                                                .resolveWith(
                                                                    (states) =>
                                                                        syanColor),
                                                        onChanged:
                                                            (dynamic value) {
                                                          timeslots[index][
                                                                      'active_flag'] ==
                                                                  1
                                                              ? value = 0
                                                              : setState(() {
                                                                  isTimeCheck =
                                                                      value;
                                                                  selected_timeid =
                                                                      int.parse(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_id']);
                                                                  selected_timeslot = timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_start_time']) +
                                                                      " - " +
                                                                      timeFormatter(
                                                                          timeslots[index]
                                                                              [
                                                                              'tm_end_time']);
                                                                });
                                                        },
                                                      ),
                                                    ),
                                                    timeslots[index][
                                                                'active_flag'] ==
                                                            1
                                                        ? Text(
                                                            timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_start_time']) +
                                                                " - " +
                                                                timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_end_time']) +
                                                                "\n" +
                                                                lang.S
                                                                    .of(context)
                                                                    .slot_is_full,
                                                            style:
                                                                montserratMedium
                                                                    .copyWith(
                                                              fontSize:
                                                                  width * 0.034,
                                                              color: errorcolor,
                                                            ),
                                                          )
                                                        : Text(
                                                            timeFormatter(timeslots[
                                                                        index][
                                                                    'tm_start_time']) +
                                                                " - " +
                                                                timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_end_time']),
                                                            style:
                                                                montserratMedium
                                                                    .copyWith(
                                                              fontSize:
                                                                  width * 0.04,
                                                              color: black,
                                                            ),
                                                          ),
                                                  ],
                                                );
                                              })
                                          : Text(
                                              lang.S
                                                  .of(context)
                                                  .no_time_slot_available,
                                              style: montserratMedium.copyWith(
                                                fontSize: width * 0.034,
                                                color: black,
                                              ),
                                            ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                              child: Padding(
                            padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                            child: Text(
                              "Drop location and type can be changed during drop schedule after work completion",
                              overflow: TextOverflow.clip,
                              style: montserratMedium.copyWith(
                                  color: black.withOpacity(0.5),
                                  fontSize: width * 0.0275),
                            ),
                          )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (isproceeding) return;
                        setState(() => isproceeding = true);
                        await Future.delayed(Duration(milliseconds: 1000));
                        proceedToSummaryClick();
                      },
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            margin: EdgeInsets.all(16),
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
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Container(
                              height: height * 0.075,
                              width: height * 0.45,
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
                                      lang.S.of(context).proceed,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

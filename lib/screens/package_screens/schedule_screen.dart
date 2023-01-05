import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/screens/package_screens/summery_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/AppWidgets.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedveh;
  String currency;
  ScheduleScreen(
      {required this.package_id,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      super.key});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  bool isserviceble = false;
  bool issubmitted = false;
  bool isLocationCheck = true;
  bool isdroplocation = false;
  bool isproceeding = false;
  bool isExpanded = false;

  late List custAddressList = [];
  late List citylist = [];
  late List areaList = [];
  late List pickup_options = [];
  late List timeslots = [];
  late List temppickup_options = [];

  List<String?> SelectAddressList = <String?>["Select Address"];
  List<String?> SelectCityList = <String?>["Select City"];
  List<String?> SelectAreaList = <String?>["Select Area"];

  var selected_address = 0;
  var selected_drop_address = 0;
  var freeservicedistance = 0;
  var servicedistance = 0;
  var max_days = 0;
  var plocdistance = 0;
  var dlocdistance = 0;
  var selected_timeid = 0;
  late double package_price = 0.0;
  var selected_timeslot = "";
  var pickupoption;
  var isTimeCheck;
  var ptemp = "";
  var dtemp = "";
  var pickup_name = "";
  var pickup_cost = "";

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
    Future.delayed(Duration.zero, () {
      _fetchdatas(0, 'p&d');
    });
    setState(() => isserviceble = true);
  }

  _setdatas() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> packdata =
        json.decode(prefs.get("booking_data").toString());
    package_price = double.parse(packdata['package_cost'].toString());
    setState(() {});
  }

  _fetchdatas(address_index, type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map req = {"customerId": prefs.getString('cust_id')};
      custAddressList = [];
      pickup_options = [];
      var temp_address = selected_address;
      var temp_drop_address = selected_address;
      selected_address = 0;
      selected_drop_address = 0;
      SelectAddressList = <String?>["Select Address"];
      await getCustomerAddresses(req).then((value) {
        if (value['ret_data'] == "success") {
          custAddressList = value['cust_addressList'];
          var ind = 1;
          for (var add in value['cust_addressList']) {
            SelectAddressList.add("#" +
                ind.toString() +
                ". " +
                add['cad_address'] +
                ", " +
                add['city_name'] +
                ", " +
                add['state_name'] +
                ", " +
                add['country_code']);
            ind++;
          }
        }
      });
      Map country = {
        "countryId": 1,
      };
      await getStateList(country).then((value) {
        if (value['ret_data'] == "success") {
          citylist = value['statelist'];
          for (var state in value['statelist']) {
            SelectCityList.add(state['state_name']);
          }
        }
      });
      // if (address_index == 1) {
      //   pickupaddresschange(address_index);
      // }
      await getPickupOptions().then((value) {
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
              "pk_cost": 'Select Address',
              "pk_cost_value": '0'
            };
            pickup_options.add(temp);
          }
        }
      });
      setState(() {});
      if (address_index == 0) {
        selected_address = address_index;
        selected_drop_address = 0;
      } else {
        if (type == 'p') {
          selected_address = SelectAddressList.length - 1;
          selected_drop_address = temp_drop_address;
          pickupaddresschange(SelectAddressList.length - 1);
        } else if (type == 'd') {
          selected_address = temp_address;
          selected_drop_address = SelectAddressList.length - 1;
          dropaddresschange(SelectAddressList.length - 1);
        }
      }
      setState(() {});
      getTimeSlots(new DateTime.now());
    } catch (e) {
      // setState(() => issubmitted = false);
      print(e.toString());
      showCustomToast(context, S.of(context).toast_application_error,
          bgColor: errorcolor, textColor: whiteColor);
    }
  }

  Future<void> init() async {}

  dropCostCalculation(
      totalDistance, serviceAvailability, message, freeFlag, rangestatus) {
    pickup_options = [];
    for (var ptemp in temppickup_options) {
      var tempCost = '0';
      freeFlag
          ? ptemp['pk_freeFlag'] != "1"
              ? tempCost =
                  (int.parse(ptemp['pk_cost']) * totalDistance).toString()
              : tempCost = "0"
          : tempCost = (int.parse(ptemp['pk_cost']) * totalDistance).toString();
      var temp = {
        "pk_id":
            ptemp['pk_freeFlag'] == "1" && rangestatus ? "0" : ptemp['pk_id'],
        "pk_name": ptemp['pk_name'],
        "pk_cost": ptemp['pk_freeFlag'] == "1" && rangestatus
            ? "Not Available"
            : serviceAvailability
                ? (int.parse(tempCost) < int.parse(ptemp['pk_min_cost']) &&
                        ptemp['pk_freeFlag'] != "1")
                    ? (widget.currency + " " + ptemp['pk_min_cost'])
                    : (widget.currency + " " + tempCost)
                : message,
        "pk_cost_value": int.parse(tempCost) < int.parse(ptemp['pk_min_cost'])
            ? (ptemp['pk_min_cost'])
            : tempCost
      };
      pickup_options.add(temp);
    }
    isserviceble = serviceAvailability;
    setState(() {});
  }

  pickupaddresschange(pick_address) {
    if ((pick_address - 1) == -1) {
      dropCostCalculation(0, false, "Select Pickup", false, false);
      showCustomToast(context, "Please select a pickup location",
          bgColor: blackColor, textColor: whiteColor);
    } else {
      setState(() {
        pickupoption = "";
        isTimeCheck = "";
        ptemp = custAddressList[pick_address - 1]['cad_id'];
        selected_address = pick_address;
        plocdistance =
            int.parse(custAddressList[pick_address - 1]['cad_distance']);
      });

      if (isLocationCheck) {
        dlocdistance = plocdistance;
        dtemp = ptemp;
        selected_drop_address = pick_address;
        if (servicedistance > plocdistance) {
          if (freeservicedistance > plocdistance) {
            dropCostCalculation(plocdistance * 2, true, "", true, false);
          } else {
            dropCostCalculation(plocdistance * 2, true, "", false, false);
          }
        } else {
          dropCostCalculation(plocdistance * 2, true, "", false, true);
          // dropCostCalculation(0, false, "No Service", false);
          // toast("Service not available in this location");
        }
      } else if (dtemp != "") {
        if (servicedistance > plocdistance && servicedistance > dlocdistance) {
          if (freeservicedistance > plocdistance &&
              freeservicedistance > dlocdistance) {
            pickup_options = [];
            dropCostCalculation(
                (plocdistance + dlocdistance), true, "", true, false);
          } else {
            dropCostCalculation(
                (plocdistance + dlocdistance), true, "", false, false);
          }
        } else {
          pickup_options = [];
          dropCostCalculation(
              (plocdistance + dlocdistance), true, "", false, true);
          // dropCostCalculation((plocdistance + dlocdistance), true, "", true);
          // dropCostCalculation(0, false, "No Service", false);
          // toast("Service not available in this location");
        }
      } else {
        dropCostCalculation(0, false, "Select Drop", false, false);
        showCustomToast(context, "Please select drop location",
            bgColor: blackColor, textColor: whiteColor);
      }
    }
  }

  dropaddresschange(drop_address) {
    if (drop_address - 1 == -1) {
      dropCostCalculation(0, false, "Select Drop", false, false);
      showCustomToast(context, "Please select a drop location",
          bgColor: blackColor, textColor: whiteColor);
    } else {
      setState(() {
        pickupoption = "";
        isTimeCheck = "";
        dtemp = custAddressList[drop_address - 1]['cad_id'];
        selected_drop_address = drop_address;
        dlocdistance =
            int.parse(custAddressList[drop_address - 1]['cad_distance']);
      });
      var tdistance = 0;
      if (plocdistance != "") {
        if (servicedistance > dlocdistance && servicedistance > plocdistance) {
          if (freeservicedistance > dlocdistance &&
              freeservicedistance > plocdistance) {
            pickup_options = [];
            tdistance = plocdistance + dlocdistance;
            dropCostCalculation(tdistance, true, "", true, false);
          } else {
            pickup_options = [];
            tdistance = plocdistance + dlocdistance;
            dropCostCalculation(tdistance, true, "", false, false);
          }
        } else {
          // toast("Service not available in this location");
          // dropCostCalculation(0, false, "No Service", false);
          pickup_options = [];
          tdistance = plocdistance + dlocdistance;
          dropCostCalculation(tdistance, true, "", false, true);
        }
      } else {
        dropCostCalculation(0, false, "Select Pickup", false, false);
        showCustomToast(context, "Please select pickup location",
            bgColor: blackColor, textColor: whiteColor);
      }
    }
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
        timeslots = [];
        if (value['ret_data'] == "success") {
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
            } else {
              var slotemp = {
                "tm_id": bslots['tm_id'],
                "tm_start_time": bslots['tm_start_time'],
                "tm_end_time": bslots['tm_end_time'],
                "active_flag": 0
              };
              timeslots.add(slotemp);
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

  proceedToSummaryClick() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> packdata =
        json.decode(prefs.get("booking_data").toString());
    if (isLocationCheck) {
      if (ptemp == "" && dtemp == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a location",
            bgColor: errorcolor, textColor: whiteColor);
      } else if (pickup_name == "" || pickupoption == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a pickup type",
            bgColor: errorcolor, textColor: whiteColor);
      } else if (selected_timeid == 0) {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a time slot",
            bgColor: errorcolor, textColor: whiteColor);
      } else if (isserviceble == false) {
        setState(() => isproceeding = false);
        showCustomToast(context,
            "Selected location not in our service area. Please choose another location",
            bgColor: errorcolor, textColor: whiteColor);
      } else {
        packdata['pick_up_location'] = SelectAddressList[selected_address];
        packdata['pick_up_location_id'] = ptemp;
        packdata['drop_location_id'] = dtemp;
        !isLocationCheck
            ? packdata['drop_location'] =
                SelectAddressList[selected_drop_address]
            : packdata['drop_location'] = SelectAddressList[selected_address];

        packdata['pick_up_price'] = pickup_cost;

        packdata['pick_type_id'] = pickupoption.toString();
        packdata['pick_type_name'] = pickup_name;
        packdata['selected_date'] = selectedDate.toString();
        packdata['selected_timeid'] = selected_timeid;
        packdata['selected_timeslot'] = selected_timeslot;
        prefs.setString("booking_data", json.encode(packdata));
        pickupoption = "";
        setState(() => isproceeding = false);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SummeryPage(
                    package_id: widget.package_id,
                    custvehlist: widget.custvehlist,
                    selectedveh: widget.selectedveh,
                    currency: widget.currency)));
      }
    } else {
      if (ptemp == "" && dtemp == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a location",
            bgColor: errorcolor, textColor: whiteColor);
      } else if (pickup_name == "" || pickupoption == "") {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a pickup type",
            bgColor: errorcolor, textColor: whiteColor);
      } else if (selected_timeid == 0) {
        setState(() => isproceeding = false);
        showCustomToast(context, "Choose a time slot",
            bgColor: errorcolor, textColor: whiteColor);
      } else if (isserviceble == false) {
        setState(() => isproceeding = false);
        showCustomToast(context,
            "Selected location not in our service area. Please choose another location",
            bgColor: errorcolor, textColor: whiteColor);
      } else {
        packdata['pick_up_location'] = SelectAddressList[selected_address];
        packdata['pick_up_location_id'] = ptemp;
        packdata['drop_location_id'] = dtemp;
        packdata['drop_location'] = SelectAddressList[selected_drop_address];
        packdata['pick_up_price'] = pickup_cost;
        if (pickup_name == "") {
          showCustomToast(context, "Choose a pickup type",
              bgColor: errorcolor, textColor: whiteColor);
          setState(() => isproceeding = false);
        } else {
          packdata['pick_type_id'] = pickupoption.toString();
          packdata['pick_type_name'] = pickup_name;
          packdata['selected_date'] = selectedDate.toString();
          if (selected_timeid != 0) {
            packdata['selected_timeid'] = selected_timeid;
            packdata['selected_timeslot'] = selected_timeslot;
            prefs.setString("booking_data", json.encode(packdata));
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
                        )));
            setState(() => isproceeding = false);
          } else {
            setState(() => isproceeding = false);
            showCustomToast(context, "Choose a time slot",
                bgColor: errorcolor, textColor: whiteColor);
          }
        }
      }
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
          backgroundColor: whiteColor,
          shadowColor: whiteColor,
          iconTheme: IconThemeData(color: whiteColor),
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
                          blueColor,
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
        body: SingleChildScrollView(
          child: Container(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(8),
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
                          margin: EdgeInsets.all(16.0),
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
                                                      color: blackColor,
                                                      fontSize: 14),
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
                                              style: montserratRegular.copyWith(
                                                  color: blackColor,
                                                  fontSize: 12),
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
                                              style: montserratRegular.copyWith(color: blackColor, fontSize: 12),
                                              overflow: TextOverflow.clip,
                                              maxLines: 5),
                                      Text(
                                        widget.currency +
                                            " " +
                                            package_price.toString(),
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor, fontSize: 14),
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
                      margin: EdgeInsets.only(right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " ",
                            style: montserratSemiBold.copyWith(
                                color: blackColor, fontSize: width * 0.04),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Add Address ",
                                  style: montserratLight.copyWith(
                                      color: blackColor, fontSize: 14),
                                ),
                                Container(
                                  child: Image.asset(
                                    ImageConst.add_black,
                                    scale: 4.7,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(alignment: Alignment.bottomCenter, children: [
                          Container(
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
                          Container(
                              height: height * 0.075,
                              width: height * 0.46,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderGreyColor),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        left: width * 0.025,
                                        right: width * 0.025,
                                      ),
                                      child: DropdownButtonFormField(
                                        value:
                                            SelectAddressList[selected_address],
                                        isExpanded: true,
                                        decoration: InputDecoration.collapsed(
                                            hintText: ''),
                                        hint: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              S.of(context).emirates,
                                              style: montserratRegular.copyWith(
                                                  color: blackColor,
                                                  fontSize: 14),
                                            )),
                                        items: SelectAddressList.map(
                                            (String? value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value!,
                                              style: montserratRegular.copyWith(
                                                  color: blackColor,
                                                  fontSize: 14),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            pickupaddresschange(
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
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
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
                            fillColor: MaterialStateProperty.all(syanColor),
                            onChanged: (value) {
                              setState(
                                () {
                                  isLocationCheck = value!;
                                  if (value != true) {
                                    isdroplocation = true;
                                    selected_drop_address = 0;
                                    dropCostCalculation(
                                        0, false, "Select Drop", false, false);
                                  } else {
                                    isdroplocation = false;
                                    selected_drop_address = selected_address;
                                    pickupaddresschange(selected_address);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        Text(
                          "Drop location same as pickup location ",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: montserratLight.copyWith(
                              color: blackColor, fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.all(2)),
                        isdroplocation
                            ? Column(
                                children: <Widget>[
                                  SizedBox(
                                    width: double.infinity,
                                    child: Container(
                                      child: Text(
                                        "Select Drop Address" + "*",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(),
                        SizedBox(
                          height: 8,
                        ),
                        isdroplocation
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
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
                                                    color: syanColor
                                                        .withOpacity(.5),
                                                    spreadRadius: 0,
                                                    blurStyle: BlurStyle.outer,
                                                    offset: Offset(0, 0)),
                                              ]),
                                        ),
                                        Container(
                                            height: height * 0.075,
                                            width: height * 0.46,
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: borderGreyColor),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                      left: width * 0.025,
                                                      right: width * 0.025,
                                                    ),
                                                    child:
                                                        DropdownButtonFormField(
                                                      value: SelectAddressList[
                                                          selected_address],
                                                      isExpanded: true,
                                                      decoration:
                                                          InputDecoration
                                                              .collapsed(
                                                                  hintText: ''),
                                                      hint: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            S
                                                                .of(context)
                                                                .emirates,
                                                            style: montserratRegular
                                                                .copyWith(
                                                                    color:
                                                                        blackColor,
                                                                    fontSize:
                                                                        14),
                                                          )),
                                                      items:
                                                          SelectAddressList.map(
                                                              (String? value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value!,
                                                            style: montserratRegular
                                                                .copyWith(
                                                                    color:
                                                                        blackColor,
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          pickupaddresschange(
                                                              SelectAddressList
                                                                  .indexOf(value
                                                                      .toString()));
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ))
                                      ]),
                                ],
                              )
                            : Container(),
                      ],
                    ),
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
                          "Pickup options" + "*",
                          textAlign: TextAlign.start,
                          style: montserratSemiBold.copyWith(
                              color: blackColor, fontSize: 14),
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
                                                  unselectedWidgetColor:
                                                      blackColor),
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
                                                    setState(() {
                                                      pickupoption = value;
                                                      pickup_name =
                                                          pickup_options[index]
                                                              ['pk_name'];
                                                      pickup_cost =
                                                          pickup_options[index]
                                                              ['pk_cost_value'];
                                                    });
                                                  },
                                                ),
                                        ),
                                        pickup_options[index]['pk_id'] == "0"
                                            ? Text(
                                                pickup_options[index]
                                                    ['pk_name'],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: montserratLight.copyWith(
                                                    color: Colors.grey[350],
                                                    fontSize: 14),
                                              )
                                            : Text(
                                                pickup_options[index]
                                                    ['pk_name'],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: montserratLight.copyWith(
                                                    color: blackColor,
                                                    fontSize: 14),
                                              ),
                                      ]),
                                  pickup_options[index]['pk_id'] == "0"
                                      ? Text(
                                          pickup_options[index]['pk_cost'] ==
                                                  "AED 0"
                                              ? "FREE"
                                              : pickup_options[index]
                                                  ['pk_cost'],
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.clip,
                                          style: montserratLight.copyWith(
                                              color: blackColor, fontSize: 14),
                                        )
                                      : Text(
                                          pickup_options[index]['pk_cost'] ==
                                                  "AED 0"
                                              ? "FREE"
                                              : pickup_options[index]
                                                  ['pk_cost'],
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.clip,
                                          style: montserratLight.copyWith(
                                              color: warningcolor,
                                              fontSize: 14),
                                        ),
                                ],
                              ),
                            ],
                          );
                        }),
                    // : Row(),
                    // isserviceble
                    //     ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(4)),
                        Expanded(
                          flex: 2,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      width: 1, color: Colors.black)),
                              elevation: 4,
                              child: ListTile(
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.date_range,
                                    color: syanColor,
                                  ),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                ),
                                onTap: () {
                                  _selectDate(context);
                                },
                                title: Text("Select Booking Date" + "*",
                                    style: montserratLight.copyWith(
                                        color: blackColor, fontSize: 12),
                                    maxLines: 3),
                                subtitle: Text(
                                  selectedDate == " "
                                      ? " "
                                      : DateFormat('dd-MM-yyyy')
                                          .format(selectedDate),
                                  style: montserratLight.copyWith(
                                      color: blackColor, fontSize: 12),
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: whiteColor,
                              border: Border.all(
                                color: blackColor,
                              ),
                            ),
                            child: ExpansionTile(
                              leading: Container(
                                child: Icon(Icons.av_timer_outlined,
                                    color: syanColor, size: 25),
                              ),
                              title: Text("Select a Time Slot",
                                  style: montserratLight.copyWith(
                                      color: blackColor, fontSize: 12),
                                  maxLines: 3),
                              subtitle: Text(
                                  selected_timeslot == ""
                                      ? " "
                                      : selected_timeslot,
                                  style: montserratLight.copyWith(
                                      color: blackColor, fontSize: 12)),
                              textColor: blackColor,
                              // trailing: isExpanded
                              //     ? Container(
                              //         child: Icon(Icons.keyboard_arrow_up,
                              //             color: whiteColor, size: 30),
                              //         padding: EdgeInsets.all(4),
                              //         decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(100),
                              //             color: whiteColor.withAlpha(32)),
                              //       )
                              //     : Icon(Icons.keyboard_arrow_down,
                              //         color: whiteColor, size: 30),
                              // onExpansionChanged: (t1) {
                              //   isExpanded = !isExpanded;
                              //   setState(() {});
                              // },
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: whiteColor,
                                    border: Border.all(
                                      color: whiteColor,
                                    ),
                                  ),
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
                                                                  blackColor),
                                                      child: Radio(
                                                        value: timeslots[index][
                                                                'tm_start_time'] +
                                                            " - " +
                                                            timeslots[index]
                                                                ['tm_end_time'],
                                                        groupValue: isTimeCheck,
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
                                                            timeFormatter(timeslots[
                                                                        index][
                                                                    'tm_start_time']) +
                                                                " - " +
                                                                timeFormatter(
                                                                    timeslots[
                                                                            index]
                                                                        [
                                                                        'tm_end_time']) +
                                                                "\n" +
                                                                "Slot is Full",
                                                            style: TextStyle(
                                                              fontSize: 14,
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
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: blackColor,
                                                            ),
                                                          ),
                                                  ],
                                                );
                                              })
                                          : Text(
                                              "No time slot available",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: whiteColor,
                                              ),
                                            ),
                                      SizedBox(
                                        height: 8,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
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
                                  blueColor,
                                ],
                              ),
                            ),
                            child: !isproceeding
                                ? Text(
                                    "BOOK",
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

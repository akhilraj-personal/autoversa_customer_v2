import 'dart:async';
import 'dart:convert';

import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/generated/l10n.dart';
import 'package:autoversa/main.dart';
import 'package:autoversa/screens/booking/resummery_screen.dart';
import 'package:autoversa/screens/no_internet_screen.dart';
import 'package:autoversa/services/post_auth_services.dart';
import 'package:autoversa/utils/AppWidgets.dart';
import 'package:autoversa/utils/app_validations.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:autoversa/utils/common_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class RescheduleScreen extends StatefulWidget {
  final Map<String, dynamic> bk_data;
  final List<dynamic> custvehlist;
  final int selectedVeh;
  String currency;
  RescheduleScreen(
      {required this.bk_data,
      required this.currency,
      required this.custvehlist,
      required this.selectedVeh,
      super.key});

  @override
  State<RescheduleScreen> createState() => RescheduleScreenState();
}

class RescheduleScreenState extends State<RescheduleScreen> {
  late double package_price = 0.0;
  late List custAddressList = [];

  late List citylist = [];
  late List areaList = [];
  late List pickup_options = [];
  late List temppickup_options = [];
  late List timeslots = [];
  List<Marker> myMarker = [];
  final _formKey = GlobalKey<FormState>();

  List<String?> SelectAddressList = <String?>["Select Address"];
  List<String?> SelectCityList = <String?>["Select City"];
  List<String?> SelectAreaList = <String?>["Select Area"];
  final GlobalKey<FormFieldState> areaKey = GlobalKey<FormFieldState>();

  var selected_address = 0;
  var selected_drop_address = 0;
  var plocdistance = 0;
  var dlocdistance = 0;
  var selected_timeslot = "";
  var selected_timeid = 0;
  var ptemp = "";
  var dtemp = "";
  var isTimeCheck;
  var freeservicedistance = 0;
  var servicedistance = 0;
  bool isdroplocation = false;
  bool isLocationCheck = true;
  var pickupoption;
  var pickup_name = "";
  var pickup_cost = "";
  var emirates = 0, city = 0;
  var AddressType = "Home";
  bool isDefaultAddressChecked = true;
  var address = "";
  var landmark = "";
  var Statelat = "24.3547";
  var Statelong = "54.5020";
  var Marklat = 0.0;
  var Marklong = 0.0;
  var max_days = 0;
  bool isgooglemap = false;
  bool iscancelsubmitted = false;
  FocusNode cancelFocus = FocusNode();
  var cancel = "";
  var vehiclename = "";

  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.3547, 54.5020), zoom: 13);
  Completer<GoogleMapController> _controller = Completer();

  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;
  bool issubmitted = false;
  bool isproceeding = false;
  bool isserviceble = false;
  bool isoffline = false;
  late Map<String, dynamic> bookingdetails = {};
  late Map<String, dynamic> booking_package = {};
  late Map<String, dynamic> vehicle = {};
  FocusNode addressFocus = FocusNode();
  FocusNode landmarkFocusNode = FocusNode();
  final GlobalKey<FormFieldState> pick_city = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> pick_area = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> drop_city = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> drop_area = GlobalKey<FormFieldState>();
  StreamSubscription? internetconnection;
  bool isActive = true;

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
    Future.delayed(Duration.zero, () {
      getBookingDetailsID();
      _fetchdatas(0, 'p&d');
    });
    setState(() => isserviceble = true);
  }

  getBookingDetailsID() async {
    Map req = {"book_id": base64.encode(utf8.encode(widget.bk_data['bk_id']))};
    print(req);
    await getbookingdetails(req).then((value) {
      if (value['ret_data'] == "success") {
        setState(() {
          bookingdetails = value['booking'];
          vehicle = value['booking']['vehicle'];
          booking_package = value['booking']['booking_package'];
        });
        setState(() {
          vehiclename = vehicle['cv_variant'] != null
              ? vehicle['cv_make'] +
                  vehicle['cv_model'] +
                  vehicle['cv_variant'] +
                  vehicle['cv_year']
              : vehicle['cv_make'] + vehicle['cv_model'] + vehicle['cv_year'];
        });
      }
    });
  }

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
            ? ptemp['pk_freeFlag'] == "1"
                ? '0'
                : (ptemp['pk_min_cost'])
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
          bgColor: errorcolor, textColor: white);
    } else {
      setState(() {
        pickupoption = "";
        isTimeCheck = "";
        selected_timeslot = "";
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
          // showCustomToast(context, "Service not available in this location",
          //     bgColor: errorcolor, textColor: white);
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
          // dropCostCalculation(0, false, "No Service", false);
          // showCustomToast(context, "Service not available in this location",
          //     bgColor: errorcolor, textColor: white);
        }
      } else {
        dropCostCalculation(0, false, "Select Drop", false, false);
        showCustomToast(context, "Please select a drop location",
            bgColor: errorcolor, textColor: white);
      }
    }
  }

  dropaddresschange(drop_address) {
    if (drop_address - 1 == -1) {
      dropCostCalculation(0, false, "Select Drop", false, false);
      showCustomToast(context, "Please select a drop location",
          bgColor: errorcolor, textColor: white);
    } else {
      setState(() {
        pickupoption = "";
        isTimeCheck = "";
        selected_timeslot = "";
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
          // dropCostCalculation(0, false, "No Service", false);
          // showCustomToast(context, "Service not available in this location",
          //     bgColor: errorcolor, textColor: white);
          pickup_options = [];
          tdistance = plocdistance + dlocdistance;
          dropCostCalculation(tdistance, true, "", false, true);
        }
      } else {
        dropCostCalculation(0, false, "Select Pickup", false, false);
        showCustomToast(context, "Please select Pick up location",
            bgColor: errorcolor, textColor: white);
      }
    }
  }

  getarealist(data) async {
    if (SelectAreaList.indexOf(data.toString()) > 0) {
      setState(() {});
      var temp = areaList[SelectAreaList.indexOf(data.toString()) - 1];
      CameraPosition _kLake = CameraPosition(
        target: LatLng(double.parse(temp['city_lattitude']),
            double.parse(temp['city_longitude'])),
        zoom: 15.4746,
      );
      final GoogleMapController controller = await _controller.future;
      controller.moveCamera(CameraUpdate.newCameraPosition(_kLake));
      setState(() {
        city = int.parse(temp['city_id']);
        Statelat = temp['city_lattitude'];
        Statelong = temp['city_longitude'];
      });
    }
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
        if (type == 'p' && isLocationCheck) {
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
      setState(() => issubmitted = false);
      showCustomToast(context, ST.of(context).toast_application_error,
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
    internetconnection!.cancel();
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
    } catch (e) {}
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

  cancelbookingbottomsheet() async {
    showModalBottomSheet(
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setBottomState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                color: context.cardColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          margin: const EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          width: width * 1.85,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          duration: 1000.milliseconds,
                          curve: Curves.linearToEaseOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      height: 950,
                                      decoration: BoxDecoration(
                                          color:
                                              context.scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 8),
                                          Column(
                                            children: <Widget>[
                                              SizedBox(
                                                width: double.infinity,
                                                child: Container(
                                                  child: Text(
                                                    "Cancel Reason" + "*",
                                                    textAlign: TextAlign.center,
                                                    style: montserratSemiBold
                                                        .copyWith(
                                                            fontSize:
                                                                width * 0.034,
                                                            color: black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                Container(
                                                  height: height * 0.045,
                                                  width: height * 0.37,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 16,
                                                            color: syanColor
                                                                .withOpacity(
                                                                    .5),
                                                            spreadRadius: 0,
                                                            blurStyle:
                                                                BlurStyle.outer,
                                                            offset:
                                                                Offset(0, 0)),
                                                      ]),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      16, 16, 16, 0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    16)),
                                                        color: white),
                                                    child: TextField(
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      minLines: 1,
                                                      maxLines: 5,
                                                      maxLength: 500,
                                                      textInputAction:
                                                          TextInputAction
                                                              .newline,
                                                      decoration:
                                                          InputDecoration(
                                                              counterText: "",
                                                              hintText:
                                                                  "Enter Reason",
                                                              hintStyle: montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          12),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            greyColor,
                                                                        width:
                                                                            0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        color:
                                                                            greyColor,
                                                                        width:
                                                                            0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              )),
                                                      focusNode: cancelFocus,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          cancel = value;
                                                        });
                                                      },
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ]),
                                          16.height,
                                          GestureDetector(
                                            onTap: () async {
                                              if (cancel == "") {
                                                setState(() =>
                                                    iscancelsubmitted = false);
                                                showCustomToast(
                                                    context, "Enter Reason",
                                                    bgColor: errorcolor,
                                                    textColor: white);
                                              } else {
                                                try {
                                                  setState(() =>
                                                      iscancelsubmitted = true);
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  Map req = {
                                                    "bookid":
                                                        widget.bk_data['bk_id'],
                                                    "reason": cancel,
                                                    "type": "CANCEL",
                                                    "backendstatus": "CANB",
                                                    "customerstatus": "CANC",
                                                    "user_type": "0",
                                                    "current_bstatus":
                                                        "Awaiting payment",
                                                    "current_cstatus":
                                                        "Awaiting payment"
                                                  };
                                                  await booking_cancel(req)
                                                      .then((value) {
                                                    if (value['ret_data'] ==
                                                        "success") {
                                                      showCustomToast(context,
                                                          "Booking Canceled",
                                                          bgColor: Colors.black,
                                                          textColor: white);
                                                      Navigator
                                                          .pushReplacementNamed(
                                                              context,
                                                              Routes.bottombar);
                                                    } else {
                                                      setState(() =>
                                                          iscancelsubmitted =
                                                              false);
                                                    }
                                                  });
                                                } catch (e) {
                                                  setState(() =>
                                                      iscancelsubmitted =
                                                          false);
                                                }
                                                // finish(context);
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
                                                          BorderRadius.circular(
                                                              14),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 16,
                                                            color: syanColor
                                                                .withOpacity(
                                                                    .6),
                                                            spreadRadius: 0,
                                                            blurStyle:
                                                                BlurStyle.outer,
                                                            offset:
                                                                Offset(0, 0)),
                                                      ]),
                                                ),
                                                Container(
                                                  height: height * 0.075,
                                                  width: height * 0.4,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                14)),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        syanColor,
                                                        lightblueColor,
                                                      ],
                                                    ),
                                                  ),
                                                  child: !isproceeding
                                                      ? Text(
                                                          "SUBMIT",
                                                          style: montserratSemiBold
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Transform.scale(
                                                              scale: 0.7,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: white,
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
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }

  proceedToSummaryClick() async {
    final prefs = await SharedPreferences.getInstance();
    late Map<String, dynamic> packdata = {};
    if (isLocationCheck) {
      if (ptemp == "" && dtemp == "") {
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
      } else if (isserviceble == false) {
        setState(() => isproceeding = false);
        showCustomToast(context,
            "Selected location not in our service area. Please choose another location",
            bgColor: errorcolor, textColor: white);
      } else {
        packdata['package_cost'] = booking_package['bkp_cust_amount'];
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
        packdata['vehicle_id'] = bookingdetails['vehicle']['cv_id'];
        packdata['complaint'] = bookingdetails['bk_complaint'];
        prefs.setString("booking_data", json.encode(packdata));
        pickupoption = "";
        setState(() => isproceeding = false);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResummeryScreen(
                      bk_data: widget.bk_data,
                      custvehlist: widget.custvehlist,
                      selectedveh: widget.selectedVeh,
                      currency: widget.currency,
                    )));
      }
    } else {
      if (ptemp == "" && dtemp == "") {
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
      } else if (isserviceble == false) {
        setState(() => isproceeding = false);
        showCustomToast(context,
            "Selected location not in our service area. Please choose another location",
            bgColor: errorcolor, textColor: white);
      } else {
        packdata['package_cost'] = booking_package['bkp_cust_amount'];
        packdata['pick_up_location'] = SelectAddressList[selected_address];
        packdata['pick_up_location_id'] = ptemp;
        packdata['drop_location_id'] = dtemp;
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
            packdata['vehicle_id'] = bookingdetails['vehicle']['cv_id'];
            packdata['complaint'] = bookingdetails['bk_complaint'];
            prefs.setString("booking_data", json.encode(packdata));
            pickupoption = "";
            setState(() => isproceeding = false);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResummeryScreen(
                        bk_data: widget.bk_data,
                        custvehlist: widget.custvehlist,
                        selectedveh: widget.selectedVeh,
                        currency: widget.currency)));
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
        statusBarBrightness: Brightness.light,
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
                            booking_package['pkg_name'] != null
                                ? booking_package['pkg_name']
                                : "Schedule Page",
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
                              if (vehicle['cv_make'] == 'Mercedes Benz') ...[
                                Image.asset(
                                  ImageConst.benz_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'BMW') ...[
                                Image.asset(
                                  ImageConst.bmw_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'Skoda') ...[
                                Image.asset(
                                  ImageConst.skod_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'Audi') ...[
                                Image.asset(
                                  ImageConst.aud_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] == 'Porsche') ...[
                                Image.asset(
                                  ImageConst.porsche_ico,
                                  width: width * 0.12,
                                ),
                              ] else if (vehicle['cv_make'] ==
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
                                      vehicle['cv_plate_number'] != "" &&
                                              vehicle['cv_plate_number'] != null
                                          ? Text(
                                              vehicle['cv_plate_number']
                                                  .toUpperCase(),
                                              style:
                                                  montserratSemiBold.copyWith(
                                                      color: black,
                                                      fontSize: width * 0.034),
                                              maxLines: 2)
                                          : SizedBox(),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(vehiclename,
                                          style: montserratMedium.copyWith(
                                              color: black,
                                              fontSize: width * 0.034),
                                          overflow: TextOverflow.clip,
                                          maxLines: 5),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        booking_package['bkp_cust_amount'] !=
                                                null
                                            ? widget.currency +
                                                " " +
                                                booking_package[
                                                    'bkp_cust_amount']
                                            : "0",
                                        style: montserratSemiBold.copyWith(
                                            color: warningcolor,
                                            fontSize: width * 0.034),
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
                            "Pickup & Drop",
                            style: montserratSemiBold.copyWith(
                                color: black, fontSize: width * 0.034),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                enableDrag: true,
                                isDismissible: true,
                                isScrollControlled: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (builder) {
                                  return StatefulBuilder(builder: (BuildContext
                                          context,
                                      StateSetter
                                          setBottomState /*You can rename this!*/) {
                                    getcitylist(data) async {
                                      if (SelectCityList.indexOf(data) > 0) {
                                        var temp = citylist[
                                            SelectCityList.indexOf(data) - 1];
                                        emirates = int.parse(temp['state_id']);
                                        Map state = {
                                          "stateId": temp['state_id'],
                                        };
                                        CameraPosition _kLake = CameraPosition(
                                          target: LatLng(
                                              double.parse(
                                                  temp['state_lattitude']),
                                              double.parse(
                                                  temp['state_longitude'])),
                                          zoom: 13.4746,
                                        );
                                        setBottomState(() {});
                                        final GoogleMapController controller =
                                            await _controller.future;
                                        controller.moveCamera(
                                            CameraUpdate.newCameraPosition(
                                                _kLake));
                                        setBottomState(() {});
                                        setBottomState(() {
                                          Statelat = temp['state_lattitude'];
                                          Statelong = temp['state_longitude'];
                                          SelectAreaList = <String?>[
                                            "Select Area"
                                          ];
                                          drop_area.currentState?.reset();
                                        });
                                        SelectAreaList.length = 1;
                                        await getCityList(state).then((value) {
                                          if (value['ret_data'] == "success") {
                                            setBottomState(() {
                                              areaList = [];
                                              SelectAreaList = <String?>[
                                                "Select Area"
                                              ];
                                            });
                                            areaList = value['citylist'];
                                            for (var city
                                                in value['citylist']) {
                                              SelectAreaList.add(
                                                  city['city_name']);
                                            }
                                          }
                                        });
                                        setBottomState(() {});
                                      }
                                    }

                                    return DraggableScrollableSheet(
                                      initialChildSize: 0.6,
                                      minChildSize: 0.2,
                                      maxChildSize: 1,
                                      builder: (context, scrollController) {
                                        return Container(
                                          color: context.cardColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: SingleChildScrollView(
                                            controller: scrollController,
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AnimatedContainer(
                                                    margin:
                                                        const EdgeInsets.all(8),
                                                    padding: EdgeInsets.all(8),
                                                    width: width * 1.85,
                                                    decoration: BoxDecoration(
                                                      color: context.cardColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      boxShadow:
                                                          defaultBoxShadow(),
                                                    ),
                                                    duration: 1000.milliseconds,
                                                    curve:
                                                        Curves.linearToEaseOut,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        Container(
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                height: 850,
                                                                decoration: BoxDecoration(
                                                                    color: context
                                                                        .scaffoldBackgroundColor,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(8))),
                                                                child: Column(
                                                                  children: [
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        SizedBox(
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Text(
                                                                              "Select City" + "*",
                                                                              textAlign: TextAlign.left,
                                                                              style: montserratMedium.copyWith(fontSize: width * 0.034, color: black),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    8.height,
                                                                    DropdownButtonFormField2(
                                                                      value:
                                                                          SelectCityList[
                                                                              0],
                                                                      key:
                                                                          drop_city,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        //Add isDense true and zero Padding.
                                                                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xffCCCCCC),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xffCCCCCC),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xffCCCCCC),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xfffff),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        errorStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              warningcolor,
                                                                        ),
                                                                        //Add more decoration as you want here
                                                                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                      ),
                                                                      isExpanded:
                                                                          true,
                                                                      hint:
                                                                          Text(
                                                                        "Select City" +
                                                                            "*",
                                                                        style: montserratMedium.copyWith(
                                                                            color:
                                                                                black,
                                                                            fontSize:
                                                                                width * 0.04),
                                                                      ),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      buttonHeight:
                                                                          height *
                                                                              0.075,
                                                                      buttonPadding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              10),
                                                                      dropdownDecoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                      ),
                                                                      items: SelectCityList.map(
                                                                          (String?
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child: Text(
                                                                              value!,
                                                                              style: montserratRegular.copyWith(fontSize: width * 0.032)),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged:
                                                                          (value) {
                                                                        setBottomState(
                                                                            () {
                                                                          isgooglemap =
                                                                              true;
                                                                        });
                                                                        getcitylist(
                                                                            value);
                                                                      },
                                                                    ),
                                                                    8.height,
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        SizedBox(
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Text(
                                                                              "Select Area" + "*",
                                                                              style: montserratMedium.copyWith(color: black, fontSize: width * 0.04),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    8.height,
                                                                    DropdownButtonFormField2(
                                                                      key:
                                                                          drop_area,
                                                                      value:
                                                                          SelectAreaList[
                                                                              0],
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        //Add isDense true and zero Padding.
                                                                        //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        focusedBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xffCCCCCC),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        focusedErrorBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xffCCCCCC),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        enabledBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xffCCCCCC),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        errorBorder:
                                                                            OutlineInputBorder(
                                                                          // width: 0.0 produces a thin "hairline" border
                                                                          borderSide: const BorderSide(
                                                                              color: const Color(0xfffff),
                                                                              width: 0.0),
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        errorStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              warningcolor,
                                                                        ),
                                                                        //Add more decoration as you want here
                                                                        //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                                      ),
                                                                      isExpanded:
                                                                          true,
                                                                      hint:
                                                                          Text(
                                                                        "Select Area" +
                                                                            "*",
                                                                        style: montserratMedium.copyWith(
                                                                            color:
                                                                                black,
                                                                            fontSize:
                                                                                width * 0.04),
                                                                      ),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      buttonHeight:
                                                                          height *
                                                                              0.075,
                                                                      buttonPadding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              10),
                                                                      dropdownDecoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                      ),
                                                                      items: SelectAreaList.map(
                                                                          (String?
                                                                              value) {
                                                                        return DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              value,
                                                                          child: Text(
                                                                              value!,
                                                                              style: boldTextStyle(size: 14)),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged:
                                                                          (value) {
                                                                        getarealist(
                                                                            value);
                                                                      },
                                                                    ),
                                                                    8.height,
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        SizedBox(
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Text(
                                                                              "Address",
                                                                              textAlign: TextAlign.left,
                                                                              style: montserratMedium.copyWith(fontSize: width * 0.032, color: black),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    8.height,
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      child:
                                                                          Container(
                                                                        width: width *
                                                                            0.85,
                                                                        decoration: const BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(16)),
                                                                            color: white),
                                                                        child:
                                                                            TextFormField(
                                                                          keyboardType:
                                                                              TextInputType.text,
                                                                          minLines:
                                                                              1,
                                                                          maxLines:
                                                                              2,
                                                                          maxLength:
                                                                              80,
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              address = value;
                                                                            });
                                                                          },
                                                                          validator:
                                                                              (value) {
                                                                            return addressValidation(value,
                                                                                context);
                                                                          },
                                                                          onFieldSubmitted:
                                                                              (value) {
                                                                            FocusScope.of(context).requestFocus(landmarkFocusNode);
                                                                          },
                                                                          focusNode:
                                                                              addressFocus,
                                                                          textCapitalization:
                                                                              TextCapitalization.sentences,
                                                                          decoration: InputDecoration(
                                                                              counterText: "",
                                                                              hintText: "Address",
                                                                              hintStyle: montserratMedium.copyWith(
                                                                                color: black,
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: const BorderSide(color: black, width: 0.5),
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: const BorderSide(color: black, width: 0.5),
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              )),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                      ),
                                                                    ),
                                                                    12.height,
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        SizedBox(
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Text(
                                                                              "Building Name/Flat No",
                                                                              textAlign: TextAlign.left,
                                                                              style: montserratMedium.copyWith(fontSize: width * 0.032, color: black),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    8.height,
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2),
                                                                      child:
                                                                          Container(
                                                                        width: width *
                                                                            0.85,
                                                                        decoration: const BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(16)),
                                                                            color: white),
                                                                        child: TextField(
                                                                            keyboardType: TextInputType.multiline,
                                                                            minLines: 1,
                                                                            maxLength: 50,
                                                                            onChanged: (value) {
                                                                              if (value != "") {
                                                                                var ret = buildingValidation(value);
                                                                                if (ret == null) {
                                                                                  setState(() {
                                                                                    landmark = value;
                                                                                  });
                                                                                } else {
                                                                                  showCustomToast(context, "Enter valid details", bgColor: errorcolor, textColor: white);
                                                                                }
                                                                              }
                                                                            },
                                                                            textCapitalization: TextCapitalization.sentences,
                                                                            decoration: InputDecoration(
                                                                                counterText: "",
                                                                                hintText: "Building Name/Flat No",
                                                                                hintStyle: montserratMedium.copyWith(color: black, fontSize: width * 0.032),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: black, width: 0.5),
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(color: black, width: 0.5),
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                ))),
                                                                        alignment:
                                                                            Alignment.center,
                                                                      ),
                                                                    ),
                                                                    8.height,
                                                                    Wrap(
                                                                        crossAxisAlignment:
                                                                            WrapCrossAlignment
                                                                                .center,
                                                                        alignment:
                                                                            WrapAlignment
                                                                                .start,
                                                                        direction:
                                                                            Axis.horizontal,
                                                                        children: [
                                                                          Theme(
                                                                            data:
                                                                                Theme.of(context).copyWith(unselectedWidgetColor: syanColor),
                                                                            child:
                                                                                Radio(
                                                                              value: 'Home',
                                                                              groupValue: AddressType,
                                                                              onChanged: (dynamic value) {
                                                                                setBottomState(() {
                                                                                  AddressType = value;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                              "Home",
                                                                              style: montserratRegular.copyWith(fontSize: width * 0.032, color: black)),
                                                                          Theme(
                                                                            data:
                                                                                Theme.of(context).copyWith(
                                                                              unselectedWidgetColor: syanColor,
                                                                            ),
                                                                            child:
                                                                                Radio(
                                                                              value: 'Office',
                                                                              groupValue: AddressType,
                                                                              onChanged: (dynamic value) {
                                                                                setBottomState(() {
                                                                                  AddressType = value;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                              "Office",
                                                                              style: montserratRegular.copyWith(fontSize: width * 0.032, color: black)),
                                                                          Theme(
                                                                            data:
                                                                                Theme.of(context).copyWith(unselectedWidgetColor: syanColor),
                                                                            child:
                                                                                Radio(
                                                                              value: 'Other',
                                                                              groupValue: AddressType,
                                                                              onChanged: (dynamic value) {
                                                                                setBottomState(() {
                                                                                  AddressType = value;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                              "Other",
                                                                              style: montserratRegular.copyWith(fontSize: width * 0.032, color: black)),
                                                                        ]),
                                                                    8.height,
                                                                    isgooglemap
                                                                        ? Column(
                                                                            children: <Widget>[
                                                                              SizedBox(
                                                                                width: double.infinity,
                                                                                child: Container(
                                                                                  child: Text(
                                                                                    "Tap to mark",
                                                                                    textAlign: TextAlign.left,
                                                                                    style: montserratSemiBold.copyWith(fontSize: width * 0.034, color: black),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : Row(),
                                                                    8.height,
                                                                    isgooglemap
                                                                        ? isMobile
                                                                            ? Container(
                                                                                height: 130,
                                                                                width: width,
                                                                                color: white,
                                                                                child: GoogleMap(
                                                                                  initialCameraPosition: _initialPosition,
                                                                                  myLocationEnabled: true,
                                                                                  markers: Set.from(myMarker),
                                                                                  onTap: _handleTap,
                                                                                  myLocationButtonEnabled: true,
                                                                                  onMapCreated: (GoogleMapController controller) {
                                                                                    _controller.complete(controller);
                                                                                  },
                                                                                ),
                                                                              )
                                                                            : Container(
                                                                                color: Colors.transparent,
                                                                                height: context.height(),
                                                                                alignment: Alignment.center,
                                                                                width: width,
                                                                                child: Text("Google Map", style: montserratRegular.copyWith(fontSize: width * 0.034)),
                                                                              )
                                                                        : Row(),
                                                                    8.height,
                                                                    Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Checkbox(
                                                                          value:
                                                                              isDefaultAddressChecked,
                                                                          fillColor:
                                                                              MaterialStateProperty.all(syanColor),
                                                                          onChanged:
                                                                              (value) {
                                                                            setBottomState(
                                                                              () {
                                                                                isDefaultAddressChecked = value!;
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                        Text(
                                                                          "Set as default address",
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.clip,
                                                                          style:
                                                                              montserratMedium.copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    26.height,
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        if (emirates ==
                                                                            0) {
                                                                          setState(() =>
                                                                              issubmitted = false);
                                                                          showCustomToast(
                                                                              context,
                                                                              "Select City",
                                                                              bgColor: errorcolor,
                                                                              textColor: white);
                                                                        } else if (city ==
                                                                            0) {
                                                                          setState(() =>
                                                                              issubmitted = false);
                                                                          showCustomToast(
                                                                              context,
                                                                              "Select Area",
                                                                              bgColor: errorcolor,
                                                                              textColor: white);
                                                                        } else if (address ==
                                                                            "") {
                                                                          setState(() =>
                                                                              issubmitted = false);
                                                                          showCustomToast(
                                                                              context,
                                                                              "Enter Address",
                                                                              bgColor: errorcolor,
                                                                              textColor: white);
                                                                        } else {
                                                                          final prefs =
                                                                              await SharedPreferences.getInstance();
                                                                          try {
                                                                            setState(() =>
                                                                                issubmitted = true);
                                                                            await Future.delayed(Duration(milliseconds: 1000));
                                                                            Map req =
                                                                                {
                                                                              "countryId": 1,
                                                                              "stateId": emirates,
                                                                              "cityId": city,
                                                                              "address": address,
                                                                              "landmark": landmark,
                                                                              "add_type": AddressType,
                                                                              "lattitude": Marklat != 0.0 ? Marklat : Statelat,
                                                                              "longitude": Marklong != 0.0 ? Marklong : Statelong,
                                                                              "cust_id": prefs.getString("cust_id")
                                                                            };
                                                                            await saveCustomerAddress(req).then((value) {
                                                                              if (value['ret_data'] == "success") {
                                                                                emirates = 0;
                                                                                city = 0;
                                                                                address = "";
                                                                                landmark = "";
                                                                                issubmitted = false;
                                                                                Marklat = 0.0;
                                                                                Marklong = 0.0;
                                                                                AddressType = "Home";
                                                                                setBottomState(() {
                                                                                  drop_city.currentState?.reset();
                                                                                  drop_area.currentState?.reset();
                                                                                  SelectCityList = <String?>[
                                                                                    "Select City"
                                                                                  ];
                                                                                  SelectAreaList = <String?>[
                                                                                    "Select Area"
                                                                                  ];
                                                                                });
                                                                                setState(() {});
                                                                                _fetchdatas(1, 'p');
                                                                                setState(() => isgooglemap = false);
                                                                                setState(() => issubmitted = false);
                                                                              } else {
                                                                                setState(() => issubmitted = false);
                                                                              }
                                                                            });
                                                                          } catch (e) {
                                                                            setState(() =>
                                                                                issubmitted = false);
                                                                            print(e.toString());
                                                                          }
                                                                          finish(
                                                                              context);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Stack(
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                height * 0.045,
                                                                            width:
                                                                                height * 0.37,
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [
                                                                              BoxShadow(blurRadius: 16, color: syanColor.withOpacity(.6), spreadRadius: 0, blurStyle: BlurStyle.outer, offset: Offset(0, 0)),
                                                                            ]),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                height * 0.075,
                                                                            width:
                                                                                height * 0.45,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.rectangle,
                                                                              borderRadius: BorderRadius.all(Radius.circular(14)),
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
                                                                                    ST.of(context).save,
                                                                                    style: montserratSemiBold.copyWith(color: Colors.white),
                                                                                  )
                                                                                : Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  });
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ST.of(context).add_address + " ",
                                  style: montserratMedium.copyWith(
                                      color: black, fontSize: width * 0.034),
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
                      height: 4,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(alignment: Alignment.bottomCenter, children: [
                          Container(
                            margin: EdgeInsets.all(16),
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
                                height: height * 0.075,
                                width: height * 0.46,
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderGreyColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: DropdownButtonFormField2(
                                          value: SelectAddressList[
                                              selected_address],
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            //Add isDense true and zero Padding.
                                            //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            focusedBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
                                                  width: 0.0),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              // width: 0.0 produces a thin "hairline" border
                                              borderSide: const BorderSide(
                                                  color:
                                                      const Color(0xffCCCCCC),
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
                                            errorStyle:
                                                montserratRegular.copyWith(
                                              fontSize: 12,
                                              color: warningcolor,
                                            ),
                                            //Add more decoration as you want here
                                            //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                          ),
                                          isExpanded: true,
                                          hint: Text(
                                            "",
                                            style: montserratMedium.copyWith(
                                                color: black,
                                                fontSize: width * 0.035),
                                          ),
                                          buttonHeight: height * 0.075,
                                          buttonPadding:
                                              const EdgeInsets.only(right: 10),
                                          dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          items: SelectAddressList.map(
                                              (String? value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value!,
                                                style:
                                                    montserratRegular.copyWith(
                                                        color: black,
                                                        fontSize:
                                                            width * 0.034),
                                              ),
                                            );
                                          }).toList(),
                                          validator: (value) {},
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
                                )),
                          )
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
                          ST.of(context).drop_location_same,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.clip,
                          style: montserratMedium.copyWith(
                              color: black, fontSize: width * 0.034),
                        ),
                      ],
                    ),
                    isdroplocation
                        ? SizedBox(
                            height: 4,
                          )
                        : SizedBox(),
                    isdroplocation
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(8)),
                              Text(
                                ST.of(context).select_drop_address + "*",
                                textAlign: TextAlign.start,
                                style: montserratSemiBold.copyWith(
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
                                          height: height * 0.075,
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
                                                    value: SelectAddressList[
                                                        selected_address],
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    decoration: InputDecoration(
                                                      //Add isDense true and zero Padding.
                                                      //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        // width: 0.0 produces a thin "hairline" border
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
                                                        // width: 0.0 produces a thin "hairline" border
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
                                                        // width: 0.0 produces a thin "hairline" border
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
                                                        // width: 0.0 produces a thin "hairline" border
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
                                                      //Add more decoration as you want here
                                                      //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                                    ),
                                                    isExpanded: true,
                                                    hint: Text(
                                                      "",
                                                      style: montserratMedium
                                                          .copyWith(
                                                              color: black,
                                                              fontSize: width *
                                                                  0.035),
                                                    ),
                                                    buttonHeight:
                                                        height * 0.075,
                                                    buttonPadding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    dropdownDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    items:
                                                        SelectAddressList.map(
                                                            (String? value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(
                                                          value!,
                                                          style:
                                                              montserratRegular
                                                                  .copyWith(
                                                                      color:
                                                                          black,
                                                                      fontSize:
                                                                          14),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        dropaddresschange(
                                                            SelectAddressList
                                                                .indexOf(value
                                                                    .toString()));
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
                        : Column(),
                    SizedBox(
                      height: 8,
                    ),
                    // isserviceble
                    //     ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(8)),
                        Text(
                          ST.of(context).pickup_options + "*",
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
                        padding: EdgeInsets.only(top: 4, bottom: 4, right: 16),
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
                                                style:
                                                    montserratMedium.copyWith(
                                                        color: Colors.grey[350],
                                                        fontSize:
                                                            width * 0.034),
                                              )
                                            : Text(
                                                pickup_options[index]
                                                    ['pk_name'],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: montserratLight.copyWith(
                                                    color: black,
                                                    fontSize: width * 0.034),
                                              ),
                                      ]),
                                  pickup_options[index]['pk_id'] == "0"
                                      ? Text(
                                          pickup_options[index]['pk_cost'] ==
                                                  "AED 0"
                                              ? ST.of(context).free
                                              : pickup_options[index]
                                                  ['pk_cost'],
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.clip,
                                          style: montserratLight.copyWith(
                                              color: black,
                                              fontSize: width * 0.034),
                                        )
                                      : Text(
                                          pickup_options[index]['pk_cost'] ==
                                                  "AED 0"
                                              ? ST.of(context).free
                                              : pickup_options[index]
                                                  ['pk_cost'],
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.clip,
                                          style: montserratMedium.copyWith(
                                              color: warningcolor,
                                              fontSize: width * 0.034),
                                        ),
                                ],
                              ),
                            ],
                          );
                        }),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(12)),
                        Text(
                          ST.of(context).select_booking_date + "*",
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
                              shadowColor: null,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      width: 1, color: Colors.grey.shade500)),
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
                                    ST.of(context).select_booking_date + " ",
                                    style: montserratMedium.copyWith(
                                        color: black, fontSize: width * 0.032),
                                    maxLines: 3),
                                subtitle: Text(
                                  selectedDate == " "
                                      ? " "
                                      : DateFormat('dd-MM-yyyy')
                                          .format(selectedDate),
                                  style: montserratMedium.copyWith(
                                      color: black, fontSize: width * 0.032),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.all(12)),
                        Text(
                          ST.of(context).select_a_time_slot + "*",
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
                                color: greyColor,
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
                              title: Text(ST.of(context).select_a_time_slot,
                                  overflow: TextOverflow.ellipsis,
                                  style: montserratMedium.copyWith(
                                      color: black, fontSize: width * 0.034),
                                  maxLines: 3),
                              subtitle: Text(
                                  selected_timeslot == ""
                                      ? ST.of(context).select_a_time_slot + "*"
                                      : selected_timeslot,
                                  style: montserratMedium.copyWith(
                                      color: black, fontSize: width * 0.034)),
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
                                                                ST
                                                                    .of(context)
                                                                    .slot_is_full,
                                                            style:
                                                                montserratMedium
                                                                    .copyWith(
                                                              fontSize:
                                                                  width * 0.034,
                                                              color: black,
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
                                                                  width * 0.034,
                                                              color: black,
                                                            ),
                                                          ),
                                                  ],
                                                );
                                              })
                                          : Text(
                                              ST
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
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              cancelbookingbottomsheet();
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: height * 0.035,
                                  width: height * 0.15,
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
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  height: height * 0.075,
                                  width: height * 0.25,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(color: syanColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        white,
                                        white,
                                        white,
                                        white,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    "CANCEL",
                                    style: montserratSemiBold.copyWith(
                                        color: syanColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              if (isproceeding) return;
                              setState(() => isproceeding = true);
                              await Future.delayed(
                                  Duration(milliseconds: 1000));
                              proceedToSummaryClick();
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: height * 0.035,
                                  width: height * 0.15,
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
                                  margin: EdgeInsets.only(left: 16, right: 16),
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
                                          "PROCEED",
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
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
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

  _handleTap(LatLng tappedpoint) {
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(tappedpoint.toString()), position: tappedpoint));
      Marklat = tappedpoint.latitude;
      Marklong = tappedpoint.longitude;
    });
  }
}

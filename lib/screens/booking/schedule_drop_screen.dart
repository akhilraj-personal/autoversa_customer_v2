import 'dart:async';
import 'dart:convert';

import 'package:custom_clippers/custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/image_const.dart';
import '../../constant/text_style.dart';
import '../../generated/l10n.dart';
import '../../services/post_auth_services.dart';
import '../../utils/AppWidgets.dart';
import '../../utils/app_validations.dart';
import '../../utils/color_utils.dart';
import '../../utils/common_utils.dart';
import 'booking_status_flow_page.dart';

class ScheduleDropScreen extends StatefulWidget {
  final String bk_id;
  final String vehname;
  final String make;
  const ScheduleDropScreen(
      {required this.bk_id,
      required this.vehname,
      required this.make,
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
      isProceeding = false,
      isgooglemap = false;

  List custAddressList = [];
  List timeslots = [];
  List pickup_options = [];
  List<String?> SelectAddressList = <String?>["Select Address"];
  List<String?> SelectCityList = <String?>["Select City"];
  List<String?> SelectAreaList = <String?>["Select Area"];
  List citylist = [];
  List areaList = [];
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
  var emirates = 0, city = 0;
  var Statelat = "24.3547";
  var Statelong = "54.5020";
  var address = "";
  var landmark = "";
  var AddressType = "Home";

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> drop_city = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> drop_area = GlobalKey<FormFieldState>();
  final TextEditingController textEditingController = TextEditingController();
  FocusNode addressFocus = FocusNode();
  FocusNode landmarkFocusNode = FocusNode();
  bool isDefaultAddressChecked = true;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getBookingDetailsByID();
      // _fetchdatas(0, 'd');
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
      // dropCostCalculation(0, false, "Select Drop", false, false);
      new_selected_drop = 0;
      showCustomToast(context, "Please select drop location",
          bgColor: errorcolor, textColor: white);
    } else {
      new_selected_drop =
          int.parse(custAddressList[drop_address - 1]['cad_id']);
      var serviceDistance =
          int.parse(custAddressList[drop_address - 1]['cad_distance']);
      var new_distance = serviceDistance - int.parse(selected_distance);
      if (new_distance < 0) {
        new_distance = 0;
      }
      pickup_options = [];
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
          setState(() {});
        }
      });
      for (var state in citylist) {
        SelectCityList.add(state['state_name']);
      }
      selected_address = SelectAddressList.length - 1;
      new_selected_drop =
          int.parse(custAddressList[SelectAddressList.length - 2]['cad_id']);
      var serviceDistance = int.parse(
          custAddressList[SelectAddressList.length - 2]['cad_distance']);
      print(custAddressList[SelectAddressList.length - 2]['cad_address']);
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
      showCustomToast(context, ST.of(context).toast_application_error,
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
            if (currentDropDetails['cad_id'] == add['cad_id']) {
              selected_address = ind;
              selected_distance = add['cad_distance'];
            }
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
            if (ptype['pk_id'] == currentDropType['pk_id']) {
              selected_drop = ptype['pk_id'];
            }
            var tempCost = '0';
            ptype['pk_id'] == currentDropType['pk_id']
                ? tempCost = "0"
                : ptype['pk_freeFlag'] != "1"
                    ? tempCost = (double.parse(ptype['pk_cost']) *
                            (double.parse(selected_distance)))
                        .toString()
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
          }
        }
      });
      // if (address_index == 0) {
      //   selected_address = address_index;
      //   selected_drop_address = 0;
      // } else {
      //   if (type == 'd') {
      //     selected_address = temp_address;
      //     selected_drop_address = SelectAddressList.length - 1;
      //     dropaddresschange(SelectAddressList.length - 1);
      //   }
      // }
      // setState(() {});
      getTimeSlots(new DateTime.now());
      isLoaded = true;
      setState(() {});
    } catch (e) {
      setState(() => isSubmitted = false);
      print(e.toString());
      showCustomToast(context, ST.of(context).toast_application_error,
          bgColor: errorcolor, textColor: Colors.white);
    }
  }

  getTimeSlots(pickdate) async {
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
              Navigator.pop(context);
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
                              onTap: () {
                                Completer<GoogleMapController> _controller =
                                    Completer();
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
                                      CameraPosition _initialPosition =
                                          CameraPosition(
                                              target: LatLng(24.3547, 54.5020),
                                              zoom: 13);
                                      getcitylist(data) async {
                                        if (SelectCityList.indexOf(data) > 0) {
                                          var temp = citylist[
                                              SelectCityList.indexOf(data) - 1];
                                          emirates =
                                              int.parse(temp['state_id']);
                                          Map state = {
                                            "stateId": temp['state_id'],
                                          };
                                          CameraPosition _kLake =
                                              CameraPosition(
                                            target: LatLng(
                                                double.parse(
                                                    temp['state_lattitude']),
                                                double.parse(
                                                    temp['state_longitude'])),
                                            zoom: 13.4746,
                                          );
                                          final GoogleMapController controller =
                                              await _controller.future;
                                          controller.moveCamera(
                                              CameraUpdate.newCameraPosition(
                                                  _kLake));
                                          setBottomState(() {
                                            Statelat = temp['state_lattitude'];
                                            Statelong = temp['state_longitude'];
                                            SelectAreaList = <String?>[
                                              "Select Area"
                                            ];
                                            drop_area.currentState?.reset();
                                          });
                                          SelectAreaList.length = 1;
                                          await getCityList(state)
                                              .then((value) {
                                            if (value['ret_data'] ==
                                                "success") {
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

                                      getarealist(data) async {
                                        // areaKey.currentState!.reset();
                                        if (SelectAreaList.indexOf(
                                                data.toString()) >
                                            0) {
                                          setState(() {});
                                          var temp = areaList[
                                              SelectAreaList.indexOf(
                                                      data.toString()) -
                                                  1];
                                          CameraPosition _kLake =
                                              CameraPosition(
                                            target: LatLng(
                                                double.parse(
                                                    temp['city_lattitude']),
                                                double.parse(
                                                    temp['city_longitude'])),
                                            zoom: 15.4746,
                                          );
                                          final GoogleMapController controller =
                                              await _controller.future;
                                          controller.moveCamera(
                                              CameraUpdate.newCameraPosition(
                                                  _kLake));
                                          setState(() {
                                            city = int.parse(temp['city_id']);
                                            Statelat = temp['city_lattitude'];
                                            Statelong = temp['city_longitude'];
                                          });
                                        }
                                      }

                                      return DraggableScrollableSheet(
                                        initialChildSize: 0.6,
                                        minChildSize: 0.2,
                                        maxChildSize: 1,
                                        builder: (context, scrollController) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0),
                                            decoration: BoxDecoration(
                                              color: context.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: defaultBoxShadow(),
                                            ),
                                            child: SingleChildScrollView(
                                              controller: scrollController,
                                              child: Form(
                                                key: _formKey,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    AnimatedContainer(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8, 8, 8, 8),
                                                      width: width * 1.85,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            context.cardColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        boxShadow:
                                                            defaultBoxShadow(),
                                                      ),
                                                      duration:
                                                          1000.milliseconds,
                                                      curve: Curves
                                                          .linearToEaseOut,
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
                                                                              8),
                                                                  decoration: BoxDecoration(
                                                                      color: context
                                                                          .cardColor,
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
                                                                              child: Text(
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
                                                                        key:
                                                                            drop_city,
                                                                        value:
                                                                            SelectCityList[0],
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
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
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xffCCCCCC), width: 0.0),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            // width: 0.0 produces a thin "hairline" border
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xffCCCCCC), width: 0.0),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            // width: 0.0 produces a thin "hairline" border
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xffCCCCCC), width: 0.0),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            // width: 0.0 produces a thin "hairline" border
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xfffff), width: 0.0),
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
                                                                              color: Colors.black,
                                                                              fontSize: width * 0.04),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        buttonHeight:
                                                                            height *
                                                                                0.075,
                                                                        buttonPadding: const EdgeInsets.only(
                                                                            left:
                                                                                20,
                                                                            right:
                                                                                10),
                                                                        dropdownDecoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                        ),
                                                                        items: SelectCityList.map((String?
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Text(
                                                                              value!,
                                                                              style: montserratMedium.copyWith(color: Colors.black, fontSize: width * 0.04),
                                                                            ),
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
                                                                              child: Text(
                                                                                "Select Area" + "*",
                                                                                textAlign: TextAlign.left,
                                                                                style: montserratMedium.copyWith(color: black, fontSize: width * 0.034),
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
                                                                            SelectAreaList[0],
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
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
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xffCCCCCC), width: 0.0),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            // width: 0.0 produces a thin "hairline" border
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xffCCCCCC), width: 0.0),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            // width: 0.0 produces a thin "hairline" border
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xffCCCCCC), width: 0.0),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            // width: 0.0 produces a thin "hairline" border
                                                                            borderSide:
                                                                                const BorderSide(color: const Color(0xfffff), width: 0.0),
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
                                                                              color: Colors.black,
                                                                              fontSize: width * 0.04),
                                                                        ),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        buttonHeight:
                                                                            height *
                                                                                0.075,
                                                                        buttonPadding: const EdgeInsets.only(
                                                                            left:
                                                                                20,
                                                                            right:
                                                                                10),
                                                                        dropdownDecoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                        ),
                                                                        items: SelectAreaList.map((String?
                                                                            value) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                value,
                                                                            child:
                                                                                Text(value!, style: montserratMedium.copyWith(color: Colors.black, fontSize: width * 0.04)),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (value) {
                                                                          getarealist(
                                                                              value);
                                                                        },
                                                                        searchController:
                                                                            textEditingController,
                                                                        searchInnerWidgetHeight:
                                                                            height *
                                                                                0.07,
                                                                        searchInnerWidget:
                                                                            Container(
                                                                          height:
                                                                              height * 0.07,
                                                                          padding:
                                                                              const EdgeInsets.only(
                                                                            top:
                                                                                8,
                                                                            bottom:
                                                                                4,
                                                                            right:
                                                                                8,
                                                                            left:
                                                                                8,
                                                                          ),
                                                                          child:
                                                                              TextFormField(
                                                                            expands:
                                                                                true,
                                                                            maxLines:
                                                                                null,
                                                                            controller:
                                                                                textEditingController,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: true,
                                                                              contentPadding: const EdgeInsets.symmetric(
                                                                                horizontal: 10,
                                                                                vertical: 8,
                                                                              ),
                                                                              hintText: 'Search area...',
                                                                              hintStyle: const TextStyle(fontSize: 12),
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                                borderSide: BorderSide(color: syanColor, width: 0.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        searchMatchFn:
                                                                            (item,
                                                                                searchValue) {
                                                                          return (item
                                                                              .value
                                                                              .toString()
                                                                              .toLowerCase()
                                                                              .contains(searchValue.toLowerCase()));
                                                                        },
                                                                        //This to clear the search value when you close the menu
                                                                        onMenuStateChange:
                                                                            (isOpen) {
                                                                          if (!isOpen) {
                                                                            textEditingController.clear();
                                                                          }
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
                                                                              child: Text(
                                                                                "Address",
                                                                                textAlign: TextAlign.left,
                                                                                style: montserratMedium.copyWith(fontSize: width * 0.034, color: black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      8.height,
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.all(2),
                                                                        child:
                                                                            Container(
                                                                          decoration: const BoxDecoration(
                                                                              borderRadius: BorderRadius.all(Radius.circular(16)),
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
                                                                            autovalidateMode:
                                                                                AutovalidateMode.onUserInteraction,
                                                                            style:
                                                                                montserratMedium.copyWith(color: Colors.black, fontSize: width * 0.04),
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                address = value;
                                                                              });
                                                                            },
                                                                            validator:
                                                                                (value) {
                                                                              return addressValidation(value, context);
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
                                                                                hintStyle: montserratMedium.copyWith(color: greyColor, fontSize: width * 0.04),
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
                                                                              child: Text(
                                                                                "Building Name/Flat No",
                                                                                textAlign: TextAlign.left,
                                                                                style: montserratMedium.copyWith(fontSize: width * 0.034, color: black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      8.height,
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.all(0),
                                                                        child:
                                                                            Container(
                                                                          decoration: const BoxDecoration(
                                                                              borderRadius: BorderRadius.all(Radius.circular(16)),
                                                                              color: white),
                                                                          child: TextFormField(
                                                                              keyboardType: TextInputType.multiline,
                                                                              minLines: 1,
                                                                              maxLength: 50,
                                                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                              style: montserratMedium.copyWith(color: Colors.black, fontSize: width * 0.04),
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
                                                                                  hintStyle: montserratMedium.copyWith(color: greyColor, fontSize: width * 0.04),
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
                                                                          crossAxisAlignment: WrapCrossAlignment
                                                                              .center,
                                                                          alignment: WrapAlignment
                                                                              .start,
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          children: [
                                                                            Theme(
                                                                              data: Theme.of(context).copyWith(unselectedWidgetColor: syanColor),
                                                                              child: Radio(
                                                                                value: 'Home',
                                                                                groupValue: AddressType,
                                                                                fillColor: MaterialStateColor.resolveWith((states) => syanColor),
                                                                                onChanged: (dynamic value) {
                                                                                  setBottomState(() {
                                                                                    AddressType = value;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Text("Home",
                                                                                style: montserratMedium.copyWith(fontSize: width * 0.034, color: black)),
                                                                            Theme(
                                                                              data: Theme.of(context).copyWith(
                                                                                unselectedWidgetColor: syanColor,
                                                                              ),
                                                                              child: Radio(
                                                                                value: 'Office',
                                                                                groupValue: AddressType,
                                                                                fillColor: MaterialStateColor.resolveWith((states) => syanColor),
                                                                                onChanged: (dynamic value) {
                                                                                  setBottomState(() {
                                                                                    AddressType = value;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Text("Office",
                                                                                style: montserratMedium.copyWith(fontSize: width * 0.034, color: black)),
                                                                            Theme(
                                                                              data: Theme.of(context).copyWith(unselectedWidgetColor: syanColor),
                                                                              child: Radio(
                                                                                value: 'Other',
                                                                                groupValue: AddressType,
                                                                                fillColor: MaterialStateColor.resolveWith((states) => syanColor),
                                                                                onChanged: (dynamic value) {
                                                                                  setBottomState(() {
                                                                                    AddressType = value;
                                                                                  });
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Text("Other",
                                                                                style: montserratMedium.copyWith(fontSize: width * 0.034, color: black)),
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
                                                                                      style: montserratMedium.copyWith(fontSize: width * 0.034, color: black),
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
                                                                              fontSize: 12,
                                                                              color: black,
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
                                                                                isSubmitted = false);
                                                                            showCustomToast(context,
                                                                                "Select City",
                                                                                bgColor: errorcolor,
                                                                                textColor: white);
                                                                          } else if (city ==
                                                                              0) {
                                                                            setState(() =>
                                                                                isSubmitted = false);
                                                                            showCustomToast(context,
                                                                                "Select Area",
                                                                                bgColor: errorcolor,
                                                                                textColor: white);
                                                                          } else if (address ==
                                                                              "") {
                                                                            setState(() =>
                                                                                isSubmitted = false);
                                                                            showCustomToast(context,
                                                                                "Enter Address",
                                                                                bgColor: errorcolor,
                                                                                textColor: white);
                                                                          } else {
                                                                            final prefs =
                                                                                await SharedPreferences.getInstance();
                                                                            try {
                                                                              setState(() => isSubmitted = true);
                                                                              await Future.delayed(Duration(milliseconds: 1000));
                                                                              Map req = {
                                                                                "countryId": 1,
                                                                                "stateId": emirates,
                                                                                "cityId": city,
                                                                                "address": address,
                                                                                "landmark": landmark,
                                                                                "add_type": AddressType,
                                                                                "lattitude": Statelat,
                                                                                "longitude": Statelong,
                                                                                "cust_id": prefs.getString("cust_id")
                                                                              };
                                                                              await saveCustomerAddress(req).then((value) {
                                                                                if (value['ret_data'] == "success") {
                                                                                  emirates = 0;
                                                                                  city = 0;
                                                                                  address = "";
                                                                                  landmark = "";
                                                                                  isSubmitted = false;
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
                                                                                  newDropAddress();
                                                                                  setState(() => isgooglemap = false);
                                                                                  setState(() => isSubmitted = false);
                                                                                } else {
                                                                                  setState(() => isSubmitted = false);
                                                                                }
                                                                              });
                                                                            } catch (e) {
                                                                              setState(() => isSubmitted = false);
                                                                              print(e.toString());
                                                                            }
                                                                            finish(context);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.bottomCenter,
                                                                          children: [
                                                                            Container(
                                                                              height: height * 0.045,
                                                                              width: height * 0.37,
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow: [
                                                                                BoxShadow(blurRadius: 16, color: syanColor.withOpacity(.6), spreadRadius: 0, blurStyle: BlurStyle.outer, offset: Offset(0, 0)),
                                                                              ]),
                                                                            ),
                                                                            Container(
                                                                              height: height * 0.075,
                                                                              width: height * 0.45,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(
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
                                                                              child: !isSubmitted
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
                                                                EdgeInsets.all(
                                                                    8),
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
                                ).whenComplete(() {
                                  setState(() => isgooglemap = false);
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ST.of(context).add_address + " ",
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
                                      value:
                                          SelectAddressList[selected_address],
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
                                      buttonHeight: height * 0.075,
                                      buttonPadding: const EdgeInsets.all(12),
                                      dropdownDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      items: SelectAddressList.map(
                                          (String? value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value!,
                                            style: montserratMedium.copyWith(
                                                color: Colors.black,
                                                fontSize: width * 0.04),
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
                                                ? ST.of(context).free
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
                                                ? ST.of(context).free
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

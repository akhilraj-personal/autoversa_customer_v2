import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:autoversa/services/post_auth_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_webservice/src/places.dart';

class LocationController extends GetxController {
  Placemark _pickPlacemark = Placemark();
  Placemark get pickPlaceMark => _pickPlacemark;

  List<Prediction> _predictionList = [];

  bool get isLoading => false;
  bool get loading => false;
  // Position get position => _position;
  // Position get pickPosition => _pickposition;
  // Placemark get placemark => -placeMark;
  // List<marker> get markers => _markers;
  // List<AddressModel> get addressList => _addressList;
  // List<String> get addressTypeList => _addressTypeList;
  // int get addressTypeIndex => _addressTypeIndex;
  // bool get inzone => _inzone;
  // bool get buttonDisabled => _buttondisabled;
  // GoogleMapController get mapcomtroller => _mapcontroller;

  Future<List<Prediction>> searchLocation(
      BuildContext context, String text) async {
    if (text != null && text.isNotEmpty) {
      var response = await getLocationData(text);
      Map<String, dynamic> data = jsonDecode(response.body);
      print("my status is " + data['desc_types']['status']);
      if (data['desc_types']['status'] == 'OK') {
        _predictionList = [];
        data['desc_types']['predictions'].forEach((prediction) =>
            _predictionList.add(Prediction.fromJson(prediction)));
      } else {
        // ApiChecker.checkApi(response);
      }
    }
    return _predictionList;
  }

  void setMapController(GoogleMapController mapController) {
    // _mapcontroller = mapController;
  }

  // Future<String> getAddressFromGeocode(LatLng latLng) async {
  //   Response response = await locationRepo.getAddressFropGeoCode(latLng);
  //   String _address = 'unknown Location Found';
  //   if (response.body['status'] == 'OK') {
  //     _address = response.body['result'][0]['formatted_address'].toString();
  //   } else {
  //     print("error in the api");
  //   }
  //   return _address;
  // }

  void updatePosition(CameraPosition position, bool fromAddress) async {
    // if (_updateAddAddressData) {
    //   loading = true;
    //   update();
    //   try {
    //     if (fromAddress) {
    //       _position = Position(
    //           longitude: position.target.longitude,
    //           latitude: position.target.latitude,
    //           timestamp: DateTime.now(),
    //           accuracy: 1,
    //           altitude: 1,
    //           heading: 1,
    //           speed: 1,
    //           speedAccuracy: 1);
    //     } else {
    //       _pickPositon = Position(
    //           longitude: position.target.longitude,
    //           latitude: position.target.latitude,
    //           timestamp: DateTime.now(),
    //           accuracy: 1,
    //           altitude: 1,
    //           heading: 1,
    //           speed: 1,
    //           speedAccuracy: 1);
    //     }
    //     ResponseModel _responseModel = await getZone(
    //         position.target.latitude.toString(),
    //         position.target.longitude.toString(),
    //         true);
    //     _buttonDiabled = !_responseModel.isSuccess;
    //     if (_changeAddress) {
    //       String _address = await getAddressFromGeocode(
    //           LatLng(position.target.latitude, position.target.longitude));
    //       print(_address);
    //       fromAddress
    //           ? _placeMark = Placemark(name: _address)
    //           : _pickPlacemark = Placemark(name: _address);
    //     } else {
    //       _changeAddress = true;
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
    // }
  }
}

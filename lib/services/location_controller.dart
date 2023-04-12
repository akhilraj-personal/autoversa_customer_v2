import 'package:get/get.dart';
import 'dart:convert';

import 'package:autoversa/services/post_auth_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/src/places.dart';

class LocationController extends GetxController {
  Placemark _pickPlacemark = Placemark();
  Placemark get pickPlaceMark => _pickPlacemark;

  List<Prediction> _predictionList = [];

  bool get isLoading => false;
  bool get loading => false;

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
}

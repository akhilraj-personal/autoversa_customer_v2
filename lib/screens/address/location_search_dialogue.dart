import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import '../../services/location_controller.dart';

class LocationSearchDialog extends StatelessWidget {
  Completer<GoogleMapController> _googleMapController = Completer();
  final GoogleMapController? mapController;
  LocationSearchDialog({required this.mapController, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    GoogleMapsPlaces _places =
        GoogleMapsPlaces(apiKey: dotenv.env['g_map_api']!);
    return Container(
      margin: EdgeInsets.only(top: 150),
      padding: EdgeInsets.all(5),
      alignment: Alignment.topCenter,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: SizedBox(
            width: 350,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _controller,
                textInputAction: TextInputAction.search,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  hintText: 'Search Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(style: BorderStyle.none, width: 0),
                  ),
                  hintStyle: Theme.of(context).textTheme.headline2?.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).disabledColor,
                      ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                style: Theme.of(context).textTheme.headline2?.copyWith(
                      color: Theme.of(context).textTheme.bodyText1?.color,
                      fontSize: 20,
                    ),
              ),
              suggestionsCallback: (pattern) async {
                return await Get.find<LocationController>()
                    .searchLocation(context, pattern);
              },
              itemBuilder: (context, Prediction suggestion) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(children: [
                    Icon(Icons.location_on),
                    Expanded(
                      child: Text(suggestion.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.headline2?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.color,
                                    fontSize: 20,
                                  )),
                    ),
                  ]),
                );
              },
              onSuggestionSelected: (Prediction suggestion) async {
                print("My location is " + suggestion.description!);
                PlacesDetailsResponse detail =
                    await _places.getDetailsByPlaceId(suggestion.placeId!);
                // print(">>>>---" +
                //     detail.result.geometry!.location.lat.toString());
                // print(">>>>---" +
                //     detail.result.geometry!.location.lng.toString());
                //Get.find<LocationController>().setLocation(suggestion.placeId!, suggestion.description!, mapController);
                print(detail.result.addressComponents[0].types[0] +
                    ".........." +
                    detail.result.addressComponents[0].longName);
                print(detail.result.addressComponents[1].types[0] +
                    ".....area....." +
                    detail.result.addressComponents[1].longName);
                print(detail.result.addressComponents[2].types[0] +
                    ".........." +
                    detail.result.addressComponents[2].longName);
                print(detail.result.addressComponents[3].types[0] +
                    ".....city....." +
                    detail.result.addressComponents[3].longName);
                print(detail.result.addressComponents[4].types[0] +
                    ".....country....." +
                    detail.result.addressComponents[4].longName);
                CameraPosition cameraPosition = new CameraPosition(
                  target: LatLng(detail.result.geometry!.location.lat,
                      detail.result.geometry!.location.lng),
                  zoom: 14,
                );

                final GoogleMapController controller =
                    await _googleMapController.future;
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition));
                // setState(() {});
                Get.back();
              },
            )),
      ),
    );
  }
}

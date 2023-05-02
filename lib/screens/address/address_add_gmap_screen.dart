import 'dart:async';

import 'package:autoversa/screens/address/address_add_final_screen.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/location_controller.dart';
import '../../utils/common_utils.dart';
import 'package:google_maps_webservice/places.dart';

class AddAddressViaGmap extends StatefulWidget {
  final int click_id;
  final Map<String, dynamic> package_id;
  final List<dynamic> custvehlist;
  final int selectedveh;
  String currency;
  final int pickup_loc;
  final int drop_loc;
  final bool drop_flag;
  final String bk_id;
  final String vehname;
  final String make;
  AddAddressViaGmap(
      {required this.package_id,
      required this.custvehlist,
      required this.selectedveh,
      required this.currency,
      required this.pickup_loc,
      required this.drop_loc,
      required this.click_id,
      required this.drop_flag,
      required this.bk_id,
      required this.vehname,
      required this.make,
      super.key});
  @override
  State<AddAddressViaGmap> createState() => AddAddressViaGmapState();
}

class AddAddressViaGmapState extends State<AddAddressViaGmap> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  late LatLng _defaultLatLng;
  late LatLng _draggedLatLng;
  String _draggedAddress = "";
  String street = "";
  String locality = "";
  String subLocality = "";
  String administrativeArea = "";
  String country = "";
  String selectedlatitude = "";
  String selectedlongitude = "";
  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(24.466667, 54.366669),
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['g_map_api']!);

  @override
  void initState() {
    _init();
    super.initState();
    getLocation();
  }

  void getLocation() async {
    getUserCurrentLocation().then((value) async {
      setState(() {
        selectedlatitude = value.latitude.toString();
        selectedlongitude = value.longitude.toString();
      });
      // marker added for current users location
      _markers.add(Marker(
        markerId: MarkerId("2"),
        position: LatLng(value.latitude, value.longitude),
        infoWindow: InfoWindow(
          title: 'My Current Location',
        ),
      ));

      // specified current users location
      CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 16,
      );

      final GoogleMapController controller = await _googleMapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  _init() {
    _defaultLatLng = LatLng(24.466667, 54.366669);
    _draggedLatLng = _defaultLatLng;
    _cameraPosition = CameraPosition(target: _defaultLatLng, zoom: 16);
  }

  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: GetBuilder<LocationController>(
        builder: (locationController) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              flexibleSpace: Container(
                alignment: Alignment.bottomCenter,
                width: width,
                height: height * 0.31,
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
                "Address Add",
                style: montserratSemiBold.copyWith(
                  fontSize: 18,
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
            body: Stack(children: <Widget>[
              _buildBody(),
              Positioned(
                top: 20,
                left: 10,
                right: 20,
                child: GestureDetector(
                  onTap: () async {
                    var place = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: dotenv.env['g_map_api']!,
                        mode: Mode.overlay,
                        language: 'es',
                        types: [],
                        strictbounds: false,
                        components: [Component(Component.country, 'ae')],
                        //google_map_webservice package
                        onError: (err) {});
                    if (place != null) {
                      // setState(() {
                      //   location = place.description.toString();
                      // });

                      String placeid = place.placeId ?? "0";
                      PlacesDetailsResponse detail =
                          await _places.getDetailsByPlaceId(placeid);
                      final geometry = detail.result.geometry!;
                      //move map camera to selected place with animation
                      CameraPosition cameraPosition = new CameraPosition(
                        target: LatLng(
                            geometry.location.lat, geometry.location.lng),
                        zoom: 16,
                      );

                      final GoogleMapController controller =
                          await _googleMapController.future;
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(cameraPosition));
                      setState(() {});
                    }
                  },
                  // onTap: () => Get.dialog(
                  //     LocationSearchDialog(mapController: _mapController)),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: greyColor.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      RadiantGradientMask(
                        child: Icon(Icons.location_on,
                            size: 25, color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(width: 5),
                      //here we show the address on the top
                      Expanded(
                        child: Text(
                          '${locationController.pickPlaceMark.name ?? ''} ${locationController.pickPlaceMark.locality ?? ''} '
                          '${locationController.pickPlaceMark.postalCode ?? ''} ${locationController.pickPlaceMark.country ?? ''}',
                          style: montserratMedium.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.search,
                          size: 25,
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ]),
                  ),
                ),
              ),
            ]),
            floatingActionButton: FloatingActionButton(
              child: Container(
                width: 60,
                height: 60,
                child: Icon(
                  Icons.my_location_outlined,
                ),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        LinearGradient(colors: [lightblueColor, syanColor])),
              ),
              onPressed: () async {
                getLocation();
                // getUserCurrentLocation().then((value) async {
                //   setState(() {
                //     selectedlatitude = value.latitude.toString();
                //     selectedlongitude = value.longitude.toString();
                //   });
                //   // marker added for current users location
                //   _markers.add(Marker(
                //     markerId: MarkerId("2"),
                //     position: LatLng(value.latitude, value.longitude),
                //     infoWindow: InfoWindow(
                //       title: 'My Current Location',
                //     ),
                //   ));

                //   // specified current users location
                //   CameraPosition cameraPosition = new CameraPosition(
                //     target: LatLng(value.latitude, value.longitude),
                //     zoom: 14,
                //   );

                //   final GoogleMapController controller =
                //       await _googleMapController.future;
                //   controller.animateCamera(
                //       CameraUpdate.newCameraPosition(cameraPosition));
                //   setState(() {});
                // });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [_getMap(), _getCustomPin(), _BottomButton()],
    );
  }

  Widget _BottomButton() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 80,
          width: height * 0.2,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddressAddFinalScreen(
                              click_id: widget.click_id,
                              package_id: widget.package_id,
                              custvehlist: widget.custvehlist,
                              currency: widget.currency,
                              selectedveh: widget.selectedveh,
                              pickup_loc: widget.pickup_loc,
                              drop_loc: widget.drop_loc,
                              drop_flag: widget.drop_flag,
                              bk_id: widget.bk_id,
                              vehname: widget.vehname,
                              make: widget.make,
                              selected_street: street,
                              selected_sublocality: subLocality,
                              selected_administrativeArea: administrativeArea,
                              selected_latitude: selectedlatitude,
                              selected_longitude: selectedlongitude,
                            )));
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
                    height: height * 0.065,
                    width: height * 0.4,
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
                    child: Text(
                      "CONFIRM",
                      style: montserratSemiBold.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _getMap() {
    return isMobile
        ? Container(
            child: GoogleMap(
              initialCameraPosition: _cameraPosition!,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController mapController) {
                _mapController = mapController;
                if (!_googleMapController.isCompleted) {
                  _googleMapController.complete(mapController);
                }
              },
              onCameraIdle: () {
                _getAddress(_draggedLatLng);
              },
              onCameraMove: (cameraPosition) {
                _draggedLatLng = cameraPosition.target;
              },
            ),
          )
        : Container(
            color: Colors.transparent,
            height: height,
            alignment: Alignment.center,
            width: width,
            child: Text('Google Maps support is coming soon',
                style: montserratSemiBold.copyWith(fontSize: width * 0.035)),
          );
  }

  Widget _getCustomPin() {
    return Center(
      child: Container(
        width: 65,
        child: Image.asset(
          ImageConst.maplocation,
        ),
      ),
    );
  }

  Future<Position> getUserCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  Future _getAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark address = placemarks[0];
    setState(() {
      street = "${address.street}";
      locality = "${address.locality}";
      subLocality = "${address.subLocality}";
      administrativeArea = "${address.administrativeArea}";
      country = "${address.country}";
      selectedlatitude = position.latitude.toString();
      selectedlongitude = position.longitude.toString();
    });
    String addressStr =
        "${address.street}, ${address.locality}, '${address.subLocality}' ${address.administrativeArea}, ${address.country},";
    setState(() {
      _draggedAddress = addressStr;
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'package:terhal_app/controllers/map_controller.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/loading.dart';

class DetailsMapView extends StatefulWidget {
  const DetailsMapView({super.key, required this.recommendation});

  final Recommendation recommendation;

  @override
  State<DetailsMapView> createState() => _DetailsMapViewState();
}

class _DetailsMapViewState extends State<DetailsMapView> {
  final Completer<GoogleMapController> _mapController = Completer();
  final log = Logger('TerhalApp');
  late LatLng? _placePosition;
  late LatLng? _currentPosition;
  final mapController = Get.put(MapController());
  late List<Polyline> _polylines = [];

  late final String _darkMapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.future.then((value) => value.dispose());
  }

  Future<void> _addPolylines() async {
    await mapController.getDirection(
      origin: _currentPosition!,
      destination: _placePosition!,
    );

    if (mapController.direction.value != null) {
      final List<PointLatLng> polylinePoints =
          mapController.direction.value!.polylinePoints;

      final List<LatLng> latLngPoints = polylinePoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines = [
          Polyline(
            polylineId: const PolylineId('route'),
            color: Constants.primaryColor,
            width: 5,
            points: latLngPoints,
          ),
        ];
      });
    }
  }

  Future<LatLng> getLocation() async {
    try {
      bool hasPermission = await Permission.location.isGranted;
      if (!hasPermission) {
        await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      log.warning(e.toString());
      return const LatLng(0.0, 0.0);
    }
  }

  Future<void> _loadMapStyle() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/json/dark_map_style.json');
  }

  void _onMapCreated(GoogleMapController controller) {
    if (Get.isDarkMode) {
      controller.setMapStyle(_darkMapStyle);
    }
    if (!_mapController.isCompleted) {
      _mapController.complete(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FutureBuilder(
            future: getLocation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading.circle;
              } else {
                _currentPosition = snapshot.data as LatLng;
                _placePosition = LatLng(widget.recommendation.latitude,
                    widget.recommendation.longitude);
                return _buildMap(context);
              }
            },
          ),
        ),
        Positioned(
          top: 5,
          left: 5,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            height: Get.height * 0.35,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.recommendation.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _addMarker,
                        icon: const Icon(Icons.directions),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(
                      "${mapController.direction.value?.totalDistance ?? '0 km'} - ${mapController.direction.value?.totalDuration ?? '0 mins'}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height * 0.01),
                  Divider(
                    color: Colors.green.withOpacity(0.5),
                  ),
                  SizedBox(height: Get.height * 0.01),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(Get.width * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                const Icon(Icons.circle, color: Colors.green),
                          ),
                          Obx(
                            () => Container(
                              width: Get.width * 0.65,
                              padding: EdgeInsets.all(Get.width * 0.02),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                mapController.direction.value?.startAddress ??
                                    "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Get.width * 0.03),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(Get.width * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: Colors.green),
                          ),
                          Container(
                            width: Get.width * 0.65,
                            padding: EdgeInsets.all(Get.width * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              widget.recommendation.fullAddress.length > 28
                                  ? "${widget.recommendation.fullAddress.substring(0, 28)}..."
                                  : widget.recommendation.fullAddress,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  GoogleMap _buildMap(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _placePosition!,
        zoom: 11.0,
      ),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('current'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _placePosition!,
          infoWindow: InfoWindow(
            title: widget.recommendation.name,
            snippet: widget.recommendation.fullAddress,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      },
      polylines: Set<Polyline>.of(_polylines),
    );
  }

  void _addMarker() async {
    await _addPolylines();
  }
}

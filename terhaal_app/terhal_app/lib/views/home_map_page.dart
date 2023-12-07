import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/widgets/loading.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage(
      {super.key,
      required this.recommendations,
      required this.currentPosition});
  final List<Recommendation> recommendations;
  final LatLng currentPosition;

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  late Set<Marker> _markers = {};
  late final String _darkMapStyle;

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

  Future<void> _addRecommendationMarkers() async {
    List<Recommendation> recommendations = widget.recommendations;

    Set<Marker> markers = {};

    for (Recommendation recommendation in recommendations) {
      Marker marker = Marker(
        markerId: MarkerId(recommendation.id.toString()),
        position: LatLng(recommendation.latitude, recommendation.longitude),
        infoWindow: InfoWindow(title: recommendation.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      markers.add(marker);
    }
    _markers = markers;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder(
                future: _addRecommendationMarkers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loading.circle;
                  } else {
                    _markers.add(
                      Marker(
                        markerId: const MarkerId('currentPosition'),
                        position: widget.currentPosition,
                      ),
                    );
                    return GoogleMap(
                      onMapCreated: _onMapCreated,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: widget.currentPosition,
                        zoom: 11,
                      ),
                      markers: _markers,
                    );
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
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/controllers/home_interest_controller.dart';
import 'package:terhal_app/controllers/home_recommendation_controller.dart';
import 'package:terhal_app/controllers/home_trending_controller.dart';
import 'package:terhal_app/views/home_interests_view.dart';
import 'package:terhal_app/views/home_map_page.dart';
import 'package:terhal_app/views/home_recommendation_view.dart';
import 'package:terhal_app/views/home_trending_view.dart';
import 'package:terhal_app/widgets/loading.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.appLocalizations,
  });

  final AppLocalizations? appLocalizations;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuthController authController = Get.find();
  final recommendationController = Get.put(HomeRecommendationController());

  final Completer<GoogleMapController> _mapController = Completer();
  final log = Logger('TerhalApp');
  late final String _darkMapStyle;

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
      Get.snackbar(
        'Error',
        "Couldn't get your location",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
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
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.future.then((value) => value.dispose());
  }

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
            child: _buildMap(context),
          ),
          SizedBox(
            height: Get.height * 0.53,
            child: Stepper(
              connectorColor:
                  MaterialStateProperty.all<Color>(Colors.teal[700]!),
              stepIconBuilder: (stepIndex, stepState) => Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.teal[700],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  stepIndex == 0 ? Icons.star : Icons.favorite,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              physics: const NeverScrollableScrollPhysics(),
              type: StepperType.horizontal,
              elevation: 0,
              connectorThickness: 0,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 1) {
                  setState(() {
                    _currentStep += 1;
                  });
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              onStepTapped: (value) => setState(() => _currentStep = value),
              steps: [
                _buildRecommendation(),
                _buildInterest(),
              ],
              controlsBuilder: (context, details) => Container(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
            child: Column(
              children: [
                _buildTrendingHeader(),
                SizedBox(height: Get.height * 0.01),
                SizedBox(
                  height: Get.height * 0.35,
                  child: HomeTrendingView(
                    appLocalizations: widget.appLocalizations,
                    trendingController: Get.put(HomeTrendingController()),
                    userFavoriteController: Get.find(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Step _buildRecommendation() {
    return Step(
      title: const Text('Recommendation'),
      isActive: _currentStep == 0,
      content: Column(
        children: [
          _buildRecommendationHeader(),
          SizedBox(height: Get.height * 0.01),
          SizedBox(
            height: Get.height * 0.35,
            child: HomeRecommendationView(
              appLocalizations: widget.appLocalizations,
              recommendationController: recommendationController,
              userFavoriteController: Get.find(),
            ),
          ),
        ],
      ),
    );
  }

  Step _buildInterest() {
    return Step(
      title: const Text('Interest'),
      isActive: _currentStep == 1,
      content: Column(
        children: [
          _buildInterestHeader(),
          SizedBox(height: Get.height * 0.01),
          SizedBox(
            height: Get.height * 0.35,
            child: HomeInterestView(
              appLocalizations: widget.appLocalizations,
              interestController: Get.put(HomeInterestController()),
              userFavoriteController: Get.find(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.appLocalizations!.recommendedForYou,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed('/recommended');
            },
            child: Text(
              widget.appLocalizations!.seeAll,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Based on your interests",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed('/interests');
            },
            child: Text(
              widget.appLocalizations!.seeAll,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.appLocalizations!.trending,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed('/trending');
            },
            child: Text(
              widget.appLocalizations!.seeAll,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildMap(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.25,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.appLocalizations!.findNearYou,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Container(
            padding: const EdgeInsets.all(2.5),
            width: Get.width,
            height: Get.height * 0.20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: FutureBuilder(
              future: getLocation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Loading.circle);
                } else {
                  if (!authController.currentUser!.emailVerified) {
                    return Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.yellow,
                      ),
                      child: const Center(
                        child: Text(
                          'Please verify your email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }

                  LatLng currentPosition = snapshot.data as LatLng;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        GoogleMap(
                          onMapCreated: _onMapCreated,
                          zoomControlsEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: currentPosition,
                            zoom: 11,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('current'),
                              position: currentPosition,
                              infoWindow:
                                  const InfoWindow(title: 'Your Location'),
                            )
                          },
                          gestureRecognizers: {
                            Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer())
                          },
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.zoom_out_map_rounded),
                            onPressed: () {
                              Get.to(
                                () => HomeMapPage(
                                  recommendations:
                                      recommendationController.recommendations,
                                  currentPosition: currentPosition,
                                ),
                                transition: Transition.zoom,
                              );
                            },
                            tooltip: 'View Full Map',
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

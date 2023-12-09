import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:terhal_app/models/direction.dart';
import 'package:terhal_app/utils/constants.dart';

class MapController extends GetxController {
  final RxBool isLoading = false.obs;
  Rx<Direction?> direction = Rx<Direction?>(null);

  Future<void> getDirection({
    required LatLng origin,
    required LatLng destination,
  }) async {
    isLoading.value = true;
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${Constants.googleAPIKey}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        direction.value = Direction.fromMap(data);
      } else {
        Get.snackbar(
          "Error",
          "Cannot get direction data for this place",
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Cannot get direction data for this place",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

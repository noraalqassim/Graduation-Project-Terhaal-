import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:terhal_app/models/place_ratings_and_reviews/place_ratings_and_reviews.dart';
import 'dart:convert';

import 'package:terhal_app/utils/constants.dart';

class PlaceRatingsAndReviewsController extends GetxController {
  PlaceRatingsAndReviewsController({this.id});

  final int? id;
  final RxBool isLoading = false.obs;

  final RxList<PlaceRatingsAndReviews> placeRatings =
      <PlaceRatingsAndReviews>[].obs;
  final RxList<PlaceRatingsAndReviews> _allPlaceRatings =
      <PlaceRatingsAndReviews>[].obs;

  final RxString next = "".obs;
  final RxString previous = "".obs;

  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchPlaceRatings();
  }

  Future<void> fetchPlaceRatings(
      {Map<String, dynamic>? params, int? placeId}) async {
    final args = {"uid": _auth.currentUser!.uid};
    if (params != null) {
      params.addAll(args);
    } else {
      params = args;
    }
    Uri url = Uri.parse(
      '${Constants.baseURL}/api/place/ratings/${id ?? placeId}/',
    ).replace(queryParameters: params);
    try {
      isLoading.value = true;
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        next.value = jsonResponse['next'] ?? "";
        previous.value = jsonResponse['previous'] ?? "";
        final List result = jsonResponse['results'];
        _allPlaceRatings.value = (result)
            .map((data) => PlaceRatingsAndReviews.fromJson(data))
            .toList();
        updatePlaceRatings();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load place ratings and reviews',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        Get.snackbar(
          'Error',
          'Request timeout',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load place ratings and reviews',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchMorePlaceRatings(String url) async {
    try {
      // isLoading.value = true;
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        next.value = jsonResponse['next'] ?? "";
        previous.value = jsonResponse['previous'] ?? "";
        final List result = jsonResponse['results'];
        _allPlaceRatings.addAll((result)
            .map((data) => PlaceRatingsAndReviews.fromJson(data))
            .toList());
        updatePlaceRatings();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load place ratings and reviews',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      if (e is TimeoutException) {
        Get.snackbar(
          'Error',
          'Request timeout',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load place ratings and reviews',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } finally {
      // isLoading.value = false;
      update();
    }
  }

  void updatePlaceRatings() {
    placeRatings.assignAll(_allPlaceRatings);
  }

  PlaceRatingsAndReviews? getCurrentUserPlaceRatings() {
    try {
      return placeRatings.firstWhere((element) => element.current);
    } catch (e) {
      return null;
    }
  }
}

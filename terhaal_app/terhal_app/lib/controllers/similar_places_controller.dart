import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';

class SimilarPlaceController extends GetxController {
  SimilarPlaceController({required this.id});

  final int id;
  final RxBool isLoading = false.obs;

  final RxList<Recommendation> similarPlaces = <Recommendation>[].obs;
  final RxList<Recommendation> _allSimilarPlaces = <Recommendation>[].obs;

  final RxString next = "".obs;
  final RxString previous = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchSimilarPlaces();
  }

  Future<void> fetchSimilarPlaces({Map<String, dynamic>? params}) async {
    final args = {'similar': "1", 'id': id.toString()};
    if (params != null) {
      params.addAll(args);
    } else {
      params = args;
    }
    Uri url = Uri.parse(
      '${Constants.baseURL}/api/recommendation/recommendations/',
    ).replace(queryParameters: params);
    try {
      isLoading.value = true;
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        next.value = jsonResponse['next'] ?? "";
        previous.value = jsonResponse['previous'] ?? "";
        final List result = jsonResponse['results'];
        _allSimilarPlaces.value =
            (result).map((data) => Recommendation.fromJson(data)).toList();
        updateSimilarPlaces();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load similar places',
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
          'Failed to load similar places',
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

  Future<void> fetchMoreSimilarPlaces(String url) async {
    try {
      // isLoading.value = true;
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        next.value = jsonResponse['next'] ?? "";
        previous.value = jsonResponse['previous'] ?? "";
        final List result = jsonResponse['results'];
        _allSimilarPlaces.addAll(
            (result).map((data) => Recommendation.fromJson(data)).toList());
        updateSimilarPlaces();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load similar places',
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
          'Failed to load similar places',
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

  void updateSimilarPlaces() {
    similarPlaces.assignAll(_allSimilarPlaces);
  }
}

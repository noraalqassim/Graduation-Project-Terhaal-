import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:terhal_app/models/recommendation.dart';
import 'package:terhal_app/utils/constants.dart';

class TrendingController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Recommendation> _allTrending = <Recommendation>[].obs;
  final RxList<Recommendation> trending = <Recommendation>[].obs;

  final RxString next = "".obs;
  final RxString previous = "".obs;

  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchTrending();
  }

  Future<void> fetchTrending({Map<String, dynamic>? params}) async {
    final args = {"uid": _auth.currentUser!.uid, 'trending': "1"};
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
        _allTrending.value =
            (result).map((data) => Recommendation.fromJson(data)).toList();
        updateTrending();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load trending',
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
          'Failed to load trending',
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

  Future<void> fetchMoreTrending(String url) async {
    try {
      // isLoading.value = true;
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        next.value = jsonResponse['next'] ?? "";
        previous.value = jsonResponse['previous'] ?? "";
        final List result = jsonResponse['results'];
        _allTrending.addAll(
            (result).map((data) => Recommendation.fromJson(data)).toList());
        updateTrending();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load trending',
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
          'Failed to load trending',
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

  void updateTrending() {
    trending.assignAll(_allTrending);
  }
}

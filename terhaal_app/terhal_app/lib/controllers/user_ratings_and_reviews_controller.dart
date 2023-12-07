import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:terhal_app/utils/constants.dart';

class UserRatingsAndReviewsController extends GetxController {
  final RxBool isLoading = false.obs;

  final _auth = FirebaseAuth.instance;

  Future<void> postUserRatingsAndReviews(
      {required Map<String, dynamic> data}) async {
    Uri url = Uri.parse(
      '${Constants.baseURL}/api/user/rating/${_auth.currentUser!.uid}/',
    );
    try {
      isLoading.value = true;
      final response = await http.post(
        url,
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Successfully added your review',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to add your review',
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
          'Failed to add your review',
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
}

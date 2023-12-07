import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:terhal_app/models/user.dart';
import 'package:terhal_app/utils/constants.dart';

class UserController extends GetxController {
  final RxBool isLoading = false.obs;

  static UserController get to => Get.put(UserController());

  createUser(User user) async {
    Uri url = Uri.parse('${Constants.baseURL}/api/user/');
    try {
      isLoading.value = true;
      final response = await http.post(url, body: user.toJson()).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
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
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  updateUser(String uid, Map<String, dynamic> user) async {
    Uri url = Uri.parse('${Constants.baseURL}/api/user/update/$uid/');
    try {
      isLoading.value = true;
      final response = await http.put(url, body: user).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      if (e is TimeoutException) {
        Get.snackbar(
          'Error',
          'Request timeout',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  deleteUser(String uid) async {
    Uri url = Uri.parse('${Constants.baseURL}/api/user/delete/$uid/');
    try {
      isLoading.value = true;
      final response = await http.delete(url).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (e is TimeoutException) {
        Get.snackbar(
          'Error',
          'Request timeout',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }
}

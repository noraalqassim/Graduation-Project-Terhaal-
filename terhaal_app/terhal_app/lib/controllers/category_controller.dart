import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:terhal_app/models/category/category.dart';
import 'package:terhal_app/utils/constants.dart';

class CategoryController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<Category> categories = <Category>[].obs;
  final RxList<Category> _allCategories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    Uri url = Uri.parse('${Constants.baseURL}/api/terhal/categories/');
    try {
      isLoading.value = true;
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List jsonResponse = json.decode(response.body)['results'];
        _allCategories.value =
            (jsonResponse).map((data) => Category.fromJson(data)).toList();
        updateCategories();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load categories',
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
          'Failed to load categories',
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

  void updateCategories() {
    categories.assignAll(_allCategories);
  }
}

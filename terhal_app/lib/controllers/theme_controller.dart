import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxBool isDarkMode = Get.isDarkMode.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemePreference();
  }

  Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkModePreference = prefs.getBool('isDarkMode');

    if (isDarkModePreference != null) {
      isDarkMode.value = isDarkModePreference;
    } else {
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode.value = Get.isDarkMode || brightness == Brightness.dark;
    }
  }

  Future<void> saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
    update();
  }
}

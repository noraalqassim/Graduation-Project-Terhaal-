import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:terhal_app/models/recommendation.dart';

import 'package:terhal_app/models/user_favorite/user_favorite.dart';
import 'package:terhal_app/utils/constants.dart';

class UserRatingController extends GetxController {
  final RxBool isLoading = false.obs;

  final Rx<UserFavorite?> userFavorite = Rx<UserFavorite?>(null);
  final Rx<UserFavorite?> _userFavorite = Rx<UserFavorite?>(null);

  final RxList<Recommendation> _allUserFavorites = <Recommendation>[].obs;
  final RxList<Recommendation> userFavorites = <Recommendation>[].obs;

  final RxString next = "".obs;
  final RxString previous = "".obs;

  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserFavorites();
    getUserFavorite();
  }

  Future<void> fetchUserFavorites({Map<String, dynamic>? params}) async {
    if (params != null) {
      params.addAll({'uid': _auth.currentUser!.uid});
    } else {
      params = {'uid': _auth.currentUser!.uid};
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
        _allUserFavorites.value =
            (result).map((data) => Recommendation.fromJson(data)).toList();
        updateUserFavorites();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load user favorites',
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
          'Failed to load user favorites',
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

  Future<void> fetchMoreUserFavorites(String url) async {
    try {
      // isLoading.value = true;
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        next.value = jsonResponse['next'] ?? "";
        previous.value = jsonResponse['previous'] ?? "";
        final List result = jsonResponse['results'];
        _allUserFavorites.addAll(
            (result).map((data) => Recommendation.fromJson(data)).toList());
        updateUserFavorites();
      } else {
        Get.snackbar(
          'Error',
          'Failed to load user favorites',
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
          'Failed to load user favorites',
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

  void updateUserFavorites() {
    userFavorites.assignAll(_allUserFavorites);
  }

  Future<void> getUserFavorite() async {
    Uri url = Uri.parse(
        '${Constants.baseURL}/api/user/favorite/${_auth.currentUser!.uid}/');
    try {
      isLoading.value = true;
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _userFavorite.value = UserFavorite.fromJson(jsonResponse);
        updateUserFavorite();
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

  void updateUserFavorite() {
    userFavorite.value = _userFavorite.value;
  }

  toggleFavorite(favoriteId) async {
    String uid = _auth.currentUser!.uid;
    Uri url = Uri.parse('${Constants.baseURL}/api/user/favorite/$uid/');

    try {
      isLoading.value = true;
      final response = await http.post(url,
          body: {'uid': uid, 'favorite_id': favoriteId.toString()}).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        userFavorites
            .removeWhere((recommendation) => recommendation.id == favoriteId);
        final jsonResponse = json.decode(response.body);
        _userFavorite.value = UserFavorite.fromJson(jsonResponse);
        updateUserFavorite();
      } else {
        Get.snackbar(
          'Error',
          'Failed to create user favorite',
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
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }
}

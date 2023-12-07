import 'package:get/get.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/controllers/firebase_firestore_controller.dart';
import 'package:terhal_app/controllers/theme_controller.dart';
import 'package:terhal_app/controllers/user_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
    Get.put(FirebaseAuthController());
    Get.put(FirebaseFirestoreController());
    Get.put(UserController());
  }
}

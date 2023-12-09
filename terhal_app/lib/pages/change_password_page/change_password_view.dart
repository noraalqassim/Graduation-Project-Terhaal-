import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/controllers/firebase_firestore_controller.dart';
import 'package:terhal_app/form/user_form.dart';
import 'package:terhal_app/models/user.dart';
import 'package:terhal_app/utils/alert.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/button.dart';
import 'package:terhal_app/widgets/loading.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView(
      {super.key, required this.appLocalizations, required this.user});

  final AppLocalizations? appLocalizations;
  final User user;

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final formKey = GlobalKey<FormBuilderState>();
  final FirebaseAuthController authController = Get.find();
  final FirebaseFirestoreController storeController = Get.find();

  @override
  Widget build(BuildContext context) {
    final UserForm userForm =
        UserForm(appLocalizations: widget.appLocalizations);

    return Stack(
      children: [
        _buildBottomBar(userForm),
        _buildTopBar(),
      ],
    );
  }

  void _handleChangePassword() async {
    if (formKey.currentState!.saveAndValidate()) {
      String currentPassword = formKey.currentState!.value['password'];
      String newPassword = formKey.currentState!.value['new_password'];

      authController.reauthenticate(password: currentPassword).then((value) {
        if (value != null) {
          _updatePassword(newPassword);
        }
      });
    }
  }

  void _showAlert(
      String title, String message, Color? colorText, Color? backgroundColor) {
    Alert.snackbar(title, message,
        colorText: colorText, backgroundColor: backgroundColor);
  }

  Future<void> _updatePassword(String newPassword) async {
    try {
      await authController.changePassword(newPassword);

      _showSuccessAlert(
          "Success", "Password has been changed. Please sign in again.");
      await authController.signOut();
    } catch (e) {
      _showErrorAlert("Error", "An error occurred while updating the password");
    }
  }

  void _showErrorAlert(String title, String message) {
    _showAlert(
      title,
      message,
      Get.theme.colorScheme.error,
      Get.theme.colorScheme.onError,
    );
  }

  void _showSuccessAlert(String title, String message) {
    _showAlert(
      title,
      message,
      Get.theme.colorScheme.primary,
      Get.theme.colorScheme.onPrimary,
    );
  }

  bool validatePasswordSimilarity(String confirmPassword, String userPassword) {
    int minLength = userPassword.length < confirmPassword.length
        ? userPassword.length
        : confirmPassword.length;

    int matchingCharacters = 0;
    for (int i = 0; i < minLength; i++) {
      if (userPassword[i] == confirmPassword[i]) {
        matchingCharacters++;
      }
    }

    double similarityPercentage = (matchingCharacters / minLength) * 100;

    if (similarityPercentage >= 50.0) {
      return true;
    } else {
      return false;
    }
  }

  Obx _buildChangePasswordButton() {
    return Obx(
      () => authController.isLoading.value
          ? Loading.circle
          : SizedBox(
              width: Get.width,
              child: Button(
                text: "Update Password",
                onPressed: _handleChangePassword,
              ),
            ),
    );
  }

  Padding _buildBottomBar(UserForm userForm) {
    return Padding(
      padding: EdgeInsets.all(Get.width * 0.02),
      child: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.black26 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(Get.width * 0.05),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: Get.height * 0.30),
                  userForm.buildPasswordField(name: "password"),
                  userForm.buildPasswordField(
                      name: 'new_password',
                      label: widget.appLocalizations!.newPassword),
                  userForm.buildConfirmPasswordField(
                      passwordField: "new_password", formKey: formKey),
                  _buildChangePasswordButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: Get.height * 0.22,
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(Get.width * 0.30),
            bottomLeft: Radius.circular(Get.width * 0.30),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.03),
            const Text(
              "Change Your",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/controllers/firebase_firestore_controller.dart';
import 'package:terhal_app/controllers/user_controller.dart';
import 'package:terhal_app/form/user_form.dart';
import 'package:terhal_app/models/user.dart';
import 'package:terhal_app/utils/alert.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/loading.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.appLocalizations});

  final AppLocalizations? appLocalizations;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final formKey = GlobalKey<FormBuilderState>();
  final FirebaseAuthController authController = Get.find();
  final FirebaseFirestoreController storeController = Get.find();
  final UserController userController = Get.find();
  bool _formEnabled = false;

  @override
  Widget build(BuildContext context) {
    final UserForm userForm = UserForm(appLocalizations: widget.appLocalizations);

    return Stack(
      children: [
        _buildBottomBar(userForm),
        _buildTopBar(),
      ],
    );
  }

  Padding _buildBottomBar(UserForm userForm) {
    return Padding(
      padding: EdgeInsets.all(Get.width * 0.02),
      child: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.black26 : Colors.grey.shade100,
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
          padding: EdgeInsets.all(Get.width * 0.02),
          child: FutureBuilder<User?>(
            future: storeController.getUser(authController.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: Get.height * 0.25),
                    Loading.circle,
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Text('User not found');
              }
              User user = snapshot.data!;
              return _buildUserForm(userForm: userForm, user: user);
            },
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildUserForm({required UserForm userForm, required User user}) {
    return SingleChildScrollView(
      child: FormBuilder(
        key: formKey,
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.23),
            userForm.buildUFullNameField(
              firstName: user.firstName,
              lastName: user.lastName,
              readOnly: !_formEnabled,
            ),
            userForm.buildAgeGenderFields(
              gender: user.gender,
              initialValue: DateFormat('yyyy-MM-dd').parse(user.dateOfBirth),
              enabled: _formEnabled,
            ),
            userForm.buildTravelCompanionField(
              travelCompanion: user.travelCompanion,
              enabled: _formEnabled,
            ),
            userForm.buildHealthConditionField(
              healthCondition: user.healthCondition,
              enabled: _formEnabled,
            ),
            userForm.buildNeedStrollerField(
              needStroller: user.needStroller.toLowerCase() == 'true',
              enabled: _formEnabled,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEditCancelButton(),
                _buildSaveButton(),
                _buildPasswordButton(user),
              ],
            ),
            SizedBox(height: Get.height * 0.02),
            if (!_formEnabled) _buildDeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  SizedBox _buildDeleteAccountButton() {
    return SizedBox(
      width: Get.width,
      height: Get.height * 0.05,
      child: MaterialButton(
        onPressed: () {
          Get.defaultDialog(
            title: "Delete Account",
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            middleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            cancelTextColor: Get.isDarkMode ? Colors.white : Colors.black,
            confirmTextColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            buttonColor: Colors.red,
            middleText: "Are you sure you want to delete your account?",
            textConfirm: "Yes",
            textCancel: "No",
            onConfirm: () {
              Get.back();
              deleteAccount();
            },
            onCancel: () {
              Get.back();
            },
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: Get.theme.colorScheme.error,
        textColor: Get.theme.colorScheme.onError,
        child: const Text("Delete Account"),
      ),
    );
  }

  void deleteAccount() {
    authController.deleteAccount().then((value) {
      Get.offAllNamed('/signin');
    });
  }

  Flexible _buildPasswordButton(User user) {
    return Flexible(
      child: MaterialButton(
        onPressed: () => Get.toNamed("/change-password", arguments: user),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: const Text("Password"),
      ),
    );
  }

  Obx _buildSaveButton() {
    return Obx(
      () => authController.isLoading.value
          ? Loading.circle
          : Flexible(
              child: MaterialButton(
                onPressed: _formEnabled
                    ? () {
                        if (formKey.currentState!.saveAndValidate()) {
                          _updateUser();
                        }
                      }
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: const Text("Save"),
              ),
            ),
    );
  }

  Future<void> _updateUser() async {
    try {
      final Map<String, dynamic> updatedValues = Map.from(formKey.currentState!.value);
      if (updatedValues.containsKey('date_of_birth')) {
        updatedValues['date_of_birth'] = DateFormat('yyyy-MM-dd').format(updatedValues['date_of_birth']);
      }
      if (updatedValues.containsKey('need_stroller')) {
        updatedValues['need_stroller'] = updatedValues['need_stroller'].toString();
      }
      await _performUpdate(updatedValues);
      Alert.snackbar(
        "Success",
        "User updated successfully",
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (error) {
      Alert.snackbar(
        "Error",
        "Failed to update user",
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } finally {
      setState(() {
        _formEnabled = !_formEnabled;
      });
    }
  }

  Future<void> _performUpdate(Map<String, dynamic> updatedValues) async {
    final String userId = authController.currentUser!.uid;
    await storeController.updateUser(userId, updatedValues);
    userController.updateUser(userId, updatedValues);
  }

  Flexible _buildEditCancelButton() {
    return Flexible(
      child: MaterialButton(
        onPressed: () {
          setState(() {
            _formEnabled = !_formEnabled;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(
          _formEnabled ? "Cancel" : "Edit",
        ),
      ),
    );
  }

  Positioned _buildTopBar() {
    final user = authController.currentUser!.displayName ?? '';
    List<String> userNames = user.split(' ');
    String firstLetter = userNames.isNotEmpty && userNames[0].isNotEmpty ? userNames[0][0].toUpperCase() : '';
    String lastLetter =
        userNames.length > 1 && userNames.last.isNotEmpty ? userNames.last[0].toUpperCase() : '';

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
        child: Center(
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.02),
              CircleAvatar(
                backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
                radius: 50,
                child: Text(
                  "$firstLetter$lastLetter",
                  style: TextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.01),
              Text(
                user,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                authController.currentUser!.email ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

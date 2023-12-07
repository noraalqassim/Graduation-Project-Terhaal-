import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/form/controls/check.dart';
import 'package:terhal_app/form/controls/data.dart';
import 'package:terhal_app/form/controls/date.dart';
import 'package:terhal_app/form/controls/password.dart';
import 'package:terhal_app/form/controls/select.dart';

class UserForm {
  UserForm({required this.appLocalizations});

  final AppLocalizations? appLocalizations;

  Padding buildUFullNameField(
      {String? firstName, String? lastName, bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.width * 0.05),
      child: Row(
        children: [
          Flexible(
            child: Data(
              name: 'first_name',
              initialValue: firstName,
              readOnly: readOnly,
              label: appLocalizations!.firstName,
              prefixIcon: const Icon(Icons.person),
              validators: [
                FormBuilderValidators.required(),
              ],
              color: Get.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          SizedBox(width: Get.width * 0.02),
          Flexible(
            child: Data(
              name: 'last_name',
              initialValue: lastName,
              readOnly: readOnly,
              label: appLocalizations!.lastName,
              prefixIcon: const Icon(Icons.person),
              validators: [
                FormBuilderValidators.required(),
              ],
              color: Get.isDarkMode ? Colors.black : Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Padding buildUsernameField() {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.width * 0.05),
      child: Data(
        name: 'username',
        label: appLocalizations!.username,
        prefixIcon: const Icon(Icons.person),
        validators: [
          FormBuilderValidators.required(),
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Padding buildEmailField() {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.width * 0.05),
      child: Data(
        name: 'email',
        label: appLocalizations!.email,
        prefixIcon: const Icon(Icons.person),
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.email(),
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  String? _strongPasswordValidator(value) {
    final RegExp passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

    if (!passwordRegex.hasMatch(value)) {
      return appLocalizations!.strongPasswordValidator;
    }

    return null;
  }

  Padding buildPasswordField({required String name, String? label}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.width * 0.05),
      child: Password(
        name: name,
        label: label ?? appLocalizations!.password,
        prefixIcon: const Icon(Icons.lock),
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.minLength(8),
          _strongPasswordValidator,
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Padding buildConfirmPasswordField(
      {String? passwordField, required GlobalKey<FormBuilderState> formKey}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Get.width * 0.05),
      child: Password(
        name: 'confirm_password',
        label: appLocalizations!.confirmPassword,
        prefixIcon: const Icon(Icons.lock),
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.minLength(8),
          _strongPasswordValidator,
          (value) {
            return FormBuilderValidators.equal(
              formKey.currentState!.value[passwordField] ?? '',
              errorText: appLocalizations!.passwordsDoNotMatch,
            )(value);
          },
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Row buildAgeGenderFields(
      {DateTime? initialValue, String? gender, bool enabled = true}) {
    return Row(
      children: [
        Flexible(
          child: Date(
            name: 'date_of_birth',
            enabled: enabled,
            initialValue: initialValue,
            label: appLocalizations!.dateOfBirth,
            prefixIcon: const Icon(Icons.calendar_today),
            validators: [
              FormBuilderValidators.required(),
            ],
            color: Get.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(width: Get.width * 0.02),
        Flexible(
          child: Select(
            name: "gender",
            initialValue: gender,
            enabled: enabled,
            label: appLocalizations!.gender,
            options: [appLocalizations!.male, appLocalizations!.female],
            prefixIcon: const Icon(Icons.person),
            validators: [
              FormBuilderValidators.required(),
            ],
            color: Get.isDarkMode ? Colors.black : Colors.white,
          ),
        )
      ],
    );
  }

  Padding buildTravelCompanionField(
      {String? travelCompanion, bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.only(top: Get.width * 0.05),
      child: Select(
        name: "travel_companion",
        initialValue: travelCompanion,
        enabled: enabled,
        label: appLocalizations!.travelCompanion,
        options: [appLocalizations!.family, appLocalizations!.solo],
        prefixIcon: const Icon(Icons.travel_explore),
        validators: [
          FormBuilderValidators.required(),
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Padding buildHealthConditionField(
      {String? healthCondition, bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.only(top: Get.width * 0.05),
      child: Select(
        name: "health_condition",
        initialValue: healthCondition,
        enabled: enabled,
        label: appLocalizations!.healthCondition,
        options: [
          appLocalizations!.heart,
          appLocalizations!.asthma,
          appLocalizations!.noCondition,
        ],
        prefixIcon: const Icon(Icons.health_and_safety),
        validators: [
          FormBuilderValidators.required(),
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Padding buildNeedStrollerField({bool? needStroller, bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.only(top: Get.width * 0.05, bottom: Get.width * 0.05),
      child: Check(
        name: 'need_stroller',
        initialValue: needStroller,
        enabled: enabled,
        title: appLocalizations!.needStroller,
        color: Get.isDarkMode ? Colors.black26 : Colors.grey.shade100,
        textColor: Get.isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
}

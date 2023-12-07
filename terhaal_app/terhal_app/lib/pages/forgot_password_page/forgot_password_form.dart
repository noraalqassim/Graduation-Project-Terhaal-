import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:terhal_app/form/controls/data.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/loading.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.appLocalizations,
  });

  final GlobalKey<FormBuilderState> formKey;
  final AppLocalizations? appLocalizations;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final FirebaseAuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widget.formKey,
      child: Column(
        children: [
          _buildEmailField(),
          _buildResetPassword(),
        ],
      ),
    );
  }

  void _handleResetPassword() async {
    if (widget.formKey.currentState!.saveAndValidate()) {
      await authController
          .resetPassword(widget.formKey.currentState!.value['email']);
    }
  }

  Container _buildResetPassword() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      height: Get.height * 0.06,
      width: Get.width,
      child: _buildResetButton(),
    );
  }

  Obx _buildResetButton() {
    return Obx(
      () => authController.isLoading.value
          ? Loading.circle
          : MaterialButton(
              onPressed: _handleResetPassword,
              color: Constants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(
                widget.appLocalizations!.resetPassword,
              ),
            ),
    );
  }

  Padding _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Data(
        name: 'email',
        label: widget.appLocalizations!.email,
        prefixIcon: const Icon(Icons.email),
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.email(),
        ],
        color: Get.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }
}

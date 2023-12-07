import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:terhal_app/controllers/firebase_firestore_controller.dart';
import 'package:terhal_app/controllers/user_controller.dart';
import 'package:terhal_app/form/user_form.dart';
import 'package:terhal_app/models/user.dart';
import 'package:terhal_app/controllers/firebase_auth_controller.dart';
import 'package:terhal_app/utils/constants.dart';
import 'package:terhal_app/widgets/button.dart';
import 'package:terhal_app/widgets/loading.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.appLocalizations,
  });

  final AppLocalizations? appLocalizations;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final formKey = GlobalKey<FormBuilderState>();
  final FirebaseAuthController authController = Get.find();
  final FirebaseFirestoreController storeController = Get.find();
  final UserController userController = Get.find();
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final UserForm userForm =
        UserForm(appLocalizations: widget.appLocalizations);

    return FormBuilder(
      key: formKey,
      child: Stepper(
        elevation: 0,
        connectorThickness: 2,
        margin: const EdgeInsets.all(0),
        type: StepperType.horizontal,
        physics: const BouncingScrollPhysics(),
        currentStep: currentStep,
        onStepContinue: () {
          setState(() {
            if (currentStep < 2) {
              currentStep += 1;
            }
          });
        },
        onStepCancel: () {
          setState(() {
            if (currentStep > 0) {
              currentStep -= 1;
            }
          });
        },
        onStepTapped: (value) => setState(() => currentStep = value),
        steps: [
          _buildStep1(userForm),
          _buildStep2(userForm),
          _buildStep3(userForm),
        ],
        controlsBuilder: (context, details) {
          final isLastStep = details.stepIndex == 2;
          final isFirstStep = details.stepIndex == 0;

          return _buildControls(details, isLastStep, isFirstStep);
        },
      ),
    );
  }

  Step _buildStep1(UserForm userForm) {
    return Step(
      title: Text(widget.appLocalizations!.step(1)),
      isActive: currentStep == 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          userForm.buildUFullNameField(),
          userForm.buildUsernameField(),
          userForm.buildEmailField(),
        ],
      ),
    );
  }

  Step _buildStep2(UserForm userForm) {
    return Step(
      title: Text(widget.appLocalizations!.step(2)),
      isActive: currentStep == 1,
      content: Column(
        children: [
          userForm.buildPasswordField(name: "password"),
          userForm.buildConfirmPasswordField(
              passwordField: 'password', formKey: formKey),
          userForm.buildAgeGenderFields(),
        ],
      ),
    );
  }

  Step _buildStep3(UserForm userForm) {
    return Step(
      title: Text(widget.appLocalizations!.step(3)),
      isActive: currentStep == 2,
      content: Column(
        children: [
          userForm.buildTravelCompanionField(),
          userForm.buildHealthConditionField(),
          userForm.buildNeedStrollerField(needStroller: false),
          _buildCreateAccount(),
          SizedBox(height: Get.height * 0.02),
          _buildSignInWidget(),
        ],
      ),
    );
  }

  Padding _buildControls(
      ControlsDetails details, bool isLastStep, bool isFirstStep) {
    return Padding(
      padding: EdgeInsets.only(top: Get.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (details.onStepContinue != null && !isLastStep)
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: Get.height * 0.05,
                child: MaterialButton(
                  onPressed: details.onStepContinue,
                  color: Constants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    widget.appLocalizations!.next,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          if (details.onStepCancel != null && !isFirstStep)
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: Get.height * 0.05,
                child: MaterialButton(
                  onPressed: details.onStepCancel,
                  color: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    widget.appLocalizations!.back,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Container _buildCreateAccount() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      height: Get.height * 0.06,
      width: Get.width,
      child: _buildCreateAccountButton(),
    );
  }

  Obx _buildCreateAccountButton() {
    return Obx(
      () => authController.isLoading.value
          ? Loading.circle
          : Button(
              text: widget.appLocalizations!.createAccount,
              onPressed: () async {
                if (formKey.currentState!.saveAndValidate()) {
                  final user = User.fromJson(formKey.currentState!.value);
                  _registerUser(user);
                }
              },
            ),
    );
  }

  Future<void> _registerUser(User user) async {
    var usernames = await storeController.getUsernames();
    if (usernames.contains(user.username)) {
      Get.snackbar(
        "Username already taken",
        "Username already taken, please choose another one",
        margin: const EdgeInsets.all(10),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    await authController
        .signUpWithEmailAndPassword(
      user,
      formKey.currentState!.value['password'],
    )
        .then((value) {
      if (value != null) {
        storeController.createUser(value.user!.uid, user);
      }
      user.uid = value!.user!.uid;
      authController.sendEmailVerification();
      userController.createUser(user);
      Get.offAllNamed('/home');
    });
  }

  Row _buildSignInWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.appLocalizations!.alreadyHaveAccount),
        SizedBox(width: Get.width * 0.01),
        GestureDetector(
          onTap: () => Get.offAllNamed('/signin'),
          child: Text(
            widget.appLocalizations!.login,
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

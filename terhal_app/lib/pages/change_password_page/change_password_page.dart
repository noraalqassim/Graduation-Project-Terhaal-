import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:terhal_app/models/user.dart';
import 'package:terhal_app/pages/change_password_page/change_password_view.dart';
import 'package:terhal_app/utils/constants.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Constants.primaryColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body:
            ChangePasswordView(appLocalizations: appLocalizations, user: user),
      ),
    );
  }
}

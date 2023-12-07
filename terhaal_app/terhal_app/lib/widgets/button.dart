import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terhal_app/utils/constants.dart';

class Button extends StatelessWidget {
  const Button({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Constants.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: Get.isDarkMode ? Colors.grey[400] : Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:terhal_app/utils/constants.dart';

final ThemeData lightThemeData = ThemeData(
  primaryColor: Constants.primarySwatch,
  colorScheme: const ColorScheme.light().copyWith(
    primary: Constants.primarySwatch,
  ),
);

final ThemeData darkThemeData = ThemeData(
  primaryColor: Constants.primarySwatch,
  colorScheme: const ColorScheme.dark().copyWith(
    primary: Constants.primarySwatch,
  ),
);

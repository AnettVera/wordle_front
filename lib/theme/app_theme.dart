import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF02060F);
  static const green = Color(0xFF0E533B);
  static const yellow = Color(0xFFCA8817);
  static const darkGrey = Color(0xFF3a3a3c);
  static const text = Color(0xFFE5D8C4);
  static const cellBorder = Color(0xFFDADADA);

}

final wordleTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'roboto',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: AppColors.text,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      fontSize: 20,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.text,
      fontWeight: FontWeight.bold,
      fontSize: 28,
      letterSpacing: 4,
    ),
    iconTheme: IconThemeData(color: AppColors.text),
  ),
);

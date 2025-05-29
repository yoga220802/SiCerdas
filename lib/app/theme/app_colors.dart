import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary color
  static const Color primary = Color.fromRGBO(45, 51, 107, 1);
  static const Color secondary = Color.fromRGBO(147, 163, 214, 1);

  // Text colors
  static const Color textWhite = Color.fromRGBO(255, 255, 255, 1);
  static const Color textBlack = Color.fromRGBO(36, 36, 36, 1);
  static const Color textGrey = Color.fromRGBO(83, 83, 83, 1);
  static const Color textBlue = Color.fromRGBO(78, 75, 102, 1);

  // Basic colors
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color black = Color.fromRGBO(36, 36, 36, 1);
  static const Color grey = Color.fromRGBO(83, 83, 83, 1);
  static const Color lightGrey = Color.fromRGBO(230, 232, 237, 1);
  static const Color backgroundGrey = Color.fromRGBO(244, 245, 247, 1);

  // Status colors
  static const Color error = Color.fromRGBO(255, 34, 34, 1);
  static const Color success = Color.fromRGBO(0, 85, 0, 1);

  // Other colors
  // Warna lain dari helper.dart yang mungkin masih relevan
  static const Color linearHelper = Color.fromRGBO(169, 181, 223, 1);
  static const Color requiredHelper = Color.fromRGBO(255, 69, 69, 1);

  // Warna spesifik dari UI yang sudah ada
  static const Color splashCircleBlue = Color.fromRGBO(138, 159, 216, 1);
  static const Color splashLoadingDot = Color.fromRGBO(138, 79, 189, 1);
}

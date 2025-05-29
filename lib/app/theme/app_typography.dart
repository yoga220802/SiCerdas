import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';

class AppTypography {
  AppTypography._();

  static final _fontFamily = GoogleFonts.lexend().fontFamily!;

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  static TextStyle _base(
    FontWeight weight, {
    Color color = AppColors.black,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // Display styles (untuk judul besar, banner, dll.)
  static final TextStyle displayLarge = _base(bold).copyWith(fontSize: 40);
  static final TextStyle displayMedium = _base(bold).copyWith(fontSize: 34);
  static final TextStyle displaySmall = _base(bold).copyWith(fontSize: 28);

  // Headline styles (untuk judul-judul penting)
  static final TextStyle headlineLarge = _base(bold).copyWith(fontSize: 24);
  static final TextStyle headlineMedium = _base(bold).copyWith(fontSize: 20);
  static final TextStyle headlineSmall = _base(semiBold).copyWith(fontSize: 18);

  // Title styles (untuk subjudul atau judul item dalam list)
  static final TextStyle titleLarge = _base(medium).copyWith(fontSize: 20);
  static final TextStyle titleMedium = _base(medium).copyWith(fontSize: 16);
  static final TextStyle titleSmall = _base(regular).copyWith(fontSize: 14);

  // Body styles (untuk teks utama, paragraf)
  static final TextStyle bodyLarge = _base(regular).copyWith(fontSize: 16);
  static final TextStyle bodyMedium = _base(regular).copyWith(fontSize: 14);
  static final TextStyle bodySmall = _base(regular).copyWith(fontSize: 12);

  // Label styles (untuk teks pada tombol, input field labels, dll.)
  static final TextStyle labelLarge = _base(
    semiBold,
  ).copyWith(fontSize: 16, color: AppColors.white);
  static final TextStyle labelMedium = _base(medium).copyWith(fontSize: 14);
  static final TextStyle labelSmall = _base(regular).copyWith(fontSize: 12);

  // Caption and Overline (untuk teks kecil, metadata)
  static final TextStyle caption = _base(regular).copyWith(fontSize: 12);
  static final TextStyle overline = _base(regular).copyWith(fontSize: 10);
}

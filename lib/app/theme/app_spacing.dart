import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Vertical Spacing
  static customVS(double input) => SizedBox(height: input);

  static const Widget vsSuperTiny = SizedBox(height: 4.0);
  static const Widget vsTiny = SizedBox(height: 8.0);
  static const Widget vsSmall = SizedBox(height: 12.0);
  static const Widget vsMedium = SizedBox(height: 16.0);
  static const Widget vsLarge = SizedBox(height: 24.0);
  static const Widget vsXLarge = SizedBox(height: 32.0);
  static const Widget vsXXLarge = SizedBox(height: 48.0);

  // Horizontal Spacing
  static customHS(double input) => SizedBox(width: input);

  static const Widget hsSuperTiny = SizedBox(width: 4.0);
  static const Widget hsTiny = SizedBox(width: 8.0);
  static const Widget hsSmall = SizedBox(width: 12.0);
  static const Widget hsMedium = SizedBox(width: 16.0);
  static const Widget hsLarge = SizedBox(width: 24.0);
  static const Widget hsXLarge = SizedBox(width: 32.0);
  static const Widget hsXXLarge = SizedBox(width: 48.0);

  // Padding Presets
  // Padding presets for consistent spacing
  static const EdgeInsets aPaddingTiny = EdgeInsets.all(4.0);
  static const EdgeInsets aPaddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets aPaddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets aPaddingLarge = EdgeInsets.all(24.0);

  // Padding presets for horizontal spacing
  static const EdgeInsets hPaddingSmall = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets hPaddingMedium = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
  static const EdgeInsets hPaddingLarge = EdgeInsets.symmetric(
    horizontal: 24.0,
  );

  // Padding presets for vertical spacing
  static const EdgeInsets vPaddingSmall = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets vPaddingMedium = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets vPadingLarge = EdgeInsets.symmetric(vertical: 24.0);
}

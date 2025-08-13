import 'package:flutter/material.dart';

class FlowCanvasThemeConstants {
  // Common color palettes
  static const MaterialColor primaryBlue = Colors.blue;
  static const MaterialColor primaryPurple = Colors.purple;
  static const MaterialColor primaryGreen = Colors.green;

  // Standard sizes
  static const double defaultBorderRadius = 8.0;
  static const double defaultHandleSize = 10.0;
  static const double defaultGap = 30.0;
  static const double defaultStrokeWidth = 2.0;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  static const Duration fastAnimationDuration = Duration(milliseconds: 100);
  static const Duration slowAnimationDuration = Duration(milliseconds: 300);

  // Shadows
  static List<BoxShadow> get lightShadows => [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get darkShadows => [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowShadows => [
        BoxShadow(
          color: Colors.blue.withAlpha(102),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];

  // Common gradients
  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
  );

  static const Gradient oceanGradient = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
  );
}

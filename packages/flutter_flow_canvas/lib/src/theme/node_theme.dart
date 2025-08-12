import 'package:flutter/material.dart';

class FlowCanvasNodeTheme {
  final Color defaultBackgroundColor;
  final Color defaultBorderColor;
  final Color selectedBackgroundColor;
  final Color selectedBorderColor;
  final Color errorBackgroundColor;
  final Color errorBorderColor;
  final double defaultBorderWidth;
  final double selectedBorderWidth;
  final double borderRadius;
  final List<BoxShadow> shadows;
  final TextStyle defaultTextStyle;

  const FlowCanvasNodeTheme({
    required this.defaultBackgroundColor,
    required this.defaultBorderColor,
    required this.selectedBackgroundColor,
    required this.selectedBorderColor,
    required this.errorBackgroundColor,
    required this.errorBorderColor,
    this.defaultBorderWidth = 1.0,
    this.selectedBorderWidth = 2.0,
    this.borderRadius = 8.0,
    this.shadows = const [],
    required this.defaultTextStyle,
  });

  factory FlowCanvasNodeTheme.light() {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor: Colors.white,
      defaultBorderColor: const Color(0xFFE0E0E0),
      selectedBackgroundColor: const Color(0xFFF0F8FF),
      selectedBorderColor: const Color(0xFF2196F3),
      errorBackgroundColor: const Color(0xFFFFEBEE),
      errorBorderColor: const Color(0xFFE57373),
      defaultBorderWidth: 1.0,
      selectedBorderWidth: 2.0,
      borderRadius: 8.0,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      defaultTextStyle: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  factory FlowCanvasNodeTheme.dark() {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor: const Color(0xFF2D2D2D),
      defaultBorderColor: const Color(0xFF404040),
      selectedBackgroundColor: const Color(0xFF1E3A5F),
      selectedBorderColor: const Color(0xFF64B5F6),
      errorBackgroundColor: const Color(0xFF3D1A1A),
      errorBorderColor: const Color(0xFFEF5350),
      defaultBorderWidth: 1.0,
      selectedBorderWidth: 2.0,
      borderRadius: 8.0,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      defaultTextStyle: const TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  FlowCanvasNodeTheme copyWith({
    Color? defaultBackgroundColor,
    Color? defaultBorderColor,
    Color? selectedBackgroundColor,
    Color? selectedBorderColor,
    Color? errorBackgroundColor,
    Color? errorBorderColor,
    double? defaultBorderWidth,
    double? selectedBorderWidth,
    double? borderRadius,
    List<BoxShadow>? shadows,
    TextStyle? defaultTextStyle,
  }) {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor:
          defaultBackgroundColor ?? this.defaultBackgroundColor,
      defaultBorderColor: defaultBorderColor ?? this.defaultBorderColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      defaultBorderWidth: defaultBorderWidth ?? this.defaultBorderWidth,
      selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      defaultTextStyle: defaultTextStyle ?? this.defaultTextStyle,
    );
  }
}

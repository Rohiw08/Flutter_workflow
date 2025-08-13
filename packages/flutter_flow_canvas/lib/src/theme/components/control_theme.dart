import 'package:flutter/material.dart';

class FlowCanvasControlTheme {
  final Color backgroundColor;
  final Color buttonColor;
  final Color buttonHoverColor;
  final Color iconColor;
  final Color iconHoverColor;
  final Color dividerColor;
  final double buttonSize;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;
  final EdgeInsets padding;

  const FlowCanvasControlTheme({
    required this.backgroundColor,
    required this.buttonColor,
    required this.buttonHoverColor,
    required this.iconColor,
    required this.iconHoverColor,
    required this.dividerColor,
    this.buttonSize = 32.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.shadows = const [],
    this.padding = const EdgeInsets.all(4.0),
  });

  factory FlowCanvasControlTheme.light() {
    return FlowCanvasControlTheme(
      backgroundColor: Colors.white,
      buttonColor: const Color(0xFFF9FAFB),
      buttonHoverColor: const Color(0xFFF3F4F6),
      iconColor: const Color(0xFF6B7280),
      iconHoverColor: const Color(0xFF374151),
      dividerColor: const Color(0xFFE5E7EB),
      buttonSize: 32.0,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      padding: const EdgeInsets.all(4.0),
    );
  }

  factory FlowCanvasControlTheme.dark() {
    return FlowCanvasControlTheme(
      backgroundColor: const Color(0xFF1F2937),
      buttonColor: const Color(0xFF374151),
      buttonHoverColor: const Color(0xFF4B5563),
      iconColor: Colors.white,
      iconHoverColor: const Color(0xFFF9FAFB),
      dividerColor: const Color(0xFF374151),
      buttonSize: 32.0,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.all(4.0),
    );
  }

  FlowCanvasControlTheme copyWith({
    Color? backgroundColor,
    Color? buttonColor,
    Color? buttonHoverColor,
    Color? iconColor,
    Color? iconHoverColor,
    Color? dividerColor,
    double? buttonSize,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    EdgeInsets? padding,
  }) {
    return FlowCanvasControlTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonHoverColor: buttonHoverColor ?? this.buttonHoverColor,
      iconColor: iconColor ?? this.iconColor,
      iconHoverColor: iconHoverColor ?? this.iconHoverColor,
      dividerColor: dividerColor ?? this.dividerColor,
      buttonSize: buttonSize ?? this.buttonSize,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      padding: padding ?? this.padding,
    );
  }
}

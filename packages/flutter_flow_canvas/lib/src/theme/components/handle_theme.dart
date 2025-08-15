import 'package:flutter/material.dart';

class FlowCanvasHandleTheme {
  final Color idleColor;
  final Color hoverColor;
  final Color activeColor;
  final Color validTargetColor;
  final Color invalidTargetColor;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final bool enableAnimations;

  const FlowCanvasHandleTheme({
    required this.idleColor,
    required this.hoverColor,
    required this.activeColor, // Updated in constructor
    required this.validTargetColor,
    required this.invalidTargetColor,
    this.size = 10.0,
    this.borderWidth = 1.5,
    required this.borderColor,
    this.shadows = const [],
    this.enableAnimations = true,
  });

  factory FlowCanvasHandleTheme.light() {
    return FlowCanvasHandleTheme(
      idleColor: const Color(0xFF9CA3AF),
      hoverColor: const Color(0xFF6B7280),
      activeColor: const Color(0xFF3B82F6), // Updated in light factory
      validTargetColor: const Color(0xFF10B981),
      invalidTargetColor: const Color(0xFFEF4444),
      size: 10.0,
      borderWidth: 1.5,
      borderColor: Colors.white,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
      enableAnimations: true,
    );
  }

  factory FlowCanvasHandleTheme.dark() {
    return FlowCanvasHandleTheme(
      idleColor: const Color(0xFF6B7280),
      hoverColor: const Color(0xFF9CA3AF),
      activeColor: const Color(0xFF60A5FA), // Updated in dark factory
      validTargetColor: const Color(0xFF34D399),
      invalidTargetColor: const Color(0xFFF87171),
      size: 10.0,
      borderWidth: 1.5,
      borderColor: const Color(0xFF374151),
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      enableAnimations: true,
    );
  }

  FlowCanvasHandleTheme copyWith({
    Color? idleColor,
    Color? hoverColor,
    Color? activeColor, // Updated in copyWith
    Color? validTargetColor,
    Color? invalidTargetColor,
    double? size,
    double? borderWidth,
    Color? borderColor,
    List<BoxShadow>? shadows,
    bool? enableAnimations,
  }) {
    return FlowCanvasHandleTheme(
      idleColor: idleColor ?? this.idleColor,
      hoverColor: hoverColor ?? this.hoverColor,
      activeColor: activeColor ?? this.activeColor, // Updated in copyWith
      validTargetColor: validTargetColor ?? this.validTargetColor,
      invalidTargetColor: invalidTargetColor ?? this.invalidTargetColor,
      size: size ?? this.size,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      shadows: shadows ?? this.shadows,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }
}

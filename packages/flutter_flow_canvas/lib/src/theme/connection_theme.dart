import 'package:flutter/material.dart';

class FlowCanvasConnectionTheme {
  final Color activeColor;
  final Color validTargetColor;
  final Color invalidTargetColor;
  final double strokeWidth;
  final double endPointRadius;

  const FlowCanvasConnectionTheme({
    required this.activeColor,
    required this.validTargetColor,
    required this.invalidTargetColor,
    this.strokeWidth = 2.0,
    this.endPointRadius = 6.0,
  });

  factory FlowCanvasConnectionTheme.light() {
    return const FlowCanvasConnectionTheme(
      activeColor: Color(0xFF2196F3),
      validTargetColor: Color(0xFF4CAF50),
      invalidTargetColor: Color(0xFFF44336),
      strokeWidth: 2.0,
      endPointRadius: 6.0,
    );
  }

  factory FlowCanvasConnectionTheme.dark() {
    return const FlowCanvasConnectionTheme(
      activeColor: Color(0xFF64B5F6),
      validTargetColor: Color(0xFF81C784),
      invalidTargetColor: Color(0xFFE57373),
      strokeWidth: 2.0,
      endPointRadius: 6.0,
    );
  }

  FlowCanvasConnectionTheme copyWith({
    Color? activeColor,
    Color? validTargetColor,
    Color? invalidTargetColor,
    double? strokeWidth,
    double? endPointRadius,
  }) {
    return FlowCanvasConnectionTheme(
      activeColor: activeColor ?? this.activeColor,
      validTargetColor: validTargetColor ?? this.validTargetColor,
      invalidTargetColor: invalidTargetColor ?? this.invalidTargetColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      endPointRadius: endPointRadius ?? this.endPointRadius,
    );
  }
}

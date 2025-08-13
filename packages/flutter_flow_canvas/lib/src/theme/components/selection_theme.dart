import 'package:flutter/material.dart';

class FlowCanvasSelectionTheme {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double dashLength;
  final double gapLength;

  const FlowCanvasSelectionTheme({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 5.0,
  });

  factory FlowCanvasSelectionTheme.light() {
    return const FlowCanvasSelectionTheme(
      fillColor: Color(0x1A2196F3),
      borderColor: Color(0xFF2196F3),
      borderWidth: 1.0,
      dashLength: 5.0,
      gapLength: 5.0,
    );
  }

  factory FlowCanvasSelectionTheme.dark() {
    return const FlowCanvasSelectionTheme(
      fillColor: Color(0x1A64B5F6),
      borderColor: Color(0xFF64B5F6),
      borderWidth: 1.0,
      dashLength: 5.0,
      gapLength: 5.0,
    );
  }

  FlowCanvasSelectionTheme copyWith({
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    double? dashLength,
    double? gapLength,
  }) {
    return FlowCanvasSelectionTheme(
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      dashLength: dashLength ?? this.dashLength,
      gapLength: gapLength ?? this.gapLength,
    );
  }
}

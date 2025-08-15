import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/components/edge_label_theme.dart';

class FlowCanvasEdgeTheme {
  final Color defaultColor;
  final Color selectedColor;
  final Color animatedColor;
  final double defaultStrokeWidth;
  final double selectedStrokeWidth;
  final double arrowHeadSize;
  final EdgeLabelTheme? label;
  final Color? hoverColor;

  const FlowCanvasEdgeTheme({
    required this.defaultColor,
    required this.selectedColor,
    required this.animatedColor,
    this.defaultStrokeWidth = 2.0,
    this.selectedStrokeWidth = 3.0,
    this.arrowHeadSize = 8.0,
    this.hoverColor,
    this.label,
  });

  factory FlowCanvasEdgeTheme.light() {
    return FlowCanvasEdgeTheme(
      defaultColor: const Color(0xFF9E9E9E),
      selectedColor: const Color(0xFF2196F3),
      hoverColor: const Color(0xFF757575), // Added hover color for light theme
      animatedColor: const Color(0xFF4CAF50),
      defaultStrokeWidth: 2.0,
      selectedStrokeWidth: 3.0,
      arrowHeadSize: 8.0,
      label: EdgeLabelTheme.light(),
    );
  }

  factory FlowCanvasEdgeTheme.dark() {
    return FlowCanvasEdgeTheme(
      defaultColor: const Color(0xFF616161),
      selectedColor: const Color(0xFF64B5F6),
      hoverColor: const Color(0xFF9E9E9E), // Added hover color for dark theme
      animatedColor: const Color(0xFF81C784),
      defaultStrokeWidth: 2.0,
      selectedStrokeWidth: 3.0,
      arrowHeadSize: 8.0,
      label: EdgeLabelTheme.dark(),
    );
  }

  FlowCanvasEdgeTheme copyWith({
    Color? defaultColor,
    Color? selectedColor,
    Color? hoverColor, // Added to copyWith
    Color? animatedColor,
    double? defaultStrokeWidth,
    double? selectedStrokeWidth,
    double? arrowHeadSize,
    EdgeLabelTheme? label,
  }) {
    return FlowCanvasEdgeTheme(
      defaultColor: defaultColor ?? this.defaultColor,
      selectedColor: selectedColor ?? this.selectedColor,
      hoverColor: hoverColor ?? this.hoverColor, // Added to copyWith
      animatedColor: animatedColor ?? this.animatedColor,
      defaultStrokeWidth: defaultStrokeWidth ?? this.defaultStrokeWidth,
      selectedStrokeWidth: selectedStrokeWidth ?? this.selectedStrokeWidth,
      arrowHeadSize: arrowHeadSize ?? this.arrowHeadSize,
      label: label ?? this.label,
    );
  }
}

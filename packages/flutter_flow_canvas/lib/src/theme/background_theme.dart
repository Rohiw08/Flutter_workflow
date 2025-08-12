import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';

class FlowCanvasBackgroundTheme {
  final Color backgroundColor;
  final BackgroundVariant variant;
  final Color patternColor;
  final double gap;
  final double lineWidth;
  final double? dotRadius;
  final double? crossSize;
  final bool fadeOnZoom;
  final Gradient? gradient;
  final Offset patternOffset;

  const FlowCanvasBackgroundTheme({
    required this.backgroundColor,
    required this.variant,
    required this.patternColor,
    this.gap = 30.0,
    this.lineWidth = 1.0,
    this.dotRadius,
    this.crossSize,
    this.fadeOnZoom = true,
    this.gradient,
    this.patternOffset = Offset.zero,
  });

  factory FlowCanvasBackgroundTheme.light() {
    return const FlowCanvasBackgroundTheme(
      backgroundColor: Color(0xFFFAFAFA),
      variant: BackgroundVariant.dots,
      patternColor: Color(0xFFE0E0E0),
      gap: 30.0,
      lineWidth: 1.0,
      fadeOnZoom: true,
    );
  }

  factory FlowCanvasBackgroundTheme.dark() {
    return const FlowCanvasBackgroundTheme(
      backgroundColor: Color(0xFF1A1A1A),
      variant: BackgroundVariant.dots,
      patternColor: Color(0xFF404040),
      gap: 30.0,
      lineWidth: 1.0,
      fadeOnZoom: true,
    );
  }

  FlowCanvasBackgroundTheme copyWith({
    Color? backgroundColor,
    BackgroundVariant? variant,
    Color? patternColor,
    double? gap,
    double? lineWidth,
    double? dotRadius,
    double? crossSize,
    bool? fadeOnZoom,
    Gradient? gradient,
    Offset? patternOffset,
  }) {
    return FlowCanvasBackgroundTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      variant: variant ?? this.variant,
      patternColor: patternColor ?? this.patternColor,
      gap: gap ?? this.gap,
      lineWidth: lineWidth ?? this.lineWidth,
      dotRadius: dotRadius ?? this.dotRadius,
      crossSize: crossSize ?? this.crossSize,
      fadeOnZoom: fadeOnZoom ?? this.fadeOnZoom,
      gradient: gradient ?? this.gradient,
      patternOffset: patternOffset ?? this.patternOffset,
    );
  }
}

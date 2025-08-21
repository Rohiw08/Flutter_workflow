import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';

class FlowCanvasBackgroundTheme
    extends ThemeExtension<FlowCanvasBackgroundTheme> {
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
  final BlendMode? blendMode;
  final double opacity;
  final List<Color>? alternateColors;

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
    this.blendMode,
    this.opacity = 1.0,
    this.alternateColors,
  });

  factory FlowCanvasBackgroundTheme.light() {
    return const FlowCanvasBackgroundTheme(
      backgroundColor: Color(0xFFFAFAFA),
      variant: BackgroundVariant.dots,
      patternColor: Color(0xFFE0E0E0),
      gap: 30.0,
      lineWidth: 1.0,
      fadeOnZoom: true,
      opacity: 1.0,
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
      opacity: 1.0,
    );
  }

  factory FlowCanvasBackgroundTheme.animatedGradient({
    required List<Color> colors,
    BackgroundVariant variant = BackgroundVariant.none,
    double gap = 30.0,
  }) {
    return FlowCanvasBackgroundTheme(
      backgroundColor: colors.first,
      variant: variant,
      patternColor: colors.length > 1 ? colors[1] : colors.first,
      gap: gap,
      gradient: LinearGradient(colors: colors),
      alternateColors: colors.length > 2 ? colors.sublist(2) : null,
    );
  }

  @override
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
    BlendMode? blendMode,
    double? opacity,
    List<Color>? alternateColors,
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
      blendMode: blendMode ?? this.blendMode,
      opacity: opacity ?? this.opacity,
      alternateColors: alternateColors ?? this.alternateColors,
    );
  }

  @override
  FlowCanvasBackgroundTheme lerp(
      ThemeExtension<FlowCanvasBackgroundTheme>? other, double t) {
    if (other is! FlowCanvasBackgroundTheme) return this;
    return FlowCanvasBackgroundTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      variant: t < 0.5 ? variant : other.variant, // Discrete switch
      patternColor: Color.lerp(patternColor, other.patternColor, t)!,
      gap: lerpDouble(gap, other.gap, t)!,
      lineWidth: lerpDouble(lineWidth, other.lineWidth, t)!,
      dotRadius: lerpDouble(dotRadius, other.dotRadius, t),
      crossSize: lerpDouble(crossSize, other.crossSize, t),
      fadeOnZoom: t < 0.5 ? fadeOnZoom : other.fadeOnZoom,
      gradient: Gradient.lerp(gradient, other.gradient, t),
      patternOffset:
          Offset.lerp(patternOffset, other.patternOffset, t) ?? Offset.zero,
      blendMode: t < 0.5 ? blendMode : other.blendMode,
      opacity: lerpDouble(opacity, other.opacity, t)!,
      alternateColors:
          t < 0.5 ? alternateColors : other.alternateColors, // Simplified
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowCanvasBackgroundTheme &&
        backgroundColor == other.backgroundColor &&
        variant == other.variant &&
        patternColor == other.patternColor &&
        gap == other.gap &&
        lineWidth == other.lineWidth &&
        dotRadius == other.dotRadius &&
        crossSize == other.crossSize &&
        fadeOnZoom == other.fadeOnZoom &&
        gradient == other.gradient &&
        patternOffset == other.patternOffset &&
        blendMode == other.blendMode &&
        opacity == other.opacity &&
        listEquals(alternateColors, other.alternateColors);
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        variant,
        patternColor,
        gap,
        lineWidth,
        dotRadius,
        crossSize,
        fadeOnZoom,
        gradient,
        patternOffset,
        blendMode,
        opacity,
        Object.hashAll(alternateColors ?? []),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

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

  // Enhanced properties
  final BlendMode? blendMode;
  final double opacity;
  final List<Color>? alternateColors; // For complex patterns

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

  /// Create animated gradient background
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowCanvasBackgroundTheme &&
        other.backgroundColor == backgroundColor &&
        other.variant == variant &&
        other.patternColor == patternColor &&
        other.gap == gap &&
        other.lineWidth == lineWidth &&
        other.dotRadius == dotRadius &&
        other.crossSize == crossSize &&
        other.fadeOnZoom == fadeOnZoom &&
        other.gradient == gradient &&
        other.patternOffset == patternOffset &&
        other.blendMode == blendMode &&
        other.opacity == opacity;
  }

  @override
  int get hashCode {
    return Object.hash(
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
    );
  }
}

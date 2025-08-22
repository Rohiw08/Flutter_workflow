import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/components/background_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

FlowCanvasBackgroundTheme resolveBackgroundTheme(
  BuildContext context,
  FlowCanvasBackgroundTheme? backgroundTheme, {
  // Local property overrides
  Color? backgroundColor,
  BackgroundVariant? pattern,
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
  // Start with the theme object if provided, otherwise fall back to the context theme.
  final base = backgroundTheme ?? context.flowCanvasTheme.background;

  // Apply all local overrides on top of the base theme.
  return base.copyWith(
    backgroundColor: backgroundColor,
    variant: pattern,
    patternColor: patternColor,
    gap: gap,
    lineWidth: lineWidth,
    dotRadius: dotRadius,
    crossSize: crossSize,
    fadeOnZoom: fadeOnZoom,
    gradient: gradient,
    patternOffset: patternOffset,
    blendMode: blendMode,
    opacity: opacity,
    alternateColors: alternateColors,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme_export.dart';

FlowCanvasControlTheme resolveControlTheme(
  BuildContext context,
  FlowCanvasControlTheme? controlsTheme, {
  // Local property overrides
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
  // Start with the theme object if provided, otherwise fall back to the context theme.
  final base = controlsTheme ?? context.flowCanvasTheme.controls;

  // Apply all local overrides on top of the base theme.
  return base.copyWith(
    backgroundColor: backgroundColor,
    buttonColor: buttonColor,
    buttonHoverColor: buttonHoverColor,
    iconColor: iconColor,
    iconHoverColor: iconHoverColor,
    dividerColor: dividerColor,
    buttonSize: buttonSize,
    borderRadius: borderRadius,
    shadows: shadows,
    padding: padding,
  );
}

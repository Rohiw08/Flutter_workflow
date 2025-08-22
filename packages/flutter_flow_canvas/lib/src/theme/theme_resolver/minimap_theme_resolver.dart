import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/components/minimap_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

FlowCanvasMiniMapTheme resolveMiniMapTheme(
  BuildContext context,
  FlowCanvasMiniMapTheme? theme, {
  // Local property overrides
  Color? backgroundColor,
  Color? nodeColor,
  Color? nodeStrokeColor,
  double? nodeBorderRadius,
  Color? selectedNodeColor,
  Color? maskColor,
  Color? maskStrokeColor,
  double? nodeStrokeWidth,
  double? maskStrokeWidth,
  double? borderRadius,
  List<BoxShadow>? shadows,
  double? padding,
  double? viewportBorderRadius,
  Color? selectedGlowColor,
  double? selectedGlowBlur,
  double? selectedGlowWidthMultiplier,
  Color? viewportInnerGlowColor,
  double? viewportInnerGlowWidthMultiplier,
  double? viewportInnerGlowBlur,
  Color? viewportInnerColor,
}) {
  // Start with the theme object if provided, otherwise fall back to the context theme.
  final base = theme ?? context.flowCanvasTheme.miniMap;

  // Apply all local overrides on top of the base theme.
  return base.copyWith(
    backgroundColor: backgroundColor,
    nodeColor: nodeColor,
    nodeStrokeColor: nodeStrokeColor,
    nodeBorderRadius: nodeBorderRadius,
    selectedNodeColor: selectedNodeColor,
    maskColor: maskColor,
    maskStrokeColor: maskStrokeColor,
    nodeStrokeWidth: nodeStrokeWidth,
    maskStrokeWidth: maskStrokeWidth,
    borderRadius: borderRadius,
    shadows: shadows,
    padding: padding,
    viewportBorderRadius: viewportBorderRadius,
    selectedGlowColor: selectedGlowColor,
    selectedGlowBlur: selectedGlowBlur,
    selectedGlowWidthMultiplier: selectedGlowWidthMultiplier,
    viewportInnerGlowColor: viewportInnerGlowColor,
    viewportInnerGlowWidthMultiplier: viewportInnerGlowWidthMultiplier,
    viewportInnerGlowBlur: viewportInnerGlowBlur,
    viewportInnerColor: viewportInnerColor,
  );
}

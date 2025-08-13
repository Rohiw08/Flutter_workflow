import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/default_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/flow_canvas_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/node_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

/// Mixin for widgets that need theme access
mixin FlowCanvasThemeMixin<T extends StatefulWidget> on State<T> {
  FlowCanvasTheme get theme {
    // Try to get from context extensions first
    try {
      return context.flowTheme;
    } catch (e) {
      // Fallback to default theme
      return FlowCanvasThemes.professional;
    }
  }

  /// Get node style for current theme and state
  NodeStyleData getNodeStyle({
    bool isSelected = false,
    bool isHovered = false,
    bool isDisabled = false,
    bool hasError = false,
  }) {
    return theme.node.getStyleForState(
      isSelected: isSelected,
      isHovered: isHovered,
      isDisabled: isDisabled,
      hasError: hasError,
    );
  }

  /// Get edge paint for current theme
  Paint getEdgePaint({bool isSelected = false, Paint? customPaint}) {
    if (customPaint != null) return customPaint;

    return Paint()
      ..color = isSelected ? theme.edge.selectedColor : theme.edge.defaultColor
      ..strokeWidth = isSelected
          ? theme.edge.selectedStrokeWidth
          : theme.edge.defaultStrokeWidth
      ..style = PaintingStyle.stroke;
  }

  /// Get handle color for state
  Color getHandleColor({
    bool isHovered = false,
    bool isConnecting = false,
    bool isValidTarget = false,
    bool isInvalidTarget = false,
  }) {
    if (isInvalidTarget) return theme.handle.invalidTargetColor;
    if (isValidTarget) return theme.handle.validTargetColor;
    if (isConnecting) return theme.handle.connectingColor;
    if (isHovered) return theme.handle.hoverColor;
    return theme.handle.idleColor;
  }
}

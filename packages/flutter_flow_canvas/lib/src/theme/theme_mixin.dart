import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

mixin FlowCanvasThemeMixin<T extends StatefulWidget> on State<T> {
  FlowCanvasTheme get flowTheme {
    return context.flowCanvasTheme;
  }

  /// Get node decoration for current state
  BoxDecoration getNodeDecoration({
    bool isSelected = false,
    bool isHovered = false,
    bool hasError = false,
  }) {
    Color backgroundColor = flowTheme.node.defaultBackgroundColor;
    Color borderColor = flowTheme.node.defaultBorderColor;
    double borderWidth = flowTheme.node.defaultBorderWidth;

    if (hasError) {
      borderColor = flowTheme.node.errorBorderColor;
      borderWidth = 2.0;
    } else if (isSelected) {
      borderColor = flowTheme.node.selectedBorderColor;
      borderWidth = 2.0;
    } else if (isHovered) {
      backgroundColor = flowTheme.node.hoverBackgroundColor ??
          flowTheme.node.defaultBackgroundColor;
    }

    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: BorderRadius.circular(flowTheme.node.borderRadius),
      boxShadow: flowTheme.node.shadows,
    );
  }

  /// Get edge paint for current state
  Paint getEdgePaint({
    bool isSelected = false,
    bool isHovered = false,
  }) {
    Color color = flowTheme.edge.defaultColor;
    double width = flowTheme.edge.defaultStrokeWidth;

    if (isSelected) {
      color = flowTheme.edge.selectedColor;
      width = flowTheme.edge.selectedStrokeWidth;
    } else if (isHovered) {
      color = flowTheme.edge.hoverColor ?? flowTheme.edge.defaultColor;
    }

    return Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  /// Get handle color for current state
  Color getHandleColor({
    bool isHovered = false,
    bool isActive = false,
    bool isValid = false,
    bool isInvalid = false,
  }) {
    if (isInvalid) return flowTheme.handle.invalidTargetColor;
    if (isValid) return flowTheme.handle.validTargetColor;
    if (isActive) return flowTheme.handle.activeColor;
    if (isHovered) return flowTheme.handle.hoverColor;
    return flowTheme.handle.idleColor;
  }
}

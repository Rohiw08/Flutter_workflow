// Widget wrapper for easy background usage
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/painters/background_painter.dart';

class FlowCanvasBackground extends StatelessWidget {
  final Matrix4 transformMatrix;
  final Widget child;

  // Theme overrides
  final BackgroundVariant? pattern;
  final Color? patternColor;
  final Color? backgroundColor;
  final double? spacing;
  final double? opacity;

  const FlowCanvasBackground({
    super.key,
    required this.transformMatrix,
    required this.child,
    this.pattern,
    this.patternColor,
    this.backgroundColor,
    this.spacing,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FlowCanvasBackgroundPainter.fromContext(
        context,
        transformMatrix,
        patternOverride: pattern,
        colorOverride: patternColor,
        backgroundColorOverride: backgroundColor,
        gapOverride: spacing,
        opacityOverride: opacity,
      ),
      child: child,
    );
  }
}

/// Background configuration for easy customization
class BackgroundConfig {
  final BackgroundVariant pattern;
  final Color? patternColor;
  final Color? backgroundColor;
  final double? spacing;
  final double? opacity;
  final double? lineWidth;

  const BackgroundConfig({
    this.pattern = BackgroundVariant.dots,
    this.patternColor,
    this.backgroundColor,
    this.spacing,
    this.opacity,
    this.lineWidth,
  });

  BackgroundConfig copyWith({
    BackgroundVariant? pattern,
    Color? patternColor,
    Color? backgroundColor,
    double? spacing,
    double? opacity,
    double? lineWidth,
  }) {
    return BackgroundConfig(
      pattern: pattern ?? this.pattern,
      patternColor: patternColor ?? this.patternColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      spacing: spacing ?? this.spacing,
      opacity: opacity ?? this.opacity,
      lineWidth: lineWidth ?? this.lineWidth,
    );
  }
}

/// Background presets for common use cases
class BackgroundPresets {
  BackgroundPresets._();

  static const BackgroundConfig subtle = BackgroundConfig(
    pattern: BackgroundVariant.dots,
    opacity: 0.1,
    spacing: 40.0,
  );

  static const BackgroundConfig grid = BackgroundConfig(
    pattern: BackgroundVariant.grid,
    opacity: 0.2,
    spacing: 25.0,
  );

  static const BackgroundConfig blueprint = BackgroundConfig(
    pattern: BackgroundVariant.lines,
    opacity: 0.3,
    spacing: 20.0,
  );

  static const BackgroundConfig minimal = BackgroundConfig(
    pattern: BackgroundVariant.none,
  );

  static const BackgroundConfig cross = BackgroundConfig(
    pattern: BackgroundVariant.cross,
    opacity: 0.15,
    spacing: 30.0,
  );
}

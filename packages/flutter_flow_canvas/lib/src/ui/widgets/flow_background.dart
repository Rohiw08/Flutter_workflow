import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/canvas_controller.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/core/providers.dart';
import 'package:flutter_flow_canvas/src/theme/theme_export.dart';
import 'package:flutter_flow_canvas/src/theme/theme_resolver/background_theme_resolver.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/painters/background_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlowBackground extends ConsumerWidget {
  final Provider<Object>? controllerProvider;
  final bool interactive;
  final FlowCanvasBackgroundTheme? backgroundTheme;

  // --- THEME & OVERRIDES ---
  final Color? backgroundColor;
  final BackgroundVariant? pattern;
  final Color? color;
  final double? gap;
  final double? lineWidth;
  final double? dotRadius;
  final double? crossSize;
  final bool? fadeOnZoom;
  final Gradient? gradient;
  final Offset? patternOffset;
  final BlendMode? blendMode;
  final double? opacity;
  final List<Color>? alternateColors;

  const FlowBackground({
    super.key,
    this.controllerProvider,
    this.interactive = true,
    this.backgroundTheme,
    this.backgroundColor,
    this.pattern,
    this.color,
    this.gap,
    this.lineWidth,
    this.dotRadius,
    this.crossSize,
    this.fadeOnZoom,
    this.gradient,
    this.patternOffset,
    this.blendMode,
    this.opacity,
    this.alternateColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = controllerProvider != null
        ? ref.watch(controllerProvider! as Provider<FlowCanvasController>)
        : ref.watch(flowControllerProvider);

    // All theme logic is now cleanly handled by the resolver function.
    final finalBackgroundTheme = resolveBackgroundTheme(
      context,
      backgroundTheme,
      backgroundColor: backgroundColor,
      pattern: pattern,
      patternColor: color,
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

    return Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: FlowCanvasBackgroundPainter(
            matrix: controller.transformationController.value,
            // Pass the fully resolved theme to the painter
            theme: finalBackgroundTheme,
          ),
          child: interactive ? const SizedBox.expand() : null,
        ),
      ),
    );
  }
}

/// Extension to provide additional providers for specific background needs
extension FlowBackgroundProviders on Ref {
  /// Watch only the transformation matrix for background rendering
  Matrix4 watchTransformationMatrix() {
    final controller = watch(flowControllerProvider);
    return controller.transformationController.value;
  }

  /// Watch the zoom level for background scaling effects
  double watchZoomLevel() {
    final controller = watch(flowControllerProvider);
    return controller.zoomLevel;
  }
}

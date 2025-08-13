// Advanced theme interpolation for smooth transitions
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';

class FlowCanvasThemeInterpolation {
  /// Create smooth transition between themes
  static FlowCanvasTheme interpolate(
    FlowCanvasTheme from,
    FlowCanvasTheme to,
    double t, {
    Curve curve = Curves.easeInOut,
  }) {
    final adjustedT = curve.transform(t);
    return FlowCanvasThemeUtils.lerp(from, to, adjustedT);
  }

  /// Create animation controller for theme transitions
  static AnimationController createThemeTransition(
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Animate between themes with callback
  static void animateThemeChange(
    AnimationController controller,
    FlowCanvasTheme from,
    FlowCanvasTheme to,
    ValueChanged<FlowCanvasTheme> onUpdate, {
    Curve curve = Curves.easeInOut,
    VoidCallback? onComplete,
  }) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );

    animation.addListener(() {
      final interpolatedTheme =
          interpolate(from, to, animation.value, curve: curve);
      onUpdate(interpolatedTheme);
    });

    if (onComplete != null) {
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          onComplete();
        }
      });
    }

    controller.forward(from: 0.0);
  }
}

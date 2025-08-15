import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

/// Background painter that integrates with FlowCanvasTheme
class FlowCanvasBackgroundPainter extends CustomPainter {
  final Matrix4 matrix;
  final FlowCanvasTheme theme;

  // Optional overrides - if null, uses theme values
  final BackgroundVariant? patternOverride;
  final Color? colorOverride;
  final Color? backgroundColorOverride;
  final double? gapOverride;
  final double? lineWidthOverride;
  final double? opacityOverride;

  const FlowCanvasBackgroundPainter({
    required this.matrix,
    required this.theme,
    this.patternOverride,
    this.colorOverride,
    this.backgroundColorOverride,
    this.gapOverride,
    this.lineWidthOverride,
    this.opacityOverride,
  });

  /// Convenience constructor that creates from context
  factory FlowCanvasBackgroundPainter.fromContext(
    BuildContext context,
    Matrix4 matrix, {
    BackgroundVariant? patternOverride,
    Color? colorOverride,
    Color? backgroundColorOverride,
    double? gapOverride,
    double? lineWidthOverride,
    double? opacityOverride,
  }) {
    return FlowCanvasBackgroundPainter(
      matrix: matrix,
      theme: context.flowCanvasTheme,
      patternOverride: patternOverride,
      colorOverride: colorOverride,
      backgroundColorOverride: backgroundColorOverride,
      gapOverride: gapOverride,
      lineWidthOverride: lineWidthOverride,
      opacityOverride: opacityOverride,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw background
    _drawBackground(canvas, rect);

    // Draw pattern if not none
    // UPDATED: Accessing theme.background.variant
    final pattern = patternOverride ?? theme.background.variant;
    if (pattern != BackgroundVariant.none) {
      _drawPattern(canvas, size, pattern);
    }
  }

  void _drawBackground(Canvas canvas, Rect rect) {
    // UPDATED: Accessing theme.background.backgroundColor
    final backgroundColor =
        backgroundColorOverride ?? theme.background.backgroundColor;
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, bgPaint);
  }

  void _drawPattern(Canvas canvas, Size size, BackgroundVariant pattern) {
    final scale = matrix.getMaxScaleOnAxis();

    // UPDATED: Accessing theme.background properties
    final gap = (gapOverride ?? theme.background.gap) * scale;
    final lineWidth = lineWidthOverride ?? theme.background.lineWidth;
    final baseOpacity = opacityOverride ?? theme.background.opacity;
    final fadeOnZoom = theme.background.fadeOnZoom;

    // UPDATED: Accessing theme.background.patternColor
    Color patternColor = colorOverride ?? theme.background.patternColor;

    // Apply zoom-based opacity changes
    double effectiveOpacity = baseOpacity;
    if (fadeOnZoom) {
      const double fadeStartScale = 0.8;
      const double fadeEndScale = 0.3;

      if (scale < fadeStartScale) {
        final fadeProgress =
            ((scale - fadeEndScale) / (fadeStartScale - fadeEndScale))
                .clamp(0.0, 1.0);
        effectiveOpacity *= fadeProgress;
      }
    }

    if (effectiveOpacity <= 0) return;

    patternColor = patternColor.withAlpha((effectiveOpacity * 255).toInt());

    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = lineWidth;

    // Calculate offset for pattern positioning
    final translation = matrix.getTranslation();
    final offsetX = translation.x % gap;
    final offsetY = translation.y % gap;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    final visibleWidth = size.width - offsetX;
    final visibleHeight = size.height - offsetY;

    // Draw the specific pattern (original logic preserved)
    switch (pattern) {
      case BackgroundVariant.dots:
        _drawDots(canvas, visibleWidth, visibleHeight, gap, paint);
        break;
      case BackgroundVariant.lines:
        _drawLines(canvas, visibleWidth, visibleHeight, gap, paint);
        break;
      case BackgroundVariant.grid:
        _drawGrid(canvas, visibleWidth, visibleHeight, gap, paint);
        break;
      case BackgroundVariant.cross:
        _drawCrosses(canvas, visibleWidth, visibleHeight, gap, paint);
        break;
      case BackgroundVariant.none:
        break;
    }

    canvas.restore();
  }

  // YOUR ORIGINAL DRAWING LOGIC - UNCHANGED
  void _drawDots(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    paint.style = PaintingStyle.fill;
    final radius = max(1.0, gap * 0.03); // Responsive dot size

    final verticalCount = (width / gap).ceil() + 1;
    final horizontalCount = (height / gap).ceil() + 1;

    for (int i = -1; i < verticalCount; i++) {
      for (int j = -1; j < horizontalCount; j++) {
        canvas.drawCircle(Offset(i * gap, j * gap), radius, paint);
      }
    }
  }

  // YOUR ORIGINAL DRAWING LOGIC - UNCHANGED
  void _drawLines(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;

    // Draw vertical lines
    final verticalCount = (width / gap).ceil() + 1;
    for (int i = -1; i < verticalCount; i++) {
      final x = i * gap;
      canvas.drawLine(Offset(x, -gap), Offset(x, height + gap), paint);
    }

    // Draw horizontal lines
    final horizontalCount = (height / gap).ceil() + 1;
    for (int i = -1; i < horizontalCount; i++) {
      final y = i * gap;
      canvas.drawLine(Offset(-gap, y), Offset(width + gap, y), paint);
    }
  }

  // YOUR ORIGINAL DRAWING LOGIC - UNCHANGED
  void _drawGrid(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    // Grid is same as lines but with different visual weight
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = paint.strokeWidth * 0.5; // Thinner lines for grid
    _drawLines(canvas, width, height, gap, paint);
  }

  // YOUR ORIGINAL DRAWING LOGIC - UNCHANGED
  void _drawCrosses(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final crossSize = gap * 0.2; // Responsive cross size
    final halfSize = crossSize / 2;

    final verticalCount = (width / gap).ceil() + 1;
    final horizontalCount = (height / gap).ceil() + 1;

    for (int i = -1; i < verticalCount; i++) {
      for (int j = -1; j < horizontalCount; j++) {
        final x = i * gap;
        final y = j * gap;

        // Horizontal line of cross
        canvas.drawLine(
          Offset(x - halfSize, y),
          Offset(x + halfSize, y),
          paint,
        );

        // Vertical line of cross
        canvas.drawLine(
          Offset(x, y - halfSize),
          Offset(x, y + halfSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FlowCanvasBackgroundPainter oldDelegate) {
    return oldDelegate.matrix != matrix ||
        oldDelegate.theme != theme ||
        oldDelegate.patternOverride != patternOverride ||
        oldDelegate.colorOverride != colorOverride ||
        oldDelegate.backgroundColorOverride != backgroundColorOverride ||
        oldDelegate.gapOverride != gapOverride ||
        oldDelegate.lineWidthOverride != lineWidthOverride ||
        oldDelegate.opacityOverride != opacityOverride;
  }
}

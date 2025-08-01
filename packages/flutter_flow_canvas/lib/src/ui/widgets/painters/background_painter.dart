import 'dart:math';
import 'package:flutter/material.dart';

/// Defines the visual style of the canvas background.
enum BackgroundVariant { lines, dots, cross }

class BackgroundPainter extends CustomPainter {
  final Matrix4 matrix;
  final BackgroundVariant variant;
  final double gap;
  final Color color;
  final double lineWidth;
  final Gradient? gradient;
  final double? dotRadius;
  final double? crossSize;
  final Offset patternOffset;
  final bool fadeOnZoom;
  final Color? bgColor;

  BackgroundPainter({
    required this.matrix,
    this.variant = BackgroundVariant.dots,
    this.color = const Color.fromARGB(255, 31, 31, 31),
    this.bgColor = const Color.fromARGB(255, 245, 240, 240),
    this.gradient,
    this.gap = 30.0,
    this.lineWidth = 1.0,
    this.dotRadius,
    this.crossSize,
    this.patternOffset = Offset.zero,
    this.fadeOnZoom = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (bgColor != null) {
      final bgPaint = Paint()..color = bgColor!;
      canvas.drawRect(rect, bgPaint);
    } else if (gradient != null) {
      final paint = Paint()..shader = gradient!.createShader(rect);
      canvas.drawRect(rect, paint);
    }

    final scale = matrix.getMaxScaleOnAxis();

    Color patternColor = color;
    if (fadeOnZoom) {
      const double fadeStartScale = 0.7;
      const double fadeEndScale = 0.2;

      final double fadeProgress =
          ((scale - fadeEndScale) / (fadeStartScale - fadeEndScale))
              .clamp(0.0, 1.0);

      if (fadeProgress < 1.0) {
        patternColor = color.withAlpha((color.a * fadeProgress).round());
      }
    }

    if (patternColor.a == 0) return;

    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = lineWidth;

    final translation = matrix.getTranslation();
    final effectiveGap = gap * scale;

    final totalOffsetX = (translation.x + patternOffset.dx * scale);
    final totalOffsetY = (translation.y + patternOffset.dy * scale);

    final offsetX = totalOffsetX % effectiveGap;
    final offsetY = totalOffsetY % effectiveGap;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    final visibleWidth = size.width - offsetX;
    final visibleHeight = size.height - offsetY;

    switch (variant) {
      case BackgroundVariant.lines:
        _drawLines(canvas, visibleWidth, visibleHeight, effectiveGap, paint);
        break;
      case BackgroundVariant.dots:
        _drawDots(canvas, visibleWidth, visibleHeight, effectiveGap, paint);
        break;
      case BackgroundVariant.cross:
        _drawCrosses(canvas, visibleWidth, visibleHeight, effectiveGap, paint);
        break;
    }
    canvas.restore();
  }

  void _drawLines(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;

    final int verticalLines = (width / gap).ceil() + 1;
    for (int i = -1; i < verticalLines; i++) {
      final double x = i * gap;
      canvas.drawLine(Offset(x, -gap), Offset(x, height + gap), paint);
    }

    final int horizontalLines = (height / gap).ceil() + 1;
    for (int i = -1; i < horizontalLines; i++) {
      final double y = i * gap;
      canvas.drawLine(Offset(-gap, y), Offset(width + gap, y), paint);
    }
  }

  void _drawDots(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    paint.style = PaintingStyle.fill;
    final r = dotRadius ?? max(1.0, lineWidth);

    final int verticalCount = (width / gap).ceil() + 1;
    final int horizontalCount = (height / gap).ceil() + 1;

    for (int i = -1; i < verticalCount; i++) {
      for (int j = -1; j < horizontalCount; j++) {
        canvas.drawCircle(Offset(i * gap, j * gap), r, paint);
      }
    }
  }

  void _drawCrosses(
      Canvas canvas, double width, double height, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final s = crossSize ?? 6.0;
    final halfSize = s / 2.0;

    final int verticalCount = (width / gap).ceil() + 1;
    final int horizontalCount = (height / gap).ceil() + 1;

    for (int i = -1; i < verticalCount; i++) {
      for (int j = -1; j < horizontalCount; j++) {
        final x = i * gap;
        final y = j * gap;
        canvas.drawLine(
            Offset(x - halfSize, y), Offset(x + halfSize, y), paint);
        canvas.drawLine(
            Offset(x, y - halfSize), Offset(x, y + halfSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.matrix != matrix ||
        oldDelegate.variant != variant ||
        oldDelegate.gap != gap ||
        oldDelegate.color != color ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.gradient != gradient ||
        oldDelegate.dotRadius != dotRadius ||
        oldDelegate.crossSize != crossSize ||
        oldDelegate.patternOffset != patternOffset ||
        oldDelegate.fadeOnZoom != fadeOnZoom ||
        oldDelegate.bgColor != bgColor; // 🔥 Add this
  }
}

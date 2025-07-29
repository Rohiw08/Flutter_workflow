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

  BackgroundPainter({
    required this.matrix,
    this.variant = BackgroundVariant.dots,
    this.gap = 30.0,
    this.color = Colors.black12,
    this.lineWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth;

    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final canvasRect =
        MatrixUtils.transformRect(matrix.clone()..invert(), screenRect);

    canvas.transform(matrix.storage);

    switch (variant) {
      case BackgroundVariant.lines:
        _drawLines(canvas, canvasRect, gap, paint);
        break;
      case BackgroundVariant.dots:
        _drawDots(canvas, canvasRect, gap, paint);
        break;
      case BackgroundVariant.cross:
        _drawCrosses(canvas, canvasRect, gap, paint);
        break;
    }
  }

  void _drawLines(Canvas canvas, Rect canvasRect, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    for (double x = canvasRect.left - canvasRect.left % gap;
        x < canvasRect.right;
        x += gap) {
      canvas.drawLine(
          Offset(x, canvasRect.top), Offset(x, canvasRect.bottom), paint);
    }
    for (double y = canvasRect.top - canvasRect.top % gap;
        y < canvasRect.bottom;
        y += gap) {
      canvas.drawLine(
          Offset(canvasRect.left, y), Offset(canvasRect.right, y), paint);
    }
  }

  void _drawDots(Canvas canvas, Rect canvasRect, double gap, Paint paint) {
    paint.style = PaintingStyle.fill;
    final double dotRadius = max(1.0, lineWidth);

    for (double x = canvasRect.left - canvasRect.left % gap;
        x < canvasRect.right;
        x += gap) {
      for (double y = canvasRect.top - canvasRect.top % gap;
          y < canvasRect.bottom;
          y += gap) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  void _drawCrosses(Canvas canvas, Rect canvasRect, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    const double crossSize = 6.0;
    const double halfSize = crossSize / 2;

    for (double x = canvasRect.left - canvasRect.left % gap;
        x < canvasRect.right;
        x += gap) {
      for (double y = canvasRect.top - canvasRect.top % gap;
          y < canvasRect.bottom;
          y += gap) {
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
        oldDelegate.lineWidth != lineWidth;
  }
}

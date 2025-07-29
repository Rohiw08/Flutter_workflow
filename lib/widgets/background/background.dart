import 'dart:math';
import 'package:flutter/material.dart';

enum BackgroundVariant { lines, dots, cross }

class InfiniteGridPainter extends CustomPainter {
  final BackgroundVariant variant;
  final double gap;
  final Color color;
  final Color? bgColor;
  final double lineWidth;
  final double patternSize;
  final Offset offset;

  InfiniteGridPainter({
    this.variant = BackgroundVariant.dots,
    this.gap = 20.0,
    this.color = Colors.grey,
    this.bgColor,
    this.lineWidth = 1.0,
    this.patternSize = 0.0, // Default handled in paint method
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background Color
    if (bgColor != null) {
      canvas.drawColor(bgColor!, BlendMode.src);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth;

    // 2. Apply the offset
    canvas.translate(offset.dx, offset.dy);
    final adjustedSize = Size(
      size.width - offset.dx,
      size.height - offset.dy,
    );

    // 3. Draw the selected pattern variant
    switch (variant) {
      case BackgroundVariant.lines:
        _drawLines(canvas, adjustedSize, paint);
        break;
      case BackgroundVariant.dots:
        _drawDots(canvas, adjustedSize, paint);
        break;
      case BackgroundVariant.cross:
        _drawCrosses(canvas, adjustedSize, paint);
        break;
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final int verticalLines = (size.width / gap).ceil();
    final int horizontalLines = (size.height / gap).ceil();

    for (int i = 0; i <= verticalLines; i++) {
      final double x = i * gap;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= horizontalLines; i++) {
      final double y = i * gap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    // Default size for dots is based on lineWidth, or use provided size
    final double dotRadius = (patternSize > 0) ? patternSize : max(1.0, lineWidth);

    final int verticalCount = (size.width / gap).ceil();
    final int horizontalCount = (size.height / gap).ceil();

    for (int i = 0; i <= verticalCount; i++) {
      for (int j = 0; j <= horizontalCount; j++) {
        canvas.drawCircle(Offset(i * gap, j * gap), dotRadius, paint);
      }
    }
  }

  void _drawCrosses(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    // Default size for crosses is 6, or use provided size
    final double crossSize = (patternSize > 0) ? patternSize : 6.0;
    final double halfSize = crossSize / 2;

    final int verticalCount = (size.width / gap).ceil();
    final int horizontalCount = (size.height / gap).ceil();

    for (int i = 0; i <= verticalCount; i++) {
      for (int j = 0; j <= horizontalCount; j++) {
        final x = i * gap;
        final y = j * gap;
        // Draw horizontal line of the cross
        canvas.drawLine(Offset(x - halfSize, y), Offset(x + halfSize, y), paint);
        // Draw vertical line of the cross
        canvas.drawLine(Offset(x, y - halfSize), Offset(x, y + halfSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteGridPainter oldDelegate) {
    // Repaint if any of the visual properties change
    return oldDelegate.variant != variant ||
        oldDelegate.gap != gap ||
        oldDelegate.color != color ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.patternSize != patternSize ||
        oldDelegate.offset != offset;
  }
}
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';
import 'package:vector_math/vector_math_64.dart';

/// Optimized background painter that integrates with FlowCanvasTheme
class FlowCanvasBackgroundPainter extends CustomPainter {
  final Matrix4 matrix;
  final FlowCanvasTheme theme;

  final BackgroundVariant? pattern;
  final Color? color;
  final Color? backgroundColor;
  final double? gap;
  final double? lineWidth;

  // Cache for performance optimization
  static final Map<String, ui.Picture> _patternCache = {};
  static const int _maxCacheSize = 20;

  const FlowCanvasBackgroundPainter({
    required this.matrix,
    required this.theme,
    this.pattern,
    this.color,
    this.backgroundColor,
    this.gap,
    this.lineWidth,
  });

  /// Convenience constructor that creates from context
  factory FlowCanvasBackgroundPainter.fromContext(
    BuildContext context,
    Matrix4 matrix, {
    BackgroundVariant? pattern,
    Color? color,
    Color? backgroundColor,
    double? gap,
    double? lineWidth,
  }) {
    return FlowCanvasBackgroundPainter(
      matrix: matrix,
      theme: context.flowCanvasTheme,
      pattern: pattern,
      color: color,
      backgroundColor: backgroundColor,
      gap: gap,
      lineWidth: lineWidth,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw background
    _drawBackground(canvas, rect);

    // Draw pattern if not none
    final pattern = this.pattern ?? theme.background.variant;
    if (pattern != BackgroundVariant.none) {
      _drawPatternOptimized(canvas, size, pattern);
    }
  }

  void _drawBackground(Canvas canvas, Rect rect) {
    final backgroundColor =
        this.backgroundColor ?? theme.background.backgroundColor;
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, bgPaint);
  }

  void _drawPatternOptimized(
      Canvas canvas, Size size, BackgroundVariant pattern) {
    final scale = matrix.getMaxScaleOnAxis();
    final gap = (this.gap ?? theme.background.gap) * scale;
    final lineWidth = this.lineWidth ?? theme.background.lineWidth;

    Color patternColor = color ?? theme.background.patternColor;

    // Early exit for very small patterns that won't be visible
    if (gap < 1.0) return;

    final paint = Paint()
      ..color = patternColor
      ..strokeWidth = lineWidth;

    // Calculate visible bounds more precisely
    final translation = matrix.getTranslation();
    final visibleRect = Rect.fromLTWH(-translation.x, -translation.y,
        size.width / scale, size.height / scale);

    // Use different optimization strategies based on pattern type and scale
    if (scale < 0.1) {
      // For very small scales, use cached tile approach
      _drawWithTiling(canvas, size, pattern, gap, paint, translation);
    } else {
      // For normal scales, use batched drawing
      _drawWithBatching(
          canvas, size, pattern, gap, paint, translation, visibleRect);
    }
  }

  void _drawWithTiling(Canvas canvas, Size size, BackgroundVariant pattern,
      double gap, Paint paint, Vector3 translation) {
    // Create a cache key
    final cacheKey =
        '${pattern}_${gap.toStringAsFixed(1)}_${paint.color.toARGB32()}_${paint.strokeWidth}';

    ui.Picture? cachedTile = _patternCache[cacheKey];

    if (cachedTile == null) {
      // Create a single tile
      final recorder = ui.PictureRecorder();
      final tileCanvas = Canvas(recorder);
      final tileSize = gap * 4; // Create a 4x4 tile for better coverage

      _drawSingleTile(tileCanvas, tileSize, pattern, gap, paint);

      cachedTile = recorder.endRecording();

      // Manage cache size
      if (_patternCache.length >= _maxCacheSize) {
        _patternCache.remove(_patternCache.keys.first);
      }
      _patternCache[cacheKey] = cachedTile;
    }

    // Draw the cached tile across the visible area
    final tileSize = gap * 4;
    final tilesX = (size.width / tileSize).ceil() + 2;
    final tilesY = (size.height / tileSize).ceil() + 2;

    final offsetX = (translation.x % tileSize);
    final offsetY = (translation.y % tileSize);

    canvas.save();
    canvas.translate(offsetX, offsetY);

    for (int x = -1; x < tilesX; x++) {
      for (int y = -1; y < tilesY; y++) {
        canvas.save();
        canvas.translate(x * tileSize, y * tileSize);
        canvas.drawPicture(cachedTile);
        canvas.restore();
      }
    }

    canvas.restore();
  }

  void _drawSingleTile(Canvas canvas, double tileSize,
      BackgroundVariant pattern, double gap, Paint paint) {
    switch (pattern) {
      case BackgroundVariant.dots:
        _drawDotsInTile(canvas, tileSize, gap, paint);
        break;
      case BackgroundVariant.grid:
        _drawGridInTile(canvas, tileSize, gap, paint);
        break;
      case BackgroundVariant.cross:
        _drawCrossesInTile(canvas, tileSize, gap, paint);
        break;
      case BackgroundVariant.none:
        break;
    }
  }

  void _drawWithBatching(Canvas canvas, Size size, BackgroundVariant pattern,
      double gap, Paint paint, Vector3 translation, Rect visibleRect) {
    final offsetX = translation.x % gap;
    final offsetY = translation.y % gap;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    final visibleWidth = size.width - offsetX;
    final visibleHeight = size.height - offsetY;

    // Calculate precise bounds to minimize overdraw
    final startX = (-offsetX / gap).floor() - 1;
    final endX = ((visibleWidth + gap) / gap).ceil();
    final startY = (-offsetY / gap).floor() - 1;
    final endY = ((visibleHeight + gap) / gap).ceil();

    switch (pattern) {
      case BackgroundVariant.dots:
        _drawDotsBatched(canvas, gap, paint, startX, endX, startY, endY);
        break;
      case BackgroundVariant.grid:
        _drawGridBatched(canvas, visibleWidth, visibleHeight, gap, paint,
            startX, endX, startY, endY);
        break;
      case BackgroundVariant.cross:
        _drawCrossesBatched(canvas, gap, paint, startX, endX, startY, endY);
        break;
      case BackgroundVariant.none:
        break;
    }

    canvas.restore();
  }

  void _drawDotsInTile(
      Canvas canvas, double tileSize, double gap, Paint paint) {
    paint.style = PaintingStyle.fill;
    final radius = max(1.0, gap * 0.03);

    final countPerRow = (tileSize / gap).ceil();

    for (int i = 0; i < countPerRow; i++) {
      for (int j = 0; j < countPerRow; j++) {
        canvas.drawCircle(Offset(i * gap, j * gap), radius, paint);
      }
    }
  }

  void _drawGridInTile(
      Canvas canvas, double tileSize, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = paint.strokeWidth * 0.5;

    final countPerRow = (tileSize / gap).ceil();

    // Vertical lines
    for (int i = 0; i <= countPerRow; i++) {
      final x = i * gap;
      canvas.drawLine(Offset(x, 0), Offset(x, tileSize), paint);
    }

    // Horizontal lines
    for (int i = 0; i <= countPerRow; i++) {
      final y = i * gap;
      canvas.drawLine(Offset(0, y), Offset(tileSize, y), paint);
    }
  }

  void _drawCrossesInTile(
      Canvas canvas, double tileSize, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final crossSize = gap * 0.2;
    final halfSize = crossSize / 2;

    final countPerRow = (tileSize / gap).ceil();

    for (int i = 0; i < countPerRow; i++) {
      for (int j = 0; j < countPerRow; j++) {
        final x = i * gap;
        final y = j * gap;

        // Horizontal line of cross
        canvas.drawLine(
            Offset(x - halfSize, y), Offset(x + halfSize, y), paint);
        // Vertical line of cross
        canvas.drawLine(
            Offset(x, y - halfSize), Offset(x, y + halfSize), paint);
      }
    }
  }

  void _drawDotsBatched(Canvas canvas, double gap, Paint paint, int startX,
      int endX, int startY, int endY) {
    paint.style = PaintingStyle.fill;
    final radius = max(1.0, gap * 0.03);

    // Use a single path for better performance when there are many dots
    final path = Path();

    for (int i = startX; i < endX; i++) {
      for (int j = startY; j < endY; j++) {
        final x = i * gap;
        final y = j * gap;
        path.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawGridBatched(Canvas canvas, double width, double height, double gap,
      Paint paint, int startX, int endX, int startY, int endY) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = paint.strokeWidth * 0.5;

    final path = Path();

    // Vertical lines
    for (int i = startX; i < endX; i++) {
      final x = i * gap;
      path.moveTo(x, -gap);
      path.lineTo(x, height + gap);
    }

    // Horizontal lines
    for (int i = startY; i < endY; i++) {
      final y = i * gap;
      path.moveTo(-gap, y);
      path.lineTo(width + gap, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawCrossesBatched(Canvas canvas, double gap, Paint paint, int startX,
      int endX, int startY, int endY) {
    paint.style = PaintingStyle.stroke;
    final crossSize = gap * 0.2;
    final halfSize = crossSize / 2;

    final path = Path();

    for (int i = startX; i < endX; i++) {
      for (int j = startY; j < endY; j++) {
        final x = i * gap;
        final y = j * gap;

        // Horizontal line of cross
        path.moveTo(x - halfSize, y);
        path.lineTo(x + halfSize, y);

        // Vertical line of cross
        path.moveTo(x, y - halfSize);
        path.lineTo(x, y + halfSize);
      }
    }

    canvas.drawPath(path, paint);
  }

  // Static method to clear cache when needed
  static void clearCache() {
    _patternCache.clear();
  }

  @override
  bool shouldRepaint(covariant FlowCanvasBackgroundPainter oldDelegate) {
    return oldDelegate.matrix != matrix ||
        oldDelegate.theme != theme ||
        oldDelegate.pattern != pattern ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gap != gap ||
        oldDelegate.lineWidth != lineWidth;
  }
}

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/components/background_theme.dart';
import 'package:vector_math/vector_math_64.dart';

class FlowCanvasBackgroundPainter extends CustomPainter {
  final Matrix4 matrix;
  final FlowCanvasBackgroundTheme theme;

  // Cache for performance optimization
  static final Map<String, ui.Picture> _patternCache = {};
  static const int _maxCacheSize = 20;

  const FlowCanvasBackgroundPainter({
    required this.matrix,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    _drawBackground(canvas, rect);

    if (theme.variant != BackgroundVariant.none) {
      _drawPatternOptimized(canvas, size, theme.variant);
    }
  }

  void _drawBackground(Canvas canvas, Rect rect) {
    final bgPaint = Paint();
    if (theme.gradient != null) {
      bgPaint.shader = theme.gradient!.createShader(rect);
    } else {
      bgPaint.color = theme.backgroundColor;
    }
    canvas.drawRect(rect, bgPaint);
  }

  void _drawPatternOptimized(
      Canvas canvas, Size size, BackgroundVariant pattern) {
    final scale = matrix.getMaxScaleOnAxis();
    final scaledGap = theme.gap * scale;

    if (scaledGap < 1.0) return;

    final paint = Paint()
      ..color = theme.patternColor
      ..strokeWidth = theme.lineWidth
      ..blendMode = theme.blendMode ?? BlendMode.srcOver;

    final translation = matrix.getTranslation();
    final totalTranslation = Vector3(
      translation.x + theme.patternOffset.dx * scale,
      translation.y + theme.patternOffset.dy * scale,
      0,
    );

    if (scale < 0.1) {
      _drawWithTiling(
          canvas, size, pattern, scaledGap, paint, totalTranslation);
    } else {
      _drawWithBatching(
          canvas, size, pattern, scaledGap, paint, totalTranslation);
    }
  }

  void _drawWithTiling(Canvas canvas, Size size, BackgroundVariant pattern,
      double gap, Paint paint, Vector3 translation) {
    final colorsKey =
        theme.alternateColors?.map((c) => c.toARGB32()).join('_') ?? '';
    final cacheKey =
        '${pattern}_${gap.toStringAsFixed(1)}_${paint.color.toARGB32()}_${paint.strokeWidth}_${theme.dotRadius}_${theme.crossSize}_$colorsKey';

    ui.Picture? cachedTile = _patternCache[cacheKey];

    if (cachedTile == null) {
      final recorder = ui.PictureRecorder();
      final tileCanvas = Canvas(recorder);
      final tileSize = gap * 4;
      _drawSingleTile(tileCanvas, tileSize, pattern, gap, paint);
      cachedTile = recorder.endRecording();

      if (_patternCache.length >= _maxCacheSize) {
        _patternCache.remove(_patternCache.keys.first);
      }
      _patternCache[cacheKey] = cachedTile;
    }

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
      double gap, Paint paint, Vector3 translation) {
    final offsetX = translation.x % gap;
    final offsetY = translation.y % gap;

    canvas.save();
    canvas.translate(offsetX, offsetY);

    final visibleWidth = size.width - offsetX;
    final visibleHeight = size.height - offsetY;
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
    final radius = theme.dotRadius ?? max(1.0, gap * 0.05);
    final colors = theme.alternateColors;
    final countPerRow = (tileSize / gap).ceil();
    final originalAlpha = paint.color.a;

    for (int i = 0; i < countPerRow; i++) {
      for (int j = 0; j < countPerRow; j++) {
        if (colors != null && colors.isNotEmpty) {
          final colorIndex = (i + j) % colors.length;
          paint.color = colors[colorIndex].withAlpha(originalAlpha.toInt());
        }
        canvas.drawCircle(Offset(i * gap, j * gap), radius, paint);
      }
    }
  }

  void _drawGridInTile(
      Canvas canvas, double tileSize, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = paint.strokeWidth * 0.5;
    final colors = theme.alternateColors;
    final originalColor = paint.color;
    final originalAlpha = originalColor.a;
    final countPerRow = (tileSize / gap).ceil();

    for (int i = 0; i <= countPerRow; i++) {
      if (colors != null && colors.isNotEmpty) {
        paint.color = colors[0].withAlpha(originalAlpha.toInt());
      }
      final x = i * gap;
      canvas.drawLine(Offset(x, 0), Offset(x, tileSize), paint);
    }
    for (int i = 0; i <= countPerRow; i++) {
      if (colors != null && colors.length > 1) {
        paint.color = colors[1].withAlpha(originalAlpha.toInt());
      }
      final y = i * gap;
      canvas.drawLine(Offset(0, y), Offset(tileSize, y), paint);
    }
    paint.color = originalColor;
  }

  void _drawCrossesInTile(
      Canvas canvas, double tileSize, double gap, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final size = theme.crossSize ?? gap * 0.2;
    final halfSize = size / 2;
    final colors = theme.alternateColors;
    final originalAlpha = paint.color.a;
    final countPerRow = (tileSize / gap).ceil();

    for (int i = 0; i < countPerRow; i++) {
      for (int j = 0; j < countPerRow; j++) {
        final x = i * gap;
        final y = j * gap;
        if (colors != null && colors.isNotEmpty) {
          final colorIndex = (i + j) % colors.length;
          paint.color = colors[colorIndex].withAlpha(originalAlpha.toInt());
        }
        canvas.drawLine(
            Offset(x - halfSize, y), Offset(x + halfSize, y), paint);
        canvas.drawLine(
            Offset(x, y - halfSize), Offset(x, y + halfSize), paint);
      }
    }
  }

  void _drawDotsBatched(Canvas canvas, double gap, Paint paint, int startX,
      int endX, int startY, int endY) {
    paint.style = PaintingStyle.fill;
    final radius = theme.dotRadius ?? max(1.0, gap * 0.05);
    final colors = theme.alternateColors;

    if (colors == null || colors.isEmpty) {
      final path = Path();
      for (int i = startX; i < endX; i++) {
        for (int j = startY; j < endY; j++) {
          path.addOval(Rect.fromCircle(
              center: Offset(i * gap, j * gap), radius: radius));
        }
      }
      canvas.drawPath(path, paint);
    } else {
      final numColors = colors.length;
      final List<Path> paths = List.generate(numColors, (_) => Path());
      for (int i = startX; i < endX; i++) {
        for (int j = startY; j < endY; j++) {
          final colorIndex = (i.abs() + j.abs()) % numColors;
          paths[colorIndex.toInt()].addOval(Rect.fromCircle(
              center: Offset(i * gap, j * gap), radius: radius));
        }
      }
      final baseAlpha = paint.color.a;
      for (int i = 0; i < numColors; i++) {
        if (!paths[i].getBounds().isEmpty) {
          paint.color = colors[i].withAlpha(baseAlpha.toInt());
          canvas.drawPath(paths[i], paint);
        }
      }
    }
  }

  void _drawGridBatched(Canvas canvas, double width, double height, double gap,
      Paint paint, int startX, int endX, int startY, int endY) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = paint.strokeWidth * 0.5;
    final colors = theme.alternateColors;

    if (colors == null || colors.isEmpty) {
      final path = Path();
      for (int i = startX; i < endX; i++) {
        final x = i * gap;
        path.moveTo(x, -gap);
        path.lineTo(x, height + gap);
      }
      for (int i = startY; i < endY; i++) {
        final y = i * gap;
        path.moveTo(-gap, y);
        path.lineTo(width + gap, y);
      }
      canvas.drawPath(path, paint);
    } else {
      final baseAlpha = paint.color.a;
      final vPath = Path();
      for (int i = startX; i < endX; i++) {
        final x = i * gap;
        vPath.moveTo(x, -gap);
        vPath.lineTo(x, height + gap);
      }
      paint.color = colors[0].withAlpha(baseAlpha.toInt());
      canvas.drawPath(vPath, paint);

      final hPath = Path();
      for (int i = startY; i < endY; i++) {
        final y = i * gap;
        hPath.moveTo(-gap, y);
        hPath.lineTo(width + gap, y);
      }
      paint.color = (colors.length > 1 ? colors[1] : colors[0])
          .withAlpha(baseAlpha.toInt());
      canvas.drawPath(hPath, paint);
    }
  }

  void _drawCrossesBatched(Canvas canvas, double gap, Paint paint, int startX,
      int endX, int startY, int endY) {
    paint.style = PaintingStyle.stroke;
    final size = theme.crossSize ?? gap * 0.2;
    final halfSize = size / 2;
    final colors = theme.alternateColors;

    if (colors == null || colors.isEmpty) {
      final path = Path();
      for (int i = startX; i < endX; i++) {
        for (int j = startY; j < endY; j++) {
          final x = i * gap;
          final y = j * gap;
          path.moveTo(x - halfSize, y);
          path.lineTo(x + halfSize, y);
          path.moveTo(x, y - halfSize);
          path.lineTo(x, y + halfSize);
        }
      }
      canvas.drawPath(path, paint);
    } else {
      final numColors = colors.length;
      final List<Path> paths = List.generate(numColors, (_) => Path());
      for (int i = startX; i < endX; i++) {
        for (int j = startY; j < endY; j++) {
          final colorIndex = (i.abs() + j.abs()) % numColors;
          final x = i * gap;
          final y = j * gap;
          paths[colorIndex.toInt()].moveTo(x - halfSize, y);
          paths[colorIndex.toInt()].lineTo(x + halfSize, y);
          paths[colorIndex.toInt()].moveTo(x, y - halfSize);
          paths[colorIndex.toInt()].lineTo(x, y + halfSize);
        }
      }
      final baseAlpha = paint.color.a;
      for (int i = 0; i < numColors; i++) {
        if (!paths[i].getBounds().isEmpty) {
          paint.color = colors[i].withAlpha(baseAlpha.toInt());
          canvas.drawPath(paths[i], paint);
        }
      }
    }
  }

  static void clearCache() => _patternCache.clear();

  @override
  bool shouldRepaint(covariant FlowCanvasBackgroundPainter oldDelegate) {
    return oldDelegate.matrix != matrix || oldDelegate.theme != theme;
  }
}

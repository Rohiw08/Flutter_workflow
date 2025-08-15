import 'dart:ui' show Rect;

class MiniMapTransform {
  final double scale;
  final double offsetX;
  final double offsetY;
  final Rect contentBounds;

  MiniMapTransform({
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.contentBounds,
  });
}

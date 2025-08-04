import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../flutter_flow_canvas.dart';

/// A data class to hold transformation details for the minimap.
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

/// The painter responsible for drawing the minimap content.
class MiniMapPainter extends CustomPainter {
  final FlowCanvasController controller;
  final MiniMapNodeColorFunc? nodeColor;
  final MiniMapNodeColorFunc? nodeStrokeColor;
  final double nodeBorderRadius;
  final double nodeStrokeWidth;
  final MiniMapNodeBuilder? nodeBuilder;
  final Color maskColor;
  final Color maskStrokeColor;
  final double maskStrokeWidth;
  final Size minimapSize;

  MiniMapPainter({
    required this.controller,
    this.nodeColor,
    this.nodeStrokeColor,
    required this.nodeBorderRadius,
    required this.nodeStrokeWidth,
    this.nodeBuilder,
    required this.maskColor,
    required this.maskStrokeColor,
    required this.maskStrokeWidth,
    required this.minimapSize,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.nodes.isEmpty) return;

    final transform =
        calculateTransform(controller.getNodesBounds(), minimapSize);
    if (transform.scale <= 0) return;

    _drawNodes(canvas, transform);
    _drawViewportMask(canvas, size, transform);
  }

  void _drawNodes(Canvas canvas, MiniMapTransform transform) {
    final defaultNodeColor = Colors.blue.shade400;
    final defaultStrokeColor = Colors.blue.shade600;

    for (final node in controller.nodes) {
      final fillColor = nodeColor?.call(node) ?? defaultNodeColor;
      final strokeColor = nodeStrokeColor?.call(node) ?? defaultStrokeColor;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = nodeStrokeWidth;

      final nodeRect = getNodeRect(node, transform);

      if (nodeBuilder != null) {
        canvas.save();
        canvas.translate(nodeRect.left, nodeRect.top);
        canvas.scale(nodeRect.width / node.size.width,
            nodeRect.height / node.size.height);
        final path = nodeBuilder!(node);
        canvas.drawPath(path, fillPaint);
        if (nodeStrokeWidth > 0) canvas.drawPath(path, strokePaint);
        canvas.restore();
      } else {
        final rrect = RRect.fromRectAndRadius(
            nodeRect, Radius.circular(nodeBorderRadius));
        canvas.drawRRect(rrect, fillPaint);
        if (nodeStrokeWidth > 0) canvas.drawRRect(rrect, strokePaint);
      }
    }
  }

  void _drawViewportMask(Canvas canvas, Size size, MiniMapTransform transform) {
    final canvasTransform = controller.transformationController.value;
    final canvasScale = canvasTransform.getMaxScaleOnAxis();
    if (canvasScale <= 0) return;

    final viewportSize = Size(controller.canvasWidth, controller.canvasHeight);
    final translation = canvasTransform.getTranslation();

    final viewportInCanvas = Rect.fromLTWH(
      -translation.x / canvasScale,
      -translation.y / canvasScale,
      viewportSize.width / canvasScale,
      viewportSize.height / canvasScale,
    );

    final viewportInMiniMap = Rect.fromLTWH(
      viewportInCanvas.left * transform.scale + transform.offsetX,
      viewportInCanvas.top * transform.scale + transform.offsetY,
      viewportInCanvas.width * transform.scale,
      viewportInCanvas.height * transform.scale,
    );

    final clampedViewportRect = Rect.fromLTRB(
      viewportInMiniMap.left.clamp(0.0, size.width),
      viewportInMiniMap.top.clamp(0.0, size.height),
      viewportInMiniMap.right.clamp(0.0, size.width),
      viewportInMiniMap.bottom.clamp(0.0, size.height),
    );

    final maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRect(clampedViewportRect),
    );

    canvas.drawPath(maskPath, Paint()..color = maskColor);

    if (maskStrokeWidth > 0) {
      canvas.drawRect(
        clampedViewportRect,
        Paint()
          ..color = maskStrokeColor
          ..strokeWidth = maskStrokeWidth
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(MiniMapPainter oldDelegate) => true;

  // --- Static Helper Methods ---

  static Rect getNodeRect(FlowNode node, MiniMapTransform transform) {
    return Rect.fromLTWH(
      node.position.dx * transform.scale + transform.offsetX,
      node.position.dy * transform.scale + transform.offsetY,
      node.size.width * transform.scale,
      node.size.height * transform.scale,
    );
  }

  static Offset fromMiniMapToCanvas(
      Offset miniMapPosition, MiniMapTransform transform) {
    if (transform.scale == 0) return Offset.zero;
    return Offset(
      (miniMapPosition.dx - transform.offsetX) / transform.scale,
      (miniMapPosition.dy - transform.offsetY) / transform.scale,
    );
  }

  static MiniMapTransform calculateTransform(
      Rect contentBounds, Size minimapSize) {
    if (contentBounds.isEmpty) {
      return MiniMapTransform(
          scale: 1.0, offsetX: 0.0, offsetY: 0.0, contentBounds: contentBounds);
    }

    const padding = 10.0;
    final availableWidth = minimapSize.width - 2 * padding;
    final availableHeight = minimapSize.height - 2 * padding;

    final scaleX = availableWidth / contentBounds.width;
    final scaleY = availableHeight / contentBounds.height;
    final scale = min(scaleX, scaleY);

    final scaledContentWidth = contentBounds.width * scale;
    final scaledContentHeight = contentBounds.height * scale;

    final offsetX = (minimapSize.width - scaledContentWidth) / 2 -
        contentBounds.left * scale;
    final offsetY = (minimapSize.height - scaledContentHeight) / 2 -
        contentBounds.top * scale;

    return MiniMapTransform(
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      contentBounds: contentBounds,
    );
  }
}

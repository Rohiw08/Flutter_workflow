import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import 'package:flutter_flow_canvas/src/core/models/minimap_transform.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

class MiniMapPainter extends CustomPainter {
  final FlowCanvasController controller;
  final FlowCanvasTheme theme;
  final MiniMapNodeColorFunc? nodeColor;
  final MiniMapNodeColorFunc? nodeStrokeColor;
  final MiniMapNodeBuilder? nodeBuilder;

  final Size minimapSize;

  MiniMapPainter({
    required this.controller,
    this.nodeColor,
    this.nodeStrokeColor,
    this.nodeBuilder,
    required this.minimapSize,
  })  : theme =
            controller.interactiveViewerKey?.currentContext?.flowCanvasTheme ??
                FlowCanvasTheme.light(), // Safely get theme
        super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Original logic preserved
    if (controller.nodes.isEmpty) return;

    final transform =
        calculateTransform(controller.getNodesBounds(), minimapSize);
    if (transform.scale <= 0) return;

    _drawNodes(canvas, transform);
    _drawViewportMask(canvas, size, transform);
  }

  void _drawNodes(Canvas canvas, MiniMapTransform transform) {
    // UPDATED: Use colors and properties from the hierarchical miniMap theme
    final minimapTheme = theme.miniMap;

    for (final node in controller.nodes) {
      // Allow override from widget, but fall back to the theme colors
      final fillColor = nodeColor?.call(node) ??
          (node.isSelected
              ? minimapTheme.selectedNodeColor
              : minimapTheme.nodeColor);
      final strokeColor =
          nodeStrokeColor?.call(node) ?? minimapTheme.nodeStrokeColor;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = minimapTheme.nodeStrokeWidth;

      final nodeRect = getNodeRect(node, transform);

      if (nodeBuilder != null) {
        // Original logic preserved
        canvas.save();
        canvas.translate(nodeRect.left, nodeRect.top);
        if (node.size.width > 0 && node.size.height > 0) {
          canvas.scale(nodeRect.width / node.size.width,
              nodeRect.height / node.size.height);
        }
        final path = nodeBuilder!(node);
        canvas.drawPath(path, fillPaint);
        if (minimapTheme.nodeStrokeWidth > 0) {
          canvas.drawPath(path, strokePaint);
        }
        canvas.restore();
      } else {
        final rrect = RRect.fromRectAndRadius(
            nodeRect, Radius.circular(minimapTheme.borderRadius));
        canvas.drawRRect(rrect, fillPaint);
        if (minimapTheme.nodeStrokeWidth > 0) {
          canvas.drawRRect(rrect, strokePaint);
        }
      }
    }
  }

  void _drawViewportMask(Canvas canvas, Size size, MiniMapTransform transform) {
    // Original logic preserved
    final canvasTransform = controller.transformationController.value;
    final canvasScale = canvasTransform.getMaxScaleOnAxis();
    if (canvasScale <= 0) return;

    final viewportSize = Size(
        (controller.interactiveViewerKey?.currentContext?.size?.width ??
            controller.canvasWidth),
        (controller.interactiveViewerKey?.currentContext?.size?.height ??
            controller.canvasHeight));

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

    // UPDATED: Use maskColor from the theme
    canvas.drawPath(maskPath, Paint()..color = theme.miniMap.maskColor);

    // UPDATED: Use maskStrokeWidth and maskStrokeColor from the theme
    final maskStrokeWidth = theme.miniMap.maskStrokeWidth;
    if (maskStrokeWidth > 0) {
      canvas.drawRect(
        clampedViewportRect,
        Paint()
          ..color = theme.miniMap.maskStrokeColor
          ..strokeWidth = maskStrokeWidth
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(MiniMapPainter oldDelegate) => true;

  // Static Helper Methods are unchanged as they are not theme-related.
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

    if (contentBounds.width <= 0 || contentBounds.height <= 0) {
      return MiniMapTransform(
          scale: 0, offsetX: 0, offsetY: 0, contentBounds: contentBounds);
    }

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

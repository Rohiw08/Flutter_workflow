import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/canvas_controller.dart';
import 'package:flutter_flow_canvas/src/core/models/minimap_transform.dart';
import 'package:flutter_flow_canvas/src/core/models/node.dart';
import 'package:flutter_flow_canvas/src/theme/components/minimap_theme.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/minimap.dart';

/// Enhanced MiniMap Painter with all React Flow features
class MiniMapPainter extends CustomPainter {
  final FlowCanvasController controller;
  final FlowCanvasMiniMapTheme theme;
  final MiniMapNodeColorFunc? nodeColor;
  final MiniMapNodeColorFunc? nodeStrokeColor;
  final MiniMapNodeBuilder? nodeBuilder;
  final Size minimapSize;
  final double offsetScale;

  Picture? _cachedNodesPicture;

  MiniMapPainter({
    required this.controller,
    required this.theme,
    this.nodeColor,
    this.nodeStrokeColor,
    this.nodeBuilder,
    required this.minimapSize,
    this.offsetScale = 1.0,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.nodes.isEmpty) return;

    // Use canvas bounds instead of just content bounds
    final canvasBounds = getCanvasBounds(controller);
    final transform = calculateTransform(
      canvasBounds,
      minimapSize,
      offsetScale,
    );

    if (transform.scale <= 0) return;

    _drawBackground(canvas, size);

    if (_cachedNodesPicture == null) {
      final recorder = PictureRecorder();
      final tempCanvas = Canvas(recorder);
      _drawNodes(tempCanvas, transform); // Draw to temp
      _cachedNodesPicture = recorder.endRecording();
    }
    canvas.drawPicture(_cachedNodesPicture!);

    _drawViewportMask(canvas, size, transform);
  }

  static Rect getCanvasBounds(FlowCanvasController controller) {
    final contentBounds = controller.getNodesBounds();

    // Get current viewport size
    final viewportSize = Size(
      controller.interactiveViewerKey?.currentContext?.size?.width ??
          controller.canvasWidth,
      controller.interactiveViewerKey?.currentContext?.size?.height ??
          controller.canvasHeight,
    );

    // Get current viewport position in canvas coordinates
    final canvasTransform = controller.transformationController.value;
    final canvasScale = canvasTransform.getMaxScaleOnAxis();
    final translation = canvasTransform.getTranslation();

    final currentViewport = Rect.fromLTWH(
      -translation.x / canvasScale,
      -translation.y / canvasScale,
      viewportSize.width / canvasScale,
      viewportSize.height / canvasScale,
    );

    // Combine content bounds and current viewport to get total canvas bounds
    if (contentBounds.isEmpty) {
      return currentViewport;
    }

    return Rect.fromLTRB(
      math.min(contentBounds.left, currentViewport.left),
      math.min(contentBounds.top, currentViewport.top),
      math.max(contentBounds.right, currentViewport.right),
      math.max(contentBounds.bottom, currentViewport.bottom),
    );
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = theme.backgroundColor;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  void _drawNodes(Canvas canvas, MiniMapTransform transform) {
    // Shared paints (created once)

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.nodeStrokeWidth;
    final regularFillPath = Path();
    final regularStrokePath = Path();
    final selectedFillPath = Path();
    final selectedStrokePath = Path();
    for (final node in controller.nodes) {
      final isSelected = node.isSelected;
      final fillColor = nodeColor?.call(node) ??
          (isSelected ? theme.selectedNodeColor : theme.nodeColor);
      final strokeColor = nodeStrokeColor?.call(node) ?? theme.nodeStrokeColor;
      final nodeRect = getNodeRect(node, transform);
      if (nodeBuilder != null) {
        // Reuse paints, just update color
        fillPaint.color = fillColor;
        strokePaint.color = strokeColor;
        _drawCustomNode(canvas, node, nodeRect, fillPaint, strokePaint);
      } else {
        final borderRadius = theme.nodeBorderRadius;
        final rrect =
            RRect.fromRectAndRadius(nodeRect, Radius.circular(borderRadius));
        final path = Path()..addRRect(rrect);
        if (isSelected) {
          selectedFillPath.addPath(path, Offset.zero);
          if (theme.nodeStrokeWidth > 0) {
            selectedStrokePath.addPath(path, Offset.zero);
          }
        } else {
          regularFillPath.addPath(path, Offset.zero);

          if (theme.nodeStrokeWidth > 0) {
            regularStrokePath.addPath(path, Offset.zero);
          }
        }
      }
    }

    // Draw batched regular nodes
    fillPaint.color = theme.nodeColor;
    canvas.drawPath(regularFillPath, fillPaint);
    strokePaint.color = theme.nodeStrokeColor;
    if (theme.nodeStrokeWidth > 0) {
      canvas.drawPath(regularStrokePath, strokePaint);
    }

    // Draw batched selected nodes
    fillPaint.color = theme.selectedNodeColor;
    canvas.drawPath(selectedFillPath, fillPaint);
    strokePaint.color = theme.nodeStrokeColor;
    if (theme.nodeStrokeWidth > 0) {
      canvas.drawPath(selectedStrokePath, strokePaint);
    }

    // Glow for selected nodes (reuse strokePaint)
    if (theme.nodeStrokeWidth > 0) {
      final glowPaint = Paint()
        ..color = theme.selectedNodeColor.withAlpha(76)
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.nodeStrokeWidth * 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawPath(selectedStrokePath, glowPaint);
    }
  }

  void _drawCustomNode(Canvas canvas, FlowNode node, Rect nodeRect,
      Paint fillPaint, Paint strokePaint) {
    canvas.save();
    canvas.translate(nodeRect.left, nodeRect.top);

    if (node.size.width > 0 && node.size.height > 0) {
      canvas.scale(
        nodeRect.width / node.size.width,
        nodeRect.height / node.size.height,
      );
    }

    final path = nodeBuilder!(node);
    canvas.drawPath(path, fillPaint);

    if (theme.nodeStrokeWidth > 0) {
      canvas.drawPath(path, strokePaint);
    }

    canvas.restore();
  }

  void _drawViewportMask(Canvas canvas, Size size, MiniMapTransform transform) {
    final canvasTransform = controller.transformationController.value;
    final canvasScale = canvasTransform.getMaxScaleOnAxis();
    if (canvasScale <= 0) return;

    final viewportSize = _getViewportSize();
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

    // Skip if viewport has zero area after clamping
    if (clampedViewportRect.isEmpty) return;

    // Create RRect for all viewport operations (use theme for radius)
    final viewportRRect = RRect.fromRectAndRadius(
      clampedViewportRect,
      Radius.circular(theme.viewportBorderRadius),
    );

    // --- Draw mask overlay with viewport hole ---
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Draw full tinted overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = theme.maskColor,
    );

    // Punch out the viewport (transparent hole)
    canvas.drawRect(
      clampedViewportRect,
      Paint()..blendMode = BlendMode.clear,
    );

    canvas.restore();

    // --- Fill viewport with inner color (NEW) ---
    if (theme.viewportInnerColor != Colors.transparent &&
        theme.viewportInnerColor.a > 0) {
      final innerColorPaint = Paint()
        ..color = theme.viewportInnerColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(viewportRRect, innerColorPaint);
    }

    // --- Border styling around viewport ---
    if (theme.maskStrokeWidth > 0) {
      final borderPaint = Paint()
        ..color = theme.maskStrokeColor
        ..strokeWidth = theme.maskStrokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(viewportRRect, borderPaint);
    }

    // --- Inner glow effect ---
    if (theme.viewportInnerGlowColor.a > 0) {
      double glowWidth =
          theme.maskStrokeWidth * theme.viewportInnerGlowWidthMultiplier;
      if (glowWidth <= 0) {
        // Fallback for when border is off but glow is desired
        glowWidth = theme.viewportInnerGlowWidthMultiplier;
      }

      final innerGlowPaint = Paint()
        ..color = theme.viewportInnerGlowColor
        ..strokeWidth = glowWidth
        ..style = PaintingStyle.stroke
        ..maskFilter = theme.viewportInnerGlowBlur > 0
            ? MaskFilter.blur(BlurStyle.normal, theme.viewportInnerGlowBlur)
            : null;

      // Clip to viewport to make glow "inner" (blur spills only inside the hole)
      canvas.save();
      canvas.clipRRect(viewportRRect);
      canvas.drawRRect(viewportRRect, innerGlowPaint);
      canvas.restore();
    }
  }

  Size _getViewportSize() {
    return Size(
      controller.interactiveViewerKey?.currentContext?.size?.width ??
          controller.canvasWidth,
      controller.interactiveViewerKey?.currentContext?.size?.height ??
          controller.canvasHeight,
    );
  }

  @override
  bool shouldRepaint(MiniMapPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.theme != theme ||
        oldDelegate.nodeColor != nodeColor || // Function identity
        oldDelegate.nodeStrokeColor != nodeStrokeColor ||
        oldDelegate.nodeBuilder != nodeBuilder ||
        oldDelegate.minimapSize != minimapSize ||
        oldDelegate.offsetScale != offsetScale;
  }

  // Static Helper Methods
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
    Rect canvasBounds,
    Size minimapSize,
    double offsetScale,
  ) {
    if (canvasBounds.isEmpty) {
      return MiniMapTransform(
        scale: 1.0 * offsetScale,
        offsetX: 0.0,
        offsetY: 0.0,
        contentBounds: canvasBounds,
      );
    }

    const padding = 10.0;
    final availableWidth = minimapSize.width - 2 * padding;
    final availableHeight = minimapSize.height - 2 * padding;

    if (canvasBounds.width <= 0 || canvasBounds.height <= 0) {
      return MiniMapTransform(
        scale: 0,
        offsetX: 0,
        offsetY: 0,
        contentBounds: canvasBounds,
      );
    }

    final scaleX = availableWidth / canvasBounds.width;
    final scaleY = availableHeight / canvasBounds.height;
    final scale = math.min(scaleX, scaleY) * offsetScale;

    final scaledContentWidth = canvasBounds.width * scale;
    final scaledContentHeight = canvasBounds.height * scale;

    final offsetX = (minimapSize.width - scaledContentWidth) / 2 -
        canvasBounds.left * scale;
    final offsetY = (minimapSize.height - scaledContentHeight) / 2 -
        canvasBounds.top * scale;

    if (availableWidth <= 0 || availableHeight <= 0) {
      return MiniMapTransform(
        scale: 0,
        offsetX: 0,
        offsetY: 0,
        contentBounds: canvasBounds,
      );
    }

    return MiniMapTransform(
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
      contentBounds: canvasBounds,
    );
  }
}

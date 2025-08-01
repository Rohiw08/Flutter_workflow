import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../../core/canvas_controller.dart';
import '../../core/models/node.dart';
import '../../core/providers.dart';

// --- Callbacks for Custom Styling and Interaction ---

/// A function that returns a color for a given node.
typedef MiniMapNodeColorFunc = Color? Function(FlowNode node);

/// A function that returns a class name for a given node (for potential future use).
typedef MiniMapNodeClassFunc = String Function(FlowNode node);

/// A custom builder function to render a node in the minimap.
/// It should return a Path to be drawn.
typedef MiniMapNodeBuilder = Path Function(FlowNode node);

/// A callback for when a node in the minimap is clicked.
typedef MiniMapNodeOnClick = void Function(FlowNode node);

/// A miniature overview map of the canvas, with extensive customization.
class MiniMap extends ConsumerStatefulWidget {
  // --- Sizing and Positioning ---
  final double width;
  final double height;
  final Alignment alignment;
  final EdgeInsets margin;

  // --- Node Styling ---
  final MiniMapNodeColorFunc? nodeColor;
  final MiniMapNodeColorFunc? nodeStrokeColor;
  final double nodeBorderRadius;
  final double nodeStrokeWidth;
  final MiniMapNodeBuilder? nodeBuilder;

  // --- Mask (Viewport) Styling ---
  final Color maskColor;
  final Color maskStrokeColor;
  final double maskStrokeWidth;

  // --- Interactivity ---
  final bool pannable;
  final bool zoomable;
  final bool inversePan;
  final double zoomStep;
  final MiniMapNodeOnClick? onNodeClick;

  // --- Accessibility & Misc ---
  final String ariaLabel;
  final Color backgroundColor;

  const MiniMap({
    super.key,
    this.width = 200,
    this.height = 150,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
    this.nodeColor,
    this.nodeStrokeColor,
    this.nodeBorderRadius = 2.0,
    this.nodeStrokeWidth = 1.5,
    this.nodeBuilder,
    this.maskColor = const Color(0x99F0F2F5), // Semi-transparent light grey
    this.maskStrokeColor = Colors.grey,
    this.maskStrokeWidth = 1.0,
    this.pannable = true,
    this.zoomable = true,
    this.inversePan = false,
    this.zoomStep = 0.1,
    this.onNodeClick,
    this.ariaLabel = 'Mini map',
    this.backgroundColor = Colors.white,
  });

  @override
  ConsumerState<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends ConsumerState<MiniMap> {
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(flowControllerProvider);

    return Align(
      alignment: widget.alignment,
      child: Semantics(
        label: widget.ariaLabel,
        child: Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withAlpha(240),
            borderRadius: BorderRadius.circular(widget.nodeBorderRadius + 1),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.nodeBorderRadius),
            child: Listener(
              onPointerSignal: widget.zoomable ? _onPointerSignal : null,
              child: GestureDetector(
                onTapUp: (details) =>
                    _onTapUp(controller, details.localPosition),
                onPanStart: widget.pannable ? _onPanStart : null,
                onPanUpdate: widget.pannable ? _onPanUpdate : null,
                child: CustomPaint(
                  painter: _MiniMapPainter(
                    controller: controller,
                    nodeColor: widget.nodeColor,
                    nodeStrokeColor: widget.nodeStrokeColor,
                    nodeBorderRadius: widget.nodeBorderRadius,
                    nodeStrokeWidth: widget.nodeStrokeWidth,
                    nodeBuilder: widget.nodeBuilder,
                    maskColor: widget.maskColor,
                    maskStrokeColor: widget.maskStrokeColor,
                    maskStrokeWidth: widget.maskStrokeWidth,
                    minimapSize: Size(widget.width, widget.height),
                  ),
                  size: Size(widget.width, widget.height),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  MiniMapTransform _calculateTransform(FlowCanvasController controller) {
    if (controller.nodes.isEmpty) {
      return MiniMapTransform(
        scale: 1.0,
        offsetX: 0.0,
        offsetY: 0.0,
        contentBounds: Rect.zero,
      );
    }

    final contentBounds = controller.getNodesBounds();
    final minimapSize = Size(widget.width, widget.height);

    if (contentBounds.width <= 0 || contentBounds.height <= 0) {
      return MiniMapTransform(
        scale: 1.0,
        offsetX: 0.0,
        offsetY: 0.0,
        contentBounds: contentBounds,
      );
    }

    // Calculate scale to fit content in minimap with some padding
    const padding = 10.0;
    final availableWidth = minimapSize.width - 2 * padding;
    final availableHeight = minimapSize.height - 2 * padding;

    final scaleX = availableWidth / contentBounds.width;
    final scaleY = availableHeight / contentBounds.height;
    final scale = min(scaleX, scaleY);

    // Calculate offset to center content in minimap
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

  void _onTapUp(FlowCanvasController controller, Offset localPosition) {
    final transform = _calculateTransform(controller);

    // Hit-test for nodes first (in reverse order for proper layering)
    for (final node in controller.nodes.reversed) {
      final nodeRect = Rect.fromLTWH(
        node.position.dx * transform.scale + transform.offsetX,
        node.position.dy * transform.scale + transform.offsetY,
        node.size.width * transform.scale,
        node.size.height * transform.scale,
      );

      if (nodeRect.contains(localPosition)) {
        widget.onNodeClick?.call(node);
        return;
      }
    }

    // If no node was clicked, navigate the canvas to the clicked position
    if (transform.scale > 0) {
      final canvasX = (localPosition.dx - transform.offsetX) / transform.scale;
      final canvasY = (localPosition.dy - transform.offsetY) / transform.scale;

      // Get current viewport size to center properly
      final currentTransform = controller.transformationController.value;
      final currentScale = currentTransform.getMaxScaleOnAxis();

      // Estimate viewport size (this should ideally come from the canvas widget)
      const viewportWidth = 800.0; // You might want to make this configurable
      const viewportHeight = 600.0;

      final viewportCenterX = viewportWidth / 2 / currentScale;
      final viewportCenterY = viewportHeight / 2 / currentScale;

      final targetX = canvasX - viewportCenterX;
      final targetY = canvasY - viewportCenterY;

      final newTransform = Matrix4.identity()
        ..scale(currentScale)
        ..translate(-targetX * currentScale, -targetY * currentScale);

      controller.transformationController.value = newTransform;
    }
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;

    final controller = ref.read(flowControllerProvider);
    final transform = _calculateTransform(controller);

    if (transform.scale <= 0) return;

    final delta = widget.inversePan ? details.delta : -details.delta;
    final canvasDelta =
        Offset(delta.dx / transform.scale, delta.dy / transform.scale);

    // Apply the pan to the main canvas
    final currentMatrix = controller.transformationController.value.clone();
    currentMatrix.translate(canvasDelta.dx, canvasDelta.dy);
    controller.transformationController.value = currentMatrix;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final controller = ref.read(flowControllerProvider);
      final transform = _calculateTransform(controller);

      if (transform.scale <= 0) return;

      // Convert minimap position to canvas position
      final canvasPosition = Offset(
        (event.localPosition.dx - transform.offsetX) / transform.scale,
        (event.localPosition.dy - transform.offsetY) / transform.scale,
      );

      final zoomDelta = -event.scrollDelta.dy * 0.001 * widget.zoomStep;
      final currentScale =
          controller.transformationController.value.getMaxScaleOnAxis();
      final newScale = (currentScale + zoomDelta).clamp(0.1, 2.0);

      if (newScale != currentScale) {
        final scaleChange = newScale / currentScale;

        // Calculate the position that should remain fixed during zoom
        final currentTransform = controller.transformationController.value;

        // Apply zoom with the canvas position as the focal point
        final newTransform = Matrix4.identity()
          ..translate(canvasPosition.dx * currentScale,
              canvasPosition.dy * currentScale)
          ..scale(scaleChange)
          ..translate(-canvasPosition.dx * currentScale,
              -canvasPosition.dy * currentScale)
          ..multiply(currentTransform);

        controller.transformationController.value = newTransform;
      }
    }
  }
}

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

class _MiniMapPainter extends CustomPainter {
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

  _MiniMapPainter({
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

    final transform = _calculateTransform();
    if (transform.scale <= 0) return;

    // Draw nodes
    _drawNodes(canvas, transform);

    // Draw viewport mask
    _drawViewportMask(canvas, size, transform);
  }

  MiniMapTransform _calculateTransform() {
    final contentBounds = controller.getNodesBounds();

    if (contentBounds.width <= 0 || contentBounds.height <= 0) {
      return MiniMapTransform(
        scale: 1.0,
        offsetX: 0.0,
        offsetY: 0.0,
        contentBounds: contentBounds,
      );
    }

    // Calculate scale to fit content in minimap with padding
    const padding = 10.0;
    final availableWidth = minimapSize.width - 2 * padding;
    final availableHeight = minimapSize.height - 2 * padding;

    final scaleX = availableWidth / contentBounds.width;
    final scaleY = availableHeight / contentBounds.height;
    final scale = min(scaleX, scaleY);

    // Calculate offset to center content
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

  void _drawNodes(Canvas canvas, MiniMapTransform transform) {
    final defaultNodeColor =
        nodeColor?.call(FlowNode.empty()) ?? Colors.blue.shade400;
    final defaultStrokeColor =
        nodeStrokeColor?.call(FlowNode.empty()) ?? Colors.blue.shade600;

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

      // Calculate node position and size in minimap coordinates
      final nodeX = node.position.dx * transform.scale + transform.offsetX;
      final nodeY = node.position.dy * transform.scale + transform.offsetY;
      final nodeWidth = node.size.width * transform.scale;
      final nodeHeight = node.size.height * transform.scale;

      if (nodeBuilder != null) {
        // Use custom node builder
        canvas.save();
        canvas.translate(nodeX, nodeY);
        canvas.scale(transform.scale);
        final path = nodeBuilder!(node);
        canvas.drawPath(path, fillPaint);
        if (nodeStrokeWidth > 0) {
          canvas.drawPath(path, strokePaint);
        }
        canvas.restore();
      } else {
        // Default rectangular node
        final nodeRect = Rect.fromLTWH(nodeX, nodeY, nodeWidth, nodeHeight);
        final rrect = RRect.fromRectAndRadius(
          nodeRect,
          Radius.circular(nodeBorderRadius),
        );

        canvas.drawRRect(rrect, fillPaint);
        if (nodeStrokeWidth > 0) {
          canvas.drawRRect(rrect, strokePaint);
        }
      }
    }
  }

  void _drawViewportMask(Canvas canvas, Size size, MiniMapTransform transform) {
    // Get the current viewport bounds in canvas coordinates
    final canvasTransform = controller.transformationController.value;
    final canvasScale = canvasTransform.getMaxScaleOnAxis();

    if (canvasScale <= 0) return;

    // Estimate viewport size (this should ideally come from the actual canvas widget)
    const viewportWidth = 800.0; // You might want to make this configurable
    const viewportHeight = 600.0;

    // Calculate viewport bounds in canvas coordinates
    final translation = canvasTransform.getTranslation();
    final viewportLeft = -translation.x / canvasScale;
    final viewportTop = -translation.y / canvasScale;
    final viewportRight = viewportLeft + viewportWidth / canvasScale;
    final viewportBottom = viewportTop + viewportHeight / canvasScale;

    // Transform viewport bounds to minimap coordinates
    final minimapViewportLeft =
        viewportLeft * transform.scale + transform.offsetX;
    final minimapViewportTop =
        viewportTop * transform.scale + transform.offsetY;
    final minimapViewportWidth =
        (viewportRight - viewportLeft) * transform.scale;
    final minimapViewportHeight =
        (viewportBottom - viewportTop) * transform.scale;

    final viewportRect = Rect.fromLTWH(
      minimapViewportLeft,
      minimapViewportTop,
      minimapViewportWidth,
      minimapViewportHeight,
    );

    // Clamp viewport rect to minimap bounds
    final clampedViewportRect = Rect.fromLTRB(
      viewportRect.left.clamp(0.0, size.width),
      viewportRect.top.clamp(0.0, size.height),
      viewportRect.right.clamp(0.0, size.width),
      viewportRect.bottom.clamp(0.0, size.height),
    );

    // Draw mask (everything except the viewport)
    final maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRect(clampedViewportRect),
    );

    canvas.drawPath(maskPath, Paint()..color = maskColor);

    // Draw viewport border
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
  bool shouldRepaint(_MiniMapPainter oldDelegate) {
    return true; // For simplicity, always repaint. Can be optimized later.
  }
}

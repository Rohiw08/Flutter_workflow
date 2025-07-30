import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/canvas_controller.dart';
import '../../core/providers.dart';

/// A miniature overview map of the canvas showing nodes and viewport
class MiniMap extends ConsumerWidget {
  /// Width of the minimap
  final double width;

  /// Height of the minimap
  final double height;

  /// Color for regular nodes
  final Color nodeColor;

  /// Color for selected nodes
  final Color selectedNodeColor;

  /// Color for viewport indicator
  final Color viewportColor;

  /// Background color of minimap
  final Color backgroundColor;

  /// Whether the minimap is interactive (click to navigate)
  final bool interactive;

  /// Corner radius for minimap
  final double borderRadius;

  /// Position of minimap on screen
  final Alignment alignment;

  /// Margin from screen edges
  final EdgeInsets margin;

  const MiniMap({
    super.key,
    this.width = 200,
    this.height = 150,
    this.nodeColor = Colors.blueGrey,
    this.selectedNodeColor = Colors.blue,
    this.viewportColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.interactive = true,
    this.borderRadius = 8.0,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);

    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor.withAlpha(240),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 1),
          child: Stack(
            children: [
              // Minimap content
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _MiniMapPainter(
                      controller: controller,
                      canvasSize:
                          Size(controller.canvasWidth, controller.canvasHeight),
                      widgetSize: Size(width, height),
                      nodeColor: nodeColor,
                      selectedNodeColor: selectedNodeColor,
                      viewportColor: viewportColor,
                    ),
                    size: Size(width, height),
                  );
                },
              ),

              // Title overlay
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Mini Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Stats overlay
              Positioned(
                bottom: 6,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      return Text(
                        '${controller.nodes.length} nodes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Interactive overlay
              if (interactive)
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) => _navigateToPosition(
                      controller,
                      details.localPosition,
                      Size(width, height),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate canvas to clicked position on minimap
  void _navigateToPosition(
      FlowCanvasController controller, Offset localPosition, Size miniMapSize) {
    final canvasSize = Size(controller.canvasWidth, controller.canvasHeight);

    // Convert minimap position to canvas coordinates
    final scaleX = canvasSize.width / miniMapSize.width;
    final scaleY = canvasSize.height / miniMapSize.height;

    final canvasPosition = Offset(
      localPosition.dx * scaleX,
      localPosition.dy * scaleY,
    );

    // Center the view on this position
    final currentScale =
        controller.transformationController.value.getMaxScaleOnAxis();
    final newTransform = Matrix4.identity()
      ..translate(-canvasPosition.dx * currentScale + miniMapSize.width / 2,
          -canvasPosition.dy * currentScale + miniMapSize.height / 2)
      ..scale(currentScale);

    controller.transformationController.value = newTransform;
  }
}

/// Custom painter for minimap content
class _MiniMapPainter extends CustomPainter {
  final FlowCanvasController controller;
  final Size canvasSize;
  final Size widgetSize;
  final Color nodeColor;
  final Color selectedNodeColor;
  final Color viewportColor;

  _MiniMapPainter({
    required this.controller,
    required this.canvasSize,
    required this.widgetSize,
    required this.nodeColor,
    required this.selectedNodeColor,
    required this.viewportColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = widgetSize.width / canvasSize.width;
    final scaleY = widgetSize.height / canvasSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Draw edges first (behind nodes)
    _drawEdges(canvas, scale);

    // Draw nodes
    _drawNodes(canvas, scale);

    // Draw viewport indicator
    _drawViewport(canvas, scale);
  }

  void _drawEdges(Canvas canvas, double scale) {
    final edgePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final edge in controller.edges) {
      final sourceNode = controller.getNode(edge.sourceNodeId);
      final targetNode = controller.getNode(edge.targetNodeId);

      if (sourceNode != null && targetNode != null) {
        final start = Offset(
          (sourceNode.position.dx + sourceNode.size.width / 2) * scale,
          (sourceNode.position.dy + sourceNode.size.height / 2) * scale,
        );
        final end = Offset(
          (targetNode.position.dx + targetNode.size.width / 2) * scale,
          (targetNode.position.dy + targetNode.size.height / 2) * scale,
        );

        canvas.drawLine(start, end, edgePaint);
      }
    }
  }

  void _drawNodes(Canvas canvas, double scale) {
    final normalNodePaint = Paint()..color = nodeColor;
    final selectedNodePaint = Paint()..color = selectedNodeColor;

    for (final node in controller.nodes) {
      final rect = Rect.fromLTWH(
        node.position.dx * scale,
        node.position.dy * scale,
        node.size.width * scale,
        node.size.height * scale,
      );

      final paint = node.isSelected ? selectedNodePaint : normalNodePaint;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(2 * scale)),
        paint,
      );
    }
  }

  void _drawViewport(Canvas canvas, double scale) {
    final viewportPaint = Paint()
      ..color = viewportColor.withAlpha(50)
      ..style = PaintingStyle.fill;

    final viewportBorderPaint = Paint()
      ..color = viewportColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final matrix = controller.transformationController.value;
    final viewportRect =
        controller.transformationController.toScene(Offset.zero);
    final currentScale = matrix.getMaxScaleOnAxis();

    final viewportSize = Size(
      widgetSize.width / currentScale,
      widgetSize.height / currentScale,
    );

    final miniMapViewPort = Rect.fromLTWH(
      -viewportRect.dx * scale,
      -viewportRect.dy * scale,
      viewportSize.width * scale,
      viewportSize.height * scale,
    );

    // Clamp viewport to minimap bounds
    final clampedViewport = Rect.fromLTWH(
      miniMapViewPort.left.clamp(0.0, widgetSize.width),
      miniMapViewPort.top.clamp(0.0, widgetSize.height),
      (miniMapViewPort.width)
          .clamp(0.0, widgetSize.width - miniMapViewPort.left),
      (miniMapViewPort.height)
          .clamp(0.0, widgetSize.height - miniMapViewPort.top),
    );

    canvas.drawRect(clampedViewport, viewportPaint);
    canvas.drawRect(clampedViewport, viewportBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

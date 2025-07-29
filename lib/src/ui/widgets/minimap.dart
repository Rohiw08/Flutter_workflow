import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/canvas_controller.dart';
import '../../core/providers.dart';

class MiniMap extends ConsumerWidget {
  final double width;
  final double height;
  final Color nodeColor;
  final Color viewportColor;

  const MiniMap({
    super.key,
    this.width = 200,
    this.height = 150,
    this.nodeColor = Colors.blueGrey,
    this.viewportColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _MiniMapPainter(
                  controller: controller,
                  canvasSize: const Size(5000, 5000),
                  widgetSize: Size(width, height),
                  nodeColor: nodeColor,
                  viewportColor: viewportColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final FlowCanvasController controller;
  final Size canvasSize;
  final Size widgetSize;
  final Color nodeColor;
  final Color viewportColor;

  _MiniMapPainter({
    required this.controller,
    required this.canvasSize,
    required this.widgetSize,
    required this.nodeColor,
    required this.viewportColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = widgetSize.width / canvasSize.width;
    final scaleY = widgetSize.height / canvasSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final nodePaint = Paint()..color = nodeColor;

    // Draw nodes
    for (final node in controller.nodes) {
      final rect = Rect.fromLTWH(
        node.position.dx * scale,
        node.position.dy * scale,
        node.size.width * scale,
        node.size.height * scale,
      );
      canvas.drawRect(rect, nodePaint);
    }

    // Draw viewport
    final viewportPaint = Paint()
      ..color = viewportColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final viewportBorderPaint = Paint()
      ..color = viewportColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final viewportRect = controller.transformationController.toScene(
      Offset.zero,
    );
    final viewportSize = Size(
      size.width / controller.transformationController.value.getMaxScaleOnAxis(),
      size.height / controller.transformationController.value.getMaxScaleOnAxis(),
    );
    
    final miniMapViewPort = Rect.fromLTWH(
        -viewportRect.dx * scale,
        -viewportRect.dy * scale,
        viewportSize.width * scale,
        viewportSize.height * scale);

    canvas.drawRect(miniMapViewPort, viewportPaint);
    canvas.drawRect(miniMapViewPort, viewportBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
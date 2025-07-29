import 'package:flutter/material.dart';
import 'package:flutter_workflow/flutter_flow_canvas.dart';
import 'package:flutter_workflow/src/utils/edge_path_creator.dart';

class FlowPainter extends CustomPainter {
  final FlowCanvasController controller;

  FlowPainter({required this.controller});

  Offset? _getHandlePosition(String nodeId, String handleId) {
    final key = controller.handleRegistry['$nodeId/$handleId'];
    if (key?.currentContext != null) {
      final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      // Get the center of the handle widget
      final position = renderBox.localToGlobal(
        Offset(size.width / 2, size.height / 2),
      );
      // Convert the global screen position to a position on the canvas scene
      return controller.transformationController.toScene(position);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = controller.transformationController.value;
    canvas.transform(matrix.storage);

    // Draw edges
    final edgePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final edge in controller.edges) {
      final start = _getHandlePosition(edge.sourceNodeId, edge.sourceHandleId);
      final end = _getHandlePosition(edge.targetNodeId, edge.targetHandleId);

      if (start != null && end != null) {
        final path = EdgePathCreator.createPath(edge.type, start, end);
        canvas.drawPath(path, edge.paint ?? edgePaint);
      }
    }

    // Draw in-progress connection
    if (controller.connection != null) {
      final connection = controller.connection!;
      // The start position is already in global coordinates, convert to scene
      final start = controller.transformationController.toScene(
        connection.startPosition,
      );
      // The end position is also global, convert to scene
      final end = controller.transformationController.toScene(
        connection.endPosition,
      );
      final path = EdgePathCreator.createPath(EdgeType.bezier, start, end);
      canvas.drawPath(path, edgePaint..color = Colors.blueAccent);
    }

    // Draw nodes (cached images)
    for (final node in controller.nodes) {
      if (node.cachedImage != null) {
        canvas.drawImage(node.cachedImage!, node.position, Paint());
      }

      // Draw selection border and resize handles
      if (node.isSelected) {
        final borderPaint = Paint()
          ..color = Colors.blue
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawRect(node.rect.inflate(2.0), borderPaint);

        // Draw resize handles (simple circles for now)
        final handlePaint = Paint()..color = Colors.blue;
        canvas.drawCircle(node.rect.bottomRight, 6, handlePaint);
      }
    }

    // Draw selection rectangle
    if (controller.selectionRect != null) {
      final selectionPaint = Paint()
        ..color = Colors.blue[50]!
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRect(controller.selectionRect!, selectionPaint);
      canvas.drawRect(controller.selectionRect!, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

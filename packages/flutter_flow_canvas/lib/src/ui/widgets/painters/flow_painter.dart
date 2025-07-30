import 'package:flutter/material.dart';
import '../../../core/canvas_controller.dart';
import '../../../core/models/edge.dart';
import '../../../utils/edge_path_creator.dart';

class FlowPainter extends CustomPainter {
  final FlowCanvasController controller;

  FlowPainter({required this.controller});

  Offset? _getHandlePosition(String nodeId, String handleId) {
    final globalPos = controller.getHandleGlobalPosition(nodeId, handleId);
    if (globalPos != null) {
      return controller.transformationController.toScene(globalPos);
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = controller.transformationController.value;
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final canvasRect =
        MatrixUtils.transformRect(matrix.clone()..invert(), screenRect);

    // ================================= //
    //           CHANGE START            //
    // ================================= //

    // Draw edges first
    _drawEdges(canvas, canvasRect);

    // Then draw nodes on top
    _drawNodes(canvas, canvasRect);

    // ================================= //
    //            CHANGE END             //
    // ================================= //

    // Draw in-progress connection
    _drawConnection(canvas);

    // Draw selection rectangle
    _drawSelectionRect(canvas, matrix);
  }

  void _drawNodes(Canvas canvas, Rect canvasRect) {
    final nodePaint = Paint();
    for (final node in controller.nodes) {
      if (node.cachedImage != null) {
        // Culling check
        if (!canvasRect.overlaps(node.rect.inflate(100))) continue;

        canvas.drawImage(node.cachedImage!, node.position, nodePaint);
      }
    }
  }

  void _drawEdges(Canvas canvas, Rect canvasRect) {
    final edgePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final selectedEdgePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final edge in controller.edges) {
      final start = _getHandlePosition(edge.sourceNodeId, edge.sourceHandleId);
      final end = _getHandlePosition(edge.targetNodeId, edge.targetHandleId);

      if (start != null && end != null) {
        // Check if edge should be culled
        final edgeRect = Rect.fromPoints(start, end);
        if (!canvasRect.overlaps(edgeRect.inflate(50))) continue;

        final path = EdgePathCreator.createPath(edge.type, start, end);

        // Determine if edge is selected (connected to selected node)
        final sourceSelected =
            controller.selectedNodes.contains(edge.sourceNodeId);
        final targetSelected =
            controller.selectedNodes.contains(edge.targetNodeId);
        final isSelected = sourceSelected || targetSelected;

        final paint =
            edge.paint ?? (isSelected ? selectedEdgePaint : edgePaint);
        canvas.drawPath(path, paint);

        // Draw arrow head
        _drawArrowHead(canvas, start, end, paint);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double arrowSize = 8.0;
    final direction = (end - start).direction;

    final arrowPoint1 = end + Offset.fromDirection(direction + 2.8, arrowSize);
    final arrowPoint2 = end + Offset.fromDirection(direction - 2.8, arrowSize);

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke; // Reset to stroke
  }

  void _drawConnection(Canvas canvas) {
    if (controller.connection != null) {
      final connection = controller.connection!;
      final start =
          controller.transformationController.toScene(connection.startPosition);
      final end =
          controller.transformationController.toScene(connection.endPosition);

      final connectionPaint = Paint()
        ..color = connection.hoveredTargetKey != null
            ? Colors.green
            : Colors.blueAccent
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final path = EdgePathCreator.createPath(EdgeType.bezier, start, end);
      canvas.drawPath(path, connectionPaint);

      // Draw connection end indicator
      final endPaint = Paint()
        ..color = connection.hoveredTargetKey != null
            ? Colors.green
            : Colors.blueAccent
        ..style = PaintingStyle.fill;

      canvas.drawCircle(end, 6.0, endPaint);
    }
  }

  void _drawSelectionRect(Canvas canvas, Matrix4 matrix) {
    if (controller.selectionRect != null) {
      final selectionPaint = Paint()
        ..color = Colors.blue.withAlpha(25) // Using withAlpha as requested
        ..style = PaintingStyle.fill;

      canvas.drawRect(controller.selectionRect!, selectionPaint);

      // Draw dashed border manually
      _drawDashedRect(canvas, controller.selectionRect!, Colors.blue,
          1.0 / matrix.getMaxScaleOnAxis());
    }
  }

  void _drawDashedRect(
      Canvas canvas, Rect rect, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashLength = 5.0;
    const double gapLength = 5.0;

    // Top edge
    _drawDashedLine(
        canvas, rect.topLeft, rect.topRight, paint, dashLength, gapLength);
    // Right edge
    _drawDashedLine(
        canvas, rect.topRight, rect.bottomRight, paint, dashLength, gapLength);
    // Bottom edge
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, paint,
        dashLength, gapLength);
    // Left edge
    _drawDashedLine(
        canvas, rect.bottomLeft, rect.topLeft, paint, dashLength, gapLength);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      double dashLength, double gapLength) {
    final distance = (end - start).distance;
    final unitVector = (end - start) / distance;

    double currentDistance = 0.0;
    bool isDash = true;

    while (currentDistance < distance) {
      final segmentLength = isDash ? dashLength : gapLength;
      final nextDistance =
          (currentDistance + segmentLength).clamp(0.0, distance);

      if (isDash) {
        final segmentStart = start + unitVector * currentDistance;
        final segmentEnd = start + unitVector * nextDistance;
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance = nextDistance;
      isDash = !isDash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

import '../../../utils/edge_path_creator.dart';

class FlowPainter extends CustomPainter {
  final FlowCanvasController controller;

  final Paint _nodePaint = Paint();
  late final Paint _selectionPaint = Paint()
    ..color = Colors.blue.withAlpha(25)
    ..style = PaintingStyle.fill;
  final Paint _edgePaint = Paint()
    ..color = Colors.grey.shade600
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;
  final Paint _selectedEdgePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;

  FlowPainter({required this.controller}) : super(repaint: controller);

  Offset? _getHandlePosition(String nodeId, String handleId) {
    // final handleKey = '$nodeId/$handleId';
    // print('=== HANDLE POSITION DEBUG for $handleKey ===');

    // Step 1: Check if handle is registered - use the connectionManager method
    final handleGlobalPos =
        controller.connectionManager.getHandleGlobalPosition(nodeId, handleId);
    // print('1. Handle global position from connectionManager: $handleGlobalPos');
    if (handleGlobalPos == null) {
      // print('   Handle not found or has no valid context/renderbox');
      return null;
    }

    // Step 2: Check InteractiveViewer key
    final ivKey = controller.interactiveViewerKey;
    // print('2. InteractiveViewer key exists: ${ivKey != null}');
    // print(
    //     '   InteractiveViewer context exists: ${ivKey?.currentContext != null}');

    if (ivKey?.currentContext == null) {
      // print('   ERROR: InteractiveViewer context is null!');
      return null;
    }

    // Step 3: Get InteractiveViewer position
    final ivRenderBox = ivKey!.currentContext!.findRenderObject() as RenderBox?;
    // print('3. InteractiveViewer RenderBox found: ${ivRenderBox != null}');
    if (ivRenderBox == null) {
      return null;
    }

    final ivGlobalPos = ivRenderBox.localToGlobal(Offset.zero);
    // print('   InteractiveViewer global position: $ivGlobalPos');

    // Step 4: Calculate relative position
    final handleViewportPos = handleGlobalPos - ivGlobalPos;
    // print('4. Handle viewport position: $handleViewportPos');

    // Step 5: Transform to scene coordinates
    final scenePos =
        controller.transformationController.toScene(handleViewportPos);
    // print('5. Final scene position: $scenePos');

    // print('=== END HANDLE POSITION DEBUG ===');
    return scenePos;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = controller.transformationController.value;
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final canvasRect =
        MatrixUtils.transformRect(matrix.clone()..invert(), screenRect);

    // Draw in optimal order for performance
    _drawNodes(canvas, canvasRect, matrix); // Pass matrix here
    _drawEdges(canvas, canvasRect);
    _drawConnection(canvas, matrix);
    _drawSelectionRect(canvas, matrix); // Pass matrix here
  }

  void _drawNodes(Canvas canvas, Rect canvasRect, Matrix4 matrix) {
    // Early exit if no nodes
    if (controller.nodes.isEmpty) return;

    final visibleNodes = <FlowNode>[];
    final selectedNodes = <FlowNode>[];

    for (final node in controller.nodes) {
      if (!canvasRect.overlaps(node.rect.inflate(100))) continue;
      visibleNodes.add(node);
      if (node.isSelected) {
        selectedNodes.add(node);
      }
    }

    // Draw all cached images in one batch
    for (final node in visibleNodes) {
      if (node.cachedImage != null) {
        canvas.drawImage(node.cachedImage!, node.position, _nodePaint);
      }
    }

    // // Draw selection borders in another batch
    // for (final node in selectedNodes) {
    //   canvas.drawRect(node.rect.inflate(1.0), _borderPaint);
    // }
  }

  void _drawEdges(Canvas canvas, Rect canvasRect) {
    // print('=== ENHANCED EDGE DEBUG ===');
    // Call this in your _drawEdges method
    // controller.connectionManager.debugHandleRegistration();
    // Use the controller's debug method instead of accessing private fields
    // controller.debugEdgeRendering();

    for (int i = 0; i < controller.edges.length; i++) {
      final edge = controller.edges[i];
      // print(
      //     '\n--- Drawing Edge $i: ${edge.sourceNodeId}/${edge.sourceHandleId} -> ${edge.targetNodeId}/${edge.targetHandleId} ---');

      // This will now print detailed debug info for each handle
      final start = _getHandlePosition(edge.sourceNodeId, edge.sourceHandleId);
      final end = _getHandlePosition(edge.targetNodeId, edge.targetHandleId);

      if (start != null && end != null) {
        // final edgeRect = Rect.fromPoints(start, end);
        // print('SUCCESS: Will draw edge from $start to $end');

        final isSelected =
            controller.selectedNodes.contains(edge.sourceNodeId) ||
                controller.selectedNodes.contains(edge.targetNodeId);
        final paint =
            edge.paint ?? (isSelected ? _selectedEdgePaint : _edgePaint);

        final path = EdgePathCreator.createPath(edge.pathType, start, end);

        final customPainter =
            controller.edgeRegistry.getPainter(edge.type ?? '');

        if (customPainter != null) {
          customPainter.paint(canvas, path, edge, paint);
        } else {
          canvas.drawPath(path, paint);
          _drawArrowHead(canvas, start, end, paint);
        }
      } else {
        // print('FAILED: start=$start, end=$end');
      }
    }
    // print('=== END ENHANCED EDGE DEBUG ===\n');
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

    final originalStyle = paint.style; // Store the original style
    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
    paint.style = originalStyle;
  }

  void _drawConnection(Canvas canvas, Matrix4 matrix) {
    final connection = controller.connectionManager.connection;
    if (connection == null) return;

    final ivKey = controller.interactiveViewerKey;

    // Ensure the InteractiveViewer key is available
    if (ivKey?.currentContext == null) return;

    final ivRenderBox = ivKey?.currentContext!.findRenderObject() as RenderBox;
    final ivGlobalPos = ivRenderBox.localToGlobal(Offset.zero);

    // --- Correctly transform the start position (the handle) ---
    final startViewportPos = connection.startPosition - ivGlobalPos;
    final start = controller.transformationController.toScene(startViewportPos);

    // --- Correctly transform the end position (the cursor) ---
    final endViewportPos = connection.endPosition - ivGlobalPos;
    final end = controller.transformationController.toScene(endViewportPos);

    // The rest of the drawing logic remains the same
    final connectionPaint = Paint()
      ..color =
          connection.hoveredTargetKey != null ? Colors.green : Colors.blueAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = EdgePathCreator.createPath(EdgePathType.bezier, start, end);
    canvas.drawPath(path, connectionPaint);

    final endPaint = Paint()
      ..color =
          connection.hoveredTargetKey != null ? Colors.green : Colors.blueAccent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(end, 6.0, endPaint);
  }

  void _drawSelectionRect(Canvas canvas, Matrix4 matrix) {
    final selectionRect = controller.selectionRect;
    if (selectionRect == null) return;

    canvas.drawRect(selectionRect, _selectionPaint);

    final strokeWidth = (1.0 / matrix.getMaxScaleOnAxis()).clamp(0.5, 3.0);
    _drawDashedRect(canvas, selectionRect, Colors.blue, strokeWidth);
  }

  void _drawDashedRect(
      Canvas canvas, Rect rect, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addPath(_createDashedLine(rect.topLeft, rect.topRight), Offset.zero)
      ..addPath(_createDashedLine(rect.topRight, rect.bottomRight), Offset.zero)
      ..addPath(
          _createDashedLine(rect.bottomRight, rect.bottomLeft), Offset.zero)
      ..addPath(_createDashedLine(rect.bottomLeft, rect.topLeft), Offset.zero);

    canvas.drawPath(path, paint);
  }

  Path _createDashedLine(Offset start, Offset end,
      [double dashLength = 5.0, double gapLength = 5.0]) {
    final path = Path();
    final distance = (end - start).distance;
    final unitVector = (end - start) / distance;
    double currentDistance = 0.0;
    while (currentDistance < distance) {
      path.moveTo(start.dx + unitVector.dx * currentDistance,
          start.dy + unitVector.dy * currentDistance);
      final nextDistance = currentDistance + dashLength;
      if (nextDistance < distance) {
        path.lineTo(start.dx + unitVector.dx * nextDistance,
            start.dy + unitVector.dy * nextDistance);
      } else {
        path.lineTo(end.dx, end.dy);
      }
      currentDistance = nextDistance + gapLength;
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant FlowPainter oldDelegate) {
    return oldDelegate.controller != controller;
  }
}

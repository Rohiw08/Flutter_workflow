import 'package:flutter/material.dart';


class EdgePainter extends CustomPainter {
  final List edges;
  final Map<String, GlobalKey> handleRegistry;
  final dynamic connectionState;
  final Matrix4 matrix;

  EdgePainter({
    required this.edges,
    required this.handleRegistry,
    required this.connectionState,
    required this.matrix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw established edges
    for (final edge in edges) {
      final sourceKey = handleRegistry["${edge.sourceNodeId}/${edge.sourceHandleId ?? ''}"];
      final targetKey = handleRegistry["${edge.targetNodeId}/${edge.targetHandleId ?? ''}"];

      if (sourceKey?.currentContext != null && targetKey?.currentContext != null) {
        final sourceRB = sourceKey!.currentContext!.findRenderObject() as RenderBox;
        final targetRB = targetKey!.currentContext!.findRenderObject() as RenderBox;
        final p1 = sourceRB.localToGlobal(sourceRB.size.center(Offset.zero));
        final p2 = targetRB.localToGlobal(targetRB.size.center(Offset.zero));
        final localP1 = MatrixUtils.transformPoint(matrix.clone()..invert(), p1);
        final localP2 = MatrixUtils.transformPoint(matrix.clone()..invert(), p2);
        canvas.drawLine(localP1, localP2, paint);
      }
    }

    // Draw the in-progress connection line
    if (connectionState != null) {
      final p1 = connectionState.startPosition;
      final p2 = connectionState.endPosition;
      final localP1 = MatrixUtils.transformPoint(matrix.clone()..invert(), p1);
      final localP2 = MatrixUtils.transformPoint(matrix.clone()..invert(), p2);
      paint.color = Colors.blueAccent;
      canvas.drawLine(localP1, localP2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant EdgePainter oldDelegate) {
    return edges != oldDelegate.edges ||
        handleRegistry != oldDelegate.handleRegistry ||
        connectionState != oldDelegate.connectionState ||
        matrix != oldDelegate.matrix;
  }
}
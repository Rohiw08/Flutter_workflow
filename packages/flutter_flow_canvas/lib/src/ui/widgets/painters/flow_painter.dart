import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/canvas_controller.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/core/models/node.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_utils.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';
import '../../../utils/edge_path_creator.dart';

class FlowPainter extends CustomPainter {
  final FlowCanvasController controller;
  final FlowCanvasTheme theme;

  FlowPainter({required this.controller})
      : theme =
            controller.interactiveViewerKey?.currentContext?.flowCanvasTheme ??
                FlowCanvasTheme.light(), // Safely get theme from context
        super(repaint: controller);

  Offset? _getHandlePosition(String nodeId, String handleId) {
    // Original logic preserved
    final handleGlobalPos =
        controller.connectionManager.getHandleGlobalPosition(nodeId, handleId);
    if (handleGlobalPos == null) {
      return null;
    }
    final ivKey = controller.interactiveViewerKey;
    if (ivKey?.currentContext == null) {
      return null;
    }
    final ivRenderBox = ivKey?.currentContext!.findRenderObject() as RenderBox?;
    if (ivRenderBox == null) {
      return null;
    }
    final ivGlobalPos = ivRenderBox.localToGlobal(Offset.zero);
    final handleViewportPos = handleGlobalPos - ivGlobalPos;
    final scenePos =
        controller.transformationController.toScene(handleViewportPos);
    return scenePos;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = controller.transformationController.value;
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final canvasRect =
        MatrixUtils.transformRect(matrix.clone()..invert(), screenRect);

    _drawNodes(canvas, canvasRect, matrix);
    _drawEdges(canvas, canvasRect);
    _drawConnection(canvas, matrix);
    _drawSelectionRect(canvas, matrix);
  }

  void _drawNodes(Canvas canvas, Rect canvasRect, Matrix4 matrix) {
    // Original logic preserved, _nodePaint is no longer needed here.
    if (controller.nodes.isEmpty) return;
    final visibleNodes = <FlowNode>[];
    for (final node in controller.nodes) {
      if (!canvasRect.overlaps(node.rect.inflate(100))) continue;
      visibleNodes.add(node);
    }
    for (final node in visibleNodes) {
      if (node.cachedImage != null) {
        // A simple paint object is fine here, as the node itself is a cached image.
        canvas.drawImage(node.cachedImage!, node.position, Paint());
      }
    }
  }

  void _drawEdges(Canvas canvas, Rect canvasRect) {
    for (int i = 0; i < controller.edges.length; i++) {
      final edge = controller.edges[i];
      final start = _getHandlePosition(edge.sourceNodeId, edge.sourceHandleId);
      final end = _getHandlePosition(edge.targetNodeId, edge.targetHandleId);

      if (start != null && end != null) {
        final isSelected =
            controller.selectedNodes.contains(edge.sourceNodeId) ||
                controller.selectedNodes.contains(edge.targetNodeId);

        // UPDATED: Use the theme to get the correct edge paint
        final paint = edge.paint ??
            FlowCanvasThemeUtils.getEdgePaint(theme, isSelected: isSelected);

        final path = EdgePathCreator.createPath(edge.pathType, start, end);
        final customPainter = controller.edgeRegistry.getPainter(edge.type);

        if (customPainter != null) {
          customPainter.paint(canvas, path, edge, paint);
        } else {
          canvas.drawPath(path, paint);
          _drawArrowHead(canvas, start, end, paint);
        }
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    // UPDATED: Use arrowHeadSize from the theme
    final double arrowSize = theme.edge.arrowHeadSize;
    final direction = (end - start).direction;

    final arrowPoint1 = end + Offset.fromDirection(direction + 2.8, arrowSize);
    final arrowPoint2 = end + Offset.fromDirection(direction - 2.8, arrowSize);

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    final originalStyle = paint.style;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, paint);
    paint.style = originalStyle;
  }

  void _drawConnection(Canvas canvas, Matrix4 matrix) {
    final connection = controller.connectionManager.connection;
    if (connection == null) return;

    final ivKey = controller.interactiveViewerKey;
    if (ivKey?.currentContext == null) return;

    final ivRenderBox = ivKey?.currentContext!.findRenderObject() as RenderBox;
    final ivGlobalPos = ivRenderBox.localToGlobal(Offset.zero);

    final startViewportPos = connection.startPosition - ivGlobalPos;
    final start = controller.transformationController.toScene(startViewportPos);

    final endViewportPos = connection.endPosition - ivGlobalPos;
    final end = controller.transformationController.toScene(endViewportPos);

    final bool isValidTarget = connection.hoveredTargetKey != null;

    // UPDATED: Use colors from the connection theme
    final connectionColor = isValidTarget
        ? theme.connection.validTargetColor
        : theme.connection.activeColor;

    final connectionPaint = Paint()
      ..color = connectionColor
      ..strokeWidth = theme.connection.strokeWidth
      ..style = PaintingStyle.stroke;

    final path = EdgePathCreator.createPath(EdgePathType.bezier, start, end);
    canvas.drawPath(path, connectionPaint);

    final endPaint = Paint()
      ..color = connectionColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(end, theme.connection.endPointRadius, endPaint);
  }

  void _drawSelectionRect(Canvas canvas, Matrix4 matrix) {
    final selectionRect = controller.selectionRect;
    if (selectionRect == null) return;

    // UPDATED: Use colors from the selection theme
    final selectionPaint = Paint()
      ..color = theme.selection.fillColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(selectionRect, selectionPaint);

    final strokeWidth = (1.0 / matrix.getMaxScaleOnAxis()).clamp(0.5, 3.0);
    _drawDashedRect(
        canvas, selectionRect, theme.selection.borderColor, strokeWidth);
  }

  void _drawDashedRect(
      Canvas canvas, Rect rect, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // UPDATED: Use dash and gap lengths from the selection theme
    final dashLength = theme.selection.dashLength;
    final gapLength = theme.selection.gapLength;

    final path = Path()
      ..addPath(
          _createDashedLine(rect.topLeft, rect.topRight, dashLength, gapLength),
          Offset.zero)
      ..addPath(
          _createDashedLine(
              rect.topRight, rect.bottomRight, dashLength, gapLength),
          Offset.zero)
      ..addPath(
          _createDashedLine(
              rect.bottomRight, rect.bottomLeft, dashLength, gapLength),
          Offset.zero)
      ..addPath(
          _createDashedLine(
              rect.bottomLeft, rect.topLeft, dashLength, gapLength),
          Offset.zero);

    canvas.drawPath(path, paint);
  }

  Path _createDashedLine(Offset start, Offset end,
      [double dashLength = 5.0, double gapLength = 5.0]) {
    // Original logic preserved
    final path = Path();
    final distance = (end - start).distance;
    if (distance == 0) return path;
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
    return oldDelegate.controller != controller || oldDelegate.theme != theme;
  }
}

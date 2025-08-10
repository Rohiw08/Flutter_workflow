import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';

class EdgePathCreator {
  static Path createPath(EdgePathType type, Offset start, Offset end) {
    switch (type) {
      case EdgePathType.bezier:
        return _createBezierPath(start, end);
      case EdgePathType.step:
        return _createStepPath(start, end);
      case EdgePathType.straight:
        return _createStraightPath(start, end);
    }
  }

  static Path _createStraightPath(Offset start, Offset end) {
    return Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
  }

  static Path _createStepPath(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(start.dx, end.dy);
    path.lineTo(end.dx, end.dy);
    return path;
  }

  static Path _createBezierPath(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    final controlPoint1 =
        Offset(start.dx + (end.dx - start.dx) * 0.5, start.dy);
    final controlPoint2 = Offset(start.dx + (end.dx - start.dx) * 0.5, end.dy);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
        controlPoint2.dy, end.dx, end.dy);
    return path;
  }
}

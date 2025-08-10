import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

/// Abstract base class for all custom edge painters.
/// Extend this class to create your own custom edge rendering logic.
abstract class EdgePainter {
  /// The main paint method for the edge.
  ///
  /// [canvas] The canvas to paint on.
  /// [path] The pre-calculated Path object for the edge's shape.
  /// [edge] The FlowEdge data model containing all properties.
  /// [paint] The default paint object for the edge.
  void paint(
    Canvas canvas,
    Path path, // <-- Corrected type
    FlowEdge edge, // <-- Corrected type
    Paint paint, // <-- Corrected type
  );
}

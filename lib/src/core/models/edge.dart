import 'package:flutter/material.dart';

enum EdgeType { bezier, step, straight }

/// Represents a connection between two nodes.
class FlowEdge {
  final String id;
  final String sourceNodeId;
  final String sourceHandleId;
  final String targetNodeId;
  final String targetHandleId;
  final EdgeType type;
  final Paint? paint;

  FlowEdge({
    required this.id,
    required this.sourceNodeId,
    required this.sourceHandleId,
    required this.targetNodeId,
    required this.targetHandleId,
    this.type = EdgeType.bezier,
    this.paint,
  });
}

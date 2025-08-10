import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';

class FlowEdge {
  final String id;
  final String sourceNodeId;
  final String sourceHandleId;
  final String targetNodeId;
  final String targetHandleId;

  /// The type of the edge, used to look up the custom painter in the EdgeRegistry.
  /// If not provided, a default painter will be used.
  final String? type;

  /// The shape of the edge's path.
  final EdgePathType pathType;

  final Paint? paint;

  // Properties for labels and other custom data
  final String? label;
  final TextStyle? labelStyle;
  final Color? labelBackgroundColor;
  final EdgeInsets? labelPadding;
  final BorderRadius? labelBorderRadius;

  // A generic data map for any other custom properties
  final Map<String, dynamic> data;

  FlowEdge({
    required this.id,
    required this.sourceNodeId,
    required this.sourceHandleId,
    required this.targetNodeId,
    required this.targetHandleId,
    this.type,
    this.pathType = EdgePathType.bezier,
    this.paint,
    this.label,
    this.labelStyle,
    this.labelBackgroundColor,
    this.labelPadding,
    this.labelBorderRadius,
    this.data = const {},
  });
}

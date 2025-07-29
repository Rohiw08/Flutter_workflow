import 'package:flutter/material.dart';

/// Holds the state for a connection that is currently being dragged by the user.
class FlowConnectionState {
  final String fromNodeId;
  final String fromHandleId;
  final Offset startPosition;
  Offset endPosition; // Made non-final to allow updates
  String? hoveredTargetKey; // Made non-final to allow updates

  FlowConnectionState({
    required this.fromNodeId,
    required this.fromHandleId,
    required this.startPosition,
    required this.endPosition,
    this.hoveredTargetKey,
  });
}

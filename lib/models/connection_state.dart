import 'package:flutter/material.dart';

class ConnectionState {
  final String fromNodeId;
  final String? fromHandleId;
  final Offset startPosition;
  Offset endPosition;
  String? hoveredTargetKey; // "nodeId/handleId"

  ConnectionState({
    required this.fromNodeId,
    this.fromHandleId,
    required this.startPosition,
    required this.endPosition,
    this.hoveredTargetKey,
  });
}
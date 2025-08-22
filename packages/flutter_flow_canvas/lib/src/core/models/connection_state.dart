import 'package:flutter/material.dart';

class FlowConnectionState {
  final String fromNodeId;
  final String fromHandleId;
  final Offset startPosition;
  Offset endPosition;
  String? hoveredTargetKey;
  bool isValid = false;

  FlowConnectionState({
    required this.fromNodeId,
    required this.fromHandleId,
    required this.startPosition,
    required this.endPosition,
    this.hoveredTargetKey,
    this.isValid = false,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/state/canvas_state.dart';
import '../models/edge.dart';

class EdgeManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;

  EdgeManager(this._state, this._notify);

  List<FlowEdge> get edges => List.unmodifiable(_state.edges);

  void addEdge(FlowEdge edge) {
    if (!_state.nodes.any((n) => n.id == edge.sourceNodeId)) {
      throw ArgumentError('Source node "${edge.sourceNodeId}" does not exist');
    }
    if (!_state.nodes.any((n) => n.id == edge.targetNodeId)) {
      throw ArgumentError('Target node "${edge.targetNodeId}" does not exist');
    }

    final exists = _state.edges.any((e) =>
        e.sourceNodeId == edge.sourceNodeId &&
        e.sourceHandleId == edge.sourceHandleId &&
        e.targetNodeId == edge.targetNodeId &&
        e.targetHandleId == edge.targetHandleId);

    if (!exists) {
      _state.edges.add(edge);
      _notify();
    }
  }

  void removeEdge(String edgeId) {
    _state.edges.removeWhere((edge) => edge.id == edgeId);
    _notify();
  }
}

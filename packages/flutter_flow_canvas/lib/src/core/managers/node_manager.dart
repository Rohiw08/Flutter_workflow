import 'package:flutter/material.dart';
import '../state/canvas_state.dart';
import 'dart:ui' as ui;
import '../models/node.dart';

class NodeManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;

  NodeManager(this._state, this._notify);

  /// Get a node by its ID.
  FlowNode? getNode(String nodeId) {
    return _state.getNode(nodeId);
  }

  void addNode(FlowNode node, Widget widget) {
    if (_state.nodes.any((n) => n.id == node.id)) {
      throw ArgumentError('Node with id "${node.id}" already exists');
    }
    _state.nodes.add(node);
    _state.nodeBuilders[node.id] = widget;
    _notify();
  }

  void removeNode(String nodeId) {
    _state.nodes.removeWhere((node) => node.id == nodeId);
    _state.nodeBuilders.remove(nodeId);
    _state.selectedNodes.remove(nodeId);
    _state.edges.removeWhere(
        (edge) => edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId);
    _notify();
  }

  void updateNodePosition(String nodeId, Offset position) {
    final node = _state.getNode(nodeId);
    if (node != null) {
      node.position = position;
      _notify();
    }
  }

  void updateNodeSize(String nodeId, Size size) {
    final node = _state.getNode(nodeId);
    if (node != null) {
      node.size = size;
      _notify();
    }
  }

  void updateNodeImage(String nodeId, ui.Image image) {
    final node = _state.getNode(nodeId);
    if (node != null) {
      node.cachedImage = image;
      node.needsRepaint = false;
      _notify();
    }
  }

  void dragSelectedNodes(Offset canvasDelta) {
    for (var nodeId in _state.selectedNodes) {
      final node = _state.getNode(nodeId);
      node?.position += canvasDelta;
    }
    _notify();
  }
}

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

  void selectNode(String nodeId, {bool multiSelect = false}) {
    if (!_state.isMultiSelect) multiSelect = false;

    if (!multiSelect) {
      _state.selectedNodes.clear();
    }
    _state.selectedNodes.add(nodeId);

    // Update node selection state
    for (var node in _state.nodes) {
      node.isSelected = _state.selectedNodes.contains(node.id);
    }
    _notify();
  }

  // In FlowCanvasController class
  void dragNode(String nodeId, Offset delta) {
    final node = getNode(nodeId);
    if (node == null) return;
    node.position += delta;
    _notify();
  }

  /// Adds a new node to the canvas.
  /// The widget for this node will be built by the NodeRegistry based on the node's type.
  void addNode(FlowNode node) {
    if (_state.nodes.any((n) => n.id == node.id)) {
      throw ArgumentError('Node with id "${node.id}" already exists');
    }
    _state.nodes.add(node);
    _notify();
  }

  /// Removes a node and its connected edges from the canvas.
  void removeNode(String nodeId) {
    _state.nodes.removeWhere((node) => node.id == nodeId);
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

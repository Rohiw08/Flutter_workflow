import 'package:flutter/material.dart';
import '../../../flutter_flow_canvas.dart';
import '../state/canvas_state.dart';
import 'dart:ui' as ui;

class NodeManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;
  final NodeRegistry _nodeRegistry;

  NodeManager(this._state, this._notify, this._nodeRegistry);

  /// Get a node by its ID.
  FlowNode? getNode(String nodeId) {
    return _state.getNode(nodeId);
  }

  // In FlowCanvasController class
  void dragNode(String nodeId, Offset delta) {
    final node = getNode(nodeId);
    if (node == null) return;
    node.position += delta;
    _notify();
  }

  void addNode(FlowNode node) {
    if (_state.nodes.any((n) => n.id == node.id)) {
      throw ArgumentError('Node with id "${node.id}" already exists');
    }
    if (!_nodeRegistry.isRegistered(node.type)) {
      throw ArgumentError(
          'Node type "${node.type}" is not registered. Please register it in the NodeRegistry before adding the node.');
    }

    // Just add the node directly. Its position is an absolute world coordinate.
    _state.nodes.add(node);
    _notify();
  }

  void addNodes(List<FlowNode> nodes) {
    for (final node in nodes) {
      if (_state.nodes.any((n) => n.id == node.id)) {
        throw ArgumentError('Node with id "${node.id}" already exists');
      }
      // VALIDATION: Check each node type in the list
      if (!_nodeRegistry.isRegistered(node.type)) {
        throw ArgumentError(
            'Node type "${node.type}" is not registered. Please register it in the NodeRegistry before adding nodes.');
      }
      node.position += Offset(_state.canvasWidth / 2, _state.canvasWidth / 2);
      _state.nodes.add(node);
    }
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

  void removeNodes(List<String> nodeIds) {
    for (final nodeId in nodeIds) {
      _state.nodes.removeWhere((node) => node.id == nodeId);
      _state.selectedNodes.remove(nodeId);
      _state.edges.removeWhere(
          (edge) => edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId);
    }
    _notify();
  }

  void removeSelectedNodes() {
    final selectedIds = List<String>.from(_state.selectedNodes);
    for (final nodeId in selectedIds) {
      _state.nodes.removeWhere((node) => node.id == nodeId);
      _state.selectedNodes.remove(nodeId);
      _state.edges.removeWhere(
          (edge) => edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId);
    }
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

  void updateNodeData(String nodeId, Map<String, dynamic> data) {
    final node = _state.getNode(nodeId);
    if (node != null) {
      node.updateData(data);
      _notify();
    }
  }

  void updateNode(
    String nodeId, {
    Offset? position,
    Size? size,
    Map<String, dynamic>? data,
  }) {
    final node = getNode(nodeId);
    if (node == null) return;

    if (position != null) {
      updateNodePosition(nodeId, position);
    }
    if (size != null) {
      updateNodeSize(nodeId, size);
    }
    if (data != null) {
      updateNodeData(nodeId, data);
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

import 'package:flutter/material.dart';
import '../../../flutter_flow_canvas.dart';
import '../state/canvas_state.dart';
import 'dart:ui' as ui;
import 'handle_manager.dart';

class NodeManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;
  final NodeRegistry _nodeRegistry;
  final HandleManager _handleManager;

  NodeManager(
      this._state, this._notify, this._nodeRegistry, this._handleManager);

  FlowNode? getNode(String nodeId) {
    return _state.getNode(nodeId);
  }

  void dragNode(String nodeId, Offset delta) {
    final node = getNode(nodeId);
    if (node == null) return;
    node.position += delta;
    _handleManager.rebuildSpatialHash();
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
    node.position += Offset(_state.canvasWidth / 2, _state.canvasHeight / 2);
    _state.nodes.add(node);
    _handleManager.rebuildSpatialHash();
    _notify();
  }

  void addNodes(List<FlowNode> nodes) {
    for (final node in nodes) {
      if (_state.nodes.any((n) => n.id == node.id)) {
        throw ArgumentError('Node with id "${node.id}" already exists');
      }
      if (!_nodeRegistry.isRegistered(node.type)) {
        throw ArgumentError(
            'Node type "${node.type}" is not registered. Please register it in the NodeRegistry before adding nodes.');
      }
      node.position += Offset(_state.canvasWidth / 2, _state.canvasHeight / 2);
      _state.nodes.add(node);
    }
    _handleManager.rebuildSpatialHash();
    _notify();
  }

  void removeNode(String nodeId) {
    _state.nodes.removeWhere((node) => node.id == nodeId);
    _state.selectedNodes.remove(nodeId);
    _state.edges.removeWhere(
        (edge) => edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId);
    _handleManager.rebuildSpatialHash();
    _notify();
  }

  void removeNodes(List<String> nodeIds) {
    for (final nodeId in nodeIds) {
      _state.nodes.removeWhere((node) => node.id == nodeId);
      _state.selectedNodes.remove(nodeId);
      _state.edges.removeWhere(
          (edge) => edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId);
    }
    _handleManager.rebuildSpatialHash();
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
    _handleManager.rebuildSpatialHash();
    _notify();
  }

  void updateNodePosition(String nodeId, Offset position) {
    final node = _state.getNode(nodeId);
    if (node != null) {
      node.position = position;
      _handleManager.rebuildSpatialHash();
      _notify();
    }
  }

  void updateNodeSize(String nodeId, Size size) {
    final node = _state.getNode(nodeId);
    if (node != null) {
      node.size = size;
      _handleManager.rebuildSpatialHash();
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

    bool needsRebuild = false;
    if (position != null) {
      node.position = position;
      needsRebuild = true;
    }
    if (size != null) {
      node.size = size;
      needsRebuild = true;
    }
    if (data != null) {
      node.updateData(data);
    }

    if (needsRebuild) {
      _handleManager.rebuildSpatialHash();
    }
    _notify();
  }

  void dragSelectedNodes(Offset canvasDelta) {
    for (var nodeId in _state.selectedNodes) {
      final node = _state.getNode(nodeId);
      node?.position += canvasDelta;
    }
    // No need to rebuild hash here as it's handled in onPanUpdate
    _notify();
  }
}

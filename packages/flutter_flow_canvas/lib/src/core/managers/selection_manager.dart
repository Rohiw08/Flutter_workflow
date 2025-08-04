import 'package:flutter/material.dart';
import '../state/canvas_state.dart';

class SelectionManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;

  SelectionManager(this._state, this._notify);

  // Public getter for selected nodes
  Set<String> get selectedNodes => Set.unmodifiable(_state.selectedNodes);

  void selectNode(String nodeId, {bool multiSelect = false}) {
    if (!_state.enableMultiSelection) multiSelect = false;
    if (!multiSelect) {
      _state.selectedNodes.clear();
    }
    _state.selectedNodes.add(nodeId);
    _updateNodeSelectionStatus();
    _notify();
  }

  void deselectNode(String nodeId) {
    _state.selectedNodes.remove(nodeId);
    _updateNodeSelectionStatus();
    _notify();
  }

  void deselectAll({bool notify = true}) {
    _state.selectedNodes.clear();
    _updateNodeSelectionStatus();
    if (notify) _notify();
  }

  void selectAll() {
    if (!_state.enableMultiSelection) return;
    _state.selectedNodes.clear();
    for (var node in _state.nodes) {
      _state.selectedNodes.add(node.id);
    }
    _updateNodeSelectionStatus();
    _notify();
  }

  void selectNodesInArea(Rect area, {bool addToSelection = false}) {
    if (!addToSelection || !_state.enableMultiSelection) {
      deselectAll(notify: false);
    }
    for (var node in _state.nodes) {
      if (area.overlaps(node.rect)) {
        _state.selectedNodes.add(node.id);
      }
    }
    _updateNodeSelectionStatus();
    _notify();
  }

  void _updateNodeSelectionStatus() {
    for (var node in _state.nodes) {
      node.isSelected = _state.selectedNodes.contains(node.id);
    }
  }
}

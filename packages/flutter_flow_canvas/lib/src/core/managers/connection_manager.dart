import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../ui/widgets/handle.dart';
import '../state/canvas_state.dart';
import '../models/connection_state.dart';
import '../models/edge.dart';
import '../enums.dart';
import 'edge_manager.dart';

class ConnectionManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;
  final EdgeManager _edgeManager;

  ConnectionManager(this._state, this._notify, this._edgeManager);

  FlowConnectionState? get connection => _state.connection;

  // === HANDLE MANAGEMENT ===

  /// Register a handle for connection detection
  void registerHandle(
      String nodeId, String handleId, GlobalKey<HandleState> key) {
    _state.handleRegistry['$nodeId/$handleId'] = key;
  }

  /// Unregister a handle
  void unregisterHandle(String nodeId, String handleId) {
    _state.handleRegistry.remove('$nodeId/$handleId');
  }

  /// Get global position of a handle
  Offset? getHandleGlobalPosition(String nodeId, String handleId) {
    final key = _state.handleRegistry['$nodeId/$handleId'];
    if (key?.currentContext != null) {
      final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      return renderBox.localToGlobal(Offset(size.width / 2, size.height / 2));
    }
    return null;
  }

  // === CONNECTION MANAGEMENT ===

  void startConnection(
      String fromNodeId, String fromHandleId, Offset startPosition) {
    _state.connection = FlowConnectionState(
      fromNodeId: fromNodeId,
      fromHandleId: fromHandleId,
      startPosition: startPosition,
      endPosition: startPosition,
    );
    _state.dragMode = DragMode.handle;
    _notify();
  }

  void updateConnection(Offset globalPosition) {
    if (_state.connection == null) return;
    _state.connection!.endPosition = globalPosition;

    String? hoveredKey;
    for (final entry in _state.handleRegistry.entries) {
      final renderBox =
          entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null &&
          renderBox.hitTest(BoxHitTestResult(),
              position: renderBox.globalToLocal(globalPosition))) {
        if ('${_state.connection!.fromNodeId}/${_state.connection!.fromHandleId}' !=
            entry.key) {
          hoveredKey = entry.key;
          break;
        }
      }
    }
    _state.connection!.hoveredTargetKey = hoveredKey;
    _notify();
  }

  void endConnection() {
    if (_state.connection?.hoveredTargetKey != null) {
      final targetKeyParts = _state.connection!.hoveredTargetKey!.split('/');
      final newEdge = FlowEdge(
        id: 'edge-${Random().nextInt(999999)}',
        sourceNodeId: _state.connection!.fromNodeId,
        sourceHandleId: _state.connection!.fromHandleId,
        targetNodeId: targetKeyParts[0],
        targetHandleId: targetKeyParts[1],
      );
      _edgeManager.addEdge(newEdge);
    }
    _state.connection = null;
    _state.dragMode = DragMode.none;
    _notify();
  }

  void cancelConnection() {
    _state.connection = null;
    _state.dragMode = DragMode.none;
    _notify();
  }
}

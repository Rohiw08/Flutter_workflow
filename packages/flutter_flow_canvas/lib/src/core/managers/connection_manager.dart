import 'dart:math';

import 'package:flutter/material.dart'
    show debugPrint, RenderBox, VoidCallback, Offset;

import '../enums.dart';
import '../models/connection_state.dart';
import '../models/edge.dart';
import '../state/canvas_state.dart';
import 'edge_manager.dart';
import 'handle_manager.dart';

/// Generates a unique edge ID using timestamp and random components
String _generateUniqueEdgeId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = Random().nextInt(999999);
  return 'edge_${timestamp}_$random';
}

class ConnectionManager {
  final FlowCanvasState _state;
  final VoidCallback _notify;
  final EdgeManager _edgeManager;
  final HandleManager _handleManager;

  // New property for snap radius
  final double snapRadius;

  ConnectionManager(
    this._state,
    this._notify,
    this._edgeManager,
    this._handleManager, {
    this.snapRadius = 20.0,
  });

  FlowConnectionState? get connection => _state.connection;

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
    if (connection == null) return;
    connection!.endPosition = globalPosition;

    String? hoveredKey;
    bool connectionIsValid = true;

    // Force rebuild spatial hash to ensure it's current
    _handleManager.rebuildSpatialHash();

    // We use the spatial hash for a coarse search
    final nearbyHandles = _handleManager.getHandlesNear(globalPosition);

    for (final handleKey in nearbyHandles) {
      if ('${connection!.fromNodeId}/${connection!.fromHandleId}' ==
          handleKey) {
        continue;
      }

      final handleState = _handleManager.getHandleState(handleKey);
      if (handleState == null) {
        continue;
      }

      final renderBox = handleState.context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) {
        continue;
      }

      final handleCenter =
          renderBox.localToGlobal(renderBox.size.center(Offset.zero));
      final distance = (globalPosition - handleCenter).distance;

      // Check if the cursor is within the snapRadius.
      if (distance <= snapRadius) {
        final targetHandleWidget = handleState.widget;
        if (targetHandleWidget.type != HandleType.source) {
          bool customValidationPassed = true;
          if (targetHandleWidget.onValidateConnection != null) {
            final targetKeyParts = handleKey.split('/');
            customValidationPassed = targetHandleWidget.onValidateConnection!(
              connection!.fromNodeId,
              connection!.fromHandleId,
              targetKeyParts[0],
              targetKeyParts[1],
            );
          }

          if (customValidationPassed) {
            connectionIsValid = true;
            hoveredKey = handleKey;
            break;
          }
        }
      }
    }

    connection!.isValid = connectionIsValid;
    connection!.hoveredTargetKey = hoveredKey;

    _notify();
  }

  void endConnection() {
    // Re-run updateConnection one last time to get the absolute final state
    if (_state.connection != null) {
      updateConnection(_state.connection!.endPosition);
    }

    if (_state.connection != null &&
        _state.connection!.isValid &&
        _state.connection!.hoveredTargetKey != null) {
      try {
        final targetKeyParts = _state.connection!.hoveredTargetKey!.split('/');
        final sourceNodeId = _state.connection!.fromNodeId;
        final sourceHandleId = _state.connection!.fromHandleId;
        final targetNodeId = targetKeyParts[0];
        final targetHandleId = targetKeyParts[1];

        final newEdge = FlowEdge(
          id: _generateUniqueEdgeId(),
          sourceNodeId: sourceNodeId,
          sourceHandleId: sourceHandleId,
          targetNodeId: targetNodeId,
          targetHandleId: targetHandleId,
        );
        _edgeManager.addEdge(newEdge);
      } catch (e) {
        debugPrint('Error creating edge: $e');
      }
    }
    _cancelConnectionInternal();
  }

  void cancelConnection() {
    _cancelConnectionInternal();
  }

  void _cancelConnectionInternal() {
    _state.connection = null;
    _state.dragMode = DragMode.none;
    _notify();
  }
}

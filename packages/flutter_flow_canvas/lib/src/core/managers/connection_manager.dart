import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../ui/widgets/handle.dart';
import '../state/canvas_state.dart';
import '../models/connection_state.dart';
import '../models/edge.dart';
import '../enums.dart';
import 'edge_manager.dart';

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

  ConnectionManager(this._state, this._notify, this._edgeManager);

  FlowConnectionState? get connection => _state.connection;

  // === HANDLE MANAGEMENT ===

  void registerHandle(
      String nodeId, String handleId, GlobalKey<HandleState> key) {
    _state.handleRegistry['$nodeId/$handleId'] = key;
    _notify();
  }

  void unregisterHandle(String nodeId, String handleId) {
    _state.handleRegistry.remove('$nodeId/$handleId');
  }

  /// Get global position of a handle with safe type checking
  Offset? getHandleGlobalPosition(String nodeId, String handleId) {
    final key = _state.handleRegistry['$nodeId/$handleId'];
    final context = key?.currentContext;

    if (context == null || !context.mounted) {
      return null;
    }
    try {
      final renderObject = context.findRenderObject();

      if (renderObject == null || renderObject is! RenderBox) {
        return null;
      }

      final renderBox = renderObject;

      if (!renderBox.attached) {
        return null;
      }

      final size = renderBox.size;

      if (size.width <= 0 || size.height <= 0) {
        return null;
      }

      return renderBox.localToGlobal(Offset(size.width / 2, size.height / 2));
    } catch (e) {
      return null;
    }
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
    if (connection == null) return;
    connection!.endPosition = globalPosition;

    String? finalHoveredKey;
    bool isConnectionValid = false;

    final hitTestResult = BoxHitTestResult();

    // 1. Iterate through all registered handles to find a potential target
    for (final entry in _state.handleRegistry.entries) {
      // Prevent connecting to the same handle the connection started from
      if ('${connection!.fromNodeId}/${connection!.fromHandleId}' ==
          entry.key) {
        continue;
      }

      try {
        final context = entry.value.currentContext;
        if (context == null || !context.mounted) continue;

        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.attached) continue;

        // 2. Perform hit-test
        if (renderBox.hitTest(hitTestResult,
            position: renderBox.globalToLocal(globalPosition))) {
          final targetHandleWidget = entry.value.currentWidget as Handle?;

          if (targetHandleWidget != null &&
              targetHandleWidget.type != HandleType.source) {
            // Assume valid until custom validation proves otherwise
            isConnectionValid = true;
            finalHoveredKey = entry.key; // Tentatively set the hovered key

            // If a custom validation callback exists, use it
            if (targetHandleWidget.onValidateConnection != null) {
              final targetKeyParts = entry.key.split('/');
              isConnectionValid = targetHandleWidget.onValidateConnection!(
                connection!.fromNodeId,
                connection!.fromHandleId,
                targetKeyParts[0],
                targetKeyParts[1],
              );
            }
          }

          // If a valid handle is found and the connection is valid, break the loop
          if (isConnectionValid) {
            break;
          } else {
            // If custom validation failed, reset the key
            finalHoveredKey = null;
          }
        }
      } catch (e) {
        debugPrint('Error in hit testing for handle ${entry.key}: $e');
        continue;
      }
    }

    // 4. Update the connection state
    connection!.isValid = isConnectionValid;
    connection!.hoveredTargetKey = isConnectionValid ? finalHoveredKey : null;

    _notify();
  }

  // In ConnectionManager class

  void endConnection() {
    if (_state.connection?.hoveredTargetKey != null) {
      try {
        final targetKeyParts = _state.connection!.hoveredTargetKey!.split('/');
        if (targetKeyParts.length != 2) {
          debugPrint(
              'Invalid target key format: ${_state.connection!.hoveredTargetKey}');
          _cancelConnectionInternal();
          return;
        }

        final sourceNodeId = _state.connection!.fromNodeId;
        final sourceHandleId = _state.connection!.fromHandleId;
        final targetNodeId = targetKeyParts[0];
        final targetHandleId = targetKeyParts[1];

        // --- START: NEW VALIDATION LOGIC ---
        final targetHandleKey =
            _state.handleRegistry[_state.connection!.hoveredTargetKey!];
        final targetHandleWidget = targetHandleKey?.currentWidget as Handle?;

        bool isConnectionValid = true; // Default to true
        if (targetHandleWidget?.onValidateConnection != null) {
          isConnectionValid = targetHandleWidget!.onValidateConnection!(
            sourceNodeId,
            sourceHandleId,
            targetNodeId,
            targetHandleId,
          );
        }
        // --- END: NEW VALIDATION LOGIC ---

        if (isConnectionValid) {
          final newEdge = FlowEdge(
            id: _generateUniqueEdgeId(),
            sourceNodeId: sourceNodeId,
            sourceHandleId: sourceHandleId,
            targetNodeId: targetNodeId,
            targetHandleId: targetHandleId,
          );
          _edgeManager.addEdge(newEdge);
        }
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

  void validateHandleRegistry() {
    final invalidHandles = <String>[];

    for (final entry in _state.handleRegistry.entries) {
      final handleKey = entry.key;
      final globalKey = entry.value;

      if (globalKey.currentContext == null ||
          !globalKey.currentContext!.mounted) {
        invalidHandles.add(handleKey);
        continue;
      }
    }

    for (final handleKey in invalidHandles) {
      _state.handleRegistry.remove(handleKey);
      debugPrint('Removed invalid handle: $handleKey');
    }

    if (invalidHandles.isNotEmpty) {
      _notify();
    }
  }
}

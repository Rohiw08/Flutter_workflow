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
      // Catching the error prevents the crash. The edge will not be drawn for this frame.
      // This is a safe fallback for this specific timing issue.
      // debugPrint('Safely handled error getting handle position for $nodeId/$handleId: $e');
      return null;
    }
  }

  Handle? _getHandleWidget(String nodeId, String handleId) {
    final key = _state.handleRegistry['$nodeId/$handleId'];
    return key?.currentWidget as Handle?;
  }

  int getConnectionCount(String nodeId, String handleId) {
    // Assuming _edgeManager has a method to get edges connected to a handle
    // Implement based on your EdgeManager logic, e.g., filter edges where source or target matches
    return _edgeManager.edges
        .where((edge) =>
            (edge.sourceNodeId == nodeId && edge.sourceHandleId == handleId) ||
            (edge.targetNodeId == nodeId && edge.targetHandleId == handleId))
        .length;
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

    String? hoveredKey;
    final hitTestResult = BoxHitTestResult();

    for (final entry in _state.handleRegistry.entries) {
      try {
        // This part is less likely to crash but good to be safe.
        final context = entry.value.currentContext;
        if (context == null || !context.mounted) continue;

        final renderObject = context.findRenderObject();

        if (renderObject == null || renderObject is! RenderBox) {
          continue;
        }

        final renderBox = renderObject;

        if (!renderBox.attached) {
          continue;
        }

        if (renderBox.hitTest(hitTestResult,
            position: renderBox.globalToLocal(globalPosition))) {
          if ('${connection!.fromNodeId}/${connection!.fromHandleId}' !=
              entry.key) {
            hoveredKey = entry.key;
            break;
          }
        }
      } catch (e) {
        debugPrint('Error in hit testing for handle ${entry.key}: $e');
        continue;
      }
    }

    connection!.hoveredTargetKey = hoveredKey;
    _notify();
  }

  void endConnection() {
    if (_state.connection?.hoveredTargetKey == null) {
      _cancelConnectionInternal();
      return;
    }

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

      // Get source and target handles
      final sourceHandle = _getHandleWidget(sourceNodeId, sourceHandleId);
      final targetHandle = _getHandleWidget(targetNodeId, targetHandleId);

      if (sourceHandle == null || targetHandle == null) {
        debugPrint('Missing source or target handle widget');
        _cancelConnectionInternal();
        return;
      }

      // Validate connection using target's onValidateConnection
      final isValid = targetHandle.onValidateConnection?.call(
            sourceNodeId,
            sourceHandleId,
            targetNodeId,
            targetHandleId,
          ) ??
          true;

      if (!isValid) {
        debugPrint('Invalid connection: validation failed');
        _cancelConnectionInternal();
        return;
      }

      // Check maxConnections on source
      final sourceConnectable =
          sourceHandle.connectable ?? const HandleConnectable();
      if (sourceConnectable.maxConnections != null) {
        final sourceCount = getConnectionCount(sourceNodeId, sourceHandleId);
        if (sourceCount >= sourceConnectable.maxConnections!) {
          debugPrint('Max connections reached for source handle');
          _cancelConnectionInternal();
          return;
        }
      }

      // Check maxConnections on target
      final targetConnectable =
          targetHandle.connectable ?? const HandleConnectable();
      if (targetConnectable.maxConnections != null) {
        final targetCount = getConnectionCount(targetNodeId, targetHandleId);
        if (targetCount >= targetConnectable.maxConnections!) {
          debugPrint('Max connections reached for target handle');
          _cancelConnectionInternal();
          return;
        }
      }

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

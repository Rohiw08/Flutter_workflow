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

  // Add this debug method to ConnectionManager to see what's happening with handles
//   void debugHandleRegistration() {
//     print('=== HANDLE REGISTRATION DEBUG ===');
//     print('Total registered handles: ${_state.handleRegistry.length}');
//     print('Registered handle keys: ${_state.handleRegistry.keys.toList()}');

//     for (final entry in _state.handleRegistry.entries) {
//       final key = entry.key;
//       final handleKey = entry.value;
//       print('Handle "$key":');
//       print('  - Key exists: ${handleKey != null}');
//       print('  - Has context: ${handleKey.currentContext != null}');

//       if (handleKey.currentContext != null) {
//         final renderObject = handleKey.currentContext!.findRenderObject();
//         print('  - Has RenderObject: ${renderObject != null}');
//         if (renderObject != null && renderObject is RenderBox) {
//           try {
//             final globalPos =
//                 (renderObject as RenderBox).localToGlobal(Offset.zero);
//             print('  - Global position: $globalPos');
//           } catch (e) {
//             print('  - Error getting position: $e');
//           }
//         }
//       }
//     }
//     print('=== END HANDLE REGISTRATION DEBUG ===');
//   }

//   // Add this method to ConnectionManager class
//   void debugHandleRegistry() {
//     print('=== HANDLE REGISTRY DEBUG ===');
//     print('Total registered handles: ${_state.handleRegistry.length}');

//     for (final entry in _state.handleRegistry.entries) {
//       final handleKey = entry.key;
//       final key = entry.value;
//       final hasContext = key.currentContext != null;
//       final hasRenderBox =
//           hasContext ? (key.currentContext!.findRenderObject() != null) : false;

//       print('Handle: $handleKey');
//       print('  - Has context: $hasContext');
//       print('  - Has RenderBox: $hasRenderBox');

//       if (hasContext && hasRenderBox) {
//         final renderBox = key.currentContext!.findRenderObject() as RenderBox;
//         final size = renderBox.size;
//         try {
//           final globalPos =
//               renderBox.localToGlobal(Offset(size.width / 2, size.height / 2));
//           print('  - Global position: $globalPos');
//           print('  - Size: $size');
//         } catch (e) {
//           print('  - Error getting position: $e');
//         }
//       }
//     }

//     print('Expected handles for edges:');
//     for (final edge in _state.edges) {
//       print('  - ${edge.sourceNodeId}/${edge.sourceHandleId}');
//       print('  - ${edge.targetNodeId}/${edge.targetHandleId}');
//     }
//     print('=== END HANDLE REGISTRY DEBUG ===');
//   }

// // Also add this method to check InteractiveViewer
//   void debugInteractiveViewer(GlobalKey? ivKey) {
//     print('=== INTERACTIVE VIEWER DEBUG ===');
//     print('Key exists: ${ivKey != null}');
//     if (ivKey != null) {
//       print('Context exists: ${ivKey.currentContext != null}');
//       if (ivKey.currentContext != null) {
//         final renderBox = ivKey.currentContext!.findRenderObject();
//         print('RenderBox exists: ${renderBox != null}');
//         if (renderBox != null) {
//           final rb = renderBox as RenderBox;
//           final globalPos = rb.localToGlobal(Offset.zero);
//           print('InteractiveViewer global position: $globalPos');
//           print('InteractiveViewer size: ${rb.size}');
//         }
//       }
//     }
//     print('=== END INTERACTIVE VIEWER DEBUG ===');
//   }
  // === HANDLE MANAGEMENT ===

  /// Register a handle for connection detection
  void registerHandle(
      String nodeId, String handleId, GlobalKey<HandleState> key) {
    _state.handleRegistry['$nodeId/$handleId'] = key;
    _notify();
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
    if (connection == null) return;
    connection!.endPosition = globalPosition;

    String? hoveredKey;
    for (final entry in _state.handleRegistry.entries) {
      final renderBox =
          entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null &&
          renderBox.hitTest(BoxHitTestResult(),
              position: renderBox.globalToLocal(globalPosition))) {
        if ('${connection!.fromNodeId}/${connection!.fromHandleId}' !=
            entry.key) {
          hoveredKey = entry.key;
          break;
        }
      }
    }
    connection!.hoveredTargetKey = hoveredKey;
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

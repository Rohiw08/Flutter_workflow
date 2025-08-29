import 'package:flutter/material.dart';
import '../../ui/widgets/handle.dart';
import '../state/canvas_state.dart';

class HandleManager {
  final FlowCanvasState _state;
  final double _gridSize;

  final Map<String, Set<String>> _grid = {};

  HandleManager(this._state, {double gridSize = 200.0}) : _gridSize = gridSize;

  /// Determines the grid key for a given position.
  String _getGridKey(Offset position) {
    final gridX = (position.dx / _gridSize).floor();
    final gridY = (position.dy / _gridSize).floor();
    return '$gridX,$gridY';
  }

  /// Registers a handle and adds it to the spatial hash.
  void registerHandle(
      String nodeId, String handleId, GlobalKey<HandleState> key) {
    final handleKey = '$nodeId/$handleId';
    _state.handleRegistry[handleKey] = key;
    final position = getHandleGlobalPosition(nodeId, handleId);
    if (position != null) {
      final gridKey = _getGridKey(position);
      _grid.putIfAbsent(gridKey, () => {}).add(handleKey);
    }
  }

  /// Unregisters a handle and removes it from the spatial hash.
  void unregisterHandle(String nodeId, String handleId) {
    final handleKey = '$nodeId/$handleId';
    _state.handleRegistry.remove(handleKey);
  }

  void rebuildSpatialHash() {
    _grid.clear();
    for (final handleKey in _state.handleRegistry.keys) {
      final keyParts = handleKey.split('/');
      final nodeId = keyParts[0];
      final handleId = keyParts[1];
      final position = getHandleGlobalPosition(nodeId, handleId);
      if (position != null) {
        final gridKey = _getGridKey(position);
        _grid.putIfAbsent(gridKey, () => {}).add(handleKey);
      }
    }
  }

  /// Gets a list of handle keys near a given position.
  Iterable<String> getHandlesNear(Offset position) {
    final gridX = (position.dx / _gridSize).floor();
    final gridY = (position.dy / _gridSize).floor();
    final nearbyHandles = <String>{};

    // Check the 9 cells around the cursor's position
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        final key = '${gridX + x},${gridY + y}';
        if (_grid.containsKey(key)) {
          nearbyHandles.addAll(_grid[key]!);
        }
      }
    }
    return nearbyHandles;
  }

  /// Gets the global position of a handle.
  Offset? getHandleGlobalPosition(String nodeId, String handleId) {
    final key = _state.handleRegistry['$nodeId/$handleId'];
    final context = key?.currentContext;

    if (context == null || !context.mounted) {
      return null;
    }
    try {
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox) return null;
      if (!renderObject.attached) return null;
      final size = renderObject.size;
      if (size.isEmpty) return null;
      return renderObject
          .localToGlobal(Offset(size.width / 2, size.height / 2));
    } catch (e) {
      return null;
    }
  }

  HandleState? getHandleState(String handleKey) {
    return _state.handleRegistry[handleKey]?.currentState;
  }
}

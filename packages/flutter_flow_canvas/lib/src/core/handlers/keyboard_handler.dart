import 'package:flutter/services.dart';
import '../state/canvas_state.dart';
import '../managers/selection_manager.dart';
import '../managers/node_manager.dart';
import '../managers/connection_manager.dart';

class KeyboardHandler {
  final FlowCanvasState _state;
  final SelectionManager _selectionManager;
  final NodeManager _nodeManager;
  final ConnectionManager _connectionManager;

  KeyboardHandler(this._state, this._selectionManager, this._nodeManager,
      this._connectionManager);

  bool handleKeyEvent(KeyEvent event) {
    if (!_state.enableKeyboardShortcuts) return false;

    if (event is KeyDownEvent) {
      final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;

      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
        _selectionManager.selectAll();
      } else if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        final nodesToDelete = List<String>.from(_state.selectedNodes);
        for (final nodeId in nodesToDelete) {
          _nodeManager.removeNode(nodeId);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _selectionManager.deselectAll();
        _connectionManager.cancelConnection();
      }
    }
    return false;
  }
}

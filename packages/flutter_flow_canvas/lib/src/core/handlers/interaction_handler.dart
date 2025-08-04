import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/canvas_state.dart';
import '../enums.dart';
import '../models/node.dart';
import '../managers/selection_manager.dart';
import '../managers/node_manager.dart';
import '../managers/navigation_manager.dart';

class InteractionHandler {
  final FlowCanvasState _state;
  final TransformationController _transformationController;
  final VoidCallback _notify;
  final SelectionManager _selectionManager;
  final NodeManager _nodeManager;
  final NavigationManager _navigationManager;

  InteractionHandler(
    this._state,
    this._transformationController,
    this._notify,
    this._selectionManager,
    this._nodeManager,
    this._navigationManager,
  );

  void onPanStart(DragStartDetails details) {
    final canvasOffset =
        _transformationController.toScene(details.localPosition);
    _state.lastPanPosition = details.localPosition;
    _state.lastCanvasPosition = canvasOffset;
    _state.isMultiSelect = _state.enableMultiSelection &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isShiftPressed);

    FlowNode? hitNode;
    for (int i = _state.nodes.length - 1; i >= 0; i--) {
      if (_state.nodes[i].rect.contains(canvasOffset)) {
        hitNode = _state.nodes[i];
        break;
      }
    }

    if (hitNode != null) {
      _state.dragMode = DragMode.node;
      if (_state.isMultiSelect) {
        if (hitNode.isSelected) {
          _selectionManager.deselectNode(hitNode.id);
        } else {
          _selectionManager.selectNode(hitNode.id, multiSelect: true);
        }
      } else if (!hitNode.isSelected) {
        _selectionManager.selectNode(hitNode.id);
      }
    } else {
      if (_state.enableBoxSelection) {
        _state.dragMode = DragMode.selection;
        if (!_state.isMultiSelect) {
          _selectionManager.deselectAll(notify: false);
        }
        _state.selectionRect = Rect.fromPoints(canvasOffset, canvasOffset);
      } else {
        _state.dragMode = DragMode.canvas;
      }
    }
    _notify();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_state.lastPanPosition == null || _state.lastCanvasPosition == null) {
      return;
    }

    final currentCanvasOffset =
        _transformationController.toScene(details.localPosition);

    switch (_state.dragMode) {
      case DragMode.node:
        final canvasDelta = currentCanvasOffset - _state.lastCanvasPosition!;
        _nodeManager.dragSelectedNodes(canvasDelta);
        _state.lastCanvasPosition = currentCanvasOffset;
        break;
      case DragMode.selection:
        _state.selectionRect =
            Rect.fromPoints(_state.selectionRect!.topLeft, currentCanvasOffset);
        _selectionManager.selectNodesInArea(_state.selectionRect!,
            addToSelection: _state.isMultiSelect);
        break;
      case DragMode.canvas:
        final screenDelta = details.localPosition - _state.lastPanPosition!;
        _navigationManager.pan(screenDelta);
        break;
      default:
        break;
    }
    _state.lastPanPosition = details.localPosition;
    _notify();
  }

  void onPanEnd(DragEndDetails details) {
    _state.dragMode = DragMode.none;
    _state.lastPanPosition = null;
    _state.lastCanvasPosition = null;
    _state.selectionRect = null;
    _notify();
  }
}

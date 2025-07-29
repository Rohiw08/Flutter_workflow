import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'models/connection_state.dart';
import 'models/edge.dart';
import 'models/node.dart';

enum DragMode { none, canvas, node, selection }

/// The central controller for managing the state of the flow canvas.
class FlowCanvasController extends ChangeNotifier {
  final List<FlowNode> _nodes = [];
  final List<FlowEdge> _edges = [];
  final Map<String, Widget> _nodeBuilders = {};
  final Map<String, GlobalKey> _nodeKeys = {};

  final Map<String, GlobalKey> handleRegistry = {};
  FlowConnectionState? connection;

  TransformationController transformationController =
      TransformationController();
  Rect? selectionRect;
  DragMode dragMode = DragMode.none;

  List<FlowNode> get nodes => _nodes;
  List<FlowEdge> get edges => _edges;

  FlowCanvasController() {
    transformationController.addListener(_notify);
  }

  void _notify() {
    notifyListeners();
  }

  /// Add a node to the canvas
  void addNode(FlowNode node, Widget widget) {
    _nodes.add(node);
    _nodeBuilders[node.id] = widget;
    _nodeKeys[node.id] = GlobalKey();
    _cacheNodeWidget(node.id);
    _notify();
  }

  /// Add an edge to the canvas
  void addEdge(FlowEdge edge) {
    _edges.add(edge);
    _notify();
  }

  // --- Handle and Connection Management ---
  void registerHandle(String nodeId, String handleId, GlobalKey key) {
    handleRegistry['$nodeId/$handleId'] = key;
  }

  void unregisterHandle(String nodeId, String handleId) {
    handleRegistry.remove('$nodeId/$handleId');
  }

  void startConnection(
      String fromNodeId, String fromHandleId, Offset startPosition) {
    connection = FlowConnectionState(
      fromNodeId: fromNodeId,
      fromHandleId: fromHandleId,
      startPosition: startPosition,
      endPosition: startPosition,
    );
    _notify();
  }

  void updateConnection(Offset globalPosition) {
    if (connection == null) return;
    connection!.endPosition = globalPosition;

    String? hoveredKey;
    for (final entry in handleRegistry.entries) {
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
    if (connection?.hoveredTargetKey != null) {
      final targetKeyParts = connection!.hoveredTargetKey!.split('/');
      final newEdge = FlowEdge(
        id: 'edge-${Random().nextInt(999999)}',
        sourceNodeId: connection!.fromNodeId,
        sourceHandleId: connection!.fromHandleId,
        targetNodeId: targetKeyParts[0],
        targetHandleId: targetKeyParts[1],
        type: EdgeType.bezier,
      );
      addEdge(newEdge);
    }
    connection = null;
    _notify();
  }

  // --- Gesture Handling ---

  void onPanStart(DragStartDetails details) {
    final canvasOffset =
        transformationController.toScene(details.localPosition);

    final hitNode = _nodes.lastWhere((n) => n.rect.contains(canvasOffset),
        orElse: () => FlowNode(
            id: '', position: Offset.zero, size: Size.zero, data: NodeData()));

    if (hitNode.id.isNotEmpty) {
      dragMode = DragMode.node;
      if (!hitNode.isSelected) {
        deselectAll(notify: false);
        hitNode.isSelected = true;
      }
    } else {
      dragMode = DragMode.selection;
      deselectAll(notify: false);
      selectionRect = Rect.fromPoints(canvasOffset, canvasOffset);
    }
    _notify();
  }

  void onPanUpdate(DragUpdateDetails details) {
    final scale = transformationController.value.getMaxScaleOnAxis();
    final scaledDelta = details.delta / scale;
    final canvasOffset =
        transformationController.toScene(details.localPosition);

    if (dragMode == DragMode.node) {
      for (var node in _nodes) {
        if (node.isSelected) {
          node.position += scaledDelta;
        }
      }
    } else if (dragMode == DragMode.selection && selectionRect != null) {
      selectionRect = Rect.fromPoints(selectionRect!.topLeft, canvasOffset);
      _updateSelection();
    }
    _notify();
  }

  void onPanEnd(DragEndDetails details) {
    dragMode = DragMode.none;
    selectionRect = null;
    _notify();
  }

  void _updateSelection() {
    if (selectionRect == null) return;
    for (var node in _nodes) {
      node.isSelected = selectionRect!.overlaps(node.rect);
    }
  }

  void deselectAll({bool notify = true}) {
    for (var node in _nodes) {
      node.isSelected = false;
    }
    if (notify) _notify();
  }

  // --- Widget to Image Caching ---

  void _cacheNodeWidget(String nodeId) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final boundary = _nodeKeys[nodeId]?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final nodeIndex = _nodes.indexWhere((n) => n.id == nodeId);
      if (nodeIndex != -1) {
        final node = _nodes[nodeIndex];
        node.cachedImage = image;
        node.needsRepaint = false;
        _notify();
      }
    });
  }

  List<Widget> buildOffstageWidgets() {
    return _nodes.where((node) => node.needsRepaint).map((node) {
      return Offstage(
        child: RepaintBoundary(
          key: _nodeKeys[node.id],
          child: _nodeBuilders[node.id],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    transformationController.removeListener(_notify);
    transformationController.dispose();
    super.dispose();
  }
}

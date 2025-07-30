import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'models/connection_state.dart';
import 'models/edge.dart';
import 'models/node.dart';

enum DragMode { none, canvas, node, selection, handle }

/// The central controller for managing the state of the flow canvas.
/// This is the main API that consumers of the library will interact with.
class FlowCanvasController extends ChangeNotifier {
  final List<FlowNode> _nodes = [];
  final List<FlowEdge> _edges = [];
  final Map<String, Widget> _nodeBuilders = {};
  final Set<String> _selectedNodes = {};

  final Map<String, GlobalKey> handleRegistry = {};
  FlowConnectionState? connection;

  TransformationController transformationController =
      TransformationController();
  Rect? selectionRect;
  DragMode dragMode = DragMode.none;
  // ignore: unused_field
  String? _draggedNodeId;
  Offset? _lastPanPosition;
  bool _isMultiSelect = false;

  // Configuration options
  bool enableMultiSelection = true;
  bool enableKeyboardShortcuts = true;
  bool enableBoxSelection = true;
  double canvasWidth = 5000;
  double canvasHeight = 5000;

  /// Read-only access to nodes
  List<FlowNode> get nodes => List.unmodifiable(_nodes);

  /// Read-only access to edges
  List<FlowEdge> get edges => List.unmodifiable(_edges);

  /// Read-only access to selected node IDs
  Set<String> get selectedNodes => Set.unmodifiable(_selectedNodes);

  /// Check if canvas has any nodes
  bool get hasNodes => _nodes.isNotEmpty;

  /// Check if canvas has any edges
  bool get hasEdges => _edges.isNotEmpty;

  /// Check if any nodes are selected
  bool get hasSelection => _selectedNodes.isNotEmpty;

  FlowCanvasController({
    this.enableMultiSelection = true,
    this.enableKeyboardShortcuts = true,
    this.enableBoxSelection = true,
    this.canvasWidth = 5000,
    this.canvasHeight = 5000,
  }) {
    transformationController.addListener(_notifyListeners);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  // === NODE MANAGEMENT ===

  /// Add a node to the canvas with its associated widget
  void addNode(FlowNode node, Widget widget) {
    if (_nodes.any((n) => n.id == node.id)) {
      throw ArgumentError('Node with id "${node.id}" already exists');
    }

    _nodes.add(node);
    _nodeBuilders[node.id] = widget;
    _notifyListeners();
  }

  /// Remove a node and all its connections
  void removeNode(String nodeId) {
    _nodes.removeWhere((node) => node.id == nodeId);
    _nodeBuilders.remove(nodeId);
    _selectedNodes.remove(nodeId);

    // Remove edges connected to this node
    _edges.removeWhere(
        (edge) => edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId);

    _notifyListeners();
  }

  /// Update a node's position
  void updateNodePosition(String nodeId, Offset position) {
    final node = getNode(nodeId);
    if (node != null) {
      node.position = position;
      _notifyListeners();
    }
  }

  /// Update a node's size
  void updateNodeSize(String nodeId, Size size) {
    final node = getNode(nodeId);
    if (node != null) {
      node.size = size;
      _notifyListeners();
    }
  }

  /// Get node by ID
  FlowNode? getNode(String nodeId) {
    try {
      return _nodes.firstWhere((node) => node.id == nodeId);
    } catch (e) {
      return null;
    }
  }

  /// Get all nodes in a given area
  List<FlowNode> getNodesInArea(Rect area) {
    return _nodes.where((node) => area.overlaps(node.rect)).toList();
  }

  /// Updates the cached image for a node
  void updateNodeImage(String nodeId, ui.Image image) {
    final node = getNode(nodeId);
    if (node != null) {
      node.cachedImage = image;
      node.needsRepaint = false;
      _notifyListeners();
    }
  }

  // === EDGE MANAGEMENT ===

  /// Add an edge between two nodes
  void addEdge(FlowEdge edge) {
    // Validate that source and target nodes exist
    if (!_nodes.any((n) => n.id == edge.sourceNodeId)) {
      throw ArgumentError('Source node "${edge.sourceNodeId}" does not exist');
    }
    if (!_nodes.any((n) => n.id == edge.targetNodeId)) {
      throw ArgumentError('Target node "${edge.targetNodeId}" does not exist');
    }

    // Check if edge already exists
    final exists = _edges.any((e) =>
        e.sourceNodeId == edge.sourceNodeId &&
        e.sourceHandleId == edge.sourceHandleId &&
        e.targetNodeId == edge.targetNodeId &&
        e.targetHandleId == edge.targetHandleId);

    if (!exists) {
      _edges.add(edge);
      _notifyListeners();
    }
  }

  /// Remove an edge
  void removeEdge(String edgeId) {
    _edges.removeWhere((edge) => edge.id == edgeId);
    _notifyListeners();
  }

  /// Get edge by ID
  FlowEdge? getEdge(String edgeId) {
    try {
      return _edges.firstWhere((edge) => edge.id == edgeId);
    } catch (e) {
      return null;
    }
  }

  /// Get all edges connected to a node
  List<FlowEdge> getNodeEdges(String nodeId) {
    return _edges
        .where((edge) =>
            edge.sourceNodeId == nodeId || edge.targetNodeId == nodeId)
        .toList();
  }

  // === SELECTION MANAGEMENT ===

  /// Select a node
  void selectNode(String nodeId, {bool multiSelect = false}) {
    if (!enableMultiSelection) multiSelect = false;

    if (!multiSelect) {
      _selectedNodes.clear();
    }
    _selectedNodes.add(nodeId);

    // Update node selection state
    for (var node in _nodes) {
      node.isSelected = _selectedNodes.contains(node.id);
    }
    _notifyListeners();
  }

  /// Deselect a node
  void deselectNode(String nodeId) {
    _selectedNodes.remove(nodeId);
    final node = getNode(nodeId);
    if (node != null) {
      node.isSelected = false;
    }
    _notifyListeners();
  }

  /// Deselect all nodes
  void deselectAll({bool notify = true}) {
    _selectedNodes.clear();
    for (var node in _nodes) {
      node.isSelected = false;
    }
    if (notify) _notifyListeners();
  }

  /// Select all nodes
  void selectAll() {
    if (!enableMultiSelection) return;

    _selectedNodes.clear();
    for (var node in _nodes) {
      _selectedNodes.add(node.id);
      node.isSelected = true;
    }
    _notifyListeners();
  }

  /// Select nodes in an area
  void selectNodesInArea(Rect area, {bool addToSelection = false}) {
    if (!addToSelection || !enableMultiSelection) {
      deselectAll(notify: false);
    }

    for (var node in _nodes) {
      if (area.overlaps(node.rect)) {
        _selectedNodes.add(node.id);
        node.isSelected = true;
      }
    }
    _notifyListeners();
  }

  // === HANDLE MANAGEMENT ===

  /// Register a handle for connection detection
  void registerHandle(String nodeId, String handleId, GlobalKey key) {
    handleRegistry['$nodeId/$handleId'] = key;
  }

  /// Unregister a handle
  void unregisterHandle(String nodeId, String handleId) {
    handleRegistry.remove('$nodeId/$handleId');
  }

  /// Get global position of a handle
  Offset? getHandleGlobalPosition(String nodeId, String handleId) {
    final key = handleRegistry['$nodeId/$handleId'];
    if (key?.currentContext != null) {
      final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      return renderBox.localToGlobal(Offset(size.width / 2, size.height / 2));
    }
    return null;
  }

  // === CONNECTION MANAGEMENT ===

  /// Start a connection from a handle
  void startConnection(
      String fromNodeId, String fromHandleId, Offset startPosition) {
    connection = FlowConnectionState(
      fromNodeId: fromNodeId,
      fromHandleId: fromHandleId,
      startPosition: startPosition,
      endPosition: startPosition,
    );
    dragMode = DragMode.handle;
    _notifyListeners();
  }

  /// Update connection end position
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
    _notifyListeners();
  }

  /// End connection and create edge if valid
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
    dragMode = DragMode.none;
    _notifyListeners();
  }

  /// Cancel current connection
  void cancelConnection() {
    connection = null;
    dragMode = DragMode.none;
    _notifyListeners();
  }

  // === KEYBOARD SHORTCUTS ===

  /// Handle keyboard events
  void handleKeyEvent(KeyEvent event) {
    if (!enableKeyboardShortcuts) return;

    if (event is KeyDownEvent) {
      final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;

      if (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyA) {
        selectAll();
      } else if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        deleteSelected();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        deselectAll();
        cancelConnection();
      }
    }
  }

  /// Delete selected nodes
  void deleteSelected() {
    final nodesToDelete = List<String>.from(_selectedNodes);
    for (final nodeId in nodesToDelete) {
      removeNode(nodeId);
    }
  }

  // === GESTURE HANDLING ===

  /// Handle pan start
  void onPanStart(DragStartDetails details) {
    final canvasOffset =
        transformationController.toScene(details.localPosition);
    _lastPanPosition = details.localPosition;
    _isMultiSelect = enableMultiSelection &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isShiftPressed);

    // Check if we hit a node (check from top to bottom for proper layering)
    FlowNode? hitNode;
    for (int i = _nodes.length - 1; i >= 0; i--) {
      if (_nodes[i].rect.contains(canvasOffset)) {
        hitNode = _nodes[i];
        break;
      }
    }

    if (hitNode != null) {
      dragMode = DragMode.node;
      _draggedNodeId = hitNode.id;

      if (_isMultiSelect) {
        if (hitNode.isSelected) {
          deselectNode(hitNode.id);
        } else {
          selectNode(hitNode.id, multiSelect: true);
        }
      } else {
        if (!hitNode.isSelected) {
          selectNode(hitNode.id);
        }
      }
    } else if (enableBoxSelection) {
      dragMode = DragMode.selection;
      if (!_isMultiSelect) {
        deselectAll(notify: false);
      }
      selectionRect = Rect.fromPoints(canvasOffset, canvasOffset);
    }
    _notifyListeners();
  }

  /// Handle pan update
  void onPanUpdate(DragUpdateDetails details) {
    if (_lastPanPosition == null) return;

    final scale = transformationController.value.getMaxScaleOnAxis();
    final scaledDelta = details.delta / scale;
    final canvasOffset =
        transformationController.toScene(details.localPosition);

    if (dragMode == DragMode.node) {
      // Move selected nodes
      for (var node in _nodes) {
        if (node.isSelected) {
          node.position += scaledDelta;
        }
      }
    } else if (dragMode == DragMode.selection && selectionRect != null) {
      selectionRect = Rect.fromPoints(selectionRect!.topLeft, canvasOffset);
      _updateSelection();
    }

    _lastPanPosition = details.localPosition;
    _notifyListeners();
  }

  /// Handle pan end
  void onPanEnd(DragEndDetails details) {
    dragMode = DragMode.none;
    _draggedNodeId = null;
    _lastPanPosition = null;
    selectionRect = null;
    _notifyListeners();
  }

  void _updateSelection() {
    if (selectionRect == null) return;

    if (!_isMultiSelect) {
      selectNodesInArea(selectionRect!, addToSelection: false);
    } else {
      selectNodesInArea(selectionRect!, addToSelection: true);
    }
  }

  // === CANVAS NAVIGATION ===

  /// Fit all nodes in view
  void fitView({EdgeInsets padding = const EdgeInsets.all(50)}) {
    if (_nodes.isEmpty) return;

    double minX = _nodes.first.position.dx;
    double minY = _nodes.first.position.dy;
    double maxX = _nodes.first.position.dx + _nodes.first.size.width;
    double maxY = _nodes.first.position.dy + _nodes.first.size.height;

    for (final node in _nodes) {
      minX = min(minX, node.position.dx);
      minY = min(minY, node.position.dy);
      maxX = max(maxX, node.position.dx + node.size.width);
      maxY = max(maxY, node.position.dy + node.size.height);
    }

    final bounds = Rect.fromLTRB(minX, minY, maxX, maxY);
    final paddedBounds = bounds.inflate(padding.horizontal / 2);

    // Calculate scale to fit
    final canvasSize = Size(canvasWidth, canvasHeight);
    final scaleX = canvasSize.width / paddedBounds.width;
    final scaleY = canvasSize.height / paddedBounds.height;
    final scale = min(scaleX, min(scaleY, 1.0));

    // Calculate translation to center
    final centerX = -paddedBounds.center.dx * scale + canvasSize.width / 2;
    final centerY = -paddedBounds.center.dy * scale + canvasSize.height / 2;

    transformationController.value = Matrix4.identity()
      ..translate(centerX, centerY)
      ..scale(scale);
  }

  /// Center view
  void centerView() {
    transformationController.value = Matrix4.identity();
  }

  /// Zoom in
  void zoomIn([double factor = 1.2]) {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 2.0) {
      transformationController.value = transformationController.value.clone()
        ..scale(factor);
    }
  }

  /// Zoom out
  void zoomOut([double factor = 1.2]) {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.1) {
      transformationController.value = transformationController.value.clone()
        ..scale(1 / factor);
    }
  }

  /// Set zoom level
  void setZoom(double zoom) {
    zoom = zoom.clamp(0.1, 2.0);
    final currentTransform = transformationController.value;
    final currentScale = currentTransform.getMaxScaleOnAxis();
    final scaleFactor = zoom / currentScale;

    transformationController.value = currentTransform.clone()
      ..scale(scaleFactor);
  }

  /// Get current zoom level
  double get zoomLevel => transformationController.value.getMaxScaleOnAxis();

  // === UTILITY METHODS ===

  /// Get node widget builder
  Widget? getNodeWidget(String nodeId) {
    return _nodeBuilders[nodeId];
  }

  /// Clear all nodes and edges
  void clear() {
    _nodes.clear();
    _edges.clear();
    _nodeBuilders.clear();
    _selectedNodes.clear();
    handleRegistry.clear();
    connection = null;
    selectionRect = null;
    dragMode = DragMode.none;
    _notifyListeners();
  }

  /// Get canvas bounds containing all nodes
  Rect? get canvasBounds {
    if (_nodes.isEmpty) return null;

    double minX = _nodes.first.position.dx;
    double minY = _nodes.first.position.dy;
    double maxX = _nodes.first.rect.right;
    double maxY = _nodes.first.rect.bottom;

    for (final node in _nodes) {
      minX = min(minX, node.position.dx);
      minY = min(minY, node.position.dy);
      maxX = max(maxX, node.rect.right);
      maxY = max(maxY, node.rect.bottom);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  void dispose() {
    transformationController.removeListener(_notifyListeners);
    transformationController.dispose();
    super.dispose();
  }
}

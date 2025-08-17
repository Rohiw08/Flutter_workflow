import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/state/edge_registry.dart';
import 'state/canvas_state.dart';
import 'managers/node_manager.dart';
import 'managers/edge_manager.dart';
import 'managers/selection_manager.dart';
import 'managers/connection_manager.dart';
import 'managers/navigation_manager.dart';
import 'handlers/interaction_handler.dart';
import 'handlers/keyboard_handler.dart';
import 'models/node.dart';
import 'models/edge.dart';
import 'enums.dart';
import 'state/node_registry.dart';

typedef CanvasInitCallback = void Function(FlowCanvasController controller);

class FlowCanvasController extends ChangeNotifier {
  // State and Transformation
  final FlowCanvasState _state = FlowCanvasState();
  final TransformationController transformationController =
      TransformationController();

  // Managers
  late final NodeManager nodeManager;
  late final EdgeManager edgeManager;
  late final SelectionManager selectionManager;
  late final ConnectionManager connectionManager;
  late final NavigationManager navigationManager;

  // Handlers
  late final InteractionHandler interactionHandler;
  late final KeyboardHandler keyboardHandler;

  // Registries
  final NodeRegistry nodeRegistry;
  final EdgeRegistry edgeRegistry;

  GlobalKey? interactiveViewerKey;

  // Fixed: Track disposal state to prevent double disposal
  bool _isDisposed = false;

  // Callback for notifying listeners
  late final VoidCallback notify;

  // Public Getters from State
  List<FlowNode> get nodes => List.unmodifiable(_state.nodes);
  List<FlowEdge> get edges => List.unmodifiable(_state.edges);
  Set<String> get selectedNodes => Set.unmodifiable(_state.selectedNodes);
  Rect? get selectionRect => _state.selectionRect;
  double get zoomLevel => transformationController.value.getMaxScaleOnAxis();
  DragMode get dragMode => _state.dragMode;
  double get canvasWidth => _state.canvasWidth;
  double get canvasHeight => _state.canvasHeight;

  FlowCanvasController({
    bool enableMultiSelection = true,
    bool enableKeyboardShortcuts = true,
    bool enableBoxSelection = true,
    double canvasWidth = 5000,
    double canvasHeight = 5000,
    required this.nodeRegistry,
    required this.edgeRegistry,
  }) {
    // Fixed: Validate canvas dimensions
    if (canvasWidth <= 0 || canvasHeight <= 0) {
      throw ArgumentError('Canvas dimensions must be positive');
    }

    _state.enableMultiSelection = enableMultiSelection;
    _state.enableKeyboardShortcuts = enableKeyboardShortcuts;
    _state.enableBoxSelection = enableBoxSelection;

    // Initialize managers and handlers
    notify = () {
      if (!_isDisposed) notifyListeners();
    };

    try {
      nodeManager = NodeManager(_state, notify, nodeRegistry);
      edgeManager = EdgeManager(_state, notify);
      selectionManager = SelectionManager(_state, notify);
      connectionManager = ConnectionManager(_state, notify, edgeManager);
      navigationManager = NavigationManager(_state, transformationController);
      interactionHandler = InteractionHandler(_state, transformationController,
          notify, selectionManager, nodeManager, navigationManager);
      keyboardHandler = KeyboardHandler(
          _state, selectionManager, nodeManager, connectionManager);

      transformationController.addListener(notify);
    } catch (e) {
      debugPrint('Error initializing FlowCanvasController: $e');
      rethrow;
    }
  }

  void setInteractiveViewerKey(GlobalKey key) {
    interactiveViewerKey = key;
    _state.interactiveViewerKey = key;
  }

  // Utility methods
  Widget? getNodeWidget(FlowNode node) {
    try {
      return nodeRegistry.buildNodeWidget(node);
    } catch (e) {
      debugPrint('Error building widget for node ${node.id}: $e');
      return null;
    }
  }

  /// This is useful for features like a minimap or fitting the view.
  Rect getNodesBounds() {
    if (_state.nodes.isEmpty) return Rect.zero;

    try {
      return _state.nodes
          .map((n) => n.rect)
          .reduce((value, element) => value.expandToInclude(element));
    } catch (e) {
      debugPrint('Error calculating nodes bounds: $e');
      return Rect.zero;
    }
  }

  void clear() {
    if (_isDisposed) return;

    try {
      _state.clear();
      notify();
    } catch (e) {
      debugPrint('Error clearing canvas: $e');
    }
  }

  /// Validates the current state and fixes common issues
  void validateAndFixState() {
    if (_isDisposed) return;

    try {
      // Validate transformation matrix
      navigationManager.validateAndFixTransformation();

      // Validate handle registry
      connectionManager.validateHandleRegistry();

      // Remove any orphaned edges (edges with non-existent nodes)
      final nodeIds = _state.nodes.map((n) => n.id).toSet();
      final edgesToRemove = <FlowEdge>[];

      for (final edge in _state.edges) {
        if (!nodeIds.contains(edge.sourceNodeId) ||
            !nodeIds.contains(edge.targetNodeId)) {
          edgesToRemove.add(edge);
        }
      }

      for (final edge in edgesToRemove) {
        edgeManager.removeEdge(edge.id);
      }

      // Remove invalid selected nodes
      final validSelectedNodes =
          _state.selectedNodes.where((id) => nodeIds.contains(id)).toSet();

      if (validSelectedNodes.length != _state.selectedNodes.length) {
        _state.selectedNodes.clear();
        _state.selectedNodes.addAll(validSelectedNodes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error validating canvas state: $e');
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;

    try {
      transformationController.removeListener(notify);
      connectionManager.cancelConnection();
      _state.clear();
      transformationController.dispose();
      super.dispose();
    } catch (e) {
      debugPrint('Error disposing FlowCanvasController: $e');
      super.dispose();
    }
  }
}

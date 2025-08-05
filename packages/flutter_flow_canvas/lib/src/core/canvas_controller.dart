import 'package:flutter/material.dart';
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

  // Public Getters from State
  List<FlowNode> get nodes => List.unmodifiable(_state.nodes);
  List<FlowEdge> get edges => List.unmodifiable(_state.edges);
  Set<String> get selectedNodes => Set.unmodifiable(_state.selectedNodes);
  Rect? get selectionRect => _state.selectionRect;
  double get zoomLevel => transformationController.value.getMaxScaleOnAxis();
  DragMode get dragMode => _state.dragMode;

  double get canvasWidth => _state.canvasWidth;
  double get canvasHeight => _state.canvasHeight;

  // Registory
  final NodeRegistry nodeRegistry;

  FlowCanvasController({
    bool enableMultiSelection = true,
    bool enableKeyboardShortcuts = true,
    bool enableBoxSelection = true,
    double canvasWidth = 5000,
    double canvasHeight = 5000,
    required this.nodeRegistry,
  }) {
    _state.enableMultiSelection = enableMultiSelection;
    _state.enableKeyboardShortcuts = enableKeyboardShortcuts;
    _state.enableBoxSelection = enableBoxSelection;
    _state.canvasWidth = canvasWidth;
    _state.canvasHeight = canvasHeight;

    // Initialize managers and handlers
    void notify() => notifyListeners();
    nodeManager = NodeManager(_state, notify);
    edgeManager = EdgeManager(_state, notify);
    selectionManager = SelectionManager(_state, notify);
    connectionManager = ConnectionManager(_state, notify, edgeManager);
    navigationManager =
        NavigationManager(_state, transformationController, notify);
    interactionHandler = InteractionHandler(_state, transformationController,
        notify, selectionManager, nodeManager, navigationManager);
    keyboardHandler = KeyboardHandler(
        _state, selectionManager, nodeManager, connectionManager);

    transformationController.addListener(notify);
  }

  // Utility methods
  Widget? getNodeWidget(FlowNode node) {
    return nodeRegistry.buildNodeWidget(node);
  }

  /// This is useful for features like a minimap or fitting the view.
  Rect getNodesBounds() {
    if (_state.nodes.isEmpty) return Rect.zero;
    return _state.nodes
        .map((n) => n.rect)
        .reduce((value, element) => value.expandToInclude(element));
  }

  void clear() {
    _state.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    transformationController.removeListener(notifyListeners);
    transformationController.dispose();
    super.dispose();
  }
}

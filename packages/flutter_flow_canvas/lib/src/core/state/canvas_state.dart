import 'package:flutter/material.dart';
import '../../../flutter_flow_canvas.dart';

class FlowCanvasState {
  // Core data
  final List<FlowNode> nodes = [];
  final List<FlowEdge> edges = [];
  final Set<String> selectedNodes = {};

  // Interaction state
  final Map<String, GlobalKey<HandleState>> handleRegistry = {};
  FlowConnectionState? connection;
  Rect? selectionRect;
  DragMode dragMode = DragMode.none;
  Offset? lastPanPosition;
  Offset? lastCanvasPosition;
  bool isMultiSelect = false;
  GlobalKey? interactiveViewerKey;

  // Configuration
  bool enableMultiSelection = true;
  bool enableKeyboardShortcuts = true;
  bool enableBoxSelection = true;
  double canvasWidth = 5000;
  double canvasHeight = 5000;

  // Helper methods
  FlowNode? getNode(String nodeId) {
    try {
      return nodes.firstWhere((node) => node.id == nodeId);
    } catch (e) {
      return null;
    }
  }

  void clear() {
    nodes.clear();
    edges.clear();
    selectedNodes.clear();
    handleRegistry.clear();
    connection = null;
    selectionRect = null;
    dragMode = DragMode.none;
    interactiveViewerKey = null; // Also clear the key
  }
}

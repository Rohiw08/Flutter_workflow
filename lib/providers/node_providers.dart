import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flow_node.dart';
import 'package:flutter/material.dart';

class NodesNotifier extends StateNotifier<List<FlowNode>> {
  NodesNotifier(super.initialNodes);

  void initNodes(List<FlowNode> nodes) {
    state = nodes;
  }

  void updateNodePosition(String nodeId, Offset delta) {
    state = [
      for (final node in state)
        if (node.id == nodeId)
          node.copyWith(position: node.position + delta)
        else
          node,
    ];
  }

  void onDragStart(String nodeId) {
    state = [
      for (final node in state)
        if (node.id == nodeId) node.copyWith(dragging: true) else node,
    ];
  }

  void onDragEnd(String nodeId) {
    state = [
      for (final node in state)
        if (node.id == nodeId) node.copyWith(dragging: false) else node,
    ];
  }
}

final nodesProvider = StateNotifierProvider<NodesNotifier, List<FlowNode>>((ref) {
  return NodesNotifier([]);
});
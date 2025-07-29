import 'package:flutter/material.dart';

class NodeData {
  final String label;
  NodeData({required this.label});
}

class FlowNode {
  final String id;
  String type; // Used to select the correct widget ('default', 'custom', etc.)
  Offset position;
  NodeData data;
  bool selected;
  bool dragging;

  FlowNode({
    required this.id,
    this.type = 'default',
    required this.position,
    required this.data,
    this.selected = false,
    this.dragging = false,
  });

  // Helper to create a copy with updated values
  FlowNode copyWith({
    Offset? position,
    bool? dragging,
    bool? selected,
  }) {
    return FlowNode(
      id: id,
      type: type,
      position: position ?? this.position,
      data: data,
      dragging: dragging ?? this.dragging,
      selected: selected ?? this.selected,
    );
  }
}
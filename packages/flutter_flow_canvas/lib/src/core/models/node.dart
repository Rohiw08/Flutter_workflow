import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A base class for node data. Extend this to add your own data to a node.
class NodeData {
  NodeData();
}

/// Represents a single node in the flow canvas.
class FlowNode {
  final String id;
  Offset position;
  Size size;
  final NodeData data;
  bool isSelected;

  // For widget-to-image caching
  ui.Image? cachedImage;
  bool needsRepaint = true;

  FlowNode({
    required this.id,
    required this.position,
    required this.size,
    required this.data,
    this.isSelected = false,
  });

  /// This is used by the MiniMap to get default styling values.
  factory FlowNode.empty() {
    return FlowNode(
      id: '_empty_',
      position: Offset.zero,
      size: Size.zero,
      data: NodeData(),
    );
  }

  Rect get rect =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  FlowNode copyWith({
    Offset? position,
    Size? size,
    bool? isSelected,
  }) {
    return FlowNode(
      id: id,
      position: position ?? this.position,
      size: size ?? this.size,
      data: data,
      isSelected: isSelected ?? this.isSelected,
    )
      ..cachedImage = cachedImage
      ..needsRepaint = needsRepaint;
  }
}

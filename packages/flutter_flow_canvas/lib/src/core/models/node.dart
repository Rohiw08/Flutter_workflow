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
  String type;
  Map<String, dynamic> data;
  bool isSelected;

  // For widget-to-image caching
  ui.Image? cachedImage;
  bool needsRepaint = true;

  FlowNode({
    required this.id,
    required this.position,
    required this.size,
    required this.type, // <-- force it
    this.data = const {},
    this.isSelected = false,
  });

  /// This is used by the MiniMap to get default styling values.
  factory FlowNode.empty() {
    return FlowNode(
      id: '_empty_',
      position: Offset.zero,
      size: Size.zero,
      data: const {},
      type: 'default', // Default type
    );
  }

  Rect get rect =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  FlowNode copyWith({
    Offset? position,
    Size? size,
    bool? isSelected,
    String? type,
    Map<String, dynamic>? data,
  }) {
    return FlowNode(
      id: id,
      position: position ?? this.position,
      size: size ?? this.size,
      type: type ?? this.type,
      data: data ?? this.data,
      isSelected: isSelected ?? this.isSelected,
    )
      ..cachedImage = cachedImage
      ..needsRepaint = needsRepaint;
  }
}

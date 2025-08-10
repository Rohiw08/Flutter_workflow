import 'dart:convert'; // Import dart:convert
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A utility function to perform a deep copy of a map.
Map<String, dynamic> _deepCopy(Map<String, dynamic> map) {
  return json.decode(json.encode(map));
}

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

  // NEW: Interaction configuration
  final bool isDraggable;
  final bool isSelectable;
  final bool hasCustomInteractions;

  FlowNode({
    required this.id,
    required this.position,
    required this.size,
    required this.type,
    Map<String, dynamic> data = const {}, // Accept the incoming data
    this.isSelected = false,
    this.isDraggable = true, // Default: nodes are draggable
    this.isSelectable = true, // Default: nodes are selectable
    this.hasCustomInteractions = false, // Default: use canvas interactions
  }) : data = _deepCopy(data); // Immediately deep copy the data

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

  factory FlowNode.create({
    required Offset position,
    required Size size,
    required String type,
    Map<String, dynamic> data = const {},
    bool isSelected = false,
    bool isDraggable = true,
    bool isSelectable = true,
    bool hasCustomInteractions = false,
  }) {
    final id = 'node_${Random().nextDouble()}'; // Simple unique ID generation
    return FlowNode(
        id: id,
        position: position,
        size: size,
        type: type,
        data: data,
        isSelected: isSelected,
        isDraggable: isDraggable,
        isSelectable: isSelectable,
        hasCustomInteractions: hasCustomInteractions);
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
      data: data ??
          _deepCopy(this
              .data), // Use deep copy of existing data if new data isn't provided
      isSelected: isSelected ?? this.isSelected,
    )
      ..cachedImage = cachedImage
      ..needsRepaint = needsRepaint;
  }

  void updateData(Map<String, dynamic> newData, {bool visualUpdate = true}) {
    // Create a new map by merging the old and new, then deep copy it.
    data = _deepCopy({...data, ...newData});
    if (visualUpdate) {
      needsRepaint = true;
    }
  }

  /// Creates a deep copy of this node.
  FlowNode clone() {
    return FlowNode(
      id: id,
      position: position,
      size: size,
      type: type,
      data: _deepCopy(data), // Use deep copy for the data
      isSelected: isSelected,
      isDraggable: isDraggable,
      isSelectable: isSelectable,
      hasCustomInteractions: hasCustomInteractions,
    )
      ..cachedImage = cachedImage
      ..needsRepaint = needsRepaint;
  }
}

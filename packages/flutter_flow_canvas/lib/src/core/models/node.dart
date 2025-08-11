import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A utility function to perform a safe deep copy of a map.
/// This version handles non-JSON-serializable objects gracefully.
Map<String, dynamic> _safeDeepCopy(Map<String, dynamic> map) {
  try {
    // First attempt: JSON serialization (fastest for simple objects)
    return json.decode(json.encode(map));
  } catch (e) {
    // Fallback: Manual deep copy for complex objects
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) {
        result[key] = null;
      } else if (value is Map<String, dynamic>) {
        result[key] = _safeDeepCopy(value);
      } else if (value is List) {
        result[key] = _deepCopyList(value);
      } else if (value is String ||
          value is num ||
          value is bool ||
          value is DateTime ||
          value is Color ||
          value is Offset ||
          value is Size) {
        // These types are safe to copy directly
        result[key] = value;
      } else {
        // For complex objects that can't be serialized, store a reference
        // This prevents crashes but may not provide true deep copy semantics
        result[key] = value;
      }
    }
    return result;
  }
}

List _deepCopyList(List list) {
  return list.map((item) {
    if (item is Map<String, dynamic>) {
      return _safeDeepCopy(item);
    } else if (item is List) {
      return _deepCopyList(item);
    } else {
      return item;
    }
  }).toList();
}

/// Generates a unique node ID using timestamp and random components
/// to virtually eliminate collision risk.
String _generateUniqueNodeId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = Random().nextInt(999999);
  return 'node_${timestamp}_$random';
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

  // Interaction configuration
  final bool isDraggable;
  final bool isSelectable;
  final bool hasCustomInteractions;

  FlowNode({
    required this.id,
    required this.position,
    required this.size,
    required this.type,
    Map<String, dynamic> data = const {},
    this.isSelected = false,
    this.isDraggable = true,
    this.isSelectable = true,
    this.hasCustomInteractions = false,
  }) : data = _safeDeepCopy(data);

  /// Creates an empty node for default styling purposes.
  factory FlowNode.empty() {
    return FlowNode(
      id: '_empty_',
      position: Offset.zero,
      size: Size.zero,
      data: const {},
      type: 'default',
    );
  }

  /// Creates a new node with a unique ID.
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
    final id =
        _generateUniqueNodeId(); // Fixed: Use collision-resistant ID generation
    return FlowNode(
      id: id,
      position: position,
      size: size,
      type: type,
      data: data,
      isSelected: isSelected,
      isDraggable: isDraggable,
      isSelectable: isSelectable,
      hasCustomInteractions: hasCustomInteractions,
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
      data: data ?? _safeDeepCopy(this.data),
      isSelected: isSelected ?? this.isSelected,
      isDraggable: isDraggable,
      isSelectable: isSelectable,
      hasCustomInteractions: hasCustomInteractions,
    )
      ..cachedImage = cachedImage
      ..needsRepaint = needsRepaint;
  }

  void updateData(Map<String, dynamic> newData, {bool visualUpdate = true}) {
    // Create a new map by merging the old and new, then safely deep copy it.
    data = _safeDeepCopy({...data, ...newData});
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
      data: _safeDeepCopy(data),
      isSelected: isSelected,
      isDraggable: isDraggable,
      isSelectable: isSelectable,
      hasCustomInteractions: hasCustomInteractions,
    )
      ..cachedImage = cachedImage
      ..needsRepaint = needsRepaint;
  }
}

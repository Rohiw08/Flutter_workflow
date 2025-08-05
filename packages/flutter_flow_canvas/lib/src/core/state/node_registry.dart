import 'package:flutter/widgets.dart';
import '../models/node.dart';

typedef NodeWidgetBuilder = Widget Function(FlowNode node);

/// A registry for managing node type builders.
///
/// An instance of this class should be created and passed to the
/// FlowCanvasController to make node types available to the canvas.
class NodeRegistry {
  final Map<String, NodeWidgetBuilder> _builders = {};

  /// Register a node type with its builder.
  void registerNodeType(String type, NodeWidgetBuilder builder) {
    _builders[type] = builder;
  }

  /// Build a widget for a given node based on its type.
  Widget? buildNodeWidget(FlowNode node) {
    final builder = _builders[node.type];
    return builder?.call(node);
  }

  /// Check if a node type is registered.
  bool isRegistered(String type) {
    return _builders.containsKey(type);
  }

  /// Get all registered node types.
  List<String> get registeredTypes => _builders.keys.toList();

  /// Unregister a node type.
  void unregisterNodeType(String type) {
    _builders.remove(type);
  }

  /// Clear all registered types.
  void clear() {
    _builders.clear();
  }
}

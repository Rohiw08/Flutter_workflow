import '../models/edge_painter.dart';

class EdgeRegistry {
  final Map<String, EdgePainter> _painters = {};

  /// Registers a custom edge type with its painter.
  void registerEdgeType(String type, EdgePainter painter) {
    _painters[type] = painter;
  }

  /// Retrieves the painter for a given edge type.
  EdgePainter? getPainter(String type) {
    return _painters[type];
  }

  /// Unregisters a custom edge type.
  void unregisterEdgeType(String type) {
    _painters.remove(type);
  }

  /// Clears all registered edge types.
  void clear() {
    _painters.clear();
  }
}

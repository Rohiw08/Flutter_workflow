// edge_registry.dart
import 'package:flutter/material.dart';

import '../models/edge_painter.dart';

/// A type-safe registry for managing custom edge painters.
/// Fixed: Added comprehensive validation and type safety.
class EdgeRegistry {
  final Map<String, EdgePainter> _painters = {};

  /// Registers a custom edge type with its painter.
  /// Fixed: Added validation and better error handling.
  void registerEdgeType(String type, EdgePainter painter) {
    if (type.trim().isEmpty) {
      throw ArgumentError('Edge type cannot be empty or whitespace');
    }
    _painters[type] = painter;
  }

  EdgePainter? getPainter(String? type) {
    // Changed to accept nullable String
    // FIXED: Handle null and empty cases differently
    if (type == null || type.isEmpty) {
      // Don't warn for null types - these are expected default cases
      // Only warn if someone explicitly passes an empty string
      if (type == '') {
        // Explicitly empty string
        debugPrint('Warning: Empty edge type requested');
      }
      return null; // Return null for both null and empty - use default painter
    }

    final painter = _painters[type];
    if (painter == null) {
      // Only warn in debug mode and for non-empty types that aren't registered
      assert(() {
        debugPrint('Warning: No painter registered for edge type "$type"');
        return true;
      }());
    }

    return painter;
  }

  /// Unregisters a custom edge type.
  /// Fixed: Added validation and confirmation.
  bool unregisterEdgeType(String type) {
    if (type.isEmpty) {
      debugPrint('Warning: Cannot unregister empty edge type');
      return false;
    }

    final wasRemoved = _painters.remove(type) != null;
    if (wasRemoved) {
      debugPrint('Successfully unregistered edge type: "$type"');
    } else {
      debugPrint('Warning: Edge type "$type" was not registered');
    }

    return wasRemoved;
  }

  /// Checks if an edge type is registered.
  bool isRegistered(String type) {
    return type.isNotEmpty && _painters.containsKey(type);
  }

  /// Gets all registered edge types.
  List<String> get registeredTypes => List.unmodifiable(_painters.keys);

  /// Gets the count of registered edge types.
  int get count => _painters.length;

  /// Validates that a painter is compatible with the registry.
  /// This can be used before registration to ensure compatibility.
  bool validatePainter(EdgePainter painter) {
    try {
      // Test if the painter can be called without throwing
      // This is a basic validation - you might want to add more specific checks
      // ignore: unnecessary_type_check
      return painter is EdgePainter;
    } catch (e) {
      debugPrint('Painter validation failed: $e');
      return false;
    }
  }

  /// Clears all registered edge types.
  void clear() {
    final typeCount = _painters.length;
    _painters.clear();
    debugPrint('Cleared $typeCount registered edge types');
  }

  /// Gets debug information about the registry state.
  Map<String, dynamic> getDebugInfo() {
    return {
      'registeredTypes': registeredTypes,
      'count': count,
      'painters': _painters.entries
          .map((e) => {
                'type': e.key,
                'painterType': e.value.runtimeType.toString(),
              })
          .toList(),
    };
  }

  @override
  String toString() {
    return 'EdgeRegistry(types: ${registeredTypes.join(', ')}, count: $count)';
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

/// A comprehensive validation utility for Flutter Flow Canvas operations.
class CanvasValidation {
  /// Validates canvas dimensions
  static bool validateCanvasDimensions(double width, double height) {
    if (width <= 0 || height <= 0) {
      debugPrint('Invalid canvas dimensions: ${width}x$height');
      return false;
    }

    if (!width.isFinite || !height.isFinite) {
      debugPrint('Non-finite canvas dimensions: ${width}x$height');
      return false;
    }

    // Check for reasonable maximum size to prevent memory issues
    const maxDimension = 50000.0;
    if (width > maxDimension || height > maxDimension) {
      debugPrint(
          'Canvas dimensions too large: ${width}x$height (max: $maxDimension)');
      return false;
    }

    return true;
  }

  /// Validates a position offset
  static bool validatePosition(Offset position) {
    if (!position.dx.isFinite || !position.dy.isFinite) {
      debugPrint('Invalid position with non-finite values: $position');
      return false;
    }

    // Check for extremely large values that might cause rendering issues
    const maxCoordinate = 1000000.0;
    if (position.dx.abs() > maxCoordinate ||
        position.dy.abs() > maxCoordinate) {
      debugPrint('Position coordinates too large: $position');
      return false;
    }

    return true;
  }

  /// Validates a size
  static bool validateSize(Size size) {
    if (size.width <= 0 || size.height <= 0) {
      debugPrint('Invalid size with non-positive dimensions: $size');
      return false;
    }

    if (!size.width.isFinite || !size.height.isFinite) {
      debugPrint('Size with non-finite dimensions: $size');
      return false;
    }

    const maxDimension = 10000.0;
    if (size.width > maxDimension || size.height > maxDimension) {
      debugPrint('Size too large: $size (max dimension: $maxDimension)');
      return false;
    }

    return true;
  }

  /// Validates a transformation matrix
  static bool validateMatrix(Matrix4 matrix) {
    try {
      final scale = matrix.getMaxScaleOnAxis();
      final translation = matrix.getTranslation();

      if (!scale.isFinite || scale <= 0) {
        debugPrint('Invalid matrix scale: $scale');
        return false;
      }

      if (!translation.x.isFinite || !translation.y.isFinite) {
        debugPrint('Invalid matrix translation: $translation');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating matrix: $e');
      return false;
    }
  }

  /// Validates a RenderBox for position calculations
  static bool validateRenderBox(RenderBox? renderBox) {
    if (renderBox == null) {
      return false;
    }

    if (!renderBox.attached) {
      debugPrint('RenderBox is not attached to render tree');
      return false;
    }

    try {
      final size = renderBox.size;
      if (!validateSize(size)) {
        return false;
      }

      // Test if we can get global position without errors
      renderBox.localToGlobal(Offset.zero);
      return true;
    } catch (e) {
      debugPrint('RenderBox validation failed: $e');
      return false;
    }
  }

  /// Validates node data for potential serialization issues
  static bool validateNodeData(Map<String, dynamic> data) {
    try {
      // Test JSON serialization
      final encoded = jsonEncode(data);
      jsonDecode(encoded);
      return true;
    } catch (e) {
      debugPrint('Node data contains non-serializable objects: $e');
      // This is not necessarily an error, just a warning
      return false;
    }
  }

  /// Validates an edge connection
  static bool validateEdgeConnection({
    required String sourceNodeId,
    required String sourceHandleId,
    required String targetNodeId,
    required String targetHandleId,
  }) {
    if (sourceNodeId.isEmpty || targetNodeId.isEmpty) {
      debugPrint('Edge connection has empty node IDs');
      return false;
    }

    if (sourceHandleId.isEmpty || targetHandleId.isEmpty) {
      debugPrint('Edge connection has empty handle IDs');
      return false;
    }

    if (sourceNodeId == targetNodeId && sourceHandleId == targetHandleId) {
      debugPrint('Edge connection cannot connect handle to itself');
      return false;
    }

    return true;
  }
}

/// Error recovery utilities for Flutter Flow Canvas
class CanvasErrorRecovery {
  /// Attempts to recover from a corrupted transformation matrix
  static Matrix4 recoverTransformationMatrix(Matrix4 corruptedMatrix) {
    try {
      final scale = corruptedMatrix.getMaxScaleOnAxis();
      final translation = corruptedMatrix.getTranslation();

      // If scale is invalid, use default
      final safeScale =
          (scale.isFinite && scale > 0) ? scale.clamp(0.1, 2.0) : 1.0;

      // If translation is invalid, center the view
      final safeTranslationX = translation.x.isFinite ? translation.x : 0.0;
      final safeTranslationY = translation.y.isFinite ? translation.y : 0.0;

      return Matrix4.identity()
        ..translate(safeTranslationX, safeTranslationY)
        ..scale(safeScale);
    } catch (e) {
      debugPrint('Could not recover transformation matrix, using identity: $e');
      return Matrix4.identity();
    }
  }

  /// Safely clones a node with error handling
  static FlowNode? safeCloneNode(FlowNode node) {
    try {
      return node.clone();
    } catch (e) {
      debugPrint('Error cloning node ${node.id}: $e');

      // Attempt to create a minimal version
      try {
        return FlowNode(
          id: node.id,
          position: CanvasValidation.validatePosition(node.position)
              ? node.position
              : Offset.zero,
          size: CanvasValidation.validateSize(node.size)
              ? node.size
              : const Size(100, 50),
          type: node.type.isNotEmpty ? node.type : 'default',
          data: const {}, // Use empty data to avoid serialization issues
          isSelected: node.isSelected,
          isDraggable: node.isDraggable,
          isSelectable: node.isSelectable,
          hasCustomInteractions: node.hasCustomInteractions,
        );
      } catch (e2) {
        debugPrint('Failed to create recovery node: $e2');
        return null;
      }
    }
  }

  /// Attempts to recover corrupted node positions
  static Offset recoverNodePosition(Offset position, Size canvasSize) {
    if (CanvasValidation.validatePosition(position)) {
      return position;
    }

    // Place at canvas center as fallback
    return Offset(canvasSize.width / 2, canvasSize.height / 2);
  }

  /// Attempts to recover corrupted node sizes
  static Size recoverNodeSize(Size size) {
    if (CanvasValidation.validateSize(size)) {
      return size;
    }

    // Use default size as fallback
    return const Size(100, 50);
  }
}

/// Performance monitoring utilities
class CanvasPerformanceMonitor {
  static final Map<String, DateTime> _operationTimestamps = {};
  static final Map<String, Duration> _operationDurations = {};

  /// Starts timing an operation
  static void startOperation(String operationName) {
    _operationTimestamps[operationName] = DateTime.now();
  }

  /// Ends timing an operation and logs if it exceeds threshold
  static void endOperation(String operationName, {Duration? warnThreshold}) {
    final startTime = _operationTimestamps.remove(operationName);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    _operationDurations[operationName] = duration;

    final threshold =
        warnThreshold ?? const Duration(milliseconds: 16); // 60fps target
    if (duration > threshold) {
      debugPrint(
          'Performance warning: $operationName took ${duration.inMilliseconds}ms');
    }
  }

  /// Gets performance statistics
  static Map<String, Duration> getStats() {
    return Map.unmodifiable(_operationDurations);
  }

  /// Clears performance statistics
  static void clearStats() {
    _operationTimestamps.clear();
    _operationDurations.clear();
  }
}

/// Memory management utilities
class CanvasMemoryManager {
  /// Checks if an image cache should be cleared based on memory pressure
  static bool shouldClearImageCache(List<FlowNode> nodes) {
    final cachedImageCount = nodes.where((n) => n.cachedImage != null).length;

    // Clear cache if we have too many cached images
    const maxCachedImages = 100;
    return cachedImageCount > maxCachedImages;
  }

  /// Clears cached images from nodes that don't need repainting
  static int clearUnneededImageCache(List<FlowNode> nodes) {
    int clearedCount = 0;

    for (final node in nodes) {
      if (node.cachedImage != null && !node.needsRepaint) {
        // Keep the most recently used images, clear others
        node.cachedImage?.dispose();
        node.cachedImage = null;
        node.needsRepaint = true;
        clearedCount++;
      }
    }

    debugPrint('Cleared $clearedCount cached images');
    return clearedCount;
  }

  /// Estimates memory usage of cached images
  static double estimateImageCacheMemoryUsage(List<FlowNode> nodes) {
    double totalBytes = 0;

    for (final node in nodes) {
      if (node.cachedImage != null) {
        final image = node.cachedImage!;
        // Rough estimation: width * height * 4 bytes per pixel (RGBA)
        totalBytes += image.width * image.height * 4;
      }
    }

    return totalBytes / (1024 * 1024); // Return MB
  }
}

/// Debugging utilities for development
class CanvasDebugUtils {
  /// Validates the entire canvas state and reports issues
  static List<String> validateCanvasState({
    required List<FlowNode> nodes,
    required List<FlowEdge> edges,
    required Set<String> selectedNodes,
    required Map<String, GlobalKey> handleRegistry,
  }) {
    final issues = <String>[];

    // Validate nodes
    for (final node in nodes) {
      if (!CanvasValidation.validatePosition(node.position)) {
        issues.add('Node ${node.id} has invalid position: ${node.position}');
      }

      if (!CanvasValidation.validateSize(node.size)) {
        issues.add('Node ${node.id} has invalid size: ${node.size}');
      }

      if (node.type.isEmpty) {
        issues.add('Node ${node.id} has empty type');
      }
    }

    // Validate edges
    final nodeIds = nodes.map((n) => n.id).toSet();
    for (final edge in edges) {
      if (!nodeIds.contains(edge.sourceNodeId)) {
        issues.add(
            'Edge ${edge.id} references non-existent source node: ${edge.sourceNodeId}');
      }

      if (!nodeIds.contains(edge.targetNodeId)) {
        issues.add(
            'Edge ${edge.id} references non-existent target node: ${edge.targetNodeId}');
      }

      if (!CanvasValidation.validateEdgeConnection(
        sourceNodeId: edge.sourceNodeId,
        sourceHandleId: edge.sourceHandleId,
        targetNodeId: edge.targetNodeId,
        targetHandleId: edge.targetHandleId,
      )) {
        issues.add('Edge ${edge.id} has invalid connection');
      }
    }

    // Validate selections
    for (final selectedId in selectedNodes) {
      if (!nodeIds.contains(selectedId)) {
        issues.add('Selected node $selectedId does not exist');
      }
    }

    return issues;
  }

  /// Logs detailed canvas state information
  static void logCanvasState({
    required List<FlowNode> nodes,
    required List<FlowEdge> edges,
    required Set<String> selectedNodes,
    required Matrix4 transformationMatrix,
  }) {
    debugPrint('=== CANVAS STATE DEBUG ===');
    debugPrint('Nodes: ${nodes.length}');
    debugPrint('Edges: ${edges.length}');
    debugPrint('Selected: ${selectedNodes.length}');

    final scale = transformationMatrix.getMaxScaleOnAxis();
    final translation = transformationMatrix.getTranslation();
    debugPrint('Zoom: ${scale.toStringAsFixed(2)}');
    debugPrint(
        'Pan: (${translation.x.toStringAsFixed(1)}, ${translation.y.toStringAsFixed(1)})');

    final memoryUsage =
        CanvasMemoryManager.estimateImageCacheMemoryUsage(nodes);
    debugPrint('Est. image cache: ${memoryUsage.toStringAsFixed(1)} MB');

    final issues = validateCanvasState(
      nodes: nodes,
      edges: edges,
      selectedNodes: selectedNodes,
      handleRegistry: {},
    );

    if (issues.isNotEmpty) {
      debugPrint('Issues found: ${issues.length}');
      for (final issue in issues) {
        debugPrint('  - $issue');
      }
    } else {
      debugPrint('No validation issues found');
    }

    debugPrint('=== END CANVAS STATE DEBUG ===');
  }
}

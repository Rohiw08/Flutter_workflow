import 'dart:math';
import 'package:flutter/material.dart';
import '../state/canvas_state.dart';

class NavigationManager {
  final FlowCanvasState _state;
  final TransformationController transformationController;
  // ignore: unused_field
  final VoidCallback _notify;

  NavigationManager(this._state, this.transformationController, this._notify);

  void pan(Offset screenDelta) {
    final currentMatrix = transformationController.value.clone();
    currentMatrix.translate(screenDelta.dx, screenDelta.dy);
    transformationController.value = currentMatrix;
  }

  void fitView({EdgeInsets padding = const EdgeInsets.all(50)}) {
    if (_state.nodes.isEmpty) return;

    final bounds = _state.nodes
        .map((n) => n.rect)
        .reduce((value, element) => value.expandToInclude(element));

    // Fixed: Validate bounds to prevent division by zero
    if (bounds.width <= 0 || bounds.height <= 0) {
      debugPrint('Invalid bounds for fitView: $bounds');
      return;
    }

    final canvasSize = Size(_state.canvasWidth, _state.canvasHeight);

    // Fixed: Ensure canvas dimensions are positive
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      debugPrint('Invalid canvas size: $canvasSize');
      return;
    }

    // Fixed: Add safety checks for padding
    final totalPaddingWidth = padding.horizontal;
    final totalPaddingHeight = padding.vertical;

    if (totalPaddingWidth >= canvasSize.width ||
        totalPaddingHeight >= canvasSize.height) {
      debugPrint('Padding too large for canvas size');
      return;
    }

    final scaleX = (canvasSize.width - totalPaddingWidth) / bounds.width;
    final scaleY = (canvasSize.height - totalPaddingHeight) / bounds.height;

    // Fixed: Validate scale calculations
    if (!scaleX.isFinite || !scaleY.isFinite || scaleX <= 0 || scaleY <= 0) {
      debugPrint('Invalid scale calculations: scaleX=$scaleX, scaleY=$scaleY');
      return;
    }

    final scale = min(scaleX, min(scaleY, 2.0));

    final scaledBoundsWidth = bounds.width * scale;
    final scaledBoundsHeight = bounds.height * scale;

    final translateX =
        (canvasSize.width - scaledBoundsWidth) / 2 - (bounds.left * scale);
    final translateY =
        (canvasSize.height - scaledBoundsHeight) / 2 - (bounds.top * scale);

    // Fixed: Validate translation values
    if (!translateX.isFinite || !translateY.isFinite) {
      debugPrint(
          'Invalid translation values: translateX=$translateX, translateY=$translateY');
      return;
    }

    try {
      transformationController.value = Matrix4.identity()
        ..translate(translateX, translateY)
        ..scale(scale);
    } catch (e) {
      debugPrint('Error setting transformation matrix: $e');
    }
  }

  void centerView() {
    try {
      transformationController.value = Matrix4.identity();
    } catch (e) {
      debugPrint('Error resetting transformation: $e');
    }
  }

  void zoomIn([double factor = 1.2]) {
    // Fixed: Validate zoom factor
    if (!factor.isFinite || factor <= 0) {
      debugPrint('Invalid zoom factor: $factor');
      return;
    }

    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Fixed: Validate current scale
    if (!currentScale.isFinite || currentScale <= 0) {
      debugPrint('Invalid current scale: $currentScale');
      return;
    }

    if (currentScale * factor <= 2.0) {
      _zoom(factor);
    }
  }

  void zoomOut([double factor = 1.2]) {
    // Fixed: Validate zoom factor
    if (!factor.isFinite || factor <= 0) {
      debugPrint('Invalid zoom factor: $factor');
      return;
    }

    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Fixed: Validate current scale
    if (!currentScale.isFinite || currentScale <= 0) {
      debugPrint('Invalid current scale: $currentScale');
      return;
    }

    if (currentScale / factor >= 0.1) {
      _zoom(1 / factor);
    }
  }

  void _zoom(double factor) {
    // Fixed: Validate zoom factor
    if (!factor.isFinite || factor <= 0) {
      debugPrint('Invalid zoom factor in _zoom: $factor');
      return;
    }

    // Fixed: Validate canvas dimensions
    if (_state.canvasWidth <= 0 || _state.canvasHeight <= 0) {
      debugPrint(
          'Invalid canvas dimensions: ${_state.canvasWidth}x${_state.canvasHeight}');
      return;
    }

    try {
      // This zooms relative to the center of the entire canvas, not the viewport
      final center = Offset(_state.canvasWidth / 2, _state.canvasHeight / 2);
      final sceneCenter = transformationController.toScene(center);

      // Fixed: Validate scene center coordinates
      if (!sceneCenter.dx.isFinite || !sceneCenter.dy.isFinite) {
        debugPrint('Invalid scene center: $sceneCenter');
        return;
      }

      final newMatrix = transformationController.value.clone()
        ..translate(sceneCenter.dx, sceneCenter.dy)
        ..scale(factor)
        ..translate(-sceneCenter.dx, -sceneCenter.dy);

      transformationController.value = newMatrix;
    } catch (e) {
      debugPrint('Error in zoom operation: $e');
    }
  }

  void setZoom(double zoom) {
    // Fixed: Validate zoom value
    if (!zoom.isFinite || zoom <= 0) {
      debugPrint('Invalid zoom value: $zoom');
      return;
    }

    zoom = zoom.clamp(0.1, 2.0);
    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Fixed: Validate current scale
    if (!currentScale.isFinite || currentScale <= 0) {
      debugPrint('Invalid current scale: $currentScale');
      return;
    }

    final scaleFactor = zoom / currentScale;
    _zoom(scaleFactor);
  }

  /// Centers the view on a specific position
  /// Fixed: Accept viewport size as parameter to avoid assumptions
  void centerOnPosition(Offset position, {Size? viewportSize}) {
    // Fixed: Validate position
    if (!position.dx.isFinite || !position.dy.isFinite) {
      debugPrint('Invalid position: $position');
      return;
    }

    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Fixed: Validate current scale
    if (!currentScale.isFinite || currentScale <= 0) {
      debugPrint('Invalid current scale: $currentScale');
      return;
    }

    // Use provided viewport size or fall back to canvas size
    final effectiveViewportSize =
        viewportSize ?? Size(_state.canvasWidth, _state.canvasHeight);

    // Fixed: Validate viewport size
    if (effectiveViewportSize.width <= 0 || effectiveViewportSize.height <= 0) {
      debugPrint('Invalid viewport size: $effectiveViewportSize');
      return;
    }

    try {
      final newTransform = Matrix4.identity()
        ..translate(
            -position.dx * currentScale + effectiveViewportSize.width / 2,
            -position.dy * currentScale + effectiveViewportSize.height / 2)
        ..scale(currentScale);

      transformationController.value = newTransform;
    } catch (e) {
      debugPrint('Error centering on position: $e');
    }
  }

  void zoomAtPoint(double zoomDelta, Offset focalPoint) {
    // Fixed: Validate inputs
    if (!zoomDelta.isFinite) {
      debugPrint('Invalid zoom delta: $zoomDelta');
      return;
    }

    if (!focalPoint.dx.isFinite || !focalPoint.dy.isFinite) {
      debugPrint('Invalid focal point: $focalPoint');
      return;
    }

    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Fixed: Validate current scale
    if (!currentScale.isFinite || currentScale <= 0) {
      debugPrint('Invalid current scale: $currentScale');
      return;
    }

    final newScale = (currentScale + zoomDelta).clamp(0.1, 2.0);
    if (newScale == currentScale) return;

    final scaleChange = newScale / currentScale;

    // Fixed: Validate scale change
    if (!scaleChange.isFinite || scaleChange <= 0) {
      debugPrint('Invalid scale change: $scaleChange');
      return;
    }

    try {
      final matrix = transformationController.value.clone()
        ..translate(focalPoint.dx, focalPoint.dy)
        ..scale(scaleChange, scaleChange)
        ..translate(-focalPoint.dx, -focalPoint.dy);

      transformationController.value = matrix;
    } catch (e) {
      debugPrint('Error in zoom at point: $e');
    }
  }

  /// Validates the current transformation matrix and fixes common issues
  void validateAndFixTransformation() {
    try {
      final matrix = transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();

      // Check for invalid scale values
      if (!scale.isFinite || scale <= 0) {
        debugPrint('Detected invalid transformation, resetting to identity');
        transformationController.value = Matrix4.identity();
        return;
      }

      // Check for invalid translation values
      final translation = matrix.getTranslation();
      if (!translation.x.isFinite || !translation.y.isFinite) {
        debugPrint('Detected invalid translation, resetting to identity');
        transformationController.value = Matrix4.identity();
        return;
      }

      // Clamp scale to valid range
      if (scale < 0.1 || scale > 2.0) {
        setZoom(scale.clamp(0.1, 2.0));
      }
    } catch (e) {
      debugPrint('Error validating transformation: $e');
      transformationController.value = Matrix4.identity();
    }
  }
}

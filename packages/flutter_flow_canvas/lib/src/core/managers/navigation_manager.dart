import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../state/canvas_state.dart';

class NavigationManager {
  final FlowCanvasState _state;
  final TransformationController transformationController;

  final ValueNotifier<bool> _lockNotifier = ValueNotifier<bool>(false);
  bool get isLocked => _lockNotifier.value;
  ValueListenable<bool> get lockState => _lockNotifier;

  NavigationManager(this._state, this.transformationController);

  void dispose() {
    _lockNotifier.dispose();
  }

  /// Toggles the pan and zoom lock on the canvas.
  void toggleLock() {
    _lockNotifier.value = !_lockNotifier.value;
  }

  void pan(Offset screenDelta) {
    if (_lockNotifier.value) return;
    final currentMatrix = transformationController.value.clone();
    currentMatrix.translate(screenDelta.dx, screenDelta.dy);
    transformationController.value = currentMatrix;
  }

  void fitView({EdgeInsets padding = const EdgeInsets.all(50)}) {
    if (_lockNotifier.value || _state.nodes.isEmpty) return;

    final bounds = _state.nodes
        .map((n) => n.rect)
        .reduce((value, element) => value.expandToInclude(element));

    if (bounds.width <= 0 || bounds.height <= 0) {
      debugPrint('Invalid bounds for fitView: $bounds');
      return;
    }

    final context = _state.interactiveViewerKey?.currentContext;
    if (context == null) {
      debugPrint('Cannot fitView without a valid context.');
      return;
    }
    final viewportSize = context.size;
    if (viewportSize == null || viewportSize.isEmpty) return;

    final totalPaddingWidth = padding.horizontal;
    final totalPaddingHeight = padding.vertical;

    if (totalPaddingWidth >= viewportSize.width ||
        totalPaddingHeight >= viewportSize.height) {
      debugPrint('Padding too large for viewport size');
      return;
    }

    final scaleX = (viewportSize.width - totalPaddingWidth) / bounds.width;
    final scaleY = (viewportSize.height - totalPaddingHeight) / bounds.height;

    if (!scaleX.isFinite || !scaleY.isFinite || scaleX <= 0 || scaleY <= 0) {
      debugPrint('Invalid scale calculations: scaleX=$scaleX, scaleY=$scaleY');
      return;
    }

    final scale = min(scaleX, min(scaleY, 2.0));

    final scaledBoundsWidth = bounds.width * scale;
    final scaledBoundsHeight = bounds.height * scale;

    final translateX =
        (viewportSize.width - scaledBoundsWidth) / 2 - (bounds.left * scale);
    final translateY =
        (viewportSize.height - scaledBoundsHeight) / 2 - (bounds.top * scale);

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
    if (_lockNotifier.value) return;
    try {
      transformationController.value = Matrix4.identity();
    } catch (e) {
      debugPrint('Error resetting transformation: $e');
    }
  }

  void zoomIn([double factor = 1.2]) {
    if (_lockNotifier.value || !factor.isFinite || factor <= 0) {
      return;
    }
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (!currentScale.isFinite || currentScale <= 0) {
      return;
    }
    if (currentScale * factor <= 2.0) {
      _zoom(factor);
    }
  }

  void zoomOut([double factor = 1.2]) {
    if (_lockNotifier.value || !factor.isFinite || factor <= 0) {
      return;
    }
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (!currentScale.isFinite || currentScale <= 0) {
      return;
    }
    if (currentScale / factor >= 0.1) {
      _zoom(1 / factor);
    }
  }

  void _zoom(double factor) {
    if (_lockNotifier.value) return;
    final context = _state.interactiveViewerKey?.currentContext;
    if (context == null) {
      debugPrint('Cannot zoom without a valid context.');
      return;
    }
    final viewportSize = context.size;
    if (viewportSize == null || viewportSize.isEmpty) return;
    final viewportCenter =
        Offset(viewportSize.width / 2, viewportSize.height / 2);
    final sceneCenter = transformationController.toScene(viewportCenter);
    try {
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
    if (_lockNotifier.value || !zoom.isFinite || zoom <= 0) {
      return;
    }
    zoom = zoom.clamp(0.1, 2.0);
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (!currentScale.isFinite || currentScale <= 0) {
      return;
    }
    final scaleFactor = zoom / currentScale;
    _zoom(scaleFactor);
  }

  void centerOnPosition(Offset position, {Size? viewportSize}) {
    if (_lockNotifier.value || !position.dx.isFinite || !position.dy.isFinite) {
      return;
    }
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (!currentScale.isFinite || currentScale <= 0) {
      return;
    }
    final context = _state.interactiveViewerKey?.currentContext;
    final effectiveViewportSize = viewportSize ?? context?.size;
    if (effectiveViewportSize == null || effectiveViewportSize.isEmpty) {
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
    if (_lockNotifier.value || !zoomDelta.isFinite) {
      return;
    }
    if (!focalPoint.dx.isFinite || !focalPoint.dy.isFinite) {
      return;
    }
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (!currentScale.isFinite || currentScale <= 0) {
      return;
    }
    final newScale = (currentScale + zoomDelta).clamp(0.1, 2.0);
    if (newScale == currentScale) return;
    final scaleChange = newScale / currentScale;
    if (!scaleChange.isFinite || scaleChange <= 0) {
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

  void validateAndFixTransformation() {
    try {
      final matrix = transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();
      if (!scale.isFinite || scale <= 0) {
        debugPrint('Detected invalid transformation, resetting to identity');
        transformationController.value = Matrix4.identity();
        return;
      }
      final translation = matrix.getTranslation();
      if (!translation.x.isFinite || !translation.y.isFinite) {
        debugPrint('Detected invalid translation, resetting to identity');
        transformationController.value = Matrix4.identity();
        return;
      }
      if (scale < 0.1 || scale > 2.0) {
        setZoom(scale.clamp(0.1, 2.0));
      }
    } catch (e) {
      debugPrint('Error validating transformation: $e');
      transformationController.value = Matrix4.identity();
    }
  }
}

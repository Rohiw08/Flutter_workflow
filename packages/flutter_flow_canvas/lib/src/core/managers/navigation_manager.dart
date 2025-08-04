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

    final canvasSize = Size(_state.canvasWidth, _state.canvasHeight);
    final scaleX = canvasSize.width / (bounds.width + padding.horizontal);
    final scaleY = canvasSize.height / (bounds.height + padding.vertical);
    final scale = min(scaleX, min(scaleY, 2.0));

    final scaledBoundsWidth = bounds.width * scale;
    final scaledBoundsHeight = bounds.height * scale;

    final translateX =
        (canvasSize.width - scaledBoundsWidth) / 2 - (bounds.left * scale);
    final translateY =
        (canvasSize.height - scaledBoundsHeight) / 2 - (bounds.top * scale);

    transformationController.value = Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(scale);
  }

  void centerView() {
    transformationController.value = Matrix4.identity();
  }

  void zoomIn([double factor = 1.2]) {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale * factor <= 2.0) {
      _zoom(factor);
    }
  }

  void zoomOut([double factor = 1.2]) {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale / factor >= 0.1) {
      _zoom(1 / factor);
    }
  }

  void _zoom(double factor) {
    // This zooms relative to the center of the entire canvas, not the viewport
    final center = Offset(_state.canvasWidth / 2, _state.canvasHeight / 2);
    final sceneCenter = transformationController.toScene(center);
    final newMatrix = transformationController.value.clone()
      ..translate(sceneCenter.dx, sceneCenter.dy)
      ..scale(factor)
      ..translate(-sceneCenter.dx, -sceneCenter.dy);
    transformationController.value = newMatrix;
  }

  void setZoom(double zoom) {
    zoom = zoom.clamp(0.1, 2.0);
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    final scaleFactor = zoom / currentScale;
    _zoom(scaleFactor);
  }

  void centerOnPosition(Offset position) {
    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Note: This assumes the viewport is the same size as the canvas, which might not be true.
    // A more robust solution would require passing the actual viewport size.
    final screenWidth = _state.canvasWidth;
    final screenHeight = _state.canvasHeight;

    final newTransform = Matrix4.identity()
      ..translate(-position.dx * currentScale + screenWidth / 2,
          -position.dy * currentScale + screenHeight / 2)
      ..scale(currentScale);

    transformationController.value = newTransform;
  }

  void zoomAtPoint(double zoomDelta, Offset focalPoint) {
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale + zoomDelta).clamp(0.1, 2.0);
    if (newScale == currentScale) return;

    final scaleChange = newScale / currentScale;

    final matrix = transformationController.value.clone()
      ..translate(focalPoint.dx, focalPoint.dy)
      ..scale(scaleChange, scaleChange)
      ..translate(-focalPoint.dx, -focalPoint.dy);

    transformationController.value = matrix;
  }
}

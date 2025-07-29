import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/providers/canvas_provider.dart';
import 'control_button.dart';

/// Defines the position of the control panel on the canvas.
enum PanelPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class Controls extends ConsumerWidget {
  final bool showZoom;
  final bool showFitView;
  final bool showInteractive;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFitView;
  final ValueChanged<bool>? onInteractiveChange;
  final PanelPosition position;
  final Axis orientation;
  final List<Widget>? children;
  final double scaleFactor;

  const Controls({
    super.key,
    this.showZoom = true,
    this.showFitView = true,
    this.showInteractive = true,
    this.onZoomIn,
    this.onZoomOut,
    this.onFitView,
    this.onInteractiveChange,
    this.position = PanelPosition.bottomLeft,
    this.orientation = Axis.vertical,
    this.children,
    this.scaleFactor = 0.2,
  });

  void _onZoomInPressed(WidgetRef ref) {
    final controller = ref.read(transformationControllerProvider);
    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = currentScale + scaleFactor;
    final halfWidth = ref.context.size!.width / 2;
    final halfHeight = ref.context.size!.height / 2;

    // Zoom towards the center of the viewport
    final newMatrix = Matrix4.identity()
      ..translate(halfWidth, halfHeight)
      ..scale(newScale / currentScale)
      ..translate(-halfWidth, -halfHeight);

    controller.value = newMatrix * controller.value;
    onZoomIn?.call();
  }

  void _onZoomOutPressed(WidgetRef ref) {
    final controller = ref.read(transformationControllerProvider);
    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale - scaleFactor).clamp(0.1, 5.0); // Clamp to min/max scale
     final halfWidth = ref.context.size!.width / 2;
    final halfHeight = ref.context.size!.height / 2;

    final newMatrix = Matrix4.identity()
      ..translate(halfWidth, halfHeight)
      ..scale(newScale / currentScale)
      ..translate(-halfWidth, -halfHeight);

    controller.value = newMatrix * controller.value;
    onZoomOut?.call();
  }

  void _onFitViewPressed(WidgetRef ref) {
    if (onFitView != null) {
      onFitView!();
    } else {
      // Default behavior: Reset to initial centered view
      final controller = ref.read(transformationControllerProvider);
      // Assuming a large canvas size like 50000
      const canvasSize = 50000.0;
      controller.value = Matrix4.identity()
        ..translate(-canvasSize / 2, -canvasSize / 2);
    }
  }

  void _onInteractiveChangePressed(WidgetRef ref) {
    final isInteractive = ref.read(isInteractiveProvider.notifier);
    isInteractive.state = !isInteractive.state;
    onInteractiveChange?.call(isInteractive.state);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInteractive = ref.watch(isInteractiveProvider);

    final controlButtons = <Widget>[
      if (showZoom)
        ControlButton(
          onPressed: () => _onZoomInPressed(ref),
          tooltip: 'Zoom In',
          child: const Icon(Icons.add),
        ),
      if (showZoom)
        ControlButton(
          onPressed: () => _onZoomOutPressed(ref),
          tooltip: 'Zoom Out',
          child: const Icon(Icons.remove),
        ),
      if (showFitView)
        ControlButton(
          onPressed: () => _onFitViewPressed(ref),
          tooltip: 'Fit View',
          child: const Icon(Icons.fit_screen),
        ),
      if (showInteractive)
        ControlButton(
          onPressed: () => _onInteractiveChangePressed(ref),
          tooltip: isInteractive ? 'Lock' : 'Unlock',
          child: Icon(isInteractive ? Icons.lock_open : Icons.lock),
        ),
      if (children != null) ...children!,
    ];

    return Positioned(
      top: position == PanelPosition.topLeft || position == PanelPosition.topRight
          ? 20
          : null,
      bottom: position == PanelPosition.bottomLeft ||
              position == PanelPosition.bottomRight
          ? 20
          : null,
      left: position == PanelPosition.topLeft ||
              position == PanelPosition.bottomLeft
          ? 20
          : null,
      right: position == PanelPosition.topRight ||
              position == PanelPosition.bottomRight
          ? 20
          : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        child: Flex(
          direction: orientation,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < controlButtons.length; i++)
              Padding(
                padding: orientation == Axis.vertical
                    ? EdgeInsets.only(top: i == 0 ? 0 : 6)
                    : EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: controlButtons[i],
              ),
          ],
        ),
      ),
    );
  }
}
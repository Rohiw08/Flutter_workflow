import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'painters/background_painter.dart';
import 'painters/flow_painter.dart';

class FlowCanvas extends ConsumerStatefulWidget {
  final BackgroundVariant backgroundVariant;
  final bool showControls;
  final Color? backgroundColor;
  final double minScale;
  final double maxScale;
  final bool interactive;
  final Size? canvasSize;

  const FlowCanvas({
    super.key,
    this.backgroundVariant = BackgroundVariant.dots,
    this.showControls = true,
    this.backgroundColor,
    this.minScale = 0.1,
    this.maxScale = 2.0,
    this.interactive = true,
    this.canvasSize,
  });

  @override
  ConsumerState<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends ConsumerState<FlowCanvas> {
  final FocusNode _focusNode = FocusNode();
  final Map<String, GlobalKey> _nodeKeys = {};

  @override
  void initState() {
    super.initState();
    if (widget.interactive) {
      _focusNode.requestFocus();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureNodeImages());
  }

  @override
  void didUpdateWidget(covariant FlowCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = ref.read(flowControllerProvider);
    if (controller.nodes.any((n) => n.needsRepaint)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureNodeImages());
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _updateNodeKeys(FlowCanvasController controller) {
    final newKeys = <String, GlobalKey>{};
    for (final node in controller.nodes) {
      if (node.needsRepaint) {
        newKeys[node.id] = _nodeKeys[node.id] ?? GlobalKey();
      }
    }
    _nodeKeys
      ..clear()
      ..addAll(newKeys);
  }

  void _captureNodeImages() async {
    if (!mounted) return;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final controller = ref.read(flowControllerProvider);

    for (final nodeId in _nodeKeys.keys) {
      final boundary = _nodeKeys[nodeId]?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        if (mounted) {
          controller.nodeManager.updateNodeImage(nodeId, image);
        }
      }
    }
  }

  Size _canvasSize(FlowCanvasController controller) =>
      widget.canvasSize ??
      Size(controller.canvasWidth, controller.canvasHeight);

  Widget _buildCanvasContent(FlowCanvasController controller) {
    // Dynamically disable InteractiveViewer's panning when dragging nodes or box selecting
    final isPanningEnabled = widget.interactive &&
        controller.dragMode != DragMode.node &&
        controller.dragMode != DragMode.selection;

    return Listener(
      onPointerMove: widget.interactive
          ? (details) {
              if (controller.dragMode == DragMode.handle) {
                controller.connectionManager.updateConnection(details.position);
              }
            }
          : null,
      onPointerUp: widget.interactive
          ? (_) {
              if (controller.dragMode == DragMode.handle) {
                controller.connectionManager.endConnection();
              }
            }
          : null,
      child: GestureDetector(
        onPanStart: widget.interactive
            ? controller.interactionHandler.onPanStart
            : null,
        onPanUpdate: widget.interactive
            ? controller.interactionHandler.onPanUpdate
            : null,
        onPanEnd:
            widget.interactive ? controller.interactionHandler.onPanEnd : null,
        child: InteractiveViewer(
          transformationController: controller.transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(0),
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          panEnabled: isPanningEnabled,
          scaleEnabled: widget.interactive,
          child: SizedBox(
            width: _canvasSize(controller).width,
            height: _canvasSize(controller).height,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(controller.canvasWidth, controller.canvasHeight),
                  painter: BackgroundPainter(
                    matrix: controller.transformationController.value,
                    variant: widget.backgroundVariant,
                  ),
                ),
                CustomPaint(
                  size: Size(controller.canvasWidth, controller.canvasHeight),
                  painter: FlowPainter(controller: controller),
                ),
                ...controller.nodes.map((node) {
                  final nodeWidget = controller.getNodeWidget(node.id);
                  if (nodeWidget == null) return const SizedBox.shrink();
                  return Positioned(
                    left: node.position.dx,
                    top: node.position.dy,
                    child: nodeWidget,
                  );
                }),
                Offstage(
                  offstage: true,
                  child: Stack(
                    children: controller.nodes
                        .where((n) => n.needsRepaint)
                        .map((node) {
                      final nodeWidget = controller.getNodeWidget(node.id);
                      if (nodeWidget == null) return const SizedBox.shrink();
                      return RepaintBoundary(
                        key: _nodeKeys[node.id],
                        child: Material(
                          type: MaterialType.transparency,
                          child: nodeWidget,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(flowControllerProvider);
    _updateNodeKeys(controller);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent:
          widget.interactive ? controller.keyboardHandler.handleKeyEvent : null,
      child: Container(
        color: widget.backgroundColor,
        child: Stack(
          children: [
            _buildCanvasContent(controller),
            if (widget.showControls)
              const FlowCanvasControls(
                alignment: ControlPanelAlignment.bottomLeft,
                orientation: Axis.vertical,
              ),
          ],
        ),
      ),
    );
  }
}

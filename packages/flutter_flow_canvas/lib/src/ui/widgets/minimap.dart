import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../flutter_flow_canvas.dart';
import 'painters/minimap_painter.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

/// A function that returns a color for a given node.
typedef MiniMapNodeColorFunc = Color? Function(FlowNode node);

/// A custom builder function to render a node in the minimap.
typedef MiniMapNodeBuilder = Path Function(FlowNode node);

/// A callback for when a node in the minimap is clicked.
typedef MiniMapNodeOnClick = void Function(FlowNode node);

/// A theme-aware, miniature overview map of the canvas.
class MiniMap extends ConsumerStatefulWidget {
  // --- Sizing and Positioning ---
  final double width;
  final double height;
  final Alignment alignment;
  final EdgeInsets margin;

  // --- Functional Overrides ---
  final MiniMapNodeColorFunc? nodeColor;
  final MiniMapNodeColorFunc? nodeStrokeColor;
  final MiniMapNodeBuilder? nodeBuilder;
  final MiniMapNodeOnClick? onNodeClick;

  // --- Interactivity ---
  final bool pannable;
  final bool zoomable;
  final bool inversePan;
  final double zoomStep;

  // --- Accessibility ---
  final String ariaLabel;

  // REMOVED: All direct styling properties are now handled by the theme.

  const MiniMap({
    super.key,
    this.width = 200,
    this.height = 150,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
    this.nodeColor,
    this.nodeStrokeColor,
    this.nodeBuilder,
    this.pannable = true,
    this.zoomable = true,
    this.inversePan = false,
    this.zoomStep = 0.1,
    this.onNodeClick,
    this.ariaLabel = 'Mini map',
  });

  @override
  ConsumerState<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends ConsumerState<MiniMap> {
  // The interaction logic (_onTapUp, _onPanUpdate, _onPointerSignal) remains unchanged.
  void _onTapUp(FlowCanvasController controller, Offset localPosition) {
    final transform = MiniMapPainter.calculateTransform(
      controller.getNodesBounds(),
      Size(widget.width, widget.height),
    );
    for (final node in controller.nodes.reversed) {
      final nodeRect = MiniMapPainter.getNodeRect(node, transform);
      if (nodeRect.contains(localPosition)) {
        widget.onNodeClick?.call(node);
        return;
      }
    }
    if (transform.scale > 0) {
      final canvasPosition =
          MiniMapPainter.fromMiniMapToCanvas(localPosition, transform);
      controller.navigationManager.centerOnPosition(canvasPosition);
    }
  }

  void _onPanUpdate(
      DragUpdateDetails details, FlowCanvasController controller) {
    final transform = MiniMapPainter.calculateTransform(
      controller.getNodesBounds(),
      Size(widget.width, widget.height),
    );
    if (transform.scale <= 0) return;
    final panDelta = widget.inversePan ? details.delta : -details.delta;
    final canvasDelta =
        Offset(panDelta.dx / transform.scale, panDelta.dy / transform.scale);
    controller.navigationManager.pan(canvasDelta);
  }

  void _onPointerSignal(
      PointerSignalEvent event, FlowCanvasController controller) {
    if (event is PointerScrollEvent) {
      final transform = MiniMapPainter.calculateTransform(
        controller.getNodesBounds(),
        Size(widget.width, widget.height),
      );
      if (transform.scale <= 0) return;
      final canvasPosition =
          MiniMapPainter.fromMiniMapToCanvas(event.localPosition, transform);
      final zoomDelta = -event.scrollDelta.dy * 0.001 * widget.zoomStep;
      controller.navigationManager.zoomAtPoint(zoomDelta, canvasPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(flowControllerProvider);
    // UPDATED: Get the specific minimap theme from the context
    final miniMapTheme = context.flowCanvasTheme.miniMap;

    return Align(
      alignment: widget.alignment,
      child: Semantics(
        label: widget.ariaLabel,
        child: Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          // UPDATED: Decoration is now sourced from the theme.
          decoration: BoxDecoration(
            color: miniMapTheme.backgroundColor,
            borderRadius: BorderRadius.circular(miniMapTheme.borderRadius),
            border: Border.all(color: miniMapTheme.maskStrokeColor, width: 1),
            boxShadow: miniMapTheme.shadows,
          ),
          child: ClipRRect(
            // UPDATED: borderRadius is sourced from the theme.
            borderRadius: BorderRadius.circular(miniMapTheme.borderRadius),
            child: Listener(
              onPointerSignal: widget.zoomable
                  ? (e) => _onPointerSignal(e, controller)
                  : null,
              child: GestureDetector(
                onTapUp: (details) =>
                    _onTapUp(controller, details.localPosition),
                onPanUpdate: widget.pannable
                    ? (details) => _onPanUpdate(details, controller)
                    : null,
                child: CustomPaint(
                  // UPDATED: Painter no longer needs direct styling properties.
                  painter: MiniMapPainter(
                    controller: controller,
                    nodeColor: widget.nodeColor,
                    nodeStrokeColor: widget.nodeStrokeColor,
                    nodeBuilder: widget.nodeBuilder,
                    minimapSize: Size(widget.width, widget.height),
                  ),
                  size: Size(widget.width, widget.height),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

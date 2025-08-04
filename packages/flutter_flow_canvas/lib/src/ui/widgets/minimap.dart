import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../flutter_flow_canvas.dart';
import 'painters/minimap_painter.dart';

/// A function that returns a color for a given node.
typedef MiniMapNodeColorFunc = Color? Function(FlowNode node);

/// A custom builder function to render a node in the minimap.
typedef MiniMapNodeBuilder = Path Function(FlowNode node);

/// A callback for when a node in the minimap is clicked.
typedef MiniMapNodeOnClick = void Function(FlowNode node);

/// A miniature overview map of the canvas, with extensive customization.
class MiniMap extends ConsumerStatefulWidget {
  // --- Sizing and Positioning ---
  final double width;
  final double height;
  final Alignment alignment;
  final EdgeInsets margin;

  // --- Node Styling ---
  final MiniMapNodeColorFunc? nodeColor;
  final MiniMapNodeColorFunc? nodeStrokeColor;
  final double nodeBorderRadius;
  final double nodeStrokeWidth;
  final MiniMapNodeBuilder? nodeBuilder;

  // --- Mask (Viewport) Styling ---
  final Color maskColor;
  final Color maskStrokeColor;
  final double maskStrokeWidth;

  // --- Interactivity ---
  final bool pannable;
  final bool zoomable;
  final bool inversePan;
  final double zoomStep;
  final MiniMapNodeOnClick? onNodeClick;

  // --- Accessibility & Misc ---
  final String ariaLabel;
  final Color backgroundColor;

  const MiniMap({
    super.key,
    this.width = 200,
    this.height = 150,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
    this.nodeColor,
    this.nodeStrokeColor,
    this.nodeBorderRadius = 2.0,
    this.nodeStrokeWidth = 1.5,
    this.nodeBuilder,
    this.maskColor = const Color(0x99F0F2F5), // Semi-transparent light grey
    this.maskStrokeColor = Colors.grey,
    this.maskStrokeWidth = 1.0,
    this.pannable = true,
    this.zoomable = true,
    this.inversePan = false,
    this.zoomStep = 0.1,
    this.onNodeClick,
    this.ariaLabel = 'Mini map',
    this.backgroundColor = Colors.white,
  });

  @override
  ConsumerState<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends ConsumerState<MiniMap> {
  void _onTapUp(FlowCanvasController controller, Offset localPosition) {
    final transform = MiniMapPainter.calculateTransform(
      controller.getNodesBounds(),
      Size(widget.width, widget.height),
    );

    // Hit-test for nodes first
    for (final node in controller.nodes.reversed) {
      final nodeRect = MiniMapPainter.getNodeRect(node, transform);
      if (nodeRect.contains(localPosition)) {
        widget.onNodeClick?.call(node);
        return; // Stop after finding the first node
      }
    }

    // If no node was clicked, navigate the main canvas
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

    return Align(
      alignment: widget.alignment,
      child: Semantics(
        label: widget.ariaLabel,
        child: Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withAlpha(240),
            borderRadius: BorderRadius.circular(widget.nodeBorderRadius + 1),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.nodeBorderRadius),
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
                  painter: MiniMapPainter(
                    controller: controller,
                    nodeColor: widget.nodeColor,
                    nodeStrokeColor: widget.nodeStrokeColor,
                    nodeBorderRadius: widget.nodeBorderRadius,
                    nodeStrokeWidth: widget.nodeStrokeWidth,
                    nodeBuilder: widget.nodeBuilder,
                    maskColor: widget.maskColor,
                    maskStrokeColor: widget.maskStrokeColor,
                    maskStrokeWidth: widget.maskStrokeWidth,
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

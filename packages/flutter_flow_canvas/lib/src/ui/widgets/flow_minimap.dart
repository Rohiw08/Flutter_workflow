import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/canvas_controller.dart';
import 'package:flutter_flow_canvas/src/core/models/node.dart';
import 'package:flutter_flow_canvas/src/core/providers.dart';
import 'package:flutter_flow_canvas/src/theme/components/minimap_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_resolver/minimap_theme_resolver.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/painters/minimap_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A function that returns a color for a given node.
typedef MiniMapNodeColorFunc = Color? Function(FlowNode node);

/// A custom builder function to render a node in the minimap.
typedef MiniMapNodeBuilder = Path Function(FlowNode node);

/// A callback for when a node in the minimap is clicked.
typedef MiniMapNodeOnClick = void Function(FlowNode node);

/// Complete React Flow-style MiniMap widget
class FlowCanvasMiniMap extends ConsumerStatefulWidget {
  // --- Sizing and Positioning ---
  final double width;
  final double height;
  final Alignment position;
  final EdgeInsets margin;
  final Alignment? customAlignment;

  // --- Theming ---
  final FlowCanvasMiniMapTheme? theme;
  final Color? backgroundColor;
  final Color? nodeColor;
  final Color? nodeStrokeColor;
  final Color? selectedNodeColor;
  final Color? maskColor;
  final Color? maskStrokeColor;

  // --- Functional Overrides ---
  final MiniMapNodeColorFunc? nodeColorFunction;
  final MiniMapNodeColorFunc? nodeStrokeColorFunction;
  final MiniMapNodeBuilder? nodeBuilder;
  final MiniMapNodeOnClick? onNodeClick;

  // --- Interactivity ---
  final bool pannable;
  final bool zoomable;
  final bool inversePan;
  final double zoomStep;

  // --- Customization ---
  final double offsetScale;
  final double? nodeStrokeWidth;
  final double? maskStrokeWidth;
  final double? borderRadius;
  final double? nodeBorderRadius;

  // --- Accessibility ---
  final String ariaLabel;

  const FlowCanvasMiniMap({
    super.key,
    this.width = 200,
    this.height = 150,
    this.position = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(20),
    this.customAlignment,
    this.theme,
    this.backgroundColor,
    this.nodeColor,
    this.nodeStrokeColor,
    this.selectedNodeColor,
    this.maskColor,
    this.maskStrokeColor,
    this.nodeColorFunction,
    this.nodeStrokeColorFunction,
    this.nodeBuilder,
    this.pannable = true,
    this.zoomable = true,
    this.inversePan = true,
    this.zoomStep = 1,
    this.offsetScale = 1.0,
    this.nodeStrokeWidth,
    this.maskStrokeWidth,
    this.borderRadius,
    this.nodeBorderRadius,
    this.onNodeClick,
    this.ariaLabel = 'Flow canvas minimap',
  });

  @override
  ConsumerState<FlowCanvasMiniMap> createState() => _FlowCanvasMiniMapState();
}

class _FlowCanvasMiniMapState extends ConsumerState<FlowCanvasMiniMap>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  FlowCanvasMiniMapTheme _getEffectiveTheme(BuildContext context) {
    return resolveMiniMapTheme(
      context,
      widget.theme,
      backgroundColor: widget.backgroundColor,
      nodeColor: widget.nodeColor,
      nodeStrokeColor: widget.nodeStrokeColor,
      selectedNodeColor: widget.selectedNodeColor,
      maskColor: widget.maskColor,
      maskStrokeColor: widget.maskStrokeColor,
      nodeStrokeWidth: widget.nodeStrokeWidth,
      maskStrokeWidth: widget.maskStrokeWidth,
      borderRadius: widget.borderRadius,
      nodeBorderRadius: widget.nodeBorderRadius,
    );
  }

  void _onTapUp(FlowCanvasController controller, Offset localPosition) {
    final canvasBounds = MiniMapPainter.getCanvasBounds(controller);
    final transform = MiniMapPainter.calculateTransform(
      canvasBounds,
      Size(widget.width, widget.height),
      widget.offsetScale,
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
    final canvasBounds = MiniMapPainter.getCanvasBounds(controller);
    final transform = MiniMapPainter.calculateTransform(
      canvasBounds,
      Size(widget.width, widget.height),
      widget.offsetScale,
    );

    if (transform.scale <= 0) return;

    final panDelta = widget.inversePan ? details.delta : -details.delta;
    final canvasDelta = Offset(
      panDelta.dx / transform.scale,
      panDelta.dy / transform.scale,
    );

    controller.navigationManager.pan(canvasDelta);
  }

  void _onPointerSignal(
      PointerSignalEvent event, FlowCanvasController controller) {
    if (event is PointerScrollEvent) {
      final canvasBounds = MiniMapPainter.getCanvasBounds(controller);
      final transform = MiniMapPainter.calculateTransform(
        canvasBounds,
        Size(widget.width, widget.height),
        widget.offsetScale,
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
    final effectiveTheme = _getEffectiveTheme(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Align(
            alignment: widget.position,
            child: Container(
              margin: widget.margin,
              child: Semantics(
                label: widget.ariaLabel,
                hint: 'Minimap showing overview of the flow canvas',
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: effectiveTheme.backgroundColor,
                    borderRadius:
                        BorderRadius.circular(effectiveTheme.borderRadius),
                    border: Border.all(
                      color: effectiveTheme.maskStrokeColor.withAlpha(76),
                      width: 1,
                    ),
                    boxShadow: effectiveTheme.shadows,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(effectiveTheme.borderRadius),
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
                        child: MouseRegion(
                          cursor: widget.pannable
                              ? SystemMouseCursors.grab
                              : widget.zoomable
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.basic,
                          child: CustomPaint(
                            painter: MiniMapPainter(
                              controller: controller,
                              theme: effectiveTheme,
                              nodeColor: widget.nodeColorFunction,
                              nodeStrokeColor: widget.nodeStrokeColorFunction,
                              nodeBuilder: widget.nodeBuilder,
                              minimapSize: Size(widget.width, widget.height),
                              offsetScale: widget.offsetScale,
                            ),
                            size: Size(widget.width, widget.height),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

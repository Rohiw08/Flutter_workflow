import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/canvas_controller.dart';
import '../../core/providers.dart';
import 'flow_canvas_controls.dart';
import 'painters/background_painter.dart';
import 'painters/flow_painter.dart';

// ... (FlowCanvas widget is unchanged)
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
  late FlowCanvasController controller;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureNodeImages());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ref.watch(flowControllerProvider);
    _updateNodeKeys();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _updateNodeKeys() {
    final newKeys = <String, GlobalKey>{};
    for (final node in controller.nodes) {
      if (node.needsRepaint) {
        newKeys[node.id] = _nodeKeys[node.id] ?? GlobalKey();
      }
    }
    _nodeKeys.clear();
    _nodeKeys.addAll(newKeys);
  }

  void _captureNodeImages() async {
    if (!mounted) return;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    for (final nodeId in _nodeKeys.keys) {
      final boundary = _nodeKeys[nodeId]?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        if (mounted) {
          final node = controller.getNode(nodeId);
          if (node != null) {
            controller.updateNodeImage(nodeId, image);
          }
        }
      }
    }
  }

  Size get _canvasSize =>
      widget.canvasSize ??
      Size(controller.canvasWidth, controller.canvasHeight);

  @override
  Widget build(BuildContext context) {
    _updateNodeKeys();
    return Container(
      color: widget.backgroundColor,
      child:
          widget.interactive ? _buildInteractiveCanvas() : _buildStaticCanvas(),
    );
  }

  Widget _buildInteractiveCanvas() {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        controller.handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        onTap: () {
          if (widget.interactive) {
            _focusNode.requestFocus();
          }
        },
        child: Stack(
          children: [
            _buildCanvasContent(),
            if (widget.showControls) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticCanvas() {
    return _buildCanvasContent();
  }

  Widget _buildCanvasContent() {
    return Listener(
      onPointerMove: widget.interactive
          ? (details) {
              if (controller.dragMode == DragMode.handle) {
                controller.updateConnection(details.position);
              }
            }
          : null,
      onPointerUp: widget.interactive
          ? (_) {
              if (controller.dragMode == DragMode.handle) {
                controller.endConnection();
              }
            }
          : null,
      child: GestureDetector(
        onPanStart: widget.interactive ? controller.onPanStart : null,
        onPanUpdate: widget.interactive ? controller.onPanUpdate : null,
        onPanEnd: widget.interactive ? controller.onPanEnd : null,
        child: InteractiveViewer(
          transformationController: controller.transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(0),
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          panEnabled: widget.interactive,
          scaleEnabled: widget.interactive,
          child: SizedBox(
            width: _canvasSize.width,
            height: _canvasSize.height,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return Stack(
                  children: [
                    // Background layer
                    CustomPaint(
                      painter: BackgroundPainter(
                        matrix: controller.transformationController.value,
                        variant: widget.backgroundVariant,
                      ),
                      size: _canvasSize,
                    ),

                    // Main painter for nodes, edges, etc.
                    CustomPaint(
                      painter: FlowPainter(controller: controller),
                      size: _canvasSize,
                    ),

                    // Offstage stack for rendering nodes to images
                    Offstage(
                      offstage: true,
                      child: Stack(
                        children: [
                          ...controller.nodes.where((n) => n.needsRepaint).map(
                            (node) {
                              final nodeWidget =
                                  controller.getNodeWidget(node.id);
                              if (nodeWidget == null) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                left: node.position.dx,
                                top: node.position.dy,
                                child: RepaintBoundary(
                                  key: _nodeKeys[node.id],
                                  // ================================= //
                                  //           CHANGE START            //
                                  // ================================= //
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: nodeWidget,
                                  ),
                                  // ================================= //
                                  //            CHANGE END             //
                                  // ================================= //
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      top: 16,
      left: 16,
      child: FlowCanvasControls(controller: controller),
    );
  }
}

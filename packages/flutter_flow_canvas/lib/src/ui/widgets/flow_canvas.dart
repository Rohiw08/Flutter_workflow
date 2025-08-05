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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _captureNodeImages();
    });
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

  bool _pendingNodeKeysUpdate = false;

  void _scheduleUpdateNodeKeys(FlowCanvasController controller) {
    if (_pendingNodeKeysUpdate) return;
    _pendingNodeKeysUpdate = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateNodeKeys(controller);
        _pendingNodeKeysUpdate = false;
      }
    });
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
    if (!mounted || _nodeKeys.isEmpty) return;

    final controller = ref.read(flowControllerProvider);
    final nodesToRepaint =
        controller.nodes.where((n) => n.needsRepaint).toList();
    if (nodesToRepaint.isEmpty) return;

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // 1. Create a list of futures. Each future will eventually return a tuple or null.
    final futures = _nodeKeys.entries.map((entry) async {
      final nodeId = entry.key;
      final boundary = entry.value.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        return (nodeId, image); // This is a Future<(String, ui.Image)>
      }
      return null; // This is a Future<null>
    }).toList(); // Convert to a list to pass to Future.wait

    // 2. Await all the futures to complete in parallel.
    // The result is a list of the resolved values (tuples or nulls).
    final results = await Future.wait(futures);

    if (!mounted) return;

    // 3. Now, process the results.
    // We iterate through the list of captured images and update the controller.
    for (final result in results) {
      if (result != null) {
        // The 'result' is the (String, ui.Image) tuple.
        final (nodeId, image) = result;
        controller.nodeManager.updateNodeImage(nodeId, image);
      }
    }
  }

  Size _canvasSize(FlowCanvasController controller) =>
      widget.canvasSize ??
      Size(controller.canvasWidth, controller.canvasHeight);

  Widget _buildNode({
    required FlowCanvasController controller,
    required FlowNode node,
    required bool isInteractive,
    required bool isForCapture,
  }) {
    final Widget? nodeWidget = controller.getNodeWidget(node);

    if (nodeWidget == null) {
      return _buildMissingNodeWidget(node);
    }

    Widget finalWidget = nodeWidget;

    // Wrap in RepaintBoundary for image capture
    if (isForCapture) {
      finalWidget = RepaintBoundary(
        key: _nodeKeys[node.id],
        child: Material(
          type: MaterialType.transparency,
          child: finalWidget,
        ),
      );
    }

    // SMART INTERACTION HANDLING
    if (isInteractive) {
      // Only add canvas-level interactions if node doesn't handle them
      if (!node.hasCustomInteractions) {
        finalWidget = _wrapWithCanvasInteractions(
          child: finalWidget,
          node: node,
          controller: controller,
        );
      }
      // If node has custom interactions, let it handle everything
    }

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: finalWidget,
    );
  }

  Widget _wrapWithCanvasInteractions({
    required Widget child,
    required FlowNode node,
    required FlowCanvasController controller,
  }) {
    return GestureDetector(
      // SELECTION HANDLING
      onTap: node.isSelectable
          ? () => controller.selectionManager.selectNode(node.id)
          : null,

      // DRAG HANDLING
      onPanStart: node.isDraggable
          ? (details) {
              controller.interactionHandler.onNodeDragStart(node.id, details);
            }
          : null,

      onPanUpdate: node.isDraggable
          ? (details) {
              controller.interactionHandler.onNodeDragUpdate(node.id, details);
            }
          : null,

      onPanEnd: node.isDraggable
          ? (details) {
              controller.interactionHandler.onNodeDragEnd(node.id, details);
            }
          : null,

      child: child,
    );
  }

  Widget _buildMissingNodeWidget(FlowNode node) {
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: Container(
        width: node.size.width,
        height: node.size.height,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(height: 4),
              Text(
                'Unknown type:\n${node.type}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              // paint background first
              CustomPaint(
                size: Size(controller.canvasWidth, controller.canvasHeight),
                painter: BackgroundPainter(
                  matrix: controller.transformationController.value,
                  variant: widget.backgroundVariant,
                ),
              ),

              // paint flow
              CustomPaint(
                size: Size(controller.canvasWidth, controller.canvasHeight),
                painter: FlowPainter(controller: controller),
              ),

              // VISIBLE NODES LAYER
              ...controller.nodes.map(
                (node) {
                  return _buildNode(
                      controller: controller,
                      node: node,
                      isInteractive: isPanningEnabled,
                      isForCapture: false);
                },
              ),

              // Offstage stack for rendering nodes to images (for caching)
              Offstage(
                offstage: true,
                child: Stack(
                  children: [
                    ...controller.nodes.where((n) => n.needsRepaint).map(
                      (node) {
                        return _buildNode(
                            controller: controller,
                            node: node,
                            isInteractive: isPanningEnabled,
                            isForCapture: true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCanvas(FlowCanvasController controller) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        bool isHandled = controller.keyboardHandler.handleKeyEvent(event);
        return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          if (widget.interactive) {
            _focusNode.requestFocus();
          }
        },
        child: Stack(
          children: [
            _buildCanvasContent(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticCanvas(FlowCanvasController controller) {
    return _buildCanvasContent(controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(flowControllerProvider);
    _scheduleUpdateNodeKeys(controller);

    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          if (widget.interactive)
            _buildInteractiveCanvas(controller)
          else
            _buildStaticCanvas(controller),
          if (widget.showControls)
            const FlowCanvasControls(
              alignment: ControlPanelAlignment.bottomLeft,
              orientation: Axis.vertical,
            ),
        ],
      ),
    );
  }
}

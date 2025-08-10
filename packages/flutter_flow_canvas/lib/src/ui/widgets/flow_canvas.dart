import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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

  final CanvasInitCallback? onCanvasInit;

  const FlowCanvas(
      {super.key,
      this.backgroundVariant = BackgroundVariant.dots,
      this.showControls = true,
      this.backgroundColor,
      this.minScale = 0.1,
      this.maxScale = 2.0,
      this.interactive = true,
      this.canvasSize,
      this.onCanvasInit});

  @override
  ConsumerState<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends ConsumerState<FlowCanvas> {
  final FocusNode _focusNode = FocusNode();
  final Map<String, GlobalKey> _nodeKeys = {};

  final GlobalKey _interactiveViewerKey = GlobalKey();

  bool _isInitialized = false;
  bool _isCapturingImages = false;

  @override
  void initState() {
    super.initState();
    if (widget.interactive) {
      _focusNode.requestFocus();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCanvas();
      }
    });
  }

  void _initializeCanvas() async {
    if (!mounted) return;

    final controller = ref.read(flowControllerProvider);
    controller.setInteractiveViewerKey(_interactiveViewerKey);

    widget.onCanvasInit?.call(controller);

    // Mark as initialized to show nodes
    setState(() {
      _isInitialized = true;
    });

    // OPTIMIZATION 3: Delay image capture to avoid initial jank
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scheduleImageCapture();
      }
    });
  }

  void _scheduleImageCapture() {
    if (_isCapturingImages) return;

    SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (mounted && !_isCapturingImages) {
        _captureNodeImagesWithThrottle();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlowCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInitialized) return;

    final controller = ref.read(flowControllerProvider);
    if (controller.nodes.any((n) => n.needsRepaint)) {
      _scheduleImageCapture();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _pendingNodeKeysUpdate = false;

  void _scheduleUpdateNodeKeys(FlowCanvasController controller) {
    if (_pendingNodeKeysUpdate || !_isInitialized) return;
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

  void _captureNodeImagesWithThrottle() async {
    if (!mounted || _nodeKeys.isEmpty || _isCapturingImages) return;

    _isCapturingImages = true;

    try {
      final controller = ref.read(flowControllerProvider);
      final nodesToCapture =
          controller.nodes.where((n) => n.needsRepaint).toList();

      if (nodesToCapture.isEmpty) {
        _isCapturingImages = false;
        return;
      }

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;

      // OPTIMIZATION 6: Process images in smaller batches to avoid frame drops
      const batchSize = 3; // Process 3 nodes at a time
      for (int i = 0; i < nodesToCapture.length; i += batchSize) {
        final batch = nodesToCapture.skip(i).take(batchSize);

        final futures = batch.map((node) async {
          final key = _nodeKeys[node.id];
          if (key == null) return null;

          final boundary =
              key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final image = await boundary.toImage(pixelRatio: pixelRatio);
            return (node.id, image);
          }
          return null;
        }).toList();

        final results = await Future.wait(futures);

        if (!mounted) break;

        // Update controller with batch results
        for (final result in results) {
          if (result != null) {
            final (nodeId, image) = result;
            controller.nodeManager.updateNodeImage(nodeId, image);
          }
        }

        // OPTIMIZATION 7: Yield between batches to prevent blocking the UI thread
        if (i + batchSize < nodesToCapture.length) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
    } finally {
      _isCapturingImages = false;
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
    // Correctly get the widget from the controller, which uses the node registry.
    final Widget? nodeWidget = controller.getNodeWidget(node);

    // If the node type isn't registered, getNodeWidget will return null.
    if (nodeWidget == null) {
      // You could also return a default error widget here for debugging.
      return const SizedBox.shrink();
    }

    // Create a mutable variable that can be wrapped by other widgets.
    Widget finalWidget = nodeWidget;

    if (isForCapture && _nodeKeys.containsKey(node.id)) {
      finalWidget = RepaintBoundary(
        key: _nodeKeys[node.id],
        child: Material(
          type: MaterialType.transparency,
          child: finalWidget,
        ),
      );
    }

    if (isInteractive) {
      finalWidget = GestureDetector(
        onTap: () => controller.selectionManager.selectNode(node.id),
        onPanUpdate: (details) =>
            controller.nodeManager.dragNode(node.id, details.delta),
        child: finalWidget,
      );
    }

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: finalWidget,
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
        key: _interactiveViewerKey,
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
              if (_isInitialized) ...[
                // Visible nodes
                ...controller.nodes.map(
                  (node) => _buildNode(
                    controller: controller,
                    node: node,
                    isInteractive: isPanningEnabled,
                    isForCapture: false,
                  ),
                ),

                if (_nodeKeys.isNotEmpty)
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
              ] else ...[
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
            // Offstage stack for rendering nodes to images (for caching)
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

    if (_isInitialized) {
      _scheduleUpdateNodeKeys(controller);
    }

    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          if (widget.interactive)
            _buildInteractiveCanvas(controller)
          else
            _buildStaticCanvas(controller),
          if (widget.showControls && _isInitialized)
            const FlowCanvasControls(
              alignment: ControlPanelAlignment.bottomLeft,
              orientation: Axis.vertical,
            ),
        ],
      ),
    );
  }
}

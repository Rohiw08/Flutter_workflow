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

  const FlowCanvas({
    super.key,
    this.backgroundVariant = BackgroundVariant.dots,
    this.showControls = true,
    this.backgroundColor,
    this.minScale = 0.1,
    this.maxScale = 2.0,
    this.interactive = true,
    this.canvasSize,
    this.onCanvasInit,
  });

  @override
  ConsumerState<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends ConsumerState<FlowCanvas> {
  final FocusNode _focusNode = FocusNode();
  final Map<String, GlobalKey> _nodeKeys = {};
  final GlobalKey _interactiveViewerKey = GlobalKey();

  bool _isInitialized = false;
  bool _isCapturingImages = false;
  bool _pendingNodeKeysUpdate = false;

  @override
  void initState() {
    super.initState();

    // Fixed: Only request focus on user interaction, not automatically
    if (widget.interactive) {
      // Don't automatically request focus - let user interactions handle it
      _focusNode.canRequestFocus = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCanvas();
      }
    });
  }

  void _initializeCanvas() async {
    if (!mounted) return;

    try {
      final controller = ref.read(flowControllerProvider);
      controller.setInteractiveViewerKey(_interactiveViewerKey);

      widget.onCanvasInit?.call(controller);

      // Mark as initialized to show nodes
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      // Fixed: Add mounted check and delay image capture to avoid initial jank
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isInitialized) {
          _scheduleImageCapture();
        }
      });
    } catch (e) {
      debugPrint('Error initializing canvas: $e');
    }
  }

  void _scheduleImageCapture() {
    if (_isCapturingImages || !mounted) return;

    SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (mounted && !_isCapturingImages) {
        _captureNodeImagesWithThrottle();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlowCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Fixed: Add mounted check before accessing provider
    if (!_isInitialized || !mounted) return;

    try {
      final controller = ref.read(flowControllerProvider);
      if (controller.nodes.any((n) => n.needsRepaint)) {
        _scheduleImageCapture();
      }
    } catch (e) {
      debugPrint('Error in didUpdateWidget: $e');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _scheduleUpdateNodeKeys(FlowCanvasController controller) {
    if (_pendingNodeKeysUpdate || !_isInitialized || !mounted) return;
    _pendingNodeKeysUpdate = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          _updateNodeKeys(controller);
        } catch (e) {
          debugPrint('Error updating node keys: $e');
        } finally {
          _pendingNodeKeysUpdate = false;
        }
      } else {
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

  /// Fixed: Atomic image capture with proper error handling and batching
  Future<void> _captureNodeImagesWithThrottle() async {
    if (!mounted || _nodeKeys.isEmpty || _isCapturingImages) return;

    // Fixed: Use atomic flag setting to prevent race conditions
    _isCapturingImages = true;

    try {
      final controller = ref.read(flowControllerProvider);
      final nodesToCapture =
          controller.nodes.where((n) => n.needsRepaint).toList();

      if (nodesToCapture.isEmpty) {
        return;
      }

      final pixelRatio = MediaQuery.of(context).devicePixelRatio;

      // Fixed: Process images in smaller batches to avoid frame drops
      const batchSize = 3;
      for (int i = 0; i < nodesToCapture.length; i += batchSize) {
        if (!mounted) break; // Check mounted state between batches

        final batch = nodesToCapture.skip(i).take(batchSize);

        final futures = batch.map((node) async {
          try {
            final key = _nodeKeys[node.id];
            if (key == null) return null;

            final boundary = key.currentContext?.findRenderObject();

            // Fixed: Safe type checking for RenderRepaintBoundary
            if (boundary == null || boundary is! RenderRepaintBoundary) {
              return null;
            }

            final renderBoundary = boundary;

            // Fixed: Validate boundary state before capturing
            if (!renderBoundary.attached) {
              return null;
            }

            // Add paint state validation before capture
            if (renderBoundary.debugNeedsPaint) {
              // Skip this node for now, it will be captured in the next frame
              return null;
            }
            // Alternative: Add additional frame delay
            await Future.delayed(
                const Duration(milliseconds: 16)); // Wait one frame

            final image = await renderBoundary.toImage(pixelRatio: pixelRatio);
            return (node.id, image);
          } catch (e) {
            debugPrint('Error capturing image for node ${node.id}: $e');
            return null;
          }
        }).toList();

        final results = await Future.wait(futures);

        if (!mounted) break;

        // Update controller with batch results
        for (final result in results) {
          if (result != null && mounted) {
            final (nodeId, image) = result;
            controller.nodeManager.updateNodeImage(nodeId, image);
          }
        }

        // Fixed: Yield between batches to prevent blocking the UI thread
        if (i + batchSize < nodesToCapture.length && mounted) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
    } catch (e) {
      debugPrint('Error in image capture process: $e');
    } finally {
      // Fixed: Ensure flag is always reset
      if (mounted) {
        _isCapturingImages = false;
      }
    }
  }

  Size _canvasSize(FlowCanvasController controller) {
    final size = widget.canvasSize ??
        Size(controller.canvasWidth, controller.canvasHeight);

    // Fixed: Validate canvas size
    if (size.width <= 0 || size.height <= 0) {
      debugPrint('Invalid canvas size: $size, using fallback');
      return const Size(5000, 5000);
    }

    return size;
  }

  Widget _buildNode({
    required FlowCanvasController controller,
    required FlowNode node,
    required bool isInteractive,
    required bool isForCapture,
  }) {
    try {
      // Get the widget from the controller using the node registry
      final Widget? nodeWidget = controller.getNodeWidget(node);

      // Fixed: Return descriptive error widget instead of silent failure
      if (nodeWidget == null) {
        return Container(
          width: node.size.width,
          height: node.size.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            color: Colors.red.withAlpha(50),
          ),
          child: Center(
            child: Text(
              'Missing\nnode type:\n"${node.type}"',
              style: const TextStyle(color: Colors.red, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

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

      if (isInteractive && node.isDraggable) {
        finalWidget = GestureDetector(
          onTap: node.isSelectable
              ? () => controller.selectionManager.selectNode(node.id)
              : null,
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
    } catch (e) {
      debugPrint('Error building node ${node.id}: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildCanvasContent(FlowCanvasController controller) {
    // Dynamically disable InteractiveViewer's panning when dragging nodes or box selecting
    final isPanningEnabled = widget.interactive &&
        controller.dragMode != DragMode.node &&
        controller.dragMode != DragMode.selection;

    return Listener(
      onPointerMove: widget.interactive
          ? (details) {
              try {
                if (controller.dragMode == DragMode.handle) {
                  controller.connectionManager
                      .updateConnection(details.position);
                }
              } catch (e) {
                debugPrint('Error in pointer move: $e');
              }
            }
          : null,
      onPointerUp: widget.interactive
          ? (_) {
              try {
                if (controller.dragMode == DragMode.handle) {
                  controller.connectionManager.endConnection();
                }
              } catch (e) {
                debugPrint('Error in pointer up: $e');
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
              // Paint background first
              CustomPaint(
                size: Size(controller.canvasWidth, controller.canvasHeight),
                painter: BackgroundPainter(
                  matrix: controller.transformationController.value,
                  variant: widget.backgroundVariant,
                ),
              ),

              // Paint flow
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

                // Offstage nodes for image capture
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
                              isInteractive:
                                  false, // Don't make capture nodes interactive
                              isForCapture: true,
                            );
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
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCanvas(FlowCanvasController controller) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        try {
          bool isHandled = controller.keyboardHandler.handleKeyEvent(event);
          return isHandled ? KeyEventResult.handled : KeyEventResult.ignored;
        } catch (e) {
          debugPrint('Error handling key event: $e');
          return KeyEventResult.ignored;
        }
      },
      child: GestureDetector(
        onTap: () {
          // Fixed: Only request focus on user interaction
          if (widget.interactive && mounted) {
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
    try {
      final controller = ref.watch(flowControllerProvider);

      if (_isInitialized && mounted) {
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
    } catch (e) {
      debugPrint('Error building FlowCanvas: $e');
      return Container(
        color: widget.backgroundColor ?? Colors.grey.shade100,
        child: const Center(
          child: Text(
            'Canvas Error\nCheck console for details',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}

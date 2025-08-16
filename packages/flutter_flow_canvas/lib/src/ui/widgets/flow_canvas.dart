import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_flow_canvas/src/core/canvas_controller.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/core/providers.dart';
import 'package:flutter_flow_canvas/src/core/models/node.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/flow_canvas_controls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'painters/background_painter.dart';
import 'painters/flow_painter.dart';

class FlowCanvas extends ConsumerStatefulWidget {
  // Styling overrides
  final BackgroundVariant? backgroundVariant;
  final Color? backgroundColor;

  // Behavior
  final bool showControls;
  final double minScale;
  final double maxScale;
  final bool interactive;
  final Size? canvasSize;
  final CanvasInitCallback? onCanvasInit;

  const FlowCanvas({
    super.key,
    this.backgroundVariant,
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
  // All internal state and lifecycle methods (_focusNode, _nodeKeys, initState, etc.)
  // remain completely unchanged as they are not directly theme-related.
  final FocusNode _focusNode = FocusNode();
  final Map<String, GlobalKey> _nodeKeys = {};
  final GlobalKey _interactiveViewerKey = GlobalKey();

  bool _isInitialized = false;
  bool _isCapturingImages = false;
  bool _pendingNodeKeysUpdate = false;

  @override
  void initState() {
    super.initState();
    if (widget.interactive) {
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
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
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

  Future<void> _captureNodeImagesWithThrottle() async {
    if (!mounted || _nodeKeys.isEmpty || _isCapturingImages) return;
    _isCapturingImages = true;
    try {
      final controller = ref.read(flowControllerProvider);
      final nodesToCapture =
          controller.nodes.where((n) => n.needsRepaint).toList();
      if (nodesToCapture.isEmpty) {
        return;
      }
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      const batchSize = 3;
      for (int i = 0; i < nodesToCapture.length; i += batchSize) {
        if (!mounted) break;
        final batch = nodesToCapture.skip(i).take(batchSize);
        final futures = batch.map((node) async {
          try {
            final key = _nodeKeys[node.id];
            if (key == null) return null;
            final boundary = key.currentContext?.findRenderObject();
            if (boundary == null || boundary is! RenderRepaintBoundary) {
              return null;
            }
            final renderBoundary = boundary;
            if (!renderBoundary.attached) {
              return null;
            }
            if (renderBoundary.debugNeedsPaint) {
              return null;
            }
            await Future.delayed(const Duration(milliseconds: 16));
            final image = await renderBoundary.toImage(pixelRatio: pixelRatio);
            return (node.id, image);
          } catch (e) {
            debugPrint('Error capturing image for node ${node.id}: $e');
            return null;
          }
        }).toList();
        final results = await Future.wait(futures);
        if (!mounted) break;
        for (final result in results) {
          if (result != null && mounted) {
            final (nodeId, image) = result;
            controller.nodeManager.updateNodeImage(nodeId, image);
          }
        }
        if (i + batchSize < nodesToCapture.length && mounted) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
    } catch (e) {
      debugPrint('Error in image capture process: $e');
    } finally {
      if (mounted) {
        _isCapturingImages = false;
      }
    }
  }

  Size _canvasSize(FlowCanvasController controller) {
    final size = widget.canvasSize ??
        Size(controller.canvasWidth, controller.canvasHeight);
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
      final Widget? nodeWidget = controller.getNodeWidget(node);
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

      // SIMPLIFIED: Remove lock check since IgnorePointer handles it
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
    final canvasContent = SizedBox(
      width: _canvasSize(controller).width,
      height: _canvasSize(controller).height,
      child: Stack(
        children: [
          // Paint flow (edges, connections, etc.)
          CustomPaint(
            size: Size(controller.canvasWidth, controller.canvasHeight),
            painter: FlowPainter(controller: controller),
          ),

          // Your existing node rendering logic...
          if (_isInitialized) ...[
            ...controller.nodes.map(
              (node) => _buildNode(
                controller: controller,
                node: node,
                isInteractive: widget.interactive, // Removed lock check
                isForCapture: false,
              ),
            ),
            // ... rest of your node logic
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
    );

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
      child: _InteractiveViewerWrapper(
        controller: controller,
        transformationController: controller.transformationController,
        interactive: widget.interactive,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        viewerKey: _interactiveViewerKey,
        child: canvasContent,
      ),
    );
  }

  Widget _buildInteractiveCanvas(FlowCanvasController controller) {
    // This method's logic is unchanged.
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
          if (widget.interactive && mounted) {
            _focusNode.requestFocus();
          }
        },
        child: _buildCanvasContent(controller),
      ),
    );
  }

  Widget _buildStaticCanvas(FlowCanvasController controller) {
    // This method's logic is unchanged.
    return _buildCanvasContent(controller);
  }

  @override
  Widget build(BuildContext context) {
    try {
      final controller = ref.watch(flowControllerProvider);

      if (_isInitialized && mounted) {
        _scheduleUpdateNodeKeys(controller);
      }

      return Stack(
        children: [
          if (widget.interactive)
            Positioned.fill(
              child: CustomPaint(
                painter: FlowCanvasBackgroundPainter.fromContext(
                  context,
                  controller.transformationController.value,
                  patternOverride: widget.backgroundVariant,
                  backgroundColorOverride: widget.backgroundColor,
                ),
              ),
            ),
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

class _InteractiveViewerWrapper extends StatelessWidget {
  final FlowCanvasController controller;
  final TransformationController transformationController;
  final Widget child;
  final bool interactive;
  final double minScale;
  final double maxScale;
  final GlobalKey viewerKey;

  const _InteractiveViewerWrapper({
    required this.controller,
    required this.transformationController,
    required this.child,
    required this.interactive,
    required this.minScale,
    required this.maxScale,
    required this.viewerKey,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.navigationManager.lockState,
      builder: (context, isLocked, constantChild) {
        return IgnorePointer(
          ignoring: isLocked, // This handles all locking logic
          child: InteractiveViewer(
            key: viewerKey,
            transformationController: transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(0),
            minScale: minScale,
            maxScale: maxScale,
            // Set to constant values - IgnorePointer handles the locking
            panEnabled: interactive,
            scaleEnabled: interactive,
            child: constantChild!,
          ),
        );
      },
      child: child,
    );
  }
}

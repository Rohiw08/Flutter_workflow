import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/canvas_controller.dart';
import '../../core/providers.dart';
import 'painters/background_painter.dart';
import 'painters/flow_painter.dart';

/// Main FlowCanvas widget that renders the interactive node-based canvas
class FlowCanvas extends ConsumerStatefulWidget {
  /// Background pattern variant
  final BackgroundVariant backgroundVariant;

  /// Whether to show canvas controls
  final bool showControls;

  /// Canvas background color
  final Color? backgroundColor;

  /// Minimum scale factor for zooming
  final double minScale;

  /// Maximum scale factor for zooming
  final double maxScale;

  /// Whether the canvas is interactive
  final bool interactive;

  /// Custom canvas size (defaults to controller settings)
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

  @override
  void initState() {
    super.initState();
    if (widget.interactive) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ref.watch(flowControllerProvider);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Size get _canvasSize =>
      widget.canvasSize ??
      Size(controller.canvasWidth, controller.canvasHeight);

  @override
  Widget build(BuildContext context) {
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

                    // Node layer - render nodes as positioned widgets
                    ...controller.nodes.map((node) {
                      final nodeWidget = controller.getNodeWidget(node.id);
                      if (nodeWidget == null) return const SizedBox.shrink();

                      return Positioned(
                        left: node.position.dx,
                        top: node.position.dy,
                        child: nodeWidget,
                      );
                    }),

                    // Edge and overlay layer
                    CustomPaint(
                      painter: FlowPainter(controller: controller),
                      size: _canvasSize,
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

/// Canvas control buttons widget
class FlowCanvasControls extends StatelessWidget {
  final FlowCanvasController controller;

  const FlowCanvasControls({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: controller.zoomIn,
                  tooltip: 'Zoom In',
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: controller.zoomOut,
                  tooltip: 'Zoom Out',
                ),
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: controller.centerView,
                  tooltip: 'Center View',
                ),
                if (controller.hasNodes)
                  IconButton(
                    icon: const Icon(Icons.fit_screen),
                    onPressed: controller.fitView,
                    tooltip: 'Fit View',
                  ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Nodes: ${controller.nodes.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (controller.hasSelection) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Selected: ${controller.selectedNodes.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade800,
                          ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

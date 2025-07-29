import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/canvas_controller.dart';
import '../../core/providers.dart';
import 'painters/background_painter.dart';
import 'painters/flow_painter.dart';

class FlowCanvas extends ConsumerStatefulWidget {
  final BackgroundVariant backgroundVariant;

  const FlowCanvas({
    super.key,
    this.backgroundVariant = BackgroundVariant.dots,
  });

  @override
  ConsumerState<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends ConsumerState<FlowCanvas> {
  late FlowCanvasController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = ref.watch(flowControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Off-screen widgets for caching
        ...controller.buildOffstageWidgets(),

        // The main canvas
        Listener(
          onPointerMove: (details) =>
              controller.updateConnection(details.position),
          onPointerUp: (_) => controller.endConnection(),
          child: GestureDetector(
            onPanStart: controller.onPanStart,
            onPanUpdate: controller.onPanUpdate,
            onPanEnd: controller.onPanEnd,
            child: InteractiveViewer(
              transformationController: controller.transformationController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(0),
              minScale: 0.1,
              maxScale: 2.0,
              child: SizedBox(
                width: 5000,
                height: 5000,
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: BackgroundPainter(
                        matrix: controller.transformationController.value,
                        variant: widget.backgroundVariant,
                      ),
                      foregroundPainter: FlowPainter(
                        controller: controller,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

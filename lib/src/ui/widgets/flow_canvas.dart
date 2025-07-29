import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/src/ui/widgets/painters/background_painter.dart';
import 'package:flutter_workflow/src/ui/widgets/painters/flow_painter.dart';
import '../../core/canvas_controller.dart';
import '../../core/providers.dart';

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
        // This is where we render the widgets off-screen to capture them as images
        ...controller.buildOffstageWidgets(),

        // The main canvas
        GestureDetector(
          onTapUp: controller.onCanvasTapUp,
          onPanStart: controller.onPanStart,
          onPanUpdate: controller.onPanUpdate,
          onPanEnd: controller.onPanEnd,
          child: InteractiveViewer(
            transformationController: controller.transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(0),
            scaleEnabled: true,
            minScale: 0.1,
            maxScale: 5.0,
            child: SizedBox(
              width: 10000,
              height: 10000,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: BackgroundPainter(
                      matrix: controller.transformationController.value,
                      variant: widget.backgroundVariant,
                    ),
                    foregroundPainter: FlowPainter(controller: controller),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

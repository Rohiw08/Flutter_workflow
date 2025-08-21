import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

// Assuming you have these custom node widget files in your project
// You will need to create these or replace them with your own.
import 'example/text_node_widget.dart';
import 'example/image_node.dart';

void main() {
  // Create the registries once.
  final nodeRegistry = NodeRegistry();
  final edgeRegistry = EdgeRegistry();

  // --- 1. Register all your custom types ---
  nodeRegistry.registerNodeType(
      'text-node', (node) => TextNodeWidget(node: node));
  nodeRegistry.registerNodeType(
      'image-node', (node) => ImageNodeWidget(node: node));
  edgeRegistry.registerEdgeType('dotted-edge', DottedEdgePainter());

  // --- 2. Create the controller with the registries ---
  final controller = FlowCanvasController(
    nodeRegistry: nodeRegistry,
    edgeRegistry: edgeRegistry,
  );

  // --- 3. Run the app, providing the controller ---
  runApp(
    ProviderScope(
      overrides: [
        flowControllerProvider.overrideWith((ref) => controller),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flow Canvas Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const FlowCanvasDemo(),
    );
  }
}

class FlowCanvasDemo extends ConsumerWidget {
  const FlowCanvasDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Flutter Flow Canvas Demo'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.add_circle_outline),
      //       onPressed: () => _addRandomNode(controller),
      //       tooltip: 'Add Random Node',
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.delete_sweep_outlined),
      //       onPressed: controller.clear,
      //       tooltip: 'Clear Canvas',
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          FlowCanvas(
            backgroundVariant: BackgroundVariant.dots,

            showControls: true,
            // --- 4. Use onCanvasInit to set up the initial graph ---
            onCanvasInit: (controller) {
              _addSampleGraph(controller);
            },
          ),
          FlowCanvasMiniMap(
            theme: FlowCanvasMiniMapTheme.light().copyWith(
              shadows: [],
              viewportInnerGlowColor: Colors.blue
                  .withAlpha(128), // Add some transparency for visibility
              viewportInnerGlowWidthMultiplier:
                  3.0, // Increase multiplier for visibility
              viewportInnerGlowBlur: 2.0, // Add some blur for glow effect
              maskStrokeWidth: 0, // Keep stroke width at 0 as intended
            ),
          )
        ],
      ),
    );
  }

  void _addRandomNode(FlowCanvasController controller) {
    final random = Random();
    final isTextNode = random.nextBool();
    final id = 'node-${random.nextInt(10000)}';

    final node = FlowNode(
      id: id,
      position: const Offset(
        150,
        200,
      ),
      size: isTextNode ? const Size(220, 120) : const Size(180, 150),
      type: isTextNode ? 'text-node' : 'image-node',
      data: {
        'title': 'Random Node',
        'description': 'ID: $id',
      },
    );
    controller.nodeManager.addNode(node);
  }

  void _addSampleGraph(FlowCanvasController controller) {
    // --- NODES ---
    final node1 = FlowNode(
        id: 'text-1',
        position: const Offset(150, 200),
        size: const Size(220, 120),
        type: 'text-node',
        data: {
          'title': 'Start Here',
          'description': 'This is the beginning of the flow.',
        });

    final node2 = FlowNode(
        id: 'image-1',
        position: const Offset(500, 150),
        size: const Size(180, 150),
        type: 'image-node',
        data: {'title': 'Image Asset'});

    final node3 = FlowNode(
        id: 'text-2',
        position: const Offset(500, 400),
        size: const Size(220, 120),
        type: 'text-node',
        data: {
          'title': 'Middle Step',
          'description': 'Processes data from the start.',
        });

    final node4 = FlowNode(
        id: 'text-3',
        position: const Offset(850, 280),
        size: const Size(220, 120),
        type: 'text-node',
        data: {
          'title': 'End Point',
          'description': 'This is the final node in the graph.',
        });

    controller.nodeManager.addNodes([node1, node2, node3, node4]);

    // --- EDGES ---
    controller.edgeManager.addEdge(FlowEdge(
      id: 'edge-1',
      sourceNodeId: 'text-1',
      sourceHandleId: 'right',
      targetNodeId: 'image-1',
      targetHandleId: 'left',
      pathType: EdgePathType.bezier,
    ));

    controller.edgeManager.addEdge(FlowEdge(
      id: 'edge-2',
      sourceNodeId: 'text-1',
      sourceHandleId: 'right',
      targetNodeId: 'text-2',
      targetHandleId: 'top',
      pathType: EdgePathType.step,
      label: 'Step Path',
    ));

    // Correctly implemented custom edge
    controller.edgeManager.addEdge(FlowEdge(
      id: 'edge-3-wavy',
      type: 'dotted-edge', // Use the registered custom type
      sourceNodeId: 'image-1',
      sourceHandleId: 'bottom',
      targetNodeId: 'text-3',
      targetHandleId: 'left',
      label: 'Custom Wavy Edge',
      labelStyle: const TextStyle(color: Colors.amber),
    ));

    controller.edgeManager.addEdge(FlowEdge(
      id: 'edge-4',
      sourceNodeId: 'text-2',
      sourceHandleId: 'right',
      targetNodeId: 'text-3',
      targetHandleId: 'left',
      pathType: EdgePathType.straight,
      label: 'Straight Path',
    ));
  }
}

class DottedEdgePainter extends EdgePainter {
  @override
  void paint(Canvas canvas, Path path, FlowEdge edge, Paint paint) {
    // Get start & end points from original path
    final pathMetrics = path.computeMetrics().first;
    final start = pathMetrics.getTangentForOffset(0)!.position;
    final end = pathMetrics.getTangentForOffset(pathMetrics.length)!.position;

    // Build a smooth cubic curve path
    final curvePath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + 80, start.dy - 120, // control point 1
        end.dx - 80, end.dy + 120, // control point 2
        end.dx, end.dy, // end point
      );

    // ---- Draw dotted line ----
    const double dotSpacing = 8.0;
    const double dotRadius = 2.5;

    for (final metric in curvePath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final pos = metric.getTangentForOffset(distance)!.position;
        canvas.drawCircle(
          pos,
          dotRadius,
          paint
            ..style = PaintingStyle.fill
            ..strokeWidth = 1.5,
        );
        distance += dotSpacing;
      }
    }

    // ---- Optional: Label ----
    if (edge.label != null && edge.label!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: edge.label,
          style: edge.labelStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      // Place label at curve midpoint
      final metric = curvePath.computeMetrics().first;
      final midpoint = metric.getTangentForOffset(metric.length / 2)!.position;
      final position =
          midpoint - Offset(textPainter.width / 2, textPainter.height / 2);

      // Label background
      final bgRect = Rect.fromCenter(
        center: midpoint,
        width: textPainter.width + 12,
        height: textPainter.height + 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
        Paint()..color = Colors.black.withAlpha(179),
      );

      textPainter.paint(canvas, position);
    }
  }
}

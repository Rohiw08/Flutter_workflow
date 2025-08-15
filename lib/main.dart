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
  edgeRegistry.registerEdgeType('wavy-edge', WavyEdgePainter());

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
      appBar: AppBar(
        title: const Text('Flutter Flow Canvas Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _addRandomNode(controller),
            tooltip: 'Add Random Node',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: controller.clear,
            tooltip: 'Clear Canvas',
          ),
        ],
      ),
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
          const MiniMap()
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
      position: Offset(
        random.nextDouble() * 800 + 100,
        random.nextDouble() * 500 + 100,
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
      type: 'wavy-edge', // Use the registered custom type
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

// --- CUSTOM EDGE PAINTER ---
class WavyEdgePainter extends EdgePainter {
  @override
  void paint(Canvas canvas, Path path, FlowEdge edge, Paint paint) {
    // This painter IGNORES the provided path and creates its own.
    // It correctly gets the start and end points from the path metrics.
    final pathMetrics = path.computeMetrics().first;
    final start = pathMetrics.getTangentForOffset(0)!.position;
    final end = pathMetrics.getTangentForOffset(pathMetrics.length)!.position;

    final wavyPath = Path();
    wavyPath.moveTo(start.dx, start.dy);
    wavyPath.cubicTo(
      start.dx + 80, start.dy - 120, // Control point 1
      end.dx - 80, end.dy + 120, // Control point 2
      end.dx, end.dy, // End point
    );

    canvas.drawPath(wavyPath, paint..strokeWidth = 2.5);

    // It can also have a label, just like a default edge
    if (edge.label != null && edge.label!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(text: edge.label, style: edge.labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final wavyMetrics = wavyPath.computeMetrics().first;
      final midpoint = wavyMetrics.getTangentForOffset(wavyMetrics.length / 2)!;
      final position = midpoint.position -
          Offset(textPainter.width / 2, textPainter.height / 2);

      final bgRect = Rect.fromCenter(
        center: midpoint.position,
        width: textPainter.width + 12,
        height: textPainter.height + 6,
      );
      canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
          Paint()..color = Colors.black.withOpacity(0.7));

      textPainter.paint(canvas, position);
    }
  }
}

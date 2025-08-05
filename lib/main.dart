import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import 'package:flutter_workflow/example/image_node.dart';
import 'example/text_node_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flow Canvas Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlowCanvasDemo(),
    );
  }
}

class FlowCanvasDemo extends StatefulWidget {
  const FlowCanvasDemo({super.key});

  @override
  State<FlowCanvasDemo> createState() => _FlowCanvasDemoState();
}

class _FlowCanvasDemoState extends State<FlowCanvasDemo> {
  late FlowCanvasController _controller;
  late NodeRegistry _nodeRegistry;

  @override
  void initState() {
    super.initState();

    // 1. Create and configure the node registry
    _nodeRegistry = NodeRegistry();

    // 2. Register custom node types
    _nodeRegistry.registerNodeType(
        'text', (node) => TextNodeWidget(node: node));
    _nodeRegistry.registerNodeType(
        'image', (node) => ImageNodeWidget(node: node));

    // 3. Create controller with the registry
    _controller = FlowCanvasController(
      nodeRegistry: _nodeRegistry,
      enableMultiSelection: true,
      enableKeyboardShortcuts: true,
      enableBoxSelection: true,
    );

    // 4. Add some sample nodes
    _addSampleNodes();
  }

  void _addSampleNodes() {
    // Add a text node
    final textNode = FlowNode(
      id: 'text-1',
      position: const Offset(100, 100),
      size: const Size(200, 100),
      type: 'text', // This must match the registered type
      data: {
        'title': 'Sample Text Node',
        'description': 'This is a custom text node with some content.',
      },
    );
    _controller.nodeManager.addNode(textNode);

    // Add an image node
    final imageNode = FlowNode(
      id: 'image-1',
      position: const Offset(400, 150),
      size: const Size(150, 120),
      type: 'image', // This must match the registered type
      data: {
        'imageUrl': 'https://picsum.photos/150/100',
        'label': 'Sample Image',
      },
    );
    _controller.nodeManager.addNode(imageNode);

    // Add another text node
    final textNode2 = FlowNode(
      id: 'text-2',
      position: const Offset(200, 300),
      size: const Size(180, 80),
      type: 'text',
      data: {
        'title': 'Another Node',
        'description': 'Connected to the first one.',
      },
    );
    _controller.nodeManager.addNode(textNode2);

    // Add an edge between nodes
    final edge = FlowEdge(
      id: 'edge-1',
      sourceNodeId: 'text-1',
      sourceHandleId: 'output',
      targetNodeId: 'text-2',
      targetHandleId: 'input',
    );
    _controller.edgeManager.addEdge(edge);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Override the provider with your controller instance
        flowControllerProvider.overrideWith((ref) => _controller),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Flow Canvas Demo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addRandomNode,
              tooltip: 'Add Random Node',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _controller.clear(),
              tooltip: 'Clear Canvas',
            ),
          ],
        ),
        body: const FlowCanvas(
          backgroundVariant: BackgroundVariant.dots,
          showControls: true,
        ),
      ),
    );
  }

  void _addRandomNode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final isTextNode = random % 2 == 0;

    final node = FlowNode(
      id: 'node-$random',
      position: Offset(
        (random % 400).toDouble() + 50,
        (random % 300).toDouble() + 50,
      ),
      size: isTextNode ? const Size(200, 100) : const Size(150, 120),
      type: isTextNode ? 'text' : 'image',
      data: isTextNode
          ? {
              'title': 'Dynamic Node $random',
              'description': 'Created at runtime',
            }
          : {
              'imageUrl': 'https://picsum.photos/150/100?random=$random',
              'label': 'Dynamic Image $random',
            },
    );

    _controller.nodeManager.addNode(node);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

void main() {
  runApp(
    ProviderScope(
      // Override the flowControllerProvider with an actual instance
      overrides: [
        flowControllerProvider.overrideWith((ref) => FlowCanvasController()),
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const FlowCanvasExample(),
    );
  }
}

class FlowCanvasExample extends ConsumerStatefulWidget {
  const FlowCanvasExample({super.key});

  @override
  ConsumerState<FlowCanvasExample> createState() => _FlowCanvasExampleState();
}

class _FlowCanvasExampleState extends ConsumerState<FlowCanvasExample> {
  @override
  void initState() {
    super.initState();
    // Add initial nodes and edges after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addInitialElements();
    });
  }

  void _addInitialElements() {
    final controller = ref.read(flowControllerProvider);
    controller.clear();

    // Add nodes
    controller.nodeManager.addNode(
      FlowNode(
          id: '1',
          position: const Offset(100, 100),
          size: const Size(180, 80),
          data: NodeData()),
      const CustomNode(
        nodeId: '1', // Pass the actual node ID
        label: 'Input Node',
        backgroundColor: Color(0xFFE0F7FA),
        borderColor: Color(0xFF4DD0E1),
      ),
    );

    controller.nodeManager.addNode(
      FlowNode(
          id: '2',
          position: const Offset(400, 250),
          size: const Size(180, 100),
          data: NodeData()),
      const CustomNode(
        nodeId: '2', // Pass the actual node ID
        label: 'Processing Node',
        backgroundColor: Color(0xFFFFF9C4),
        borderColor: Color(0xFFFFEE58),
        hasInput: true,
      ),
    );

    controller.nodeManager.addNode(
      FlowNode(
          id: '3',
          position: const Offset(100, 400),
          size: const Size(180, 80),
          data: NodeData()),
      const CustomNode(
        nodeId: '3', // Pass the actual node ID
        label: 'Another Input',
        backgroundColor: Color(0xFFE0F7FA),
        borderColor: Color(0xFF4DD0E1),
      ),
    );

    controller.nodeManager.addNode(
      FlowNode(
        id: '4',
        position: const Offset(700, 350),
        size: const Size(180, 80),
        data: NodeData(),
      ),
      const CustomNode(
        nodeId: '4', // Pass the actual node ID
        label: 'Output Node',
        backgroundColor: Color(0xFFFCE4EC),
        borderColor: Color(0xFFF06292),
        hasInput: true,
        hasOutput: false,
      ),
    );

    // Add edges
    controller.edgeManager.addEdge(
      FlowEdge(
          id: 'e1-2',
          sourceNodeId: '1',
          sourceHandleId: 'output',
          targetNodeId: '2',
          targetHandleId: 'input_a'),
    );
    controller.edgeManager.addEdge(
      FlowEdge(
          id: 'e3-2',
          sourceNodeId: '3',
          sourceHandleId: 'output',
          targetNodeId: '2',
          targetHandleId: 'input_b'),
    );
    controller.edgeManager.addEdge(
      FlowEdge(
          id: 'e2-4',
          sourceNodeId: '2',
          sourceHandleId: 'output',
          targetNodeId: '4',
          targetHandleId: 'input'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Flow Canvas Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            tooltip: 'Reset Canvas',
            onPressed: _addInitialElements,
          ),
        ],
      ),
      body: const Stack(
        children: [
          FlowCanvas(
            showControls: false, // We'll use a custom controls widget
          ),
          FlowCanvasControls(
            alignment: ControlPanelAlignment.bottomLeft,
          ),
          MiniMap(
            width: 250,
            height: 180,
          ),
        ],
      ),
    );
  }
}

/// A custom widget for displaying nodes on the canvas.
class CustomNode extends StatelessWidget {
  final String nodeId; // Add nodeId parameter
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final bool hasInput;
  final bool hasOutput;

  const CustomNode({
    super.key,
    required this.nodeId, // Make nodeId required
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    this.hasInput = false,
    this.hasOutput = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (hasInput)
            Handle(
              nodeId: nodeId, // Use the actual node ID
              id: 'input_a',
              position: HandlePosition.left,
              type: HandleType.target,
            ),
          if (hasInput)
            Handle(
              nodeId: nodeId, // Use the actual node ID
              id: 'input_b',
              position: HandlePosition.top,
              type: HandleType.target,
            ),
          if (hasOutput)
            Handle(
              nodeId: nodeId, // Use the actual node ID
              id: 'output',
              position: HandlePosition.right,
              type: HandleType.source,
            ),
        ],
      ),
    );
  }
}

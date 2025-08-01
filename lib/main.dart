import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import 'package:flutter_workflow/example/complex_node.dart';
import 'package:flutter_workflow/example/example_node.dart';

// The single controller for the entire canvas, provided via Riverpod.
final exampleController = FlowCanvasController();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flow Canvas Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      home: const OptimizedExampleFlowCanvas(),
    );
  }
}

class OptimizedExampleFlowCanvas extends StatefulWidget {
  const OptimizedExampleFlowCanvas({super.key});

  @override
  State<OptimizedExampleFlowCanvas> createState() =>
      _OptimizedExampleFlowCanvasState();
}

class _OptimizedExampleFlowCanvasState
    extends State<OptimizedExampleFlowCanvas> {
  final BackgroundVariant _variant = BackgroundVariant.dots;
  bool _nodesInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize nodes after the first frame to ensure context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNodes();
    });
  }

  void _initializeNodes() {
    if (_nodesInitialized || !mounted) return;

    // --- Create Standard Nodes ---
    _createNode('start', 'Start Process', const Offset(2200, 2300),
        Icons.play_arrow, Colors.green.shade50);
    _createNode('process1', 'Data Processing', const Offset(2500, 2200),
        Icons.settings, Colors.blue.shade50);
    _createNode('decision', 'Decision Point', const Offset(2500, 2400),
        Icons.help_outline, Colors.orange.shade50);
    _createNode('process2', 'Transform Data', const Offset(2800, 2150),
        Icons.transform, Colors.purple.shade50);
    _createNode('process3', 'Save Results', const Offset(2800, 2350),
        Icons.save, Colors.indigo.shade50);
    _createNode('end', 'End Process', const Offset(3100, 2250), Icons.stop,
        Colors.red.shade50);

    // --- Create a Complex Node to show manual handle positioning ---
    _createComplexNode('complex1', const Offset(2200, 2500));

    // --- Create Initial Connections ---
    _createConnection('start', 'output', 'process1', 'input');
    _createConnection('process1', 'output', 'decision', 'input');
    _createConnection('decision', 'top', 'process2', 'input');
    _createConnection('decision', 'bottom', 'process3', 'input');
    _createConnection('complex1', 'a', 'decision', 'input');

    _nodesInitialized = true;
    // Force a rebuild to show the newly added nodes.
    setState(() {});
  }

  void _createNode(
      String id, String label, Offset position, IconData icon, Color color) {
    final node = FlowNode(
      id: id,
      position: position,
      size: const Size(180, 100),
      data: ExampleNodeData(
        label: label,
        icon: icon,
        color: color,
      ),
    );

    final nodeWidget = ExampleNode(
      nodeId: node.id,
      data: node.data as ExampleNodeData,
    );

    exampleController.addNode(node, nodeWidget);
  }

  void _createComplexNode(String id, Offset position) {
    final node = FlowNode(
      id: id,
      position: position,
      size: const Size(180, 100), // Size must match the widget's constraints
      data: NodeData(), // No special data needed for this one
    );

    final nodeWidget = ComplexNode(nodeId: id);

    exampleController.addNode(node, nodeWidget);
  }

  void _createConnection(String sourceId, String sourceHandle, String targetId,
      String targetHandle) {
    final edge = FlowEdge(
      id: '${sourceId}_${sourceHandle}_${targetId}_$targetHandle',
      sourceNodeId: sourceId,
      sourceHandleId: sourceHandle,
      targetNodeId: targetId,
      targetHandleId: targetHandle,
      type: EdgeType.bezier,
    );

    exampleController.addEdge(edge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProviderScope(
        overrides: [
          // Provide the single controller instance to the widget tree.
          flowControllerProvider.overrideWithValue(exampleController),
        ],
        child: Stack(
          children: [
            FlowCanvas(
              backgroundVariant: _variant,
              // Example of customizing the background
              backgroundColor: const Color.fromARGB(255, 246, 223, 231),

              // backgroundPainter: BackgroundPainter(
              //   matrix: exampleController.transformationController.value,
              //   variant: _variant,
              //   color: Colors.grey.shade700,
              //   gap: 40,
              // ),
            ),
            // The MiniMap widget, assuming it exists in your package
            const MiniMap(),
          ],
        ),
      ),
    );
  }
}

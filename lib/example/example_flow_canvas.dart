import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/example/example_node.dart';
import 'package:flutter_workflow/flutter_flow_canvas.dart';
import 'package:flutter_workflow/src/core/providers.dart';

// 1. Create a controller instance that will be shared across the canvas and its widgets
final exampleController = FlowCanvasController();

class ExampleFlowCanvas extends StatefulWidget {
  const ExampleFlowCanvas({super.key});

  @override
  State<ExampleFlowCanvas> createState() => _ExampleFlowCanvasState();
}

class _ExampleFlowCanvasState extends State<ExampleFlowCanvas> {
  // State to manage the background style
  BackgroundVariant _variant = BackgroundVariant.dots;

  @override
  void initState() {
    super.initState();

    // 2. Add some initial nodes to the controller when the app starts
    final node1 = FlowNode(
      id: 'node-1',
      position: const Offset(2350, 2400),
      size: const Size(200, 150),
      data: ExampleNodeData(label: 'Start Node'),
    );
    // Add the node model and its corresponding widget to the controller
    exampleController.addNode(
      node1,
      ExampleNode(data: node1.data as ExampleNodeData, node: node1),
    );

    final node2 = FlowNode(
      id: 'node-2',
      position: const Offset(2650, 2550),
      size: const Size(200, 150),
      data: ExampleNodeData(label: 'End Node'),
    );
    exampleController.addNode(
      node2,
      ExampleNode(data: node2.data as ExampleNodeData, node: node2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Flow Canvas'),
        actions: [
          // Button to switch background style
          PopupMenuButton<BackgroundVariant>(
            icon: const Icon(Icons.grid_on),
            onSelected: (variant) => setState(() => _variant = variant),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: BackgroundVariant.dots,
                child: Text('Dots'),
              ),
              const PopupMenuItem(
                value: BackgroundVariant.lines,
                child: Text('Lines'),
              ),
              const PopupMenuItem(
                value: BackgroundVariant.cross,
                child: Text('Cross'),
              ),
            ],
          ),
        ],
      ),
      body: ProviderScope(
        // 3. Override the library's provider with our controller instance.
        // This makes the controller available to all widgets inside the scope.
        overrides: [
          flowControllerProvider.overrideWithValue(exampleController),
        ],
        child: Stack(
          children: [
            // 4. Add the main canvas widget
            FlowCanvas(backgroundVariant: _variant),
            // 5. Add the minimap widget
            const MiniMap(),
          ],
        ),
      ),
    );
  }
}

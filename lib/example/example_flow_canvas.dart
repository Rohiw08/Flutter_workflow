import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/example/example_node.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

final exampleController = FlowCanvasController();

class ExampleFlowCanvas extends StatefulWidget {
  const ExampleFlowCanvas({super.key});

  @override
  State<ExampleFlowCanvas> createState() => _ExampleFlowCanvasState();
}

class _ExampleFlowCanvasState extends State<ExampleFlowCanvas> {
  BackgroundVariant _variant = BackgroundVariant.dots;
  bool _nodesInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize nodes after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNodes();
    });
  }

  void _initializeNodes() {
    if (_nodesInitialized) return;

    // Create multiple example nodes with different types
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

    // Create some initial connections
    _createConnection('start', 'output', 'process1', 'input');
    _createConnection('process1', 'output', 'decision', 'input');
    _createConnection('decision', 'top', 'process2', 'input');
    _createConnection('decision', 'bottom', 'process3', 'input');

    _nodesInitialized = true;

    // Force a rebuild
    if (mounted) {
      setState(() {});
    }
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
      data: node.data as ExampleNodeData,
      node: node,
    );

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

  void _addNewNode() {
    final nodeCount = exampleController.nodes.length;
    final newId = 'node_$nodeCount';

    _createNode(
      newId,
      'New Node $nodeCount',
      Offset(2300 + (nodeCount * 50.0), 2500 + (nodeCount * 30.0)),
      Icons.add_box,
      Colors.grey.shade100,
    );
  }

  void _deleteSelected() {
    exampleController.deleteSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Flow Canvas - Full Featured'),
        backgroundColor: Colors.blue.shade50,
        elevation: 1,
        actions: [
          // Background variant selector
          PopupMenuButton<BackgroundVariant>(
            icon: const Icon(Icons.grid_on),
            onSelected: (variant) => setState(() => _variant = variant),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: BackgroundVariant.dots,
                  child: Text('Dots Background')),
              const PopupMenuItem(
                  value: BackgroundVariant.lines,
                  child: Text('Lines Background')),
              const PopupMenuItem(
                  value: BackgroundVariant.cross,
                  child: Text('Cross Background')),
            ],
          ),

          // Add node button
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addNewNode,
            tooltip: 'Add New Node',
          ),

          // Delete selected
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteSelected,
            tooltip: 'Delete Selected (Del)',
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: ProviderScope(
        overrides: [
          flowControllerProvider.overrideWithValue(exampleController),
        ],
        child: Stack(
          children: [
            FlowCanvas(backgroundVariant: _variant),
            const MiniMap(),

            // Help overlay
            Positioned(
              bottom: 20,
              left: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Controls:',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('• Drag nodes to move',
                          style: TextStyle(fontSize: 12)),
                      const Text('• Drag handles to connect',
                          style: TextStyle(fontSize: 12)),
                      const Text('• Ctrl+A: Select all',
                          style: TextStyle(fontSize: 12)),
                      const Text('• Del: Delete selected',
                          style: TextStyle(fontSize: 12)),
                      const Text('• Esc: Deselect all',
                          style: TextStyle(fontSize: 12)),
                      const Text('• Drag empty space: Box select',
                          style: TextStyle(fontSize: 12)),
                      const Text('• Mouse wheel: Zoom',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_workflow/flutter_flow_canvas.dart';

// A custom data model for this specific type of node
class ExampleNodeData extends NodeData {
  final String label;
  ExampleNodeData({required this.label});
}

// The custom widget for this node type
class ExampleNode extends StatelessWidget {
  final ExampleNodeData data;
  final FlowNode node;
  const ExampleNode({super.key, required this.data, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.size.width,
      height: node.size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade300, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The main content of the node
          Center(
            child: Text(
              data.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // Add connection handles to the node
          Handle(
            nodeId: node.id,
            id: 'in_top', // Unique ID for this handle
            position: HandlePosition.top,
          ),
          Handle(
            nodeId: node.id,
            id: 'out_bottom',
            position: HandlePosition.bottom,
          ),
          Handle(
            nodeId: node.id,
            id: 'out_right',
            position: HandlePosition.right,
          ),
          Handle(nodeId: node.id, id: 'in_left', position: HandlePosition.left),
        ],
      ),
    );
  }
}

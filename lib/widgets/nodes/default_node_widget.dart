import 'package:flutter/material.dart';
import 'package:flutter_workflow/models/flow_node.dart';
import 'package:flutter_workflow/widgets/edges/handle.dart';

class DefaultNodeWidget extends StatelessWidget {
  final FlowNode node;
  const DefaultNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: node.dragging ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade300, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(node.data.label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          // --- Handles ---
          Handle(
            nodeId: node.id,
            type: HandleType.target,
            position: HandlePosition.left,
          ),
          Handle(
            nodeId: node.id,
            id: 'a', // Example of a handle with a specific ID
            type: HandleType.source,
            position: HandlePosition.right,
          ),
           Handle(
            nodeId: node.id,
            id: 'b',
            type: HandleType.source,
            position: HandlePosition.bottom,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class TextNodeWidget extends StatelessWidget {
  final FlowNode node;

  const TextNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.size.width,
      height: node.size.height,
      decoration: BoxDecoration(
        color: node.isSelected
            ? Colors.lightBlue.shade100
            : Colors.lightBlue.shade50,
        border: Border.all(
          color: node.isSelected ? Colors.blue : Colors.blueAccent,
          width: node.isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: node.isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.data['title'] ?? 'Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    node.data['description'] ?? 'Description goes here...',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          // Connection handles
          Handle(
            nodeId: node.id, // This should be dynamic
            id: 'input',
            position: HandlePosition.left,
            type: HandleType.target,
          ),
          Handle(
            nodeId: node.id, // This should be dynamic
            id: 'output',
            position: HandlePosition.right,
            type: HandleType.source,
          ),
        ],
      ),
    );
  }
}

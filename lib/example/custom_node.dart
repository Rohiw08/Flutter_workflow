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
        color: Colors.lightBlue.shade50,
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.data['title'] ?? 'Title',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            node.data['description'] ?? 'Description goes here...',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

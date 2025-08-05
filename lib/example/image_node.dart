import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class ImageNodeWidget extends StatelessWidget {
  final FlowNode node;

  const ImageNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.size.width,
      height: node.size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.purple, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              node.data['imageUrl'] ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              node.data['label'] ?? 'Image Label',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

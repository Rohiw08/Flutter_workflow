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
        border: Border.all(
          color: node.isSelected ? Colors.deepPurple : Colors.purple,
          width: node.isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: node.isSelected
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  child: Image.network(
                    node.data['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 32,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  node.data['label'] ?? 'Image Label',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Connection handles
          Handle(
            nodeId: node.id, // This should be dynamic
            id: 'input',
            position: HandlePosition.top,
            type: HandleType.target,
          ),
          Handle(
            nodeId: node.id, // This should be dynamic
            id: 'output',
            position: HandlePosition.bottom,
            type: HandleType.source,
          ),
        ],
      ),
    );
  }
}

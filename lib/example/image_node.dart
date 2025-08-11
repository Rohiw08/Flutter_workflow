import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class ImageNodeWidget extends StatelessWidget {
  final FlowNode node;

  const ImageNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final title = node.data['title'] as String? ?? 'Image Node';

    return Container(
      width: node.size.width,
      height: node.size.height,
      child: Stack(
        children: [
          // Main node content
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: node.isSelected
                  ? Colors.purple.shade100
                  : Colors.purple.shade50,
              border: Border.all(
                color: node.isSelected
                    ? Colors.purple.shade700
                    : Colors.purple.shade300,
                width: node.isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.purple.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // IMPORTANT: Add Handle widgets
          // These must match the handle IDs used in your edges!

          // Left handle (input)
          Handle(
            nodeId: node.id,
            id: 'left',
            position: HandlePosition.left,
            type: HandleType.target,
            size: 10.0,
          ),

          // Right handle (output)
          Handle(
            nodeId: node.id,
            id: 'right',
            position: HandlePosition.right,
            type: HandleType.source,
            size: 10.0,
          ),

          // Top handle (input)
          Handle(
            nodeId: node.id,
            id: 'top',
            position: HandlePosition.top,
            type: HandleType.target,
            size: 10.0,
          ),

          // Bottom handle (output)
          Handle(
            nodeId: node.id,
            id: 'bottom',
            position: HandlePosition.bottom,
            type: HandleType.source,
            size: 10.0,
          ),
        ],
      ),
    );
  }
}

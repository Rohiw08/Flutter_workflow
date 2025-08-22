import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class TextNodeWidget extends StatelessWidget {
  final FlowNode node;

  const TextNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final title = node.data['title'] as String? ?? 'Text Node';
    final description = node.data['description'] as String? ?? '';

    return SizedBox(
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
              color:
                  node.isSelected ? Colors.blue.shade100 : Colors.blue.shade50,
              border: Border.all(
                color: node.isSelected
                    ? Colors.blue.shade700
                    : Colors.blue.shade300,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // IMPORTANT: Add Handle widgets
          // These are what create the connection points!

          // Left handle (input)
          Handle(
            nodeId: node.id,
            id: 'left',
            position: HandlePosition.left,
            type: HandleType.target,
          ),

          // Right handle (output)
          Handle(
            nodeId: node.id,
            id: 'right',
            position: HandlePosition.right,
            type: HandleType.source,
          ),

          // Top handle (input)
          Handle(
            nodeId: node.id,
            id: 'top',
            position: HandlePosition.top,
            type: HandleType.target,
          ),

          // Bottom handle (output)
          Handle(
            nodeId: node.id,
            id: 'bottom',
            position: HandlePosition.bottom,
            type: HandleType.source,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

/// Custom data model for our example nodes.
class ExampleNodeData extends NodeData {
  final String label;
  final IconData icon;
  final Color color;

  ExampleNodeData({
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// A standard node widget that uses automatic handle positioning.
class ExampleNode extends StatelessWidget {
  final String nodeId;
  final ExampleNodeData data;

  const ExampleNode({
    super.key,
    required this.nodeId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 100,
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow handles to be visible outside
        children: [
          // Node content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(data.icon, size: 24, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // --- Handles with Automatic Positioning ---
          Handle(
            nodeId: nodeId,
            id: 'input',
            position: HandlePosition.left,
            type: HandleType.target,
          ),
          Handle(
            nodeId: nodeId,
            id: 'output',
            position: HandlePosition.right,
            type: HandleType.source,
          ),
          Handle(
            nodeId: nodeId,
            id: 'top',
            position: HandlePosition.top,
            type: HandleType.source,
          ),
          Handle(
            nodeId: nodeId,
            id: 'bottom',
            position: HandlePosition.bottom,
            type: HandleType.source,
          ),
        ],
      ),
    );
  }
}

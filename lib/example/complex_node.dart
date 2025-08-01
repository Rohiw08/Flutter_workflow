import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

/// A node widget that demonstrates manual handle positioning.
class ComplexNode extends StatelessWidget {
  final String nodeId;
  const ComplexNode({super.key, required this.nodeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 100,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(child: Text('Complex Node')),

          // --- Manually position multiple handles on the left ---
          Positioned(
            left: -22, // Manual offset from the Stack's edge
            top: 10,
            child: Handle(nodeId: nodeId, id: 'a', type: HandleType.source),
          ),
          Positioned(
            left: -22,
            top: 40,
            child: Handle(nodeId: nodeId, id: 'b', type: HandleType.source),
          ),
        ],
      ),
    );
  }
}

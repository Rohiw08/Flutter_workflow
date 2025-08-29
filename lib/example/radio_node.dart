import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class RadioNodeWidget extends StatelessWidget {
  final FlowNode node;

  const RadioNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.size.width,
      height: node.size.height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Radio(
            value: node.id,
            groupValue: node.data['selectedValue'],
            onChanged: (value) {
              // Handle radio button change
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.data['title'] ?? 'Radio Node',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  node.data['description'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

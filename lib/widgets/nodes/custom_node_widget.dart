import 'package:flutter/material.dart';
import 'package:flutter_workflow/widgets/edges/handle.dart';

class CustomNodeWidget extends StatelessWidget {
  final String label;
  const CustomNodeWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label),
        ),
        const Handle(
          type: HandleType.target,
          position: HandlePosition.top,
          nodeId: 'handle1',
        ),
        const Handle(
          type: HandleType.source,
          position: HandlePosition.right,
          nodeId: 'handle2',
        ),
      ],
    );
  }
}

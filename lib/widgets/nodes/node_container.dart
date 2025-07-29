import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/models/flow_node.dart';
import 'package:flutter_workflow/providers/node_providers.dart';
import 'package:flutter_workflow/providers/canvas_provider.dart'; // Import canvas provider

class NodeContainer extends ConsumerWidget {
  final FlowNode node;
  final Widget child;
  
  const NodeContainer({
    super.key,
    required this.node,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the transformation controller to read the current scale
    final transformationController = ref.watch(transformationControllerProvider);

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanStart: (_) => ref.read(nodesProvider.notifier).onDragStart(node.id),
        onPanUpdate: (details) {
          // Adjust the drag delta by the canvas scale
          final scale = transformationController.value.getMaxScaleOnAxis();
          final scaledDelta = details.delta / scale;
          ref.read(nodesProvider.notifier).updateNodePosition(node.id, scaledDelta);
        },
        onPanEnd: (_) => ref.read(nodesProvider.notifier).onDragEnd(node.id),
        child: child,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/canvas_controller.dart';

/// Canvas control buttons widget
class FlowCanvasControls extends StatelessWidget {
  final FlowCanvasController controller;

  const FlowCanvasControls({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: controller.zoomIn,
                  tooltip: 'Zoom In',
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: controller.zoomOut,
                  tooltip: 'Zoom Out',
                ),
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: controller.centerView,
                  tooltip: 'Center View',
                ),
                if (controller.hasNodes)
                  IconButton(
                    icon: const Icon(Icons.fit_screen),
                    onPressed: controller.fitView,
                    tooltip: 'Fit View',
                  ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Nodes: ${controller.nodes.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (controller.hasSelection) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Selected: ${controller.selectedNodes.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade800,
                          ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

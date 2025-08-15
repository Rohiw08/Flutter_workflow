import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/managers/navigation_manager.dart';
import 'package:flutter_flow_canvas/src/core/models/flow_controller.dart';

/// Helper class for generating default canvas control actions
class DefaultActionsHelper {
  /// Generate default control actions for the given controller
  static List<FlowCanvasControlAction> getDefaultActions(
      NavigationManager controller) {
    return [
      FlowCanvasControlAction(
        icon: Icons.add,
        onPressed: controller.zoomIn,
        tooltip: 'Zoom In',
      ),
      FlowCanvasControlAction(
        icon: Icons.remove,
        onPressed: controller.zoomOut,
        tooltip: 'Zoom Out',
      ),
      FlowCanvasControlAction(
        icon: Icons.fit_screen,
        onPressed: controller.fitView,
        tooltip: 'Fit View',
      ),
    ];
  }
}

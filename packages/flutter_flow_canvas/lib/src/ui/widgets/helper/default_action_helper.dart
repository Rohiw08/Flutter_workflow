import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/managers/navigation_manager.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/control_button.dart';

/// Helper class for generating default canvas control actions
class DefaultActionsHelper {
  /// Generate default control actions for the given controller
  static List<FlowCanvasControlAction> getDefaultActions(
      NavigationManager navigationManager) {
    return [
      FlowCanvasControlAction(
        icon: Icons.add,
        onPressed: navigationManager.zoomIn,
        tooltip: 'Zoom In',
      ),
      FlowCanvasControlAction(
        icon: Icons.remove,
        onPressed: navigationManager.zoomOut,
        tooltip: 'Zoom Out',
      ),
      FlowCanvasControlAction(
        icon: Icons.fit_screen,
        onPressed: navigationManager.fitView,
        tooltip: 'Fit View',
      ),
      FlowCanvasControlAction(
        icon: navigationManager.isLocked
            ? Icons.lock_outline
            : Icons.lock_open_outlined,
        onPressed: navigationManager.toggleLock,
        tooltip: navigationManager.isLocked ? 'Unlock View' : 'Lock View',
      ),
    ];
  }
}

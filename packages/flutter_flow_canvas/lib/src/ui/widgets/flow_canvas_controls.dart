import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/managers/navigation_manager.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/control_button.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/controllers_divider.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/helper/default_action_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

class FlowCanvasControls extends ConsumerWidget {
  final bool showDefaultActions;
  final List<FlowCanvasControlAction> additionalActions;
  final Axis orientation;
  final ControlPanelAlignment alignment;
  final double buttonSize;

  const FlowCanvasControls({
    super.key,
    this.showDefaultActions = true,
    this.additionalActions = const [],
    this.orientation = Axis.vertical,
    this.alignment = ControlPanelAlignment.bottomRight,
    this.buttonSize = 32.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);
    final controlsTheme = context.flowCanvasTheme.controls;

    final defaultActions = showDefaultActions
        ? DefaultActionsHelper.getDefaultActions(controller.navigationManager)
        : <FlowCanvasControlAction>[];

    // Find the original lock action provided by the helper
    final lockActionIndex = defaultActions.indexWhere((action) =>
        action.onPressed == controller.navigationManager.toggleLock);

    // If found, replace it with a builder that creates our reactive widget
    if (lockActionIndex != -1) {
      defaultActions[lockActionIndex] = FlowCanvasControlAction(
        builder: (context) => _LockControlButton(
          navigationManager: controller.navigationManager,
          size: buttonSize,
        ),
      );
    }

    final List<Widget> children = [];

    void addActions(List<FlowCanvasControlAction> actions) {
      for (int i = 0; i < actions.length; i++) {
        children.add(ControlButton(
          action: actions[i],
          size: buttonSize,
        ));
        if (i < actions.length - 1) {
          children.add(ControlDivider(orientation: orientation));
        }
      }
    }

    if (defaultActions.isNotEmpty) addActions(defaultActions);

    if (defaultActions.isNotEmpty && additionalActions.isNotEmpty) {
      children.add(SectionDivider(orientation: orientation));
    }

    if (additionalActions.isNotEmpty) addActions(additionalActions);

    if (children.isEmpty) return const SizedBox.shrink();

    final panel = Container(
      padding: controlsTheme.padding,
      decoration: BoxDecoration(
        color: controlsTheme.backgroundColor,
        borderRadius: controlsTheme.borderRadius,
        boxShadow: controlsTheme.shadows,
        border: Border.all(color: controlsTheme.dividerColor, width: 1),
      ),
      child: Flex(
        direction: orientation,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    final constrainedPanel =
        orientation == Axis.vertical ? IntrinsicWidth(child: panel) : panel;

    return Align(
      alignment: AlignmentHelper.getAlignment(alignment),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: constrainedPanel,
      ),
    );
  }
}

// --- START: NEW REACTIVE WIDGET ---
/// A self-contained, reactive button for the lock/unlock functionality.
class _LockControlButton extends StatefulWidget {
  final NavigationManager navigationManager;
  final double size;

  const _LockControlButton({
    required this.navigationManager,
    required this.size,
  });

  @override
  State<_LockControlButton> createState() => _LockControlButtonState();
}

class _LockControlButtonState extends State<_LockControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final controlsTheme = context.flowCanvasTheme.controls;

    // Listen to the lock state directly from the manager
    return ValueListenableBuilder<bool>(
      valueListenable: widget.navigationManager.lockState,
      builder: (context, isLocked, child) {
        // Determine colors based on hover state
        final buttonColor = _isHovered
            ? controlsTheme.buttonHoverColor
            : controlsTheme.buttonColor;
        final iconColor =
            _isHovered ? controlsTheme.iconHoverColor : controlsTheme.iconColor;

        // This widget replicates the style of ControlButton but with reactive data
        return Tooltip(
          message: isLocked ? 'Unlock View' : 'Lock View',
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.navigationManager.toggleLock,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: controlsTheme.borderRadius
                      .resolve(Directionality.of(context))
                      .subtract(BorderRadius.circular(4)),
                ),
                child: Icon(
                  isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                  size: widget.size * 0.6,
                  color: iconColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

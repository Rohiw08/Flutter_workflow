import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/models/flow_controller.dart';
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
    this.alignment = ControlPanelAlignment.bottomRight, // Changed default
    this.buttonSize = 32.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);
    // UPDATED: Get the specific controls theme from the context
    final controlsTheme = context.flowCanvasTheme.controls;

    final defaultActions = showDefaultActions
        ? DefaultActionsHelper.getDefaultActions(controller.navigationManager)
        : <FlowCanvasControlAction>[];

    final List<Widget> children = [];

    // This local function remains the same, but the widgets it adds are now theme-aware.
    void addActions(List<FlowCanvasControlAction> actions) {
      for (int i = 0; i < actions.length; i++) {
        children.add(ControlButton(
          action: actions[i],
          size: buttonSize,
          // REMOVED: ControlButton now gets its colors from the theme internally.
        ));
        if (i < actions.length - 1) {
          // UPDATED: Divider now gets its color from the theme.
          children.add(ControlDivider(orientation: orientation));
        }
      }
    }

    if (defaultActions.isNotEmpty) addActions(defaultActions);

    if (defaultActions.isNotEmpty && additionalActions.isNotEmpty) {
      // UPDATED: SectionDivider also gets its color from the theme.
      children.add(SectionDivider(orientation: orientation));
    }

    if (additionalActions.isNotEmpty) addActions(additionalActions);

    if (children.isEmpty) return const SizedBox.shrink();

    // The main panel container
    final panel = Container(
      // UPDATED: Padding and decoration are now sourced from the theme.
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

    // This logic to prevent stretching remains the same.
    final constrainedPanel =
        orientation == Axis.vertical ? IntrinsicWidth(child: panel) : panel;

    return Align(
      alignment: AlignmentHelper.getAlignment(alignment),
      child: Padding(
        padding:
            const EdgeInsets.all(16.0), // Outer padding from the screen edge
        child: constrainedPanel,
      ),
    );
  }
}

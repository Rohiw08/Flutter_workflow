import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/models/flow_controller.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/control_button.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/controllers_divider.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/helper/alignment_helper.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/helper/default_action_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import '../../core/providers.dart';

class FlowCanvasControls extends ConsumerWidget {
  final bool showDefaultActions;
  final List<FlowCanvasControlAction> additionalActions;
  final Axis orientation;
  final ControlPanelAlignment alignment;

  // Styling
  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? iconColor;
  final double buttonSize;

  const FlowCanvasControls({
    super.key,
    this.showDefaultActions = true,
    this.additionalActions = const [],
    this.orientation = Axis.vertical,
    this.alignment = ControlPanelAlignment.topRight,
    this.backgroundColor,
    this.buttonColor,
    this.iconColor,
    this.buttonSize = 32.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor =
        backgroundColor ?? (isDark ? const Color(0xFF1F2937) : Colors.white);
    final btnColor = buttonColor ??
        (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB));
    final iconCol =
        iconColor ?? (isDark ? Colors.white : const Color(0xFF6B7280));
    final dividerColor =
        isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    final defaultActions = showDefaultActions
        ? DefaultActionsHelper.getDefaultActions(controller.navigationManager)
        : <FlowCanvasControlAction>[];

    final List<Widget> children = [];

    void addActions(List<FlowCanvasControlAction> actions) {
      for (int i = 0; i < actions.length; i++) {
        children.add(ControlButton(
          action: actions[i],
          color: btnColor,
          iconColor: iconCol,
          size: buttonSize,
        ));
        if (i < actions.length - 1) {
          children.add(
              ControlDivider(orientation: orientation, color: dividerColor));
        }
      }
    }

    if (defaultActions.isNotEmpty) addActions(defaultActions);

    if (defaultActions.isNotEmpty && additionalActions.isNotEmpty) {
      children
          .add(SectionDivider(orientation: orientation, color: dividerColor));
    }

    if (additionalActions.isNotEmpty) addActions(additionalActions);

    if (children.isEmpty) return const SizedBox.shrink();

    final panel = Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Flex(
        direction: orientation,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    // Fix: Prevent stretching in vertical orientation.
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

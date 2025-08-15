import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

/// A theme-aware divider for separating buttons in a control panel.
class ControlDivider extends StatelessWidget {
  final Axis orientation;

  const ControlDivider({
    super.key,
    required this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    // UPDATED: Get the divider color from the theme
    final dividerColor = context.flowCanvasTheme.controls.dividerColor;

    return Container(
      width: orientation == Axis.horizontal ? 1 : double.infinity,
      height: orientation == Axis.vertical ? 1 : 24,
      margin: orientation == Axis.vertical
          ? const EdgeInsets.symmetric(vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 2),
      color: dividerColor,
    );
  }
}

/// A theme-aware, wider divider for separating sections in a control panel.
class SectionDivider extends StatelessWidget {
  final Axis orientation;

  const SectionDivider({
    super.key,
    required this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    // UPDATED: Get the divider color from the theme
    final dividerColor = context.flowCanvasTheme.controls.dividerColor;

    return Container(
      width: orientation == Axis.horizontal ? 1 : double.infinity,
      height: orientation == Axis.vertical ? 1 : 24,
      margin: orientation == Axis.vertical
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 8),
      color: dividerColor,
    );
  }
}

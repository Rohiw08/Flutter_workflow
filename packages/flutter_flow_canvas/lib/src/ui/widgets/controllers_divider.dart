import 'package:flutter/material.dart';

/// Divider between buttons
class ControlDivider extends StatelessWidget {
  final Axis orientation;
  final Color color;

  const ControlDivider({
    super.key,
    required this.orientation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: orientation == Axis.horizontal ? 1 : double.infinity,
      height: orientation == Axis.vertical ? 1 : 24,
      margin: orientation == Axis.vertical
          ? const EdgeInsets.symmetric(vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 2),
      color: color,
    );
  }
}

/// Divider between control sections
class SectionDivider extends StatelessWidget {
  final Axis orientation;
  final Color color;

  const SectionDivider({
    super.key,
    required this.orientation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: orientation == Axis.horizontal ? 1 : double.infinity,
      height: orientation == Axis.vertical ? 1 : 24,
      margin: orientation == Axis.vertical
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 8),
      color: color,
    );
  }
}

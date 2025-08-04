import 'package:flutter/material.dart';

/// Defines a single control action button.
class FlowCanvasControlAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const FlowCanvasControlAction({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });
}

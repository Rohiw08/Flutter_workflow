import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/models/flow_controller.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

/// A theme-aware button for canvas control actions.
class ControlButton extends StatefulWidget {
  final FlowCanvasControlAction action;
  final double size;

  const ControlButton({
    super.key,
    required this.action,
    required this.size,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // UPDATED: Get the controls theme from the context
    final controlsTheme = context.flowCanvasTheme.controls;

    // UPDATED: Determine colors based on the theme and hover state
    final buttonColor =
        _isHovered ? controlsTheme.buttonHoverColor : controlsTheme.buttonColor;
    final iconColor =
        _isHovered ? controlsTheme.iconHoverColor : controlsTheme.iconColor;

    return Tooltip(
      message: widget.action.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.action.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              // UPDATED: Use theme-derived colors
              color: buttonColor,
              borderRadius: controlsTheme.borderRadius
                  .resolve(Directionality.of(context))
                  .subtract(
                      BorderRadius.circular(4)), // Adjust for inner radius
            ),
            child: Icon(
              widget.action.icon,
              size: widget.size * 0.6,
              // UPDATED: Use theme-derived icon color
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

class FlowCanvasControlAction {
  final Widget Function(BuildContext)? builder; // optional builder
  final IconData? icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const FlowCanvasControlAction({
    this.icon,
    this.onPressed,
    this.tooltip,
    this.builder,
  });
}

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
    final controlsTheme = context.flowCanvasTheme.controls;

    // Hover colors
    final buttonColor =
        _isHovered ? controlsTheme.buttonHoverColor : controlsTheme.buttonColor;
    final iconColor =
        _isHovered ? controlsTheme.iconHoverColor : controlsTheme.iconColor;

    // If using builder mode
    if (widget.action.builder != null) {
      return widget.action.builder!(context);
    }

    // Icon mode
    return Tooltip(
      message: widget.action.tooltip ?? '',
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
              color: buttonColor,
              borderRadius: controlsTheme.borderRadius
                  .resolve(Directionality.of(context))
                  .subtract(BorderRadius.circular(4)),
            ),
            child: Icon(
              widget.action.icon,
              size: widget.size * 0.6,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

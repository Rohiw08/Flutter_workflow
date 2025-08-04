import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/models/flow_controller.dart';

/// Control Button widget for canvas controls
class ControlButton extends StatefulWidget {
  final FlowCanvasControlAction action;
  final Color color;
  final Color iconColor;
  final double size;

  const ControlButton({
    super.key,
    required this.action,
    required this.color,
    required this.iconColor,
    required this.size,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
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
              color: _isHovered ? widget.color.withAlpha(200) : widget.color,
              borderRadius: BorderRadius.circular(4),
              border: _isHovered
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Icon(
              widget.action.icon,
              size: widget.size * 0.5,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

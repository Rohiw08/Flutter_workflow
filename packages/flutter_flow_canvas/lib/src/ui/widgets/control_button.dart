import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/components/control_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_extensions.dart';

class FlowCanvasControlAction {
  final Widget Function(BuildContext)? builder; // optional builder
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback?
      onPressedOverride; // New: Optional callback for side effects
  final String? tooltip;

  const FlowCanvasControlAction({
    this.icon,
    this.onPressed,
    this.onPressedOverride,
    this.tooltip,
    this.builder,
  });
}

class ControlButton extends StatefulWidget {
  final FlowCanvasControlAction action;
  final double size;
  final FlowCanvasControlTheme? theme;

  const ControlButton({
    super.key,
    required this.action,
    required this.size,
    this.theme,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Level 2 > Level 1 precedence
    final controlsTheme = widget.theme ?? context.flowCanvasTheme.controls;

    // Hover colors
    final buttonColor =
        _isHovered ? controlsTheme.buttonHoverColor : controlsTheme.buttonColor;
    final iconColor =
        _isHovered ? controlsTheme.iconHoverColor : controlsTheme.iconColor;

    // If using builder mode
    if (widget.action.builder != null) {
      return Semantics(
        label: widget.action.tooltip,
        button: true,
        child: widget.action.builder!(context),
      );
    }

    // Icon mode
    return Semantics(
      label: widget.action.tooltip,
      button: true,
      child: Tooltip(
        message: widget.action.tooltip ?? '',
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              widget.action.onPressed?.call();
              widget.action.onPressedOverride
                  ?.call(); // Call override if provided
            },
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
      ),
    );
  }
}

class ControlDivider extends StatelessWidget {
  final Axis orientation;

  /// Theme passed from parent (`FlowCanvasControls`)
  final FlowCanvasControlTheme? theme;

  const ControlDivider({
    super.key,
    required this.orientation,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Level 2 > Level 1 precedence
    final controlsTheme = theme ?? context.flowCanvasTheme.controls;

    return Container(
      width: orientation == Axis.horizontal ? 1 : double.infinity,
      height: orientation == Axis.vertical ? 1 : 24,
      margin: orientation == Axis.vertical
          ? const EdgeInsets.symmetric(vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 2),
      color: controlsTheme.dividerColor,
    );
  }
}

class SectionDivider extends StatelessWidget {
  final Axis orientation;
  final FlowCanvasControlTheme? theme;

  const SectionDivider({
    super.key,
    required this.orientation,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Level 2 > Level 1 precedence
    final controlsTheme = theme ?? context.flowCanvasTheme.controls;

    return Container(
      width: orientation == Axis.horizontal ? 1 : double.infinity,
      height: orientation == Axis.vertical ? 1 : 24,
      margin: orientation == Axis.vertical
          ? const EdgeInsets.symmetric(vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 8),
      color: controlsTheme.dividerColor,
    );
  }
}

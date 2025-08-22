import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/managers/navigation_manager.dart';
import 'package:flutter_flow_canvas/src/ui/widgets/helper/default_action_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class FlowCanvasControls extends ConsumerWidget {
  final bool showZoom; // New: Granular visibility for zoom buttons
  final bool showFitView; // New: Granular visibility for fit view
  final bool showLock; // New: Granular visibility for lock
  final List<FlowCanvasControlAction> additionalActions;
  final List<Widget> children; // New: Allow arbitrary custom widgets
  final Axis orientation;
  final Alignment alignment;
  final FlowCanvasControlTheme? controlsTheme;
  final double buttonSize;
  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? iconColor;

  const FlowCanvasControls({
    super.key,
    this.showZoom = true,
    this.showFitView = true,
    this.showLock = true,
    this.additionalActions = const [],
    this.children = const [], // New: Default empty list for custom children
    this.orientation = Axis.vertical,
    this.alignment = Alignment.bottomLeft,
    this.buttonSize = 32.0,
    this.controlsTheme,
    this.backgroundColor,
    this.buttonColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(flowControllerProvider);

    final baseTheme = context.flowCanvasTheme.controls;
    final themeFromPrecedence = controlsTheme ?? baseTheme;

    final finalControlsTheme = themeFromPrecedence.copyWith(
      backgroundColor: backgroundColor ?? themeFromPrecedence.backgroundColor,
      buttonColor: buttonColor ?? themeFromPrecedence.buttonColor,
      iconColor: iconColor ?? themeFromPrecedence.iconColor,
    );

    final defaultActions = DefaultActionsHelper.getDefaultActions(
      controller.navigationManager,
      showZoom: showZoom,
      showFitView: showFitView,
      showLock: showLock,
    );

    // Replace lock action with reactive builder if shown
    final lockActionIndex = defaultActions.indexWhere(
      (action) => action.onPressed == controller.navigationManager.toggleLock,
    );

    if (lockActionIndex != -1) {
      defaultActions[lockActionIndex] = FlowCanvasControlAction(
        builder: (context) => _LockControlButton(
          navigationManager: controller.navigationManager,
          size: buttonSize,
        ),
      );
    }

    final List<Widget> panelChildren = [];

    void addActions(List<FlowCanvasControlAction> actions) {
      for (int i = 0; i < actions.length; i++) {
        panelChildren.add(ControlButton(
          action: actions[i],
          size: buttonSize,
          theme: finalControlsTheme,
        ));
        if (i < actions.length - 1) {
          panelChildren.add(ControlDivider(
            orientation: orientation,
            theme: finalControlsTheme,
          ));
        }
      }
    }

    if (defaultActions.isNotEmpty) addActions(defaultActions);

    if (defaultActions.isNotEmpty &&
        (additionalActions.isNotEmpty || children.isNotEmpty)) {
      panelChildren.add(SectionDivider(
        orientation: orientation,
        theme: finalControlsTheme,
      ));
    }

    if (additionalActions.isNotEmpty) addActions(additionalActions);

    if (additionalActions.isNotEmpty && children.isNotEmpty) {
      panelChildren.add(SectionDivider(
        orientation: orientation,
        theme: finalControlsTheme,
      ));
    }

    if (children.isNotEmpty) {
      panelChildren.addAll(children); // Add custom widgets at the end
    }

    if (panelChildren.isEmpty) return const SizedBox.shrink();

    // -----------------------------
    // Panel UI
    // -----------------------------
    final panel = Container(
      padding: finalControlsTheme.padding,
      decoration: BoxDecoration(
        color: finalControlsTheme.backgroundColor,
        borderRadius: finalControlsTheme.borderRadius,
        boxShadow: finalControlsTheme.shadows,
        border: Border.all(
          color: finalControlsTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Flex(
        direction: orientation,
        mainAxisSize: MainAxisSize.min,
        children: panelChildren,
      ),
    );

    final constrainedPanel = orientation == Axis.vertical
        ? IntrinsicWidth(child: panel)
        : IntrinsicHeight(
            child: panel); // New: Add IntrinsicHeight for horizontal mode

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: constrainedPanel,
      ),
    );
  }
}

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

    return ValueListenableBuilder<bool>(
      valueListenable: widget.navigationManager.lockState,
      builder: (context, isLocked, child) {
        final buttonColor = _isHovered
            ? controlsTheme.buttonHoverColor
            : controlsTheme.buttonColor;
        final iconColor =
            _isHovered ? controlsTheme.iconHoverColor : controlsTheme.iconColor;

        return Semantics(
          label: isLocked ? 'Unlock View' : 'Lock View',
          button: true,
          child: Tooltip(
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
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';

/// Provides FlowCanvas theme to the widget tree
class FlowCanvasThemeProvider extends StatelessWidget {
  final FlowCanvasTheme theme;
  final Widget child;

  const FlowCanvasThemeProvider({
    super.key,
    required this.theme,
    required this.child,
  });

  /// Convenience constructor for light theme
  FlowCanvasThemeProvider.light({
    super.key,
    required this.child,
  }) : theme = FlowCanvasTheme.light();

  /// Convenience constructor for dark theme
  FlowCanvasThemeProvider.dark({
    super.key,
    required this.child,
  }) : theme = FlowCanvasTheme.dark();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(context).extensions.values,
        ],
      ),
      child: child,
    );
  }

  /// Get the FlowCanvas theme from the context
  static FlowCanvasTheme of(BuildContext context) {
    return Theme.of(context).extension<FlowCanvasTheme>() ??
        FlowCanvasTheme.light();
  }

  /// Get the FlowCanvas theme from the context or null if not found
  static FlowCanvasTheme? maybeOf(BuildContext context) {
    return Theme.of(context).extension<FlowCanvasTheme>();
  }
}

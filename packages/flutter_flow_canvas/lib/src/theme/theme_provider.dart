import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';

class FlowCanvasThemeProvider extends InheritedWidget {
  final FlowCanvasTheme theme;

  const FlowCanvasThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  static FlowCanvasTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<FlowCanvasThemeProvider>();
    return provider?.theme ?? FlowCanvasTheme.light();
  }

  @override
  bool updateShouldNotify(FlowCanvasThemeProvider oldWidget) {
    return oldWidget.theme != theme;
  }
}

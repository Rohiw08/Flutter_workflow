import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';

/// Extension to easily access FlowCanvasTheme
extension FlowCanvasThemeExtension on BuildContext {
  FlowCanvasTheme get flowCanvasTheme {
    return Theme.of(this).extension<FlowCanvasTheme>() ??
        FlowCanvasTheme.light();
  }
}

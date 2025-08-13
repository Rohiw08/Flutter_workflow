import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_provider.dart';

extension FlowCanvasThemeExtension on BuildContext {
  /// Returns the current [FlowCanvasTheme].
  FlowCanvasTheme get flowTheme => FlowCanvasThemeProvider.of(this);
}

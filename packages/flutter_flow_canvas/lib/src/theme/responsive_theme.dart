// Responsive theming based on screen size and density
import 'dart:ui';
import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';

class ResponsiveThemeConfig {
  final double compactBreakpoint;
  final double mediumBreakpoint;
  final double expandedBreakpoint;

  const ResponsiveThemeConfig({
    this.compactBreakpoint = 600,
    this.mediumBreakpoint = 840,
    this.expandedBreakpoint = 1200,
  });
}

class ResponsiveFlowCanvasTheme {
  final ResponsiveThemeConfig config;

  const ResponsiveFlowCanvasTheme({
    this.config = const ResponsiveThemeConfig(),
  });

  FlowCanvasTheme getThemeForSize(Size screenSize, FlowCanvasTheme baseTheme) {
    final width = screenSize.width;

    if (width < config.compactBreakpoint) {
      return _adaptForCompact(baseTheme);
    } else if (width < config.mediumBreakpoint) {
      return _adaptForMedium(baseTheme);
    } else {
      return _adaptForExpanded(baseTheme);
    }
  }

  FlowCanvasTheme _adaptForCompact(FlowCanvasTheme theme) {
    return theme.copyWith(
      handle: theme.handle.copyWith(size: theme.handle.size * 1.2),
      controls:
          theme.controls.copyWith(buttonSize: theme.controls.buttonSize * 1.1),
      background: theme.background.copyWith(gap: theme.background.gap * 0.8),
    );
  }

  FlowCanvasTheme _adaptForMedium(FlowCanvasTheme theme) {
    return theme.copyWith(
      handle: theme.handle.copyWith(size: theme.handle.size * 1.1),
      controls:
          theme.controls.copyWith(buttonSize: theme.controls.buttonSize * 1.05),
    );
  }

  FlowCanvasTheme _adaptForExpanded(FlowCanvasTheme theme) {
    return theme; // No changes for large screens
  }
}

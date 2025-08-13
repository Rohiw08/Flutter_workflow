import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';
import 'package:flutter_flow_canvas/src/theme/default_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';
import 'package:flutter_flow_canvas/src/theme/theme_builder.dart';

class FlowCanvasThemeUtils {
  /// Create a theme from a base color
  static FlowCanvasTheme fromBaseColor(Color baseColor, {bool isDark = false}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return FlowCanvasThemes.fromColorScheme(colorScheme);
  }

  /// Interpolate between two themes for smooth transitions
  static FlowCanvasTheme lerp(FlowCanvasTheme a, FlowCanvasTheme b, double t) {
    return FlowCanvasTheme(
      background: _lerpBackground(a.background, b.background, t),
      node: _lerpNode(a.node, b.node, t),
      edge: _lerpEdge(a.edge, b.edge, t),
      handle: _lerpHandle(a.handle, b.handle, t),
      selection: _lerpSelection(a.selection, b.selection, t),
      controls: _lerpControls(a.controls, b.controls, t),
      miniMap: _lerpMiniMap(a.miniMap, b.miniMap, t),
      connection: _lerpConnection(a.connection, b.connection, t),
    );
  }

  static FlowCanvasBackgroundTheme _lerpBackground(
      FlowCanvasBackgroundTheme a, FlowCanvasBackgroundTheme b, double t) {
    return FlowCanvasBackgroundTheme(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t)!,
      variant: t < 0.5 ? a.variant : b.variant,
      patternColor: Color.lerp(a.patternColor, b.patternColor, t)!,
      gap: _lerpDouble(a.gap, b.gap, t),
      lineWidth: _lerpDouble(a.lineWidth, b.lineWidth, t),
      fadeOnZoom: t < 0.5 ? a.fadeOnZoom : b.fadeOnZoom,
      gradient: t < 0.5 ? a.gradient : b.gradient,
    );
  }

  static FlowCanvasNodeTheme _lerpNode(
      FlowCanvasNodeTheme a, FlowCanvasNodeTheme b, double t) {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor:
          Color.lerp(a.defaultBackgroundColor, b.defaultBackgroundColor, t)!,
      defaultBorderColor:
          Color.lerp(a.defaultBorderColor, b.defaultBorderColor, t)!,
      selectedBackgroundColor:
          Color.lerp(a.selectedBackgroundColor, b.selectedBackgroundColor, t)!,
      selectedBorderColor:
          Color.lerp(a.selectedBorderColor, b.selectedBorderColor, t)!,
      errorBackgroundColor:
          Color.lerp(a.errorBackgroundColor, b.errorBackgroundColor, t)!,
      errorBorderColor: Color.lerp(a.errorBorderColor, b.errorBorderColor, t)!,
      defaultBorderWidth:
          _lerpDouble(a.defaultBorderWidth, b.defaultBorderWidth, t),
      selectedBorderWidth:
          _lerpDouble(a.selectedBorderWidth, b.selectedBorderWidth, t),
      borderRadius: _lerpDouble(a.borderRadius, b.borderRadius, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      defaultTextStyle:
          TextStyle.lerp(a.defaultTextStyle, b.defaultTextStyle, t)!,
    );
  }

  static FlowCanvasEdgeTheme _lerpEdge(
      FlowCanvasEdgeTheme a, FlowCanvasEdgeTheme b, double t) {
    return FlowCanvasEdgeTheme(
      defaultColor: Color.lerp(a.defaultColor, b.defaultColor, t)!,
      selectedColor: Color.lerp(a.selectedColor, b.selectedColor, t)!,
      animatedColor: Color.lerp(a.animatedColor, b.animatedColor, t)!,
      defaultStrokeWidth:
          _lerpDouble(a.defaultStrokeWidth, b.defaultStrokeWidth, t),
      selectedStrokeWidth:
          _lerpDouble(a.selectedStrokeWidth, b.selectedStrokeWidth, t),
      arrowHeadSize: _lerpDouble(a.arrowHeadSize, b.arrowHeadSize, t),
      label: t < 0.5 ? a.label : b.label,
    );
  }

  static FlowCanvasHandleTheme _lerpHandle(
      FlowCanvasHandleTheme a, FlowCanvasHandleTheme b, double t) {
    return FlowCanvasHandleTheme(
      idleColor: Color.lerp(a.idleColor, b.idleColor, t)!,
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t)!,
      connectingColor: Color.lerp(a.connectingColor, b.connectingColor, t)!,
      validTargetColor: Color.lerp(a.validTargetColor, b.validTargetColor, t)!,
      invalidTargetColor:
          Color.lerp(a.invalidTargetColor, b.invalidTargetColor, t)!,
      size: _lerpDouble(a.size, b.size, t),
      borderWidth: _lerpDouble(a.borderWidth, b.borderWidth, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
      shadows: t < 0.5 ? a.shadows : b.shadows,
      enableAnimations: t < 0.5 ? a.enableAnimations : b.enableAnimations,
    );
  }

  static FlowCanvasSelectionTheme _lerpSelection(
      FlowCanvasSelectionTheme a, FlowCanvasSelectionTheme b, double t) {
    return FlowCanvasSelectionTheme(
      fillColor: Color.lerp(a.fillColor, b.fillColor, t)!,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t)!,
      borderWidth: _lerpDouble(a.borderWidth, b.borderWidth, t),
      dashLength: _lerpDouble(a.dashLength, b.dashLength, t),
      gapLength: _lerpDouble(a.gapLength, b.gapLength, t),
    );
  }

  static FlowCanvasControlTheme _lerpControls(
      FlowCanvasControlTheme a, FlowCanvasControlTheme b, double t) {
    return FlowCanvasControlTheme(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t)!,
      buttonColor: Color.lerp(a.buttonColor, b.buttonColor, t)!,
      buttonHoverColor: Color.lerp(a.buttonHoverColor, b.buttonHoverColor, t)!,
      iconColor: Color.lerp(a.iconColor, b.iconColor, t)!,
      iconHoverColor: Color.lerp(a.iconHoverColor, b.iconHoverColor, t)!,
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t)!,
      buttonSize: _lerpDouble(a.buttonSize, b.buttonSize, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t)!,
      shadows: t < 0.5 ? a.shadows : b.shadows,
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
    );
  }

  static FlowCanvasMiniMapTheme _lerpMiniMap(
      FlowCanvasMiniMapTheme a, FlowCanvasMiniMapTheme b, double t) {
    return FlowCanvasMiniMapTheme(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t)!,
      nodeColor: Color.lerp(a.nodeColor, b.nodeColor, t)!,
      nodeStrokeColor: Color.lerp(a.nodeStrokeColor, b.nodeStrokeColor, t)!,
      selectedNodeColor:
          Color.lerp(a.selectedNodeColor, b.selectedNodeColor, t)!,
      maskColor: Color.lerp(a.maskColor, b.maskColor, t)!,
      maskStrokeColor: Color.lerp(a.maskStrokeColor, b.maskStrokeColor, t)!,
      nodeStrokeWidth: _lerpDouble(a.nodeStrokeWidth, b.nodeStrokeWidth, t),
      maskStrokeWidth: _lerpDouble(a.maskStrokeWidth, b.maskStrokeWidth, t),
      borderRadius: _lerpDouble(a.borderRadius, b.borderRadius, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
    );
  }

  static FlowCanvasConnectionTheme _lerpConnection(
      FlowCanvasConnectionTheme a, FlowCanvasConnectionTheme b, double t) {
    return FlowCanvasConnectionTheme(
      activeColor: Color.lerp(a.activeColor, b.activeColor, t)!,
      validTargetColor: Color.lerp(a.validTargetColor, b.validTargetColor, t)!,
      invalidTargetColor:
          Color.lerp(a.invalidTargetColor, b.invalidTargetColor, t)!,
      strokeWidth: _lerpDouble(a.strokeWidth, b.strokeWidth, t),
      endPointRadius: _lerpDouble(a.endPointRadius, b.endPointRadius, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Validate theme for accessibility
  static List<String> validateAccessibility(FlowCanvasTheme theme) {
    final issues = <String>[];

    // Check contrast ratios
    final bgLuminance = theme.background.backgroundColor.computeLuminance();
    final textLuminance =
        theme.node.defaultTextStyle.color?.computeLuminance() ?? 0.0;

    final contrast = _calculateContrast(bgLuminance, textLuminance);
    if (contrast < 4.5) {
      issues.add('Text contrast ratio is below WCAG AA standard (4.5:1)');
    }

    // Check handle sizes
    if (theme.handle.size < 8.0) {
      issues.add('Handle size is too small for touch targets (minimum 8.0)');
    }

    // Check button sizes
    if (theme.controls.buttonSize < 32.0) {
      issues.add('Control button size is too small (minimum 32.0)');
    }

    return issues;
  }

  static double _calculateContrast(double luminance1, double luminance2) {
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Generate a theme based on brand colors
  static FlowCanvasTheme generateBrandTheme({
    required Color primaryColor,
    required Color backgroundColor,
    Color? accentColor,
    bool isDark = false,
  }) {
    final accent = accentColor ?? _generateAccentColor(primaryColor);
    final textColor = isDark ? Colors.white : Colors.black87;

    return FlowCanvasThemeBuilder()
        .background(
          backgroundColor: backgroundColor,
          patternColor: primaryColor.withAlpha(51),
          variant: BackgroundVariant.dots,
        )
        .nodes(
          defaultBackgroundColor: backgroundColor,
          defaultBorderColor: primaryColor.withAlpha(128),
          selectedBorderColor: primaryColor,
          textStyle: TextStyle(color: textColor),
        )
        .edges(
          defaultColor: primaryColor.withAlpha(128),
          selectedColor: primaryColor,
          animatedColor: accent,
        )
        .handles(
          idleColor: primaryColor.withAlpha(128),
          hoverColor: primaryColor,
          connectingColor: accent,
        )
        .build();
  }

  static Color _generateAccentColor(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withHue((hsl.hue + 30) % 360).toColor();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/default_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/flow_canvas_theme.dart';

class FlowCanvasThemeBuilder {
  FlowCanvasTheme _theme;

  FlowCanvasThemeBuilder([FlowCanvasTheme? baseTheme])
      : _theme = baseTheme ?? FlowCanvasThemes.professional;

  /// Start with a predefined theme
  FlowCanvasThemeBuilder.fromTheme(FlowCanvasTheme theme) : _theme = theme;

  /// Start with a named theme
  FlowCanvasThemeBuilder.named(String themeName)
      : _theme = FlowCanvasThemes.getThemeByName(themeName) ??
            FlowCanvasThemes.professional;

  /// Configure background
  FlowCanvasThemeBuilder background({
    Color? backgroundColor,
    BackgroundVariant? variant,
    Color? patternColor,
    double? gap,
    double? lineWidth,
    bool? fadeOnZoom,
    Gradient? gradient,
  }) {
    _theme = _theme.copyWith(
      background: _theme.background.copyWith(
        backgroundColor: backgroundColor,
        variant: variant,
        patternColor: patternColor,
        gap: gap,
        lineWidth: lineWidth,
        fadeOnZoom: fadeOnZoom,
        gradient: gradient,
      ),
    );
    return this;
  }

  /// Configure nodes
  FlowCanvasThemeBuilder nodes({
    Color? defaultBackgroundColor,
    Color? defaultBorderColor,
    Color? selectedBackgroundColor,
    Color? selectedBorderColor,
    double? borderRadius,
    List<BoxShadow>? shadows,
    TextStyle? textStyle,
  }) {
    _theme = _theme.copyWith(
      node: _theme.node.copyWith(
        defaultBackgroundColor: defaultBackgroundColor,
        defaultBorderColor: defaultBorderColor,
        selectedBackgroundColor: selectedBackgroundColor,
        selectedBorderColor: selectedBorderColor,
        borderRadius: borderRadius,
        shadows: shadows,
        defaultTextStyle: textStyle,
      ),
    );
    return this;
  }

  /// Configure edges
  FlowCanvasThemeBuilder edges({
    Color? defaultColor,
    Color? selectedColor,
    Color? animatedColor,
    double? strokeWidth,
    double? selectedStrokeWidth,
  }) {
    _theme = _theme.copyWith(
      edge: _theme.edge.copyWith(
        defaultColor: defaultColor,
        selectedColor: selectedColor,
        animatedColor: animatedColor,
        defaultStrokeWidth: strokeWidth,
        selectedStrokeWidth: selectedStrokeWidth,
      ),
    );
    return this;
  }

  /// Configure handles
  FlowCanvasThemeBuilder handles({
    Color? idleColor,
    Color? hoverColor,
    Color? connectingColor,
    double? size,
    Color? borderColor,
    double? borderWidth,
  }) {
    _theme = _theme.copyWith(
      handle: _theme.handle.copyWith(
        idleColor: idleColor,
        hoverColor: hoverColor,
        connectingColor: connectingColor,
        size: size,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
    );
    return this;
  }

  /// Configure controls
  FlowCanvasThemeBuilder controls({
    Color? backgroundColor,
    Color? buttonColor,
    Color? iconColor,
    double? buttonSize,
    BorderRadius? borderRadius,
  }) {
    _theme = _theme.copyWith(
      controls: _theme.controls.copyWith(
        backgroundColor: backgroundColor,
        buttonColor: buttonColor,
        iconColor: iconColor,
        buttonSize: buttonSize,
        borderRadius: borderRadius,
      ),
    );
    return this;
  }

  /// Apply a color scheme to the entire theme
  FlowCanvasThemeBuilder colorScheme(ColorScheme scheme) {
    _theme = _theme.copyWith(
      background: _theme.background.copyWith(
        backgroundColor: scheme.surface,
        patternColor: scheme.outline,
      ),
      node: _theme.node.copyWith(
        defaultBackgroundColor: scheme.surfaceContainer,
        defaultBorderColor: scheme.outline,
        selectedBackgroundColor: scheme.primaryContainer,
        selectedBorderColor: scheme.primary,
        defaultTextStyle: _theme.node.defaultTextStyle.copyWith(
          color: scheme.onSurface,
        ),
      ),
      edge: _theme.edge.copyWith(
        defaultColor: scheme.outline,
        selectedColor: scheme.primary,
      ),
      handle: _theme.handle.copyWith(
        idleColor: scheme.outline,
        hoverColor: scheme.primary,
        connectingColor: scheme.secondary,
      ),
    );
    return this;
  }

  /// Build the final theme
  FlowCanvasTheme build() => _theme;
}

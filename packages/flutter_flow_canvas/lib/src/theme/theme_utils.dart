import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';

/// A collection of utility functions for creating and manipulating FlowCanvas themes.
class FlowCanvasThemeUtils {
  FlowCanvasThemeUtils._();

  /// Create a theme from a single base color using Material 3's ColorScheme.fromSeed.
  static FlowCanvasTheme fromBaseColor(
    Color baseColor, {
    Brightness brightness = Brightness.light,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      brightness: brightness,
    );
    return FlowCanvasTheme.fromColorScheme(colorScheme);
  }

  /// Create a theme directly from a Material 3 ColorScheme.
  static FlowCanvasTheme fromMaterial3(ColorScheme colorScheme) {
    return FlowCanvasTheme.fromColorScheme(colorScheme);
  }

  /// Validate a theme for common accessibility issues.
  static List<String> validateAccessibility(FlowCanvasTheme theme) {
    final issues = <String>[];

    // Check contrast ratio between node text and node background
    final bgLuminance = theme.node.defaultBackgroundColor.computeLuminance();
    final textLuminance =
        theme.node.defaultTextStyle.color?.computeLuminance() ?? 0.0;
    final contrast = _calculateContrast(bgLuminance, textLuminance);

    if (contrast < 4.5) {
      issues.add('Node text contrast ratio is below WCAG AA standard (4.5:1)');
    }

    // Check handle size for touch targets
    if (theme.handle.size < 8.0) {
      issues.add('Handle size is too small for touch targets (minimum 8.0)');
    }

    // Check node text size
    if (theme.node.defaultTextStyle.fontSize != null &&
        theme.node.defaultTextStyle.fontSize! < 12.0) {
      issues.add('Node text size is too small (minimum 12.0)');
    }

    return issues;
  }

  static double _calculateContrast(double luminance1, double luminance2) {
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Create a theme from a set of brand colors.
  static FlowCanvasTheme createBrandTheme({
    required Color primaryColor,
    required Color backgroundColor,
    Color? accentColor,
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark;
    final accent = accentColor ?? _generateAccentColor(primaryColor);

    final baseTheme = isDark ? FlowCanvasTheme.dark() : FlowCanvasTheme.light();

    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: backgroundColor,
        patternColor: primaryColor.withAlpha(52),
      ),
      node: baseTheme.node.copyWith(
        selectedBorderColor: primaryColor,
        // You might want to customize other node properties here
      ),
      edge: baseTheme.edge.copyWith(
        defaultColor: primaryColor.withAlpha(179),
        selectedColor: primaryColor,
        hoverColor: primaryColor,
      ),
      handle: baseTheme.handle.copyWith(
        activeColor: accent,
        hoverColor: accent,
      ),
    );
  }

  static Color _generateAccentColor(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withHue((hsl.hue + 45) % 360).toColor();
  }

  /// Get node decoration for different states by delegating to the node theme.
  static BoxDecoration getNodeDecoration(
    FlowCanvasTheme theme, {
    bool isSelected = false,
    bool isHovered = false,
    bool hasError = false,
    bool isDisabled = false,
  }) {
    return theme.node
        .getStyleForState(
          isSelected: isSelected,
          isHovered: isHovered,
          hasError: hasError,
          isDisabled: isDisabled,
        )
        .decoration;
  }

  /// Get edge paint for different states.
  static Paint getEdgePaint(
    FlowCanvasTheme theme, {
    bool isSelected = false,
    bool isHovered = false,
  }) {
    Color color = theme.edge.defaultColor;
    double width = theme.edge.defaultStrokeWidth;

    if (isSelected) {
      color = theme.edge.selectedColor;
      width = theme.edge.selectedStrokeWidth;
    } else if (isHovered) {
      color = theme.edge.hoverColor ?? theme.edge.defaultColor;
    }

    return Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  /// Get handle color for different states.
  static Color getHandleColor(
    FlowCanvasTheme theme, {
    bool isHovered = false,
    bool isActive = false,
    bool isValid = false,
    bool isInvalid = false,
  }) {
    if (isInvalid) return theme.handle.invalidTargetColor;
    if (isValid) return theme.handle.validTargetColor;
    if (isActive) return theme.handle.activeColor;
    if (isHovered) return theme.handle.hoverColor;
    return theme.handle.idleColor;
  }
}

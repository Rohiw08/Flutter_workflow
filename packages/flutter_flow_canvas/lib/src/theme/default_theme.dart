import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/components/background_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/flow_canvas_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/node_theme.dart';

class FlowCanvasThemes {
  /// Professional light theme
  static FlowCanvasTheme get professional => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFFBFBFB),
          patternColor: const Color(0xFFE8E8E8),
          variant: BackgroundVariant.lines,
          gap: 25.0,
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBackgroundColor: const Color(0xFFFEFEFE),
          defaultBorderColor: const Color(0xFFD1D5DB),
          selectedBorderColor: const Color(0xFF3B82F6),
          borderRadius: 6.0,
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );

  /// Dark professional theme
  static FlowCanvasTheme get darkProfessional =>
      FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF0F0F0F),
          patternColor: const Color(0xFF2A2A2A),
          variant: BackgroundVariant.lines,
          gap: 25.0,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBackgroundColor: const Color(0xFF1C1C1C),
          selectedBorderColor: const Color(0xFF60A5FA),
          borderRadius: 6.0,
        ),
      );

  /// High contrast theme for accessibility
  static FlowCanvasTheme get highContrast => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: Colors.white,
          patternColor: Colors.black,
          variant: BackgroundVariant.dots,
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBorderColor: Colors.black,
          selectedBackgroundColor: const Color(0xFFFFEB3B),
          defaultBorderWidth: 2.0,
          selectedBorderWidth: 3.0,
        ),
      );

  /// Vibrant colorful theme
  static FlowCanvasTheme get vibrant => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFF8FAFC),
          patternColor: const Color(0xFFE2E8F0),
          variant: BackgroundVariant.dots,
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          selectedBorderColor: const Color(0xFF8B5CF6),
          borderRadius: 12.0,
        ),
      );

  /// Minimal clean theme
  static FlowCanvasTheme get minimal => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: Colors.white,
          variant: BackgroundVariant.none,
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          selectedBorderColor: Colors.black,
          borderRadius: 4.0,
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );

  /// Blueprint technical theme
  static FlowCanvasTheme get blueprint => FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF1E3A8A),
          patternColor: const Color(0xFF3B82F6),
          variant: BackgroundVariant.lines,
          gap: 20.0,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBackgroundColor: const Color(0xFF1E3A8A),
          defaultBorderColor: const Color(0xFF60A5FA),
          selectedBorderColor: const Color(0xFFFBBF24),
          borderRadius: 0.0,
          shadows: [],
        ),
      );

  /// Neon cyberpunk theme
  static FlowCanvasTheme get neon => FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF0A0A0A),
          patternColor: const Color(0xFF1A1A1A),
          variant: BackgroundVariant.dots,
          gap: 40.0,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBorderColor: const Color(0xFF00FFFF),
          selectedBorderColor: const Color(0xFF00FFFF),
          shadows: [
            BoxShadow(
              color: const Color(0xFF00FFFF).withAlpha(77),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
      );

  /// Ocean blue theme
  static FlowCanvasTheme get ocean => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFF0F9FF),
          patternColor: const Color(0xFFBAE6FD),
          variant: BackgroundVariant.dots,
          gradient: const LinearGradient(
            colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
          ),
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBorderColor: const Color(0xFF0EA5E9),
          selectedBorderColor: const Color(0xFF0284C7),
        ),
      );

  /// Forest green theme
  static FlowCanvasTheme get forest => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFF0FDF4),
          patternColor: const Color(0xFFBBF7D0),
          variant: BackgroundVariant.lines,
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBorderColor: const Color(0xFF22C55E),
          selectedBorderColor: const Color(0xFF16A34A),
        ),
      );

  /// Sunset warm theme
  static FlowCanvasTheme get sunset => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFFFF7ED),
          patternColor: const Color(0xFFDDD6FE),
          variant: BackgroundVariant.dots,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7ED),
              Color(0xFFFFEDD5),
              Color(0xFFFED7AA),
            ],
          ),
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBorderColor: const Color(0xFFEA580C),
          selectedBorderColor: const Color(0xFFDC2626),
          selectedBackgroundColor: const Color(0xFFFFF7ED),
        ),
      );

  /// Midnight dark theme
  static FlowCanvasTheme get midnight => FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF0C0A09),
          patternColor: const Color(0xFF292524),
          variant: BackgroundVariant.lines,
          gap: 35.0,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBackgroundColor: const Color(0xFF1C1917),
          defaultBorderColor: const Color(0xFF44403C),
          selectedBorderColor: const Color(0xFFF59E0B),
          borderRadius: 8.0,
        ),
      );

  /// Retro 80s theme
  static FlowCanvasTheme get retro => FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF1A0B2E),
          patternColor: const Color(0xFF7209B7),
          variant: BackgroundVariant.lines,
          gap: 30.0,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBackgroundColor: const Color(0xFF2D1B69),
          defaultBorderColor: const Color(0xFFE879F9),
          selectedBorderColor: const Color(0xFF00F5FF),
          borderRadius: 4.0,
          shadows: [
            BoxShadow(
              color: const Color(0xFFE879F9).withAlpha(102),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      );

  /// Create theme from Material Design ColorScheme
  static FlowCanvasTheme fromColorScheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final baseTheme = isDark ? FlowCanvasTheme.dark() : FlowCanvasTheme.light();

    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: colorScheme.surface,
        patternColor: colorScheme.outline,
      ),
      node: baseTheme.node.copyWith(
        defaultBackgroundColor: colorScheme.surfaceContainer,
        defaultBorderColor: colorScheme.outline,
        selectedBackgroundColor: colorScheme.primaryContainer,
        selectedBorderColor: colorScheme.primary,
        defaultTextStyle: baseTheme.node.defaultTextStyle.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      edge: baseTheme.edge.copyWith(
        defaultColor: colorScheme.outline,
        selectedColor: colorScheme.primary,
        animatedColor: colorScheme.secondary,
      ),
      handle: baseTheme.handle.copyWith(
        idleColor: colorScheme.outline,
        hoverColor: colorScheme.primary,
        connectingColor: colorScheme.secondary,
        validTargetColor: colorScheme.tertiary,
        borderColor: colorScheme.surface,
      ),
    );
  }
}

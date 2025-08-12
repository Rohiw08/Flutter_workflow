import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/canvas_theme.dart';

class FlowCanvasThemes {
  /// Professional light theme with subtle colors
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
        edge: FlowCanvasEdgeTheme.light().copyWith(
          defaultColor: const Color(0xFF9CA3AF),
          selectedColor: const Color(0xFF3B82F6),
        ),
      );

  /// High contrast theme for better accessibility
  static FlowCanvasTheme get highContrast => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: Colors.white,
          patternColor: const Color(0xFF000000),
          variant: BackgroundVariant.dots,
          gap: 20.0,
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBackgroundColor: Colors.white,
          defaultBorderColor: Colors.black,
          selectedBackgroundColor: const Color(0xFFFFEB3B),
          selectedBorderColor: Colors.black,
          defaultBorderWidth: 2.0,
          selectedBorderWidth: 3.0,
          defaultTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        edge: FlowCanvasEdgeTheme.light().copyWith(
          defaultColor: Colors.black,
          selectedColor: const Color(0xFFFF5722),
          defaultStrokeWidth: 3.0,
          selectedStrokeWidth: 4.0,
        ),
        handle: FlowCanvasHandleTheme.light().copyWith(
          idleColor: Colors.black,
          hoverColor: const Color(0xFF2196F3),
          borderColor: Colors.white,
          borderWidth: 2.0,
          size: 12.0,
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
          defaultBorderColor: const Color(0xFF3A3A3A),
          selectedBackgroundColor: const Color(0xFF0F1419),
          selectedBorderColor: const Color(0xFF60A5FA),
          borderRadius: 6.0,
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        edge: FlowCanvasEdgeTheme.dark().copyWith(
          defaultColor: const Color(0xFF6B7280),
          selectedColor: const Color(0xFF60A5FA),
        ),
      );

  /// Colorful theme with vibrant colors
  static FlowCanvasTheme get vibrant => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFF8FAFC),
          patternColor: const Color(0xFFE2E8F0),
          variant: BackgroundVariant.dots,
          gap: 30.0,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFF1F5F9),
            ],
          ),
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          selectedBackgroundColor: const Color(0xFFDDD6FE),
          selectedBorderColor: const Color(0xFF8B5CF6),
          errorBackgroundColor: const Color(0xFFFEE2E2),
          errorBorderColor: const Color(0xFFDC2626),
          borderRadius: 12.0,
          shadows: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        edge: FlowCanvasEdgeTheme.light().copyWith(
          defaultColor: const Color(0xFF8B5CF6),
          selectedColor: const Color(0xFF7C3AED),
          animatedColor: const Color(0xFF059669),
        ),
        handle: FlowCanvasHandleTheme.light().copyWith(
          idleColor: const Color(0xFFA855F7),
          hoverColor: const Color(0xFF9333EA),
          connectingColor: const Color(0xFF7C3AED),
          validTargetColor: const Color(0xFF059669),
          invalidTargetColor: const Color(0xFFDC2626),
        ),
      );

  /// Minimal theme with clean design
  static FlowCanvasTheme get minimal => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: Colors.white,
          patternColor: const Color(0xFFF5F5F5),
          variant: BackgroundVariant.none,
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBackgroundColor: Colors.white,
          defaultBorderColor: const Color(0xFFE5E5E5),
          selectedBackgroundColor: Colors.white,
          selectedBorderColor: const Color(0xFF000000),
          borderRadius: 4.0,
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        edge: FlowCanvasEdgeTheme.light().copyWith(
          defaultColor: const Color(0xFFBDBDBD),
          selectedColor: const Color(0xFF000000),
          defaultStrokeWidth: 1.5,
          selectedStrokeWidth: 2.0,
        ),
        handle: FlowCanvasHandleTheme.light().copyWith(
          idleColor: const Color(0xFFBDBDBD),
          hoverColor: const Color(0xFF757575),
          connectingColor: const Color(0xFF000000),
          size: 8.0,
          borderColor: Colors.white,
        ),
        controls: FlowCanvasControlTheme.light().copyWith(
          backgroundColor: Colors.white,
          buttonColor: const Color(0xFFFAFAFA),
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );

  /// Blueprint theme inspired by technical drawings
  static FlowCanvasTheme get blueprint => FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF1E3A8A),
          patternColor: const Color(0xFF3B82F6),
          variant: BackgroundVariant.lines,
          gap: 20.0,
          lineWidth: 0.8,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBackgroundColor: const Color(0xFF1E3A8A),
          defaultBorderColor: const Color(0xFF60A5FA),
          selectedBackgroundColor: const Color(0xFF1E40AF),
          selectedBorderColor: const Color(0xFFFBBF24),
          borderRadius: 0.0,
          defaultTextStyle: const TextStyle(
            color: Color(0xFFDBEAFE),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'monospace',
          ),
          shadows: [],
        ),
        edge: FlowCanvasEdgeTheme.dark().copyWith(
          defaultColor: const Color(0xFF60A5FA),
          selectedColor: const Color(0xFFFBBF24),
          animatedColor: const Color(0xFF34D399),
          defaultStrokeWidth: 1.5,
        ),
        handle: FlowCanvasHandleTheme.dark().copyWith(
          idleColor: const Color(0xFF60A5FA),
          hoverColor: const Color(0xFF3B82F6),
          connectingColor: const Color(0xFFFBBF24),
          validTargetColor: const Color(0xFF34D399),
          invalidTargetColor: const Color(0xFFF87171),
          borderColor: const Color(0xFF1E3A8A),
          size: 8.0,
          shadows: [],
        ),
        controls: FlowCanvasControlTheme.dark().copyWith(
          backgroundColor: const Color(0xFF1E3A8A),
          buttonColor: const Color(0xFF1E40AF),
          buttonHoverColor: const Color(0xFF2563EB),
          iconColor: const Color(0xFFDBEAFE),
          iconHoverColor: const Color(0xFFFBBF24),
          shadows: [],
        ),
      );

  /// Neon theme with glowing effects
  static FlowCanvasTheme get neon => FlowCanvasTheme.dark().copyWith(
        background: FlowCanvasBackgroundTheme.dark().copyWith(
          backgroundColor: const Color(0xFF0A0A0A),
          patternColor: const Color(0xFF1A1A1A),
          variant: BackgroundVariant.dots,
          gap: 40.0,
        ),
        node: FlowCanvasNodeTheme.dark().copyWith(
          defaultBackgroundColor: const Color(0xFF0F0F0F),
          defaultBorderColor: const Color(0xFF00FFFF),
          selectedBackgroundColor: const Color(0xFF001A1A),
          selectedBorderColor: const Color(0xFF00FFFF),
          errorBackgroundColor: const Color(0xFF1A0000),
          errorBorderColor: const Color(0xFFFF0080),
          borderRadius: 8.0,
          shadows: [
            BoxShadow(
              color: const Color(0xFF00FFFF).withAlpha(77),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
          defaultTextStyle: const TextStyle(
            color: Color(0xFF00FFFF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            shadows: [
              Shadow(
                color: Color(0xFF00FFFF),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        edge: FlowCanvasEdgeTheme.dark().copyWith(
          defaultColor: const Color(0xFF00FF80),
          selectedColor: const Color(0xFFFF0080),
          animatedColor: const Color(0xFFFFFF00),
          defaultStrokeWidth: 2.0,
        ),
        handle: FlowCanvasHandleTheme.dark().copyWith(
          idleColor: const Color(0xFF00FFFF),
          hoverColor: const Color(0xFF00FF80),
          connectingColor: const Color(0xFFFF0080),
          validTargetColor: const Color(0xFF00FF00),
          invalidTargetColor: const Color(0xFFFF0000),
          borderColor: const Color(0xFF0A0A0A),
          size: 12.0,
          shadows: [
            BoxShadow(
              color: const Color(0xFF00FFFF).withAlpha(204),
              blurRadius: 10,
            ),
          ],
        ),
      );

  /// Ocean theme with blue tones
  static FlowCanvasTheme get ocean => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFF0F9FF),
          patternColor: const Color(0xFFBAE6FD),
          variant: BackgroundVariant.dots,
          gap: 32.0,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F9FF),
              Color(0xFFE0F2FE),
            ],
          ),
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBackgroundColor: Colors.white,
          defaultBorderColor: const Color(0xFF0EA5E9),
          selectedBackgroundColor: const Color(0xFFE0F2FE),
          selectedBorderColor: const Color(0xFF0284C7),
          borderRadius: 10.0,
          shadows: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          defaultTextStyle: const TextStyle(
            color: Color(0xFF0C4A6E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        edge: FlowCanvasEdgeTheme.light().copyWith(
          defaultColor: const Color(0xFF0EA5E9),
          selectedColor: const Color(0xFF0284C7),
          animatedColor: const Color(0xFF06B6D4),
        ),
        handle: FlowCanvasHandleTheme.light().copyWith(
          idleColor: const Color(0xFF0EA5E9),
          hoverColor: const Color(0xFF0284C7),
          connectingColor: const Color(0xFF0369A1),
          validTargetColor: const Color(0xFF059669),
          invalidTargetColor: const Color(0xFFDC2626),
          borderColor: Colors.white,
        ),
      );

  /// Forest theme with green tones
  static FlowCanvasTheme get forest => FlowCanvasTheme.light().copyWith(
        background: FlowCanvasBackgroundTheme.light().copyWith(
          backgroundColor: const Color(0xFFF0FDF4),
          patternColor: const Color(0xFFBBF7D0),
          variant: BackgroundVariant.lines,
          gap: 28.0,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFDCFCE7),
            ],
          ),
        ),
        node: FlowCanvasNodeTheme.light().copyWith(
          defaultBackgroundColor: Colors.white,
          defaultBorderColor: const Color(0xFF22C55E),
          selectedBackgroundColor: const Color(0xFFDCFCE7),
          selectedBorderColor: const Color(0xFF16A34A),
          borderRadius: 8.0,
          shadows: [
            BoxShadow(
              color: const Color(0xFF22C55E).withAlpha(38),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          defaultTextStyle: const TextStyle(
            color: Color(0xFF14532D),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        edge: FlowCanvasEdgeTheme.light().copyWith(
          defaultColor: const Color(0xFF22C55E),
          selectedColor: const Color(0xFF16A34A),
          animatedColor: const Color(0xFF059669),
        ),
        handle: FlowCanvasHandleTheme.light().copyWith(
          idleColor: const Color(0xFF22C55E),
          hoverColor: const Color(0xFF16A34A),
          connectingColor: const Color(0xFF15803D),
          validTargetColor: const Color(0xFF059669),
          invalidTargetColor: const Color(0xFFDC2626),
          borderColor: Colors.white,
        ),
      );
}

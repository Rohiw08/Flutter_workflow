import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';

/// A collection of well-designed, predefined themes for FlowCanvas.
class FlowCanvasThemes {
  FlowCanvasThemes._();

  /// A clean, professional light theme.
  static FlowCanvasTheme get professional {
    final baseTheme = FlowCanvasTheme.light();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: const Color(0xFFFBFBFB),
        patternColor: const Color(0xFFE8E8E8),
        variant: BackgroundVariant.grid,
      ),
      node: baseTheme.node.copyWith(
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
  }

  /// A sleek, professional dark theme.
  static FlowCanvasTheme get darkProfessional {
    final baseTheme = FlowCanvasTheme.dark();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: const Color(0xFF18181B),
        patternColor: const Color(0xFF2A2A2A),
        variant: BackgroundVariant.grid,
      ),
      node: baseTheme.node.copyWith(
        defaultBackgroundColor: const Color(0xFF27272A),
        selectedBorderColor: const Color(0xFF60A5FA),
        borderRadius: 6.0,
      ),
    );
  }

  /// A high-contrast theme for maximum accessibility.
  static FlowCanvasTheme get highContrast {
    final baseTheme = FlowCanvasTheme.light();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: Colors.white,
        patternColor: Colors.black,
        variant: BackgroundVariant.dots,
      ),
      node: baseTheme.node.copyWith(
        defaultBorderColor: Colors.black,
        selectedBorderColor: const Color(0xFFFFD600),
        defaultBorderWidth: 2.0,
        defaultTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// A minimal, clean theme with no background pattern.
  static FlowCanvasTheme get minimal {
    final baseTheme = FlowCanvasTheme.light();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: Colors.white,
        variant: BackgroundVariant.none,
      ),
      node: baseTheme.node.copyWith(
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
  }

  /// A cool, oceanic blue theme.
  static FlowCanvasTheme get ocean {
    final baseTheme = FlowCanvasTheme.light();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: const Color(0xFFF0F9FF),
        patternColor: const Color(0xFFBAE6FD),
        variant: BackgroundVariant.dots,
      ),
      node: baseTheme.node.copyWith(
        defaultBorderColor: const Color(0xFF0EA5E9),
        selectedBorderColor: const Color(0xFF0284C7),
      ),
      edge: baseTheme.edge.copyWith(
        defaultColor: const Color(0xFF38BDF8),
        selectedColor: const Color(0xFF0284C7),
        hoverColor: const Color(0xFF0EA5E9),
      ),
    );
  }

  /// A vibrant, forest green theme.
  static FlowCanvasTheme get forest {
    final baseTheme = FlowCanvasTheme.light();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: const Color(0xFFF0FDF4),
        patternColor: const Color(0xFFBBF7D0),
        variant: BackgroundVariant.grid,
      ),
      node: baseTheme.node.copyWith(
        defaultBorderColor: const Color(0xFF22C55E),
        selectedBorderColor: const Color(0xFF16A34A),
      ),
      edge: baseTheme.edge.copyWith(
        defaultColor: const Color(0xFF4ADE80),
        selectedColor: const Color(0xFF16A34A),
        hoverColor: const Color(0xFF22C55E),
      ),
    );
  }

  /// A futuristic, neon cyberpunk theme.
  static FlowCanvasTheme get cyberpunk {
    final baseTheme = FlowCanvasTheme.dark();
    return baseTheme.copyWith(
      background: baseTheme.background.copyWith(
        backgroundColor: const Color(0xFF000020),
        patternColor: const Color(0xFF1A1A3A),
        variant: BackgroundVariant.grid,
      ),
      node: baseTheme.node.copyWith(
        defaultBorderColor: const Color(0xFF00FFFF),
        selectedBorderColor: const Color(0xFFF000FF),
        shadows: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withAlpha(77),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFF000FF).withAlpha(77),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      edge: baseTheme.edge.copyWith(
        defaultColor: const Color(0xFF00FFFF),
        selectedColor: const Color(0xFFF000FF),
        hoverColor: Colors.white,
      ),
    );
  }

  /// A map of all available predefined themes.
  static Map<String, FlowCanvasTheme> get allThemes => {
        'light': FlowCanvasTheme.light(),
        'dark': FlowCanvasTheme.dark(),
        'professional': professional,
        'darkProfessional': darkProfessional,
        'highContrast': highContrast,
        'minimal': minimal,
        'ocean': ocean,
        'forest': forest,
        'cyberpunk': cyberpunk,
      };
}

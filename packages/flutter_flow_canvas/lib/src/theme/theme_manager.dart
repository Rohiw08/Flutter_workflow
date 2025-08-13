import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/default_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';
import 'package:flutter_flow_canvas/src/theme/theme_variant_data.dart';

class FlowCanvasThemeManager extends ChangeNotifier {
  final Map<String, FlowCanvasThemeData> _customThemes = {};
  FlowCanvasTheme _currentTheme = FlowCanvasThemes.professional;
  String _currentThemeName = 'professional';

  /// Current active theme
  FlowCanvasTheme get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;

  /// All available themes (built-in + custom)
  List<FlowCanvasThemeData> get allThemes {
    final builtInThemes = FlowCanvasThemes.availableThemes.map((name) {
      final theme = FlowCanvasThemes.getThemeByName(name)!;
      return FlowCanvasThemeData(
        name: name,
        description: _getThemeDescription(name),
        theme: theme,
        category: _getThemeCategory(name),
        tags: _getThemeTags(name),
      );
    }).toList();

    return [...builtInThemes, ..._customThemes.values];
  }

  /// Set theme by name
  void setTheme(String themeName) {
    FlowCanvasTheme? theme;

    // Check built-in themes first
    theme = FlowCanvasThemes.getThemeByName(themeName);

    // Check custom themes
    theme ??= _customThemes[themeName]?.theme;

    // ignore: unnecessary_null_comparison
    if (theme != null) {
      _currentTheme = theme;
      _currentThemeName = themeName;
      notifyListeners();
    }
  }

  /// Set theme directly
  void setThemeData(FlowCanvasTheme theme, {String? name}) {
    _currentTheme = theme;
    _currentThemeName = name ?? 'custom';
    notifyListeners();
  }

  /// Save a custom theme
  void saveCustomTheme(FlowCanvasThemeData themeData) {
    _customThemes[themeData.name] = themeData;
    notifyListeners();
  }

  /// Remove a custom theme
  bool removeCustomTheme(String name) {
    final removed = _customThemes.remove(name) != null;
    if (removed) {
      notifyListeners();
    }
    return removed;
  }

  /// Get themes by category
  List<FlowCanvasThemeData> getThemesByCategory(ThemeCategory category) {
    return allThemes.where((t) => t.category == category).toList();
  }

  /// Search themes by tags
  List<FlowCanvasThemeData> searchThemes(List<String> tags) {
    return allThemes
        .where((t) => tags.any((tag) => t.tags.contains(tag.toLowerCase())))
        .toList();
  }

  String _getThemeDescription(String name) {
    switch (name) {
      case 'professional':
        return 'Clean, business-ready theme';
      case 'dark_professional':
        return 'Dark variant of professional theme';
      case 'high_contrast':
        return 'Accessible high contrast theme';
      case 'vibrant':
        return 'Colorful and energetic theme';
      case 'minimal':
        return 'Clean and simple design';
      case 'blueprint':
        return 'Technical blueprint-style theme';
      case 'neon':
        return 'Cyberpunk-inspired neon theme';
      case 'ocean':
        return 'Calming blue ocean theme';
      case 'forest':
        return 'Natural green forest theme';
      default:
        return 'Custom theme';
    }
  }

  ThemeCategory _getThemeCategory(String name) {
    switch (name) {
      case 'professional':
      case 'dark_professional':
      case 'minimal':
        return ThemeCategory.professional;
      case 'high_contrast':
        return ThemeCategory.accessibility;
      case 'blueprint':
        return ThemeCategory.technical;
      case 'vibrant':
      case 'neon':
      case 'ocean':
      case 'forest':
        return ThemeCategory.creative;
      default:
        return ThemeCategory.custom;
    }
  }

  List<String> _getThemeTags(String name) {
    switch (name) {
      case 'professional':
        return ['light', 'business', 'clean'];
      case 'dark_professional':
        return ['dark', 'business', 'clean'];
      case 'high_contrast':
        return ['accessibility', 'contrast', 'wcag'];
      case 'vibrant':
        return ['colorful', 'creative', 'gradient'];
      case 'minimal':
        return ['simple', 'clean', 'minimal'];
      case 'blueprint':
        return ['technical', 'engineering', 'blue'];
      case 'neon':
        return ['cyberpunk', 'glow', 'futuristic'];
      case 'ocean':
        return ['blue', 'calm', 'water'];
      case 'forest':
        return ['green', 'nature', 'organic'];
      default:
        return [];
    }
  }
}

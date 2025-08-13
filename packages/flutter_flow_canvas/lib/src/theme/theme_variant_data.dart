import 'package:flutter_flow_canvas/src/theme/components/flow_canvas_theme.dart';

class FlowCanvasThemeData {
  final String name;
  final String description;
  final FlowCanvasTheme theme;
  final ThemeCategory category;
  final List<String> tags;
  final bool isCustom;

  const FlowCanvasThemeData({
    required this.name,
    required this.description,
    required this.theme,
    required this.category,
    this.tags = const [],
    this.isCustom = false,
  });

  /// Create from existing theme
  factory FlowCanvasThemeData.fromTheme(
    String name,
    FlowCanvasTheme theme, {
    String? description,
    ThemeCategory category = ThemeCategory.custom,
    List<String> tags = const [],
  }) {
    return FlowCanvasThemeData(
      name: name,
      description: description ?? 'Custom $name theme',
      theme: theme,
      category: category,
      tags: tags,
      isCustom: true,
    );
  }
}

enum ThemeCategory {
  professional,
  creative,
  accessibility,
  technical,
  gaming,
  custom,
}

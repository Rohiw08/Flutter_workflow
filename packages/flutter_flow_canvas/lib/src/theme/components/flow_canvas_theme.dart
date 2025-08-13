import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';

class FlowCanvasTheme {
  final FlowCanvasBackgroundTheme background;
  final FlowCanvasNodeTheme node;
  final FlowCanvasEdgeTheme edge;
  final FlowCanvasHandleTheme handle;
  final FlowCanvasSelectionTheme selection;
  final FlowCanvasControlTheme controls;
  final FlowCanvasMiniMapTheme miniMap;
  final FlowCanvasConnectionTheme connection;

  // Enhanced metadata
  final String? name;
  final String? description;
  final String? version;
  final Map<String, dynamic> metadata;

  const FlowCanvasTheme({
    required this.background,
    required this.node,
    required this.edge,
    required this.handle,
    required this.selection,
    required this.controls,
    required this.miniMap,
    required this.connection,
    this.name,
    this.description,
    this.version,
    this.metadata = const {},
  });

  factory FlowCanvasTheme.fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? FlowCanvasTheme.dark()
        : FlowCanvasTheme.light();
  }

  factory FlowCanvasTheme.light() {
    return FlowCanvasTheme(
      background: FlowCanvasBackgroundTheme.light(),
      node: FlowCanvasNodeTheme.light(),
      edge: FlowCanvasEdgeTheme.light(),
      handle: FlowCanvasHandleTheme.light(),
      selection: FlowCanvasSelectionTheme.light(),
      controls: FlowCanvasControlTheme.light(),
      miniMap: FlowCanvasMiniMapTheme.light(),
      connection: FlowCanvasConnectionTheme.light(),
      name: 'Light',
      description: 'Default light theme',
      version: '1.0.0',
    );
  }

  factory FlowCanvasTheme.dark() {
    return FlowCanvasTheme(
      background: FlowCanvasBackgroundTheme.dark(),
      node: FlowCanvasNodeTheme.dark(),
      edge: FlowCanvasEdgeTheme.dark(),
      handle: FlowCanvasHandleTheme.dark(),
      selection: FlowCanvasSelectionTheme.dark(),
      controls: FlowCanvasControlTheme.dark(),
      miniMap: FlowCanvasMiniMapTheme.dark(),
      connection: FlowCanvasConnectionTheme.dark(),
      name: 'Dark',
      description: 'Default dark theme',
      version: '1.0.0',
    );
  }

  /// Create theme from Material Design ColorScheme
  factory FlowCanvasTheme.fromColorScheme(
    ColorScheme colorScheme, {
    String? name,
    String? description,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final baseTheme = isDark ? FlowCanvasTheme.dark() : FlowCanvasTheme.light();

    return baseTheme.copyWith(
      name: name ?? '${colorScheme.primary.toString()} Theme',
      description: description ?? 'Generated from ColorScheme',
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

  FlowCanvasTheme copyWith({
    FlowCanvasBackgroundTheme? background,
    FlowCanvasNodeTheme? node,
    FlowCanvasEdgeTheme? edge,
    FlowCanvasHandleTheme? handle,
    FlowCanvasSelectionTheme? selection,
    FlowCanvasControlTheme? controls,
    FlowCanvasMiniMapTheme? miniMap,
    FlowCanvasConnectionTheme? connection,
    String? name,
    String? description,
    String? version,
    Map<String, dynamic>? metadata,
  }) {
    return FlowCanvasTheme(
      background: background ?? this.background,
      node: node ?? this.node,
      edge: edge ?? this.edge,
      handle: handle ?? this.handle,
      selection: selection ?? this.selection,
      controls: controls ?? this.controls,
      miniMap: miniMap ?? this.miniMap,
      connection: connection ?? this.connection,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get theme complexity score for performance analysis
  int get complexityScore {
    int score = 0;

    // Background complexity
    if (background.variant != BackgroundVariant.none) score += 1;
    if (background.gradient != null) score += 1;
    if (background.gap < 15.0) score += 2;

    // Shadow complexity
    score += node.shadows.length;
    score += handle.shadows.length;
    score += controls.shadows.length;

    // Animation complexity
    if (handle.enableAnimations) score += 1;

    return score;
  }

  /// Get dominant color palette from theme
  List<Color> get colorPalette {
    return [
      background.backgroundColor,
      node.defaultBorderColor,
      node.selectedBorderColor,
      edge.defaultColor,
      edge.selectedColor,
      handle.idleColor,
      handle.hoverColor,
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlowCanvasTheme &&
        other.background == background &&
        other.node == node &&
        other.edge == edge &&
        other.handle == handle &&
        other.selection == selection &&
        other.controls == controls &&
        other.miniMap == miniMap &&
        other.connection == connection &&
        other.name == name &&
        other.description == description &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(
      background,
      node,
      edge,
      handle,
      selection,
      controls,
      miniMap,
      connection,
      name,
      description,
      version,
    );
  }

  @override
  String toString() {
    return 'FlowCanvasTheme('
        'name: $name, '
        'description: $description, '
        'version: $version, '
        'complexity: $complexityScore'
        ')';
  }
}

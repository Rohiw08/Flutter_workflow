import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/background_theme.dart';
import 'package:flutter_flow_canvas/src/theme/connection_theme.dart';
import 'package:flutter_flow_canvas/src/theme/control_theme.dart';
import 'package:flutter_flow_canvas/src/theme/edge_theme.dart';
import 'package:flutter_flow_canvas/src/theme/handle_theme.dart';
import 'package:flutter_flow_canvas/src/theme/minimap_theme.dart';
import 'package:flutter_flow_canvas/src/theme/node_theme.dart';
import 'package:flutter_flow_canvas/src/theme/selection_theme.dart';

/// Defines the overall theme for the Flow Canvas
class FlowCanvasTheme {
  /// Background theme configuration
  final FlowCanvasBackgroundTheme background;

  /// Node theme configuration
  final FlowCanvasNodeTheme node;

  /// Edge theme configuration
  final FlowCanvasEdgeTheme edge;

  /// Handle theme configuration
  final FlowCanvasHandleTheme handle;

  /// Selection theme configuration
  final FlowCanvasSelectionTheme selection;

  /// Control panel theme configuration
  final FlowCanvasControlTheme controls;

  /// MiniMap theme configuration
  final FlowCanvasMiniMapTheme miniMap;

  /// Connection (drag) theme configuration
  final FlowCanvasConnectionTheme connection;

  const FlowCanvasTheme({
    required this.background,
    required this.node,
    required this.edge,
    required this.handle,
    required this.selection,
    required this.controls,
    required this.miniMap,
    required this.connection,
  });

  /// Create a theme based on Material Design brightness
  factory FlowCanvasTheme.fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? FlowCanvasTheme.dark()
        : FlowCanvasTheme.light();
  }

  /// Light theme
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
    );
  }

  /// Dark theme
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
    );
  }

  /// Copy with method for theme modifications
  FlowCanvasTheme copyWith({
    FlowCanvasBackgroundTheme? background,
    FlowCanvasNodeTheme? node,
    FlowCanvasEdgeTheme? edge,
    FlowCanvasHandleTheme? handle,
    FlowCanvasSelectionTheme? selection,
    FlowCanvasControlTheme? controls,
    FlowCanvasMiniMapTheme? miniMap,
    FlowCanvasConnectionTheme? connection,
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
    );
  }
}

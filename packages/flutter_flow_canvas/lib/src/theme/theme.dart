import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/components/background_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/node_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/edge_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/handle_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/selection_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/control_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/minimap_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/connection_theme.dart';

/// The core theme for the Flow Canvas.
@immutable
class FlowCanvasTheme {
  final FlowCanvasBackgroundTheme background;
  final FlowCanvasNodeTheme node;
  final FlowCanvasEdgeTheme edge;
  final FlowCanvasHandleTheme handle;
  final FlowCanvasSelectionTheme selection;
  final FlowCanvasControlTheme controls;
  final FlowCanvasMiniMapTheme miniMap;
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

  /// Creates a light theme.
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

  /// Creates a dark theme.
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

  /// Creates a copy of this theme with the given fields replaced by the new values.
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

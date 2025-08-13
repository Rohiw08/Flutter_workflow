import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';

class FlowCanvasThemeOverlay {
  final FlowCanvasBackgroundTheme? background;
  final FlowCanvasNodeTheme? node;
  final FlowCanvasEdgeTheme? edge;
  final FlowCanvasHandleTheme? handle;
  final FlowCanvasSelectionTheme? selection;
  final FlowCanvasControlTheme? controls;
  final FlowCanvasMiniMapTheme? miniMap;
  final FlowCanvasConnectionTheme? connection;

  const FlowCanvasThemeOverlay({
    this.background,
    this.node,
    this.edge,
    this.handle,
    this.selection,
    this.controls,
    this.miniMap,
    this.connection,
  });

  /// Apply this overlay to a base theme
  FlowCanvasTheme apply(FlowCanvasTheme baseTheme) {
    return baseTheme.copyWith(
      background: background ?? baseTheme.background,
      node: node ?? baseTheme.node,
      edge: edge ?? baseTheme.edge,
      handle: handle ?? baseTheme.handle,
      selection: selection ?? baseTheme.selection,
      controls: controls ?? baseTheme.controls,
      miniMap: miniMap ?? baseTheme.miniMap,
      connection: connection ?? baseTheme.connection,
    );
  }

  /// Merge with another overlay
  FlowCanvasThemeOverlay merge(FlowCanvasThemeOverlay other) {
    return FlowCanvasThemeOverlay(
      background: other.background ?? background,
      node: other.node ?? node,
      edge: other.edge ?? edge,
      handle: other.handle ?? handle,
      selection: other.selection ?? selection,
      controls: other.controls ?? controls,
      miniMap: other.miniMap ?? miniMap,
      connection: other.connection ?? connection,
    );
  }
}

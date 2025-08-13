// Enhanced serialization for themes
import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';
import 'package:flutter_flow_canvas/src/theme/components/connection_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/edge_label_theme.dart';
import 'package:flutter_flow_canvas/src/theme/components/minimap_theme.dart';
import 'package:flutter_flow_canvas/src/theme/theme_exports.dart';

class FlowCanvasThemeSerializer {
  /// Convert theme to JSON with full fidelity
  static Map<String, dynamic> toJson(FlowCanvasTheme theme) {
    return {
      'meta': {
        'name': theme.name,
        'description': theme.description,
        'version': theme.version ?? '1.0.0',
        'created': DateTime.now().toIso8601String(),
        'metadata': theme.metadata,
      },
      'background': _backgroundToJson(theme.background),
      'node': _nodeToJson(theme.node),
      'edge': _edgeToJson(theme.edge),
      'handle': _handleToJson(theme.handle),
      'selection': _selectionToJson(theme.selection),
      'controls': _controlsToJson(theme.controls),
      'miniMap': _miniMapToJson(theme.miniMap),
      'connection': _connectionToJson(theme.connection),
    };
  }

  /// Create theme from JSON
  static FlowCanvasTheme? fromJson(Map<String, dynamic> json) {
    try {
      return FlowCanvasTheme(
        name: json['meta']?['name'],
        description: json['meta']?['description'],
        version: json['meta']?['version'],
        metadata: Map<String, dynamic>.from(json['meta']?['metadata'] ?? {}),
        background: _backgroundFromJson(json['background']),
        node: _nodeFromJson(json['node']),
        edge: _edgeFromJson(json['edge']),
        handle: _handleFromJson(json['handle']),
        selection: _selectionFromJson(json['selection']),
        controls: _controlsFromJson(json['controls']),
        miniMap: _miniMapFromJson(json['miniMap']),
        connection: _connectionFromJson(json['connection']),
      );
    } catch (e) {
      debugPrint('Error deserializing theme: $e');
      return null;
    }
  }

  static Map<String, dynamic> _backgroundToJson(FlowCanvasBackgroundTheme bg) {
    return {
      'backgroundColor': bg.backgroundColor.value,
      'variant': bg.variant.name,
      'patternColor': bg.patternColor.value,
      'gap': bg.gap,
      'lineWidth': bg.lineWidth,
      'dotRadius': bg.dotRadius,
      'crossSize': bg.crossSize,
      'fadeOnZoom': bg.fadeOnZoom,
      'patternOffset': {'dx': bg.patternOffset.dx, 'dy': bg.patternOffset.dy},
      'opacity': bg.opacity,
      'gradient': bg.gradient != null ? _gradientToJson(bg.gradient!) : null,
    };
  }

  static FlowCanvasBackgroundTheme _backgroundFromJson(
      Map<String, dynamic> json) {
    return FlowCanvasBackgroundTheme(
      backgroundColor: Color(json['backgroundColor']),
      variant:
          BackgroundVariant.values.firstWhere((v) => v.name == json['variant']),
      patternColor: Color(json['patternColor']),
      gap: json['gap']?.toDouble() ?? 30.0,
      lineWidth: json['lineWidth']?.toDouble() ?? 1.0,
      dotRadius: json['dotRadius']?.toDouble(),
      crossSize: json['crossSize']?.toDouble(),
      fadeOnZoom: json['fadeOnZoom'] ?? true,
      patternOffset: json['patternOffset'] != null
          ? Offset(json['patternOffset']['dx'], json['patternOffset']['dy'])
          : Offset.zero,
      opacity: json['opacity']?.toDouble() ?? 1.0,
      gradient:
          json['gradient'] != null ? _gradientFromJson(json['gradient']) : null,
    );
  }

  static Map<String, dynamic> _nodeToJson(FlowCanvasNodeTheme node) {
    return {
      'defaultBackgroundColor': node.defaultBackgroundColor.value,
      'defaultBorderColor': node.defaultBorderColor.value,
      'selectedBackgroundColor': node.selectedBackgroundColor.value,
      'selectedBorderColor': node.selectedBorderColor.value,
      'errorBackgroundColor': node.errorBackgroundColor.value,
      'errorBorderColor': node.errorBorderColor.value,
      'hoverBackgroundColor': node.hoverBackgroundColor?.value,
      'hoverBorderColor': node.hoverBorderColor?.value,
      'defaultBorderWidth': node.defaultBorderWidth,
      'selectedBorderWidth': node.selectedBorderWidth,
      'hoverBorderWidth': node.hoverBorderWidth,
      'borderRadius': node.borderRadius,
      'animationDuration': node.animationDuration.inMilliseconds,
      'defaultPadding': _edgeInsetsToJson(node.defaultPadding),
      'textStyle': _textStyleToJson(node.defaultTextStyle),
      'shadows': node.shadows.map(_boxShadowToJson).toList(),
      'minWidth': node.minWidth,
      'minHeight': node.minHeight,
      'maxWidth': node.maxWidth,
      'maxHeight': node.maxHeight,
    };
  }

  static FlowCanvasNodeTheme _nodeFromJson(Map<String, dynamic> json) {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor: Color(json['defaultBackgroundColor']),
      defaultBorderColor: Color(json['defaultBorderColor']),
      selectedBackgroundColor: Color(json['selectedBackgroundColor']),
      selectedBorderColor: Color(json['selectedBorderColor']),
      errorBackgroundColor: Color(json['errorBackgroundColor']),
      errorBorderColor: Color(json['errorBorderColor']),
      hoverBackgroundColor: json['hoverBackgroundColor'] != null
          ? Color(json['hoverBackgroundColor'])
          : null,
      hoverBorderColor: json['hoverBorderColor'] != null
          ? Color(json['hoverBorderColor'])
          : null,
      defaultBorderWidth: json['defaultBorderWidth']?.toDouble() ?? 1.0,
      selectedBorderWidth: json['selectedBorderWidth']?.toDouble() ?? 2.0,
      hoverBorderWidth: json['hoverBorderWidth']?.toDouble(),
      borderRadius: json['borderRadius']?.toDouble() ?? 8.0,
      animationDuration:
          Duration(milliseconds: json['animationDuration'] ?? 200),
      defaultPadding: _edgeInsetsFromJson(json['defaultPadding']),
      defaultTextStyle: _textStyleFromJson(json['textStyle']),
      shadows: (json['shadows'] as List?)
              ?.map((s) => _boxShadowFromJson(s))
              .toList() ??
          [],
      minWidth: json['minWidth']?.toDouble(),
      minHeight: json['minHeight']?.toDouble(),
      maxWidth: json['maxWidth']?.toDouble(),
      maxHeight: json['maxHeight']?.toDouble(),
    );
  }

  static Map<String, dynamic> _edgeToJson(FlowCanvasEdgeTheme edge) {
    return {
      'defaultColor': edge.defaultColor.value,
      'selectedColor': edge.selectedColor.value,
      'animatedColor': edge.animatedColor.value,
      'defaultStrokeWidth': edge.defaultStrokeWidth,
      'selectedStrokeWidth': edge.selectedStrokeWidth,
      'arrowHeadSize': edge.arrowHeadSize,
      'label': _edgeLabelToJson(edge.label),
    };
  }

  static FlowCanvasEdgeTheme _edgeFromJson(Map<String, dynamic> json) {
    return FlowCanvasEdgeTheme(
      defaultColor: Color(json['defaultColor']),
      selectedColor: Color(json['selectedColor']),
      animatedColor: Color(json['animatedColor']),
      defaultStrokeWidth: json['defaultStrokeWidth']?.toDouble() ?? 2.0,
      selectedStrokeWidth: json['selectedStrokeWidth']?.toDouble() ?? 3.0,
      arrowHeadSize: json['arrowHeadSize']?.toDouble() ?? 8.0,
      label: _edgeLabelFromJson(json['label']),
    );
  }

  static Map<String, dynamic> _handleToJson(FlowCanvasHandleTheme handle) {
    return {
      'idleColor': handle.idleColor.value,
      'hoverColor': handle.hoverColor.value,
      'connectingColor': handle.connectingColor.value,
      'validTargetColor': handle.validTargetColor.value,
      'invalidTargetColor': handle.invalidTargetColor.value,
      'size': handle.size,
      'borderWidth': handle.borderWidth,
      'borderColor': handle.borderColor.value,
      'enableAnimations': handle.enableAnimations,
      'shadows': handle.shadows.map(_boxShadowToJson).toList(),
    };
  }

  static FlowCanvasHandleTheme _handleFromJson(Map<String, dynamic> json) {
    return FlowCanvasHandleTheme(
      idleColor: Color(json['idleColor']),
      hoverColor: Color(json['hoverColor']),
      connectingColor: Color(json['connectingColor']),
      validTargetColor: Color(json['validTargetColor']),
      invalidTargetColor: Color(json['invalidTargetColor']),
      size: json['size']?.toDouble() ?? 10.0,
      borderWidth: json['borderWidth']?.toDouble() ?? 1.5,
      borderColor: Color(json['borderColor']),
      enableAnimations: json['enableAnimations'] ?? true,
      shadows: (json['shadows'] as List?)
              ?.map((s) => _boxShadowFromJson(s))
              .toList() ??
          [],
    );
  }

  static Map<String, dynamic> _selectionToJson(
      FlowCanvasSelectionTheme selection) {
    return {
      'fillColor': selection.fillColor.value,
      'borderColor': selection.borderColor.value,
      'borderWidth': selection.borderWidth,
      'dashLength': selection.dashLength,
      'gapLength': selection.gapLength,
    };
  }

  static FlowCanvasSelectionTheme _selectionFromJson(
      Map<String, dynamic> json) {
    return FlowCanvasSelectionTheme(
      fillColor: Color(json['fillColor']),
      borderColor: Color(json['borderColor']),
      borderWidth: json['borderWidth']?.toDouble() ?? 1.0,
      dashLength: json['dashLength']?.toDouble() ?? 5.0,
      gapLength: json['gapLength']?.toDouble() ?? 5.0,
    );
  }

  static Map<String, dynamic> _controlsToJson(FlowCanvasControlTheme controls) {
    return {
      'backgroundColor': controls.backgroundColor.value,
      'buttonColor': controls.buttonColor.value,
      'buttonHoverColor': controls.buttonHoverColor.value,
      'iconColor': controls.iconColor.value,
      'iconHoverColor': controls.iconHoverColor.value,
      'dividerColor': controls.dividerColor.value,
      'buttonSize': controls.buttonSize,
      'borderRadius': _borderRadiusToJson(controls.borderRadius),
      'padding': _edgeInsetsToJson(controls.padding),
      'shadows': controls.shadows.map(_boxShadowToJson).toList(),
    };
  }

  static FlowCanvasControlTheme _controlsFromJson(Map<String, dynamic> json) {
    return FlowCanvasControlTheme(
      backgroundColor: Color(json['backgroundColor']),
      buttonColor: Color(json['buttonColor']),
      buttonHoverColor: Color(json['buttonHoverColor']),
      iconColor: Color(json['iconColor']),
      iconHoverColor: Color(json['iconHoverColor']),
      dividerColor: Color(json['dividerColor']),
      buttonSize: json['buttonSize']?.toDouble() ?? 32.0,
      borderRadius: _borderRadiusFromJson(json['borderRadius']),
      padding: _edgeInsetsFromJson(json['padding']),
      shadows: (json['shadows'] as List?)
              ?.map((s) => _boxShadowFromJson(s))
              .toList() ??
          [],
    );
  }

  static Map<String, dynamic> _miniMapToJson(FlowCanvasMiniMapTheme miniMap) {
    return {
      'backgroundColor': miniMap.backgroundColor.value,
      'nodeColor': miniMap.nodeColor.value,
      'nodeStrokeColor': miniMap.nodeStrokeColor.value,
      'selectedNodeColor': miniMap.selectedNodeColor.value,
      'maskColor': miniMap.maskColor.value,
      'maskStrokeColor': miniMap.maskStrokeColor.value,
      'nodeStrokeWidth': miniMap.nodeStrokeWidth,
      'maskStrokeWidth': miniMap.maskStrokeWidth,
      'borderRadius': miniMap.borderRadius,
      'shadows': miniMap.shadows.map(_boxShadowToJson).toList(),
    };
  }

  static FlowCanvasMiniMapTheme _miniMapFromJson(Map<String, dynamic> json) {
    return FlowCanvasMiniMapTheme(
      backgroundColor: Color(json['backgroundColor']),
      nodeColor: Color(json['nodeColor']),
      nodeStrokeColor: Color(json['nodeStrokeColor']),
      selectedNodeColor: Color(json['selectedNodeColor']),
      maskColor: Color(json['maskColor']),
      maskStrokeColor: Color(json['maskStrokeColor']),
      nodeStrokeWidth: json['nodeStrokeWidth']?.toDouble() ?? 1.5,
      maskStrokeWidth: json['maskStrokeWidth']?.toDouble() ?? 1.0,
      borderRadius: json['borderRadius']?.toDouble() ?? 8.0,
      shadows: (json['shadows'] as List?)
              ?.map((s) => _boxShadowFromJson(s))
              .toList() ??
          [],
    );
  }

  static Map<String, dynamic> _connectionToJson(
      FlowCanvasConnectionTheme connection) {
    return {
      'activeColor': connection.activeColor.value,
      'validTargetColor': connection.validTargetColor.value,
      'invalidTargetColor': connection.invalidTargetColor.value,
      'strokeWidth': connection.strokeWidth,
      'endPointRadius': connection.endPointRadius,
    };
  }

  static FlowCanvasConnectionTheme _connectionFromJson(
      Map<String, dynamic> json) {
    return FlowCanvasConnectionTheme(
      activeColor: Color(json['activeColor']),
      validTargetColor: Color(json['validTargetColor']),
      invalidTargetColor: Color(json['invalidTargetColor']),
      strokeWidth: json['strokeWidth']?.toDouble() ?? 2.0,
      endPointRadius: json['endPointRadius']?.toDouble() ?? 6.0,
    );
  }

  // Helper serialization methods
  static Map<String, dynamic> _edgeLabelToJson(EdgeLabelTheme label) {
    return {
      'textStyle': _textStyleToJson(label.textStyle),
      'backgroundColor': label.backgroundColor.value,
      'borderColor': label.borderColor.value,
      'padding': _edgeInsetsToJson(label.padding),
      'borderRadius': _borderRadiusToJson(label.borderRadius),
    };
  }

  static EdgeLabelTheme _edgeLabelFromJson(Map<String, dynamic> json) {
    return EdgeLabelTheme(
      textStyle: _textStyleFromJson(json['textStyle']),
      backgroundColor: Color(json['backgroundColor']),
      borderColor: Color(json['borderColor']),
      padding: _edgeInsetsFromJson(json['padding']),
      borderRadius: _borderRadiusFromJson(json['borderRadius']),
    );
  }

  static Map<String, dynamic> _textStyleToJson(TextStyle style) {
    return {
      'color': style.color?.value,
      'fontSize': style.fontSize,
      'fontWeight': style.fontWeight?.index,
      'fontFamily': style.fontFamily,
      'letterSpacing': style.letterSpacing,
      'height': style.height,
    };
  }

  static TextStyle _textStyleFromJson(Map<String, dynamic> json) {
    return TextStyle(
      color: json['color'] != null ? Color(json['color']) : null,
      fontSize: json['fontSize']?.toDouble(),
      fontWeight: json['fontWeight'] != null
          ? FontWeight.values[json['fontWeight']]
          : null,
      fontFamily: json['fontFamily'],
      letterSpacing: json['letterSpacing']?.toDouble(),
      height: json['height']?.toDouble(),
    );
  }

  static Map<String, dynamic> _boxShadowToJson(BoxShadow shadow) {
    return {
      'color': shadow.color.value,
      'offset': {'dx': shadow.offset.dx, 'dy': shadow.offset.dy},
      'blurRadius': shadow.blurRadius,
      'spreadRadius': shadow.spreadRadius,
    };
  }

  static BoxShadow _boxShadowFromJson(Map<String, dynamic> json) {
    return BoxShadow(
      color: Color(json['color']),
      offset: Offset(json['offset']['dx'], json['offset']['dy']),
      blurRadius: json['blurRadius']?.toDouble() ?? 0.0,
      spreadRadius: json['spreadRadius']?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> _edgeInsetsToJson(EdgeInsets insets) {
    return {
      'left': insets.left,
      'top': insets.top,
      'right': insets.right,
      'bottom': insets.bottom,
    };
  }

  static EdgeInsets _edgeInsetsFromJson(Map<String, dynamic> json) {
    return EdgeInsets.only(
      left: json['left']?.toDouble() ?? 0.0,
      top: json['top']?.toDouble() ?? 0.0,
      right: json['right']?.toDouble() ?? 0.0,
      bottom: json['bottom']?.toDouble() ?? 0.0,
    );
  }

  static Map<String, dynamic> _borderRadiusToJson(BorderRadius radius) {
    return {
      'topLeft': radius.topLeft.x,
      'topRight': radius.topRight.x,
      'bottomLeft': radius.bottomLeft.x,
      'bottomRight': radius.bottomRight.x,
    };
  }

  static BorderRadius _borderRadiusFromJson(Map<String, dynamic> json) {
    return BorderRadius.only(
      topLeft: Radius.circular(json['topLeft']?.toDouble() ?? 0.0),
      topRight: Radius.circular(json['topRight']?.toDouble() ?? 0.0),
      bottomLeft: Radius.circular(json['bottomLeft']?.toDouble() ?? 0.0),
      bottomRight: Radius.circular(json['bottomRight']?.toDouble() ?? 0.0),
    );
  }

  static Map<String, dynamic> _gradientToJson(Gradient gradient) {
    if (gradient is LinearGradient) {
      return {
        'type': 'linear',
        'colors': gradient.colors.map((c) => c.value).toList(),
        'stops': gradient.stops,
        'begin': _alignmentToJson(gradient.begin),
        'end': _alignmentToJson(gradient.end),
      };
    } else if (gradient is RadialGradient) {
      return {
        'type': 'radial',
        'colors': gradient.colors.map((c) => c.value).toList(),
        'stops': gradient.stops,
        'center': _alignmentToJson(gradient.center),
        'radius': gradient.radius,
      };
    }
    return {'type': 'unknown'};
  }

  static Gradient? _gradientFromJson(Map<String, dynamic> json) {
    final colors = (json['colors'] as List).map((c) => Color(c)).toList();
    final stops = (json['stops'] as List?)?.map((s) => s.toDouble()).toList();

    switch (json['type']) {
      case 'linear':
        return LinearGradient(
          colors: colors,
          stops: stops,
          begin: _alignmentFromJson(json['begin']),
          end: _alignmentFromJson(json['end']),
        );
      case 'radial':
        return RadialGradient(
          colors: colors,
          stops: stops,
          center: _alignmentFromJson(json['center']),
          radius: json['radius']?.toDouble() ?? 0.5,
        );
      default:
        return null;
    }
  }

  static Map<String, dynamic> _alignmentToJson(Alignment alignment) {
    return {'x': alignment.x, 'y': alignment.y};
  }

  static Alignment _alignmentFromJson(Map<String, dynamic> json) {
    return Alignment(
        json['x']?.toDouble() ?? 0.0, json['y']?.toDouble() ?? 0.0);
  }
}

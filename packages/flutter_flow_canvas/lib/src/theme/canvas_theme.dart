import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';

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

/// Theme for canvas background
class FlowCanvasBackgroundTheme {
  final Color backgroundColor;
  final BackgroundVariant variant;
  final Color patternColor;
  final double gap;
  final double lineWidth;
  final double? dotRadius;
  final double? crossSize;
  final bool fadeOnZoom;
  final Gradient? gradient;
  final Offset patternOffset;

  const FlowCanvasBackgroundTheme({
    required this.backgroundColor,
    required this.variant,
    required this.patternColor,
    this.gap = 30.0,
    this.lineWidth = 1.0,
    this.dotRadius,
    this.crossSize,
    this.fadeOnZoom = true,
    this.gradient,
    this.patternOffset = Offset.zero,
  });

  factory FlowCanvasBackgroundTheme.light() {
    return const FlowCanvasBackgroundTheme(
      backgroundColor: Color(0xFFFAFAFA),
      variant: BackgroundVariant.dots,
      patternColor: Color(0xFFE0E0E0),
      gap: 30.0,
      lineWidth: 1.0,
      fadeOnZoom: true,
    );
  }

  factory FlowCanvasBackgroundTheme.dark() {
    return const FlowCanvasBackgroundTheme(
      backgroundColor: Color(0xFF1A1A1A),
      variant: BackgroundVariant.dots,
      patternColor: Color(0xFF404040),
      gap: 30.0,
      lineWidth: 1.0,
      fadeOnZoom: true,
    );
  }

  FlowCanvasBackgroundTheme copyWith({
    Color? backgroundColor,
    BackgroundVariant? variant,
    Color? patternColor,
    double? gap,
    double? lineWidth,
    double? dotRadius,
    double? crossSize,
    bool? fadeOnZoom,
    Gradient? gradient,
    Offset? patternOffset,
  }) {
    return FlowCanvasBackgroundTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      variant: variant ?? this.variant,
      patternColor: patternColor ?? this.patternColor,
      gap: gap ?? this.gap,
      lineWidth: lineWidth ?? this.lineWidth,
      dotRadius: dotRadius ?? this.dotRadius,
      crossSize: crossSize ?? this.crossSize,
      fadeOnZoom: fadeOnZoom ?? this.fadeOnZoom,
      gradient: gradient ?? this.gradient,
      patternOffset: patternOffset ?? this.patternOffset,
    );
  }
}

/// Theme for nodes
class FlowCanvasNodeTheme {
  final Color defaultBackgroundColor;
  final Color defaultBorderColor;
  final Color selectedBackgroundColor;
  final Color selectedBorderColor;
  final Color errorBackgroundColor;
  final Color errorBorderColor;
  final double defaultBorderWidth;
  final double selectedBorderWidth;
  final double borderRadius;
  final List<BoxShadow> shadows;
  final TextStyle defaultTextStyle;

  const FlowCanvasNodeTheme({
    required this.defaultBackgroundColor,
    required this.defaultBorderColor,
    required this.selectedBackgroundColor,
    required this.selectedBorderColor,
    required this.errorBackgroundColor,
    required this.errorBorderColor,
    this.defaultBorderWidth = 1.0,
    this.selectedBorderWidth = 2.0,
    this.borderRadius = 8.0,
    this.shadows = const [],
    required this.defaultTextStyle,
  });

  factory FlowCanvasNodeTheme.light() {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor: Colors.white,
      defaultBorderColor: const Color(0xFFE0E0E0),
      selectedBackgroundColor: const Color(0xFFF0F8FF),
      selectedBorderColor: const Color(0xFF2196F3),
      errorBackgroundColor: const Color(0xFFFFEBEE),
      errorBorderColor: const Color(0xFFE57373),
      defaultBorderWidth: 1.0,
      selectedBorderWidth: 2.0,
      borderRadius: 8.0,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      defaultTextStyle: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  factory FlowCanvasNodeTheme.dark() {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor: const Color(0xFF2D2D2D),
      defaultBorderColor: const Color(0xFF404040),
      selectedBackgroundColor: const Color(0xFF1E3A5F),
      selectedBorderColor: const Color(0xFF64B5F6),
      errorBackgroundColor: const Color(0xFF3D1A1A),
      errorBorderColor: const Color(0xFFEF5350),
      defaultBorderWidth: 1.0,
      selectedBorderWidth: 2.0,
      borderRadius: 8.0,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      defaultTextStyle: const TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  FlowCanvasNodeTheme copyWith({
    Color? defaultBackgroundColor,
    Color? defaultBorderColor,
    Color? selectedBackgroundColor,
    Color? selectedBorderColor,
    Color? errorBackgroundColor,
    Color? errorBorderColor,
    double? defaultBorderWidth,
    double? selectedBorderWidth,
    double? borderRadius,
    List<BoxShadow>? shadows,
    TextStyle? defaultTextStyle,
  }) {
    return FlowCanvasNodeTheme(
      defaultBackgroundColor:
          defaultBackgroundColor ?? this.defaultBackgroundColor,
      defaultBorderColor: defaultBorderColor ?? this.defaultBorderColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      defaultBorderWidth: defaultBorderWidth ?? this.defaultBorderWidth,
      selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      defaultTextStyle: defaultTextStyle ?? this.defaultTextStyle,
    );
  }
}

/// Theme for edges
class FlowCanvasEdgeTheme {
  final Color defaultColor;
  final Color selectedColor;
  final Color animatedColor;
  final double defaultStrokeWidth;
  final double selectedStrokeWidth;
  final double arrowHeadSize;
  final EdgeLabelTheme label;

  const FlowCanvasEdgeTheme({
    required this.defaultColor,
    required this.selectedColor,
    required this.animatedColor,
    this.defaultStrokeWidth = 2.0,
    this.selectedStrokeWidth = 3.0,
    this.arrowHeadSize = 8.0,
    required this.label,
  });

  factory FlowCanvasEdgeTheme.light() {
    return FlowCanvasEdgeTheme(
      defaultColor: const Color(0xFF9E9E9E),
      selectedColor: const Color(0xFF2196F3),
      animatedColor: const Color(0xFF4CAF50),
      defaultStrokeWidth: 2.0,
      selectedStrokeWidth: 3.0,
      arrowHeadSize: 8.0,
      label: EdgeLabelTheme.light(),
    );
  }

  factory FlowCanvasEdgeTheme.dark() {
    return FlowCanvasEdgeTheme(
      defaultColor: const Color(0xFF616161),
      selectedColor: const Color(0xFF64B5F6),
      animatedColor: const Color(0xFF81C784),
      defaultStrokeWidth: 2.0,
      selectedStrokeWidth: 3.0,
      arrowHeadSize: 8.0,
      label: EdgeLabelTheme.dark(),
    );
  }

  FlowCanvasEdgeTheme copyWith({
    Color? defaultColor,
    Color? selectedColor,
    Color? animatedColor,
    double? defaultStrokeWidth,
    double? selectedStrokeWidth,
    double? arrowHeadSize,
    EdgeLabelTheme? label,
  }) {
    return FlowCanvasEdgeTheme(
      defaultColor: defaultColor ?? this.defaultColor,
      selectedColor: selectedColor ?? this.selectedColor,
      animatedColor: animatedColor ?? this.animatedColor,
      defaultStrokeWidth: defaultStrokeWidth ?? this.defaultStrokeWidth,
      selectedStrokeWidth: selectedStrokeWidth ?? this.selectedStrokeWidth,
      arrowHeadSize: arrowHeadSize ?? this.arrowHeadSize,
      label: label ?? this.label,
    );
  }
}

/// Theme for edge labels
class EdgeLabelTheme {
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const EdgeLabelTheme({
    required this.textStyle,
    required this.backgroundColor,
    required this.borderColor,
    this.padding = const EdgeInsets.all(4.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  });

  factory EdgeLabelTheme.light() {
    return const EdgeLabelTheme(
      textStyle: TextStyle(
        color: Color(0xFF333333),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      borderColor: Color(0xFFE0E0E0),
      padding: EdgeInsets.all(4.0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    );
  }

  factory EdgeLabelTheme.dark() {
    return const EdgeLabelTheme(
      textStyle: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Color(0xFF2D2D2D),
      borderColor: Color(0xFF404040),
      padding: EdgeInsets.all(4.0),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    );
  }

  EdgeLabelTheme copyWith({
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return EdgeLabelTheme(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

/// Theme for handles
class FlowCanvasHandleTheme {
  final Color idleColor;
  final Color hoverColor;
  final Color connectingColor;
  final Color validTargetColor;
  final Color invalidTargetColor;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final bool enableAnimations;

  const FlowCanvasHandleTheme({
    required this.idleColor,
    required this.hoverColor,
    required this.connectingColor,
    required this.validTargetColor,
    required this.invalidTargetColor,
    this.size = 10.0,
    this.borderWidth = 1.5,
    required this.borderColor,
    this.shadows = const [],
    this.enableAnimations = true,
  });

  factory FlowCanvasHandleTheme.light() {
    return FlowCanvasHandleTheme(
      idleColor: const Color(0xFF9CA3AF),
      hoverColor: const Color(0xFF6B7280),
      connectingColor: const Color(0xFF3B82F6),
      validTargetColor: const Color(0xFF10B981),
      invalidTargetColor: const Color(0xFFEF4444),
      size: 10.0,
      borderWidth: 1.5,
      borderColor: Colors.white,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
      enableAnimations: true,
    );
  }

  factory FlowCanvasHandleTheme.dark() {
    return FlowCanvasHandleTheme(
      idleColor: const Color(0xFF6B7280),
      hoverColor: const Color(0xFF9CA3AF),
      connectingColor: const Color(0xFF60A5FA),
      validTargetColor: const Color(0xFF34D399),
      invalidTargetColor: const Color(0xFFF87171),
      size: 10.0,
      borderWidth: 1.5,
      borderColor: const Color(0xFF374151),
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      enableAnimations: true,
    );
  }

  FlowCanvasHandleTheme copyWith({
    Color? idleColor,
    Color? hoverColor,
    Color? connectingColor,
    Color? validTargetColor,
    Color? invalidTargetColor,
    double? size,
    double? borderWidth,
    Color? borderColor,
    List<BoxShadow>? shadows,
    bool? enableAnimations,
  }) {
    return FlowCanvasHandleTheme(
      idleColor: idleColor ?? this.idleColor,
      hoverColor: hoverColor ?? this.hoverColor,
      connectingColor: connectingColor ?? this.connectingColor,
      validTargetColor: validTargetColor ?? this.validTargetColor,
      invalidTargetColor: invalidTargetColor ?? this.invalidTargetColor,
      size: size ?? this.size,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      shadows: shadows ?? this.shadows,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }
}

/// Theme for selection
class FlowCanvasSelectionTheme {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double dashLength;
  final double gapLength;

  const FlowCanvasSelectionTheme({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.dashLength = 5.0,
    this.gapLength = 5.0,
  });

  factory FlowCanvasSelectionTheme.light() {
    return const FlowCanvasSelectionTheme(
      fillColor: Color(0x1A2196F3),
      borderColor: Color(0xFF2196F3),
      borderWidth: 1.0,
      dashLength: 5.0,
      gapLength: 5.0,
    );
  }

  factory FlowCanvasSelectionTheme.dark() {
    return const FlowCanvasSelectionTheme(
      fillColor: Color(0x1A64B5F6),
      borderColor: Color(0xFF64B5F6),
      borderWidth: 1.0,
      dashLength: 5.0,
      gapLength: 5.0,
    );
  }

  FlowCanvasSelectionTheme copyWith({
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    double? dashLength,
    double? gapLength,
  }) {
    return FlowCanvasSelectionTheme(
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      dashLength: dashLength ?? this.dashLength,
      gapLength: gapLength ?? this.gapLength,
    );
  }
}

/// Theme for control panel
class FlowCanvasControlTheme {
  final Color backgroundColor;
  final Color buttonColor;
  final Color buttonHoverColor;
  final Color iconColor;
  final Color iconHoverColor;
  final Color dividerColor;
  final double buttonSize;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;
  final EdgeInsets padding;

  const FlowCanvasControlTheme({
    required this.backgroundColor,
    required this.buttonColor,
    required this.buttonHoverColor,
    required this.iconColor,
    required this.iconHoverColor,
    required this.dividerColor,
    this.buttonSize = 32.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.shadows = const [],
    this.padding = const EdgeInsets.all(4.0),
  });

  factory FlowCanvasControlTheme.light() {
    return FlowCanvasControlTheme(
      backgroundColor: Colors.white,
      buttonColor: const Color(0xFFF9FAFB),
      buttonHoverColor: const Color(0xFFF3F4F6),
      iconColor: const Color(0xFF6B7280),
      iconHoverColor: const Color(0xFF374151),
      dividerColor: const Color(0xFFE5E7EB),
      buttonSize: 32.0,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      padding: const EdgeInsets.all(4.0),
    );
  }

  factory FlowCanvasControlTheme.dark() {
    return FlowCanvasControlTheme(
      backgroundColor: const Color(0xFF1F2937),
      buttonColor: const Color(0xFF374151),
      buttonHoverColor: const Color(0xFF4B5563),
      iconColor: Colors.white,
      iconHoverColor: const Color(0xFFF9FAFB),
      dividerColor: const Color(0xFF374151),
      buttonSize: 32.0,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.all(4.0),
    );
  }

  FlowCanvasControlTheme copyWith({
    Color? backgroundColor,
    Color? buttonColor,
    Color? buttonHoverColor,
    Color? iconColor,
    Color? iconHoverColor,
    Color? dividerColor,
    double? buttonSize,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    EdgeInsets? padding,
  }) {
    return FlowCanvasControlTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonHoverColor: buttonHoverColor ?? this.buttonHoverColor,
      iconColor: iconColor ?? this.iconColor,
      iconHoverColor: iconHoverColor ?? this.iconHoverColor,
      dividerColor: dividerColor ?? this.dividerColor,
      buttonSize: buttonSize ?? this.buttonSize,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
      padding: padding ?? this.padding,
    );
  }
}

/// Theme for minimap
class FlowCanvasMiniMapTheme {
  final Color backgroundColor;
  final Color nodeColor;
  final Color nodeStrokeColor;
  final Color selectedNodeColor;
  final Color maskColor;
  final Color maskStrokeColor;
  final double nodeStrokeWidth;
  final double maskStrokeWidth;
  final double borderRadius;
  final List<BoxShadow> shadows;

  const FlowCanvasMiniMapTheme({
    required this.backgroundColor,
    required this.nodeColor,
    required this.nodeStrokeColor,
    required this.selectedNodeColor,
    required this.maskColor,
    required this.maskStrokeColor,
    this.nodeStrokeWidth = 1.5,
    this.maskStrokeWidth = 1.0,
    this.borderRadius = 8.0,
    this.shadows = const [],
  });

  factory FlowCanvasMiniMapTheme.light() {
    return FlowCanvasMiniMapTheme(
      backgroundColor: Colors.white,
      nodeColor: const Color(0xFF2196F3),
      nodeStrokeColor: const Color(0xFF1976D2),
      selectedNodeColor: const Color(0xFFFF9800),
      maskColor: const Color(0x99F0F2F5),
      maskStrokeColor: const Color(0xFF9E9E9E),
      nodeStrokeWidth: 1.5,
      maskStrokeWidth: 1.0,
      borderRadius: 8.0,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  factory FlowCanvasMiniMapTheme.dark() {
    return FlowCanvasMiniMapTheme(
      backgroundColor: const Color(0xFF2D2D2D),
      nodeColor: const Color(0xFF64B5F6),
      nodeStrokeColor: const Color(0xFF42A5F5),
      selectedNodeColor: const Color(0xFFFFB74D),
      maskColor: const Color(0x99000000),
      maskStrokeColor: const Color(0xFF616161),
      nodeStrokeWidth: 1.5,
      maskStrokeWidth: 1.0,
      borderRadius: 8.0,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(77),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  FlowCanvasMiniMapTheme copyWith({
    Color? backgroundColor,
    Color? nodeColor,
    Color? nodeStrokeColor,
    Color? selectedNodeColor,
    Color? maskColor,
    Color? maskStrokeColor,
    double? nodeStrokeWidth,
    double? maskStrokeWidth,
    double? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return FlowCanvasMiniMapTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      nodeColor: nodeColor ?? this.nodeColor,
      nodeStrokeColor: nodeStrokeColor ?? this.nodeStrokeColor,
      selectedNodeColor: selectedNodeColor ?? this.selectedNodeColor,
      maskColor: maskColor ?? this.maskColor,
      maskStrokeColor: maskStrokeColor ?? this.maskStrokeColor,
      nodeStrokeWidth: nodeStrokeWidth ?? this.nodeStrokeWidth,
      maskStrokeWidth: maskStrokeWidth ?? this.maskStrokeWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
    );
  }
}

/// Theme for connection (drag) visualization
class FlowCanvasConnectionTheme {
  final Color activeColor;
  final Color validTargetColor;
  final Color invalidTargetColor;
  final double strokeWidth;
  final double endPointRadius;

  const FlowCanvasConnectionTheme({
    required this.activeColor,
    required this.validTargetColor,
    required this.invalidTargetColor,
    this.strokeWidth = 2.0,
    this.endPointRadius = 6.0,
  });

  factory FlowCanvasConnectionTheme.light() {
    return const FlowCanvasConnectionTheme(
      activeColor: Color(0xFF2196F3),
      validTargetColor: Color(0xFF4CAF50),
      invalidTargetColor: Color(0xFFF44336),
      strokeWidth: 2.0,
      endPointRadius: 6.0,
    );
  }

  factory FlowCanvasConnectionTheme.dark() {
    return const FlowCanvasConnectionTheme(
      activeColor: Color(0xFF64B5F6),
      validTargetColor: Color(0xFF81C784),
      invalidTargetColor: Color(0xFFE57373),
      strokeWidth: 2.0,
      endPointRadius: 6.0,
    );
  }

  FlowCanvasConnectionTheme copyWith({
    Color? activeColor,
    Color? validTargetColor,
    Color? invalidTargetColor,
    double? strokeWidth,
    double? endPointRadius,
  }) {
    return FlowCanvasConnectionTheme(
      activeColor: activeColor ?? this.activeColor,
      validTargetColor: validTargetColor ?? this.validTargetColor,
      invalidTargetColor: invalidTargetColor ?? this.invalidTargetColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      endPointRadius: endPointRadius ?? this.endPointRadius,
    );
  }
}

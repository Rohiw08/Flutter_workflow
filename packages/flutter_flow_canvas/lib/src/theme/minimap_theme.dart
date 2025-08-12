import 'package:flutter/material.dart';

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

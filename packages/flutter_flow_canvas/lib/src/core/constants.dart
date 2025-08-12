import 'package:flutter/material.dart';

class FlowCanvasConstants {
  // Handle positioning
  static const double defaultHandleSize = 10.0;
  static const double handleGestureArea = 2.5; // Multiplier for touch area

  // Animation durations
  static const Duration handleScaleAnimation = Duration(milliseconds: 200);
  static const Duration handlePulseAnimation = Duration(milliseconds: 1200);

  // Zoom limits
  static const double minZoom = 0.1;
  static const double maxZoom = 2.0;
  static const double defaultZoomStep = 1.2;

  // Edge styling
  static const double defaultEdgeStrokeWidth = 2.0;
  static const double selectedEdgeStrokeWidth = 3.0;
  static const double arrowHeadSize = 8.0;

  // Canvas defaults
  static const double defaultCanvasWidth = 5000.0;
  static const double defaultCanvasHeight = 5000.0;

  // Performance settings
  static const int imageCapturesBatchSize = 3;
  static const Duration batchDelay = Duration(milliseconds: 1);

  // UI spacing
  static const EdgeInsets defaultControlPadding = EdgeInsets.all(16.0);
  static const double defaultControlButtonSize = 32.0;
}

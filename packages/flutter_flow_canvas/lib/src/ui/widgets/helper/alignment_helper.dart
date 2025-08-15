import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/core/enums.dart';

/// Helper class for converting control panel alignment to Flutter Alignment
class AlignmentHelper {
  /// Convert ControlPanelAlignment to Flutter Alignment
  static Alignment getAlignment(ControlPanelAlignment align) {
    switch (align) {
      case ControlPanelAlignment.topLeft:
        return Alignment.topLeft;
      case ControlPanelAlignment.topRight:
        return Alignment.topRight;
      case ControlPanelAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case ControlPanelAlignment.bottomRight:
        return Alignment.bottomRight;
      case ControlPanelAlignment.center:
        return Alignment.center;
    }
  }
}

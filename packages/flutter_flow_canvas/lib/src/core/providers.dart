import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'canvas_controller.dart';

/// Provider for the main FlowCanvasController.
/// This should be overridden at the root of the widget tree that uses the FlowCanvas.
final flowControllerProvider =
    ChangeNotifierProvider<FlowCanvasController>((ref) {
  throw UnimplementedError('flowControllerProvider must be overridden');
});

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [TransformationController] for the InteractiveViewer.
/// This allows different widgets (like the Controls) to interact with the canvas.
final transformationControllerProvider =
    Provider((ref) => TransformationController());

/// Manages the interactive (locked/unlocked) state of the canvas.
final isInteractiveProvider = StateProvider<bool>((ref) => true);
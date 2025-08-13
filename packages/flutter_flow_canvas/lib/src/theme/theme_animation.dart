import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedFlowCanvasTheme extends ConsumerWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedFlowCanvasTheme({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(flowCanvasThemeProvider);

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        color: theme.background.backgroundColor,
      ),
      child: child,
    );
  }
}

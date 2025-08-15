import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/src/theme/theme.dart';

class AnimatedFlowCanvasTheme extends StatelessWidget {
  final FlowCanvasTheme theme;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const AnimatedFlowCanvasTheme({
    super.key,
    required this.theme,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: duration,
      curve: curve,
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(context).extensions.values,
        ],
      ),
      child: child,
    );
  }
}

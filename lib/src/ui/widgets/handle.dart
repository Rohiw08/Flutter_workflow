import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

enum HandlePosition { top, right, bottom, left }

class Handle extends ConsumerStatefulWidget {
  final String nodeId;
  final String id;
  final HandlePosition position;
  final double size;
  final Color color;
  final Color borderColor;

  const Handle({
    super.key,
    required this.nodeId,
    required this.id,
    required this.position,
    this.size = 15.0,
    this.color = Colors.white,
    this.borderColor = Colors.grey,
  });

  @override
  ConsumerState<Handle> createState() => _HandleState();
}

class _HandleState extends ConsumerState<Handle> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(flowControllerProvider)
            .registerHandle(widget.nodeId, widget.id, _key);
      }
    });
  }

  @override
  void dispose() {
    ref.read(flowControllerProvider).unregisterHandle(widget.nodeId, widget.id);
    super.dispose();
  }

  Alignment _getAlignment() {
    switch (widget.position) {
      case HandlePosition.top:
        return Alignment.topCenter;
      case HandlePosition.right:
        return Alignment.centerRight;
      case HandlePosition.bottom:
        return Alignment.bottomCenter;
      case HandlePosition.left:
        return Alignment.centerLeft;
    }
  }

  void _onPanStart(DragStartDetails details) {
    final controller = ref.read(flowControllerProvider);
    controller.startConnection(
      widget.nodeId,
      widget.id,
      details.globalPosition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: GestureDetector(
        onPanStart: _onPanStart,
        child: Container(
          key: _key,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: widget.borderColor, width: 2.0),
          ),
        ),
      ),
    );
  }
}

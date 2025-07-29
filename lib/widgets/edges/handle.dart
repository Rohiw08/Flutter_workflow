import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/models/connection_state.dart' as custom;
import 'package:flutter_workflow/models/flow_edge.dart';
import 'package:flutter_workflow/providers/connection_state_provider.dart';
import 'package:flutter_workflow/providers/handle_registory_provider.dart';
import 'package:flutter/material.dart' hide ConnectionState;

enum HandleType { source, target }
enum HandlePosition { top, right, bottom, left }

class Handle extends ConsumerStatefulWidget {
  final String nodeId; // The ID of the parent node
  final String? id; // The unique ID of this handle within the node
  final HandleType type;
  final HandlePosition position;
  final bool isConnectable;
  final bool isConnectableStart;
  final bool isConnectableEnd;
  final bool Function(Edge)? isValidConnection;
  final void Function(Edge)? onConnect;
  final bool visible;

  const Handle({
    super.key,
    required this.nodeId,
    this.id,
    required this.type,
    required this.position,
    this.isConnectable = true,
    this.isConnectableStart = true,
    this.isConnectableEnd = true,
    this.isValidConnection,
    this.onConnect,
    this.visible = true,
  });

  @override
  ConsumerState<Handle> createState() => _HandleState();
}

class _HandleState extends ConsumerState<Handle> {
  final GlobalKey _key = GlobalKey();

  // A unique key for this handle in the registry
  String get _registryKey => "${widget.nodeId}/${widget.id ?? ''}";

  @override
  void initState() {
    super.initState();
    // Register this handle's key so the painter can find it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(handleRegistryProvider.notifier).update(
              (state) => {...state, _registryKey: _key},
            );
      }
    });
  }

  @override
  void dispose() {
    // Unregister the handle
    ref.read(handleRegistryProvider.notifier).update(
          (state) => {...state}..remove(_registryKey),
        );
    super.dispose();
  }
  
  Alignment _getAlignment() {
    switch (widget.position) {
      case HandlePosition.top: return Alignment.topCenter;
      case HandlePosition.right: return Alignment.centerRight;
      case HandlePosition.bottom: return Alignment.bottomCenter;
      case HandlePosition.left: return Alignment.centerLeft;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isConnectable || !widget.isConnectableStart) return;

    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // The starting point of the connection line
    final startPos = renderBox.localToGlobal(renderBox.size.center(Offset.zero));

    ref.read(connectionStateProvider.notifier).state = custom.ConnectionState(
      fromNodeId: widget.nodeId,
      fromHandleId: widget.id,
      startPosition: startPos,
      endPosition: details.globalPosition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(connectionStateProvider);
    final isConnecting = connection != null;
    final isTarget = connection?.hoveredTargetKey == _registryKey;
    
    // Style adjustments when connecting
    Color borderColor = widget.type == HandleType.source ? Colors.green.shade300 : Colors.red.shade300;
    if (isConnecting) {
      borderColor = Colors.grey;
    }
    if (isTarget) {
      borderColor = Colors.blueAccent;
    }

    return Align(
      alignment: _getAlignment(),
      child: Visibility(
        key: _key,
        visible: widget.visible,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: GestureDetector(
          onPanStart: _onPanStart,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2.5),
            ),
          ),
        ),
      ),
    );
  }
}
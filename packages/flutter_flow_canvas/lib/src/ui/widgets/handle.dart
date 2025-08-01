import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart'; // Assuming this provides your FlowCanvasController

/// Defines the automatic alignment position of a handle on a node.
enum HandlePosition { top, right, bottom, left }

/// Type of handle for connection validation.
enum HandleType { source, target }

/// A callback function to validate a potential connection.
typedef IsValidConnectionCallback = bool Function(
  String sourceNodeId,
  String sourceHandleId,
  String targetNodeId,
  String targetHandleId,
);

/// A highly customizable connection handle that can be placed on nodes.
///
/// This widget supports two positioning modes:
/// 1.  **Automatic Positioning:** If a `position` is provided, the handle will
///     automatically align itself to that edge of its parent container.
/// 2.  **Manual Positioning:** If `position` is null, the handle renders as a
///     simple widget, and you are responsible for positioning it using widgets
///     like `Stack` and `Positioned`.
class Handle extends ConsumerStatefulWidget {
  /// The ID of the node this handle belongs to.
  final String nodeId;

  /// Unique ID for this handle within the node.
  final String id;

  /// positioning is required.
  final HandlePosition? position;

  /// The type of handle, determining if it can be a source or a target.
  final HandleType type;

  /// The size (width and height) of the handle widget.
  final double size;

  /// A custom widget to display inside the handle. If null, a default
  /// representation is used.
  final Widget? child;

  /// The base decoration for the handle. This is used for the default state.
  final BoxDecoration? decoration;

  /// The decoration to apply when the handle is hovered, being connected,
  /// or targeted by a connection. If null, a default hover effect is used.
  final BoxDecoration? hoverDecoration;

  /// A master switch to enable or disable all connections for this handle.
  final bool isConnectable;

  /// Determines if a new connection can be dragged FROM this handle.
  /// Only applies if `type` is `HandleType.source`.
  final bool isConnectableStart;

  /// Determines if a connection can be dropped ONTO this handle.
  /// Only applies if `type` is `HandleType.target`.
  final bool isConnectableEnd;

  /// Enables or disables all hover and connection animations for performance
  /// or stylistic reasons.
  final bool enableAnimations;

  /// A custom callback to validate a connection attempt. If it returns false,
  /// the connection will be disallowed.
  final IsValidConnectionCallback? onValidateConnection;

  /// A callback fired when a connection is successfully made involving this
  /// handle.
  final VoidCallback? onConnect;

  const Handle({
    super.key,
    required this.nodeId,
    required this.id,
    this.position,
    this.type = HandleType.source,
    this.size = 15.0,
    this.child,
    this.decoration,
    this.hoverDecoration,
    this.isConnectable = true,
    this.isConnectableStart = true,
    this.isConnectableEnd = true,
    this.enableAnimations = true,
    this.onValidateConnection,
    this.onConnect,
  });

  @override
  ConsumerState<Handle> createState() => _HandleState();
}

class _HandleState extends ConsumerState<Handle> with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  bool _isHovered = false;
  bool _isConnecting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

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
    _animationController.dispose();
    ref.read(flowControllerProvider).unregisterHandle(widget.nodeId, widget.id);
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isConnectable ||
        !widget.isConnectableStart ||
        widget.type != HandleType.source) {
      return;
    }

    final controller = ref.read(flowControllerProvider);
    controller.startConnection(
      widget.nodeId,
      widget.id,
      details.globalPosition,
    );
    setState(() => _isConnecting = true);
    if (widget.enableAnimations) {
      _animationController.forward();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isConnecting) return;
    setState(() => _isConnecting = false);
    if (widget.enableAnimations && !_isHovered) {
      _animationController.reverse();
    }
  }

  BoxDecoration _buildDefaultDecoration(Color color, Color borderColor) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 2.0),
    );
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
      default:
        return Alignment.center;
    }
  }

  Offset _getOffset() {
    final double offset = widget.size / 2;
    switch (widget.position) {
      case HandlePosition.top:
        return Offset(0, -offset);
      case HandlePosition.right:
        return Offset(offset, 0);
      case HandlePosition.bottom:
        return Offset(0, offset);
      case HandlePosition.left:
        return Offset(-offset, 0);
      default:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(flowControllerProvider);
    final isTargeted = controller.connection?.hoveredTargetKey ==
        '${widget.nodeId}/${widget.id}';
    final canBeTarget = widget.isConnectable &&
        widget.isConnectableEnd &&
        widget.type == HandleType.target;
    final showAsActive =
        _isHovered || _isConnecting || (isTargeted && canBeTarget);

    BoxDecoration? currentDecoration;
    if (showAsActive) {
      currentDecoration = widget.hoverDecoration ??
          _buildDefaultDecoration(Colors.blue, Colors.blue.shade700);
    } else {
      currentDecoration = widget.decoration ??
          _buildDefaultDecoration(Colors.white, Colors.grey.shade400);
    }

    final handleWidget = MouseRegion(
      onEnter: (_) {
        if (!widget.enableAnimations) return;
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        if (!widget.enableAnimations) return;
        setState(() => _isHovered = false);
        if (!_isConnecting) {
          _animationController.reverse();
        }
      },
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              key: _key,
              scale: widget.enableAnimations ? _scaleAnimation.value : 1.0,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: widget.child ?? Container(decoration: currentDecoration),
              ),
            );
          },
        ),
      ),
    );

    if (widget.position != null) {
      return Align(
        alignment: _getAlignment(),
        child: Transform.translate(
          offset: _getOffset(),
          child: handleWidget,
        ),
      );
    }

    // If no position is specified, return the widget directly for manual positioning.
    return handleWidget;
  }
}

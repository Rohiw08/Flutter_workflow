import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../flutter_flow_canvas.dart';

/// A callback function to validate a potential connection.
typedef IsValidConnectionCallback = bool Function(
  String sourceNodeId,
  String sourceHandleId,
  String targetNodeId,
  String targetHandleId,
);

/// A React Flow style connection handle that can be placed on nodes.
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
  /// React Flow style representation is used.
  final Widget? child;

  /// Custom colors for the handle states
  final Color? idleColor;
  final Color? hoverColor;
  final Color? connectingColor;
  final Color? validTargetColor;

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
    this.size = 8.0, // Smaller default size like React Flow
    this.child,
    this.idleColor,
    this.hoverColor,
    this.connectingColor,
    this.validTargetColor,
    this.isConnectable = true,
    this.isConnectableStart = true,
    this.isConnectableEnd = true,
    this.enableAnimations = true,
    this.onValidateConnection,
    this.onConnect,
  });

  @override
  ConsumerState<Handle> createState() => HandleState();
}

class HandleState extends ConsumerState<Handle> with TickerProviderStateMixin {
  final GlobalKey<HandleState> _key = GlobalKey<HandleState>();
  bool _isHovered = false;
  bool _isConnecting = false;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  FlowCanvasController get controller => ref.read(flowControllerProvider);

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.connectionManager
            .registerHandle(widget.nodeId, widget.id, _key);
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    controller.connectionManager.unregisterHandle(widget.nodeId, widget.id);
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isConnectable ||
        !widget.isConnectableStart ||
        widget.type != HandleType.source) {
      return;
    }

    controller.connectionManager.startConnection(
      widget.nodeId,
      widget.id,
      details.globalPosition,
    );
    setState(() => _isConnecting = true);
    if (widget.enableAnimations) {
      _scaleController.forward();
      _pulseController.repeat();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isConnecting) return;

    controller.connectionManager.endConnection();

    setState(() => _isConnecting = false);
    if (widget.enableAnimations) {
      _pulseController.stop();
      _pulseController.reset();
      if (!_isHovered) {
        _scaleController.reverse();
      }
    }
  }

  Color _getHandleColor() {
    final currentConnection = ref.watch(
        flowControllerProvider.select((c) => c.connectionManager.connection));
    final isTargeted =
        currentConnection?.hoveredTargetKey == '${widget.nodeId}/${widget.id}';
    final canBeTarget = widget.isConnectable &&
        widget.isConnectableEnd &&
        widget.type == HandleType.target;

    if (isTargeted && canBeTarget) {
      return widget.validTargetColor ?? const Color(0xFF10B981); // Green
    }
    if (_isConnecting) {
      return widget.connectingColor ?? const Color(0xFF3B82F6); // Blue
    }
    if (_isHovered) {
      return widget.hoverColor ?? const Color(0xFF6B7280); // Gray-500
    }
    return widget.idleColor ?? const Color(0xFF9CA3AF); // Gray-400
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

  Widget _buildReactFlowHandle() {
    final handleColor = _getHandleColor();
    final currentConnection = ref.watch(
        flowControllerProvider.select((c) => c.connectionManager.connection));
    final isTargeted =
        currentConnection?.hoveredTargetKey == '${widget.nodeId}/${widget.id}';
    final canBeTarget = widget.isConnectable &&
        widget.isConnectableEnd &&
        widget.type == HandleType.target;
    final showPulse = _isConnecting || (isTargeted && canBeTarget);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showPulse && widget.enableAnimations)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: widget.size * (2 + _pulseAnimation.value * 1.5),
                height: widget.size * (2 + _pulseAnimation.value * 1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: handleColor
                        .withOpacity(0.3 * (1 - _pulseAnimation.value)),
                    width: 1.0,
                  ),
                ),
              );
            },
          ),
        if (_isHovered || _isConnecting || (isTargeted && canBeTarget))
          Container(
            width: widget.size * 1.8,
            height: widget.size * 1.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: handleColor.withAlpha(50),
            ),
          ),
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: handleColor,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        if (widget.type == HandleType.source || _isConnecting)
          Container(
            width: widget.size * 0.4,
            height: widget.size * 0.4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final handleWidget = MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (widget.enableAnimations) {
          _scaleController.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (widget.enableAnimations && !_isConnecting) {
          _scaleController.reverse();
        }
      },
      cursor: widget.isConnectable
          ? SystemMouseCursors.grab
          : SystemMouseCursors.basic,
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
                width: widget.size * 2.5, // Larger hit area
                height: widget.size * 2.5,
                child: Center(
                  child: widget.child ?? _buildReactFlowHandle(),
                ),
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
    return handleWidget;
  }
}

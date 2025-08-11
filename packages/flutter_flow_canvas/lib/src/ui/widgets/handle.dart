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
  final String nodeId;
  final String id;
  final HandlePosition? position;
  final HandleType type;
  final double size;
  final Widget? child;

  /// Custom colors for the handle states
  final Color? idleColor;
  final Color? hoverColor;
  final Color? connectingColor;
  final Color? validTargetColor;

  /// A master switch to enable or disable all connections for this handle.
  final bool isConnectable;
  final bool isConnectableStart;
  final bool isConnectableEnd;

  /// Enables or disables all hover and connection animations for performance
  /// or stylistic reasons.
  final bool enableAnimations;
  final IsValidConnectionCallback? onValidateConnection;

  /// A callback fired when a connection is successfully made involving this
  final VoidCallback? onConnect;

  const Handle({
    super.key,
    required this.nodeId,
    required this.id,
    this.position,
    this.type = HandleType.source,
    this.size = 10.0,
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
  // Fixed: Generate unique GlobalKey for each handle instance
  late final GlobalKey<HandleState> _key;
  bool _isHovered = false;
  bool _isConnecting = false;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  late final FlowCanvasController controller;

  String? _registeredNodeId;
  String? _registeredHandleId;

  @override
  void initState() {
    super.initState();

    // Fixed: Create unique GlobalKey for each handle instance
    _key = GlobalKey<HandleState>();

    controller = ref.read(flowControllerProvider);

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
      // Fixed: Add mounted check before registration
      if (mounted) {
        _registerHandle();
      }
    });
  }

  @override
  void dispose() {
    // Fixed: Unregister first, then dispose controllers to prevent animation issues
    _unregisterHandle();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Handle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodeId != widget.nodeId || oldWidget.id != widget.id) {
      _unregisterHandle();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Fixed: Add mounted check in callback
        if (mounted) {
          _registerHandle();
        }
      });
    }
  }

  void _registerHandle() {
    if (mounted) {
      controller.connectionManager
          .registerHandle(widget.nodeId, widget.id, _key);
      _registeredNodeId = widget.nodeId;
      _registeredHandleId = widget.id;
    }
  }

  void _unregisterHandle() {
    if (_registeredNodeId != null && _registeredHandleId != null) {
      controller.connectionManager
          .unregisterHandle(_registeredNodeId!, _registeredHandleId!);
      _registeredNodeId = null;
      _registeredHandleId = null;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isConnectable ||
        !widget.isConnectableStart ||
        widget.type != HandleType.source) {
      return;
    }

    // Fixed: Check if still mounted before starting connection
    if (!mounted) return;

    controller.connectionManager.startConnection(
      widget.nodeId,
      widget.id,
      details.globalPosition,
    );

    if (mounted) {
      setState(() => _isConnecting = true);
      if (widget.enableAnimations) {
        _scaleController.forward();
        _pulseController.repeat();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isConnecting || !mounted) return;

    controller.connectionManager.endConnection();

    if (mounted) {
      setState(() => _isConnecting = false);
      if (widget.enableAnimations) {
        _pulseController.stop();
        _pulseController.reset();
        if (!_isHovered) {
          _scaleController.reverse();
        }
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
        return Offset(0, offset - 17);
      case HandlePosition.right:
        return Offset(-offset + 17, 0);
      case HandlePosition.bottom:
        return Offset(0, -offset + 17);
      case HandlePosition.left:
        return Offset(offset - 17, 0);
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
                    color: handleColor.withOpacity(
                      0.3 * (1 - _pulseAnimation.value),
                    ),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final handleWidget = MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
          if (widget.enableAnimations) {
            _scaleController.forward();
          }
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
          if (widget.enableAnimations && !_isConnecting) {
            _scaleController.reverse();
          }
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
                width: widget.size * 2.5,
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

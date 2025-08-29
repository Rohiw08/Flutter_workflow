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

/// A theme-aware, React Flow style connection handle that can be placed on nodes.
class Handle extends ConsumerStatefulWidget {
  final String nodeId;
  final String id;
  final HandlePosition? position;
  final HandleType type;
  final Widget? child;

  // Styling overrides
  final double? size;
  final Color? idleColor;
  final Color? hoverColor;
  final Color? activeColor; // Renamed from connectingColor
  final Color? validTargetColor;
  final Color? invalidTargetColor; // Added for completeness

  // Behavior overrides
  final bool? isConnectable;
  final bool? isConnectableStart;
  final bool? isConnectableEnd;
  final bool? enableAnimations;

  // Callbacks
  final IsValidConnectionCallback? onValidateConnection;
  final VoidCallback? onConnect;

  const Handle({
    super.key,
    required this.nodeId,
    required this.id,
    this.position,
    this.type = HandleType.source,
    this.child,
    this.size,
    this.idleColor,
    this.hoverColor,
    this.activeColor,
    this.validTargetColor,
    this.invalidTargetColor,
    this.isConnectable,
    this.isConnectableStart,
    this.isConnectableEnd,
    this.enableAnimations,
    this.onValidateConnection,
    this.onConnect,
  });

  @override
  ConsumerState<Handle> createState() => HandleState();
}

class HandleState extends ConsumerState<Handle> with TickerProviderStateMixin {
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

  // initState and other lifecycle methods remain the same
  @override
  void initState() {
    super.initState();
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
      if (mounted) {
        _registerHandle();
      }
    });
  }

  @override
  void dispose() {
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
        if (mounted) {
          _registerHandle();
        }
      });
    }
  }

  void _registerHandle() {
    if (mounted) {
      controller.handleManager.registerHandle(widget.nodeId, widget.id, _key);
      _registeredNodeId = widget.nodeId;
      _registeredHandleId = widget.id;
    }
  }

  void _unregisterHandle() {
    if (_registeredNodeId != null && _registeredHandleId != null) {
      controller.handleManager
          .unregisterHandle(_registeredNodeId!, _registeredHandleId!);
      _registeredNodeId = null;
      _registeredHandleId = null;
    }
  }

  // Pan handling logic remains the same
  void _onPanStart(DragStartDetails details) {
    final handleTheme = context.flowCanvasTheme.handle;
    final enableAnimations =
        widget.enableAnimations ?? handleTheme.enableAnimations;
    final isConnectable = widget.isConnectable ?? true;
    final isConnectableStart = widget.isConnectableStart ?? true;

    if (!isConnectable ||
        !isConnectableStart ||
        widget.type == HandleType.target) {
      return;
    }
    if (!mounted) return;

    controller.connectionManager.startConnection(
      widget.nodeId,
      widget.id,
      details.globalPosition,
    );

    if (mounted) {
      setState(() => _isConnecting = true);
      if (enableAnimations) {
        _scaleController.forward();
        _pulseController.repeat();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final handleTheme = context.flowCanvasTheme.handle;
    final enableAnimations =
        widget.enableAnimations ?? handleTheme.enableAnimations;
    if (!_isConnecting || !mounted) return;

    controller.connectionManager.endConnection();

    if (mounted) {
      setState(() => _isConnecting = false);
      if (enableAnimations) {
        _pulseController.stop();
        _pulseController.reset();
        if (!_isHovered) {
          _scaleController.reverse();
        }
      }
    }
  }

  // UPDATED: This method now sources its colors from the theme,
  // allowing widget properties to act as overrides.
  Color _getHandleColor(FlowCanvasHandleTheme handleTheme) {
    final currentConnection = ref.watch(
        flowControllerProvider.select((c) => c.connectionManager.connection));
    final isTargeted =
        currentConnection?.hoveredTargetKey == '${widget.nodeId}/${widget.id}';
    final canBeTarget = (widget.isConnectable ?? true) &&
        (widget.isConnectableEnd ?? true) &&
        widget.type != HandleType.source;

    if (isTargeted && canBeTarget) {
      return widget.validTargetColor ?? handleTheme.validTargetColor;
    }
    if (_isConnecting) {
      return widget.activeColor ?? handleTheme.activeColor;
    }
    if (_isHovered) {
      return widget.hoverColor ?? handleTheme.hoverColor;
    }
    return widget.idleColor ?? handleTheme.idleColor;
  }

  // Alignment and offset logic remains the same
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

  Offset _getOffset(double handleSize) {
    final double offset = handleSize / 2;
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

  // UPDATED: This build method now sources all its styling from the theme.
  Widget _buildReactFlowHandle(FlowCanvasHandleTheme handleTheme) {
    final handleColor = _getHandleColor(handleTheme);
    final handleSize = widget.size ?? handleTheme.size;
    final enableAnimations =
        widget.enableAnimations ?? handleTheme.enableAnimations;

    final currentConnection = ref.watch(
        flowControllerProvider.select((c) => c.connectionManager.connection));
    final isTargeted =
        currentConnection?.hoveredTargetKey == '${widget.nodeId}/${widget.id}';
    final canBeTarget = (widget.isConnectable ?? true) &&
        (widget.isConnectableEnd ?? true) &&
        widget.type != HandleType.source;
    final showPulse = _isConnecting || (isTargeted && canBeTarget);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showPulse && enableAnimations)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: handleSize * (2 + _pulseAnimation.value * 1.5),
                height: handleSize * (2 + _pulseAnimation.value * 1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: handleColor.withAlpha(
                      (75 * (1 - _pulseAnimation.value)).toInt(),
                    ),
                    width: 1.0,
                  ),
                ),
              );
            },
          ),
        if (_isHovered || _isConnecting || (isTargeted && canBeTarget))
          Container(
            width: handleSize * 1.8,
            height: handleSize * 1.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: handleColor.withAlpha(50),
            ),
          ),
        Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: handleColor,
            border: Border.all(
              color: handleTheme.borderColor,
              width: handleTheme.borderWidth,
            ),
            boxShadow: handleTheme.shadows,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Get theme once at the top of the build method.
    final handleTheme = context.flowCanvasTheme.handle;
    final handleSize = widget.size ?? handleTheme.size;
    final enableAnimations =
        widget.enableAnimations ?? handleTheme.enableAnimations;
    final isConnectable = widget.isConnectable ?? true;

    final handleWidget = MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
          if (enableAnimations) {
            _scaleController.forward();
          }
          debugPrint(
              'Hovered over handle ${widget.id} of node ${widget.nodeId}');
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
          if (enableAnimations && !_isConnecting) {
            _scaleController.reverse();
          }
        }
      },
      cursor:
          isConnectable ? SystemMouseCursors.grab : SystemMouseCursors.basic,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              key: _key,
              scale: enableAnimations ? _scaleAnimation.value : 1.0,
              child: SizedBox(
                width: handleSize * 2.5, // Gesture area
                height: handleSize * 2.5, // Gesture area
                child: Center(
                  child: widget.child ?? _buildReactFlowHandle(handleTheme),
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
          offset: _getOffset(handleSize),
          child: handleWidget,
        ),
      );
    }
    return handleWidget;
  }
}

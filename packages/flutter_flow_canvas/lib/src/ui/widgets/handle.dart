import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

/// Position of handle on a node
enum HandlePosition { top, right, bottom, left }

/// Type of handle for connection validation
enum HandleType { source, target, both }

/// A connection handle widget that can be attached to nodes
/// for creating connections between nodes
class Handle extends ConsumerStatefulWidget {
  /// The ID of the node this handle belongs to
  final String nodeId;

  /// Unique ID for this handle within the node
  final String id;

  /// Position of the handle on the node
  final HandlePosition position;

  /// Type of handle (source, target, or both)
  final HandleType type;

  /// Size of the handle
  final double size;

  /// Default color of the handle
  final Color color;

  /// Border color of the handle
  final Color borderColor;

  /// Color when hovered or active
  final Color hoverColor;

  /// Whether this handle can accept connections
  final bool isConnectable;

  /// Custom validation function for connections
  final bool Function(String sourceNodeId, String sourceHandleId,
      String targetNodeId, String targetHandleId)? onValidateConnection;

  /// Callback when connection is attempted
  final void Function(String sourceNodeId, String sourceHandleId,
      String targetNodeId, String targetHandleId)? onConnect;

  const Handle({
    super.key,
    required this.nodeId,
    required this.id,
    required this.position,
    this.type = HandleType.both,
    this.size = 12.0,
    this.color = Colors.white,
    this.borderColor = Colors.grey,
    this.hoverColor = Colors.blue,
    this.isConnectable = true,
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
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Register handle after widget is built
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

  /// Get alignment based on handle position
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

  /// Get offset to position handle outside node bounds
  Offset _getOffset() {
    const double offset = 6.0;
    switch (widget.position) {
      case HandlePosition.top:
        return const Offset(0, -offset);
      case HandlePosition.right:
        return const Offset(offset, 0);
      case HandlePosition.bottom:
        return const Offset(0, offset);
      case HandlePosition.left:
        return const Offset(-offset, 0);
    }
  }

  /// Handle pan start - begin connection
  void _onPanStart(DragStartDetails details) {
    if (!widget.isConnectable) return;

    final controller = ref.read(flowControllerProvider);
    controller.startConnection(
        widget.nodeId, widget.id, details.globalPosition);
    setState(() => _isConnecting = true);
    _animationController.forward();
  }

  /// Handle pan end - complete connection
  void _onPanEnd(DragEndDetails details) {
    setState(() => _isConnecting = false);
    _animationController.reverse();
  }

  /// Get icon based on handle type
  IconData _getHandleIcon() {
    switch (widget.type) {
      case HandleType.source:
        return Icons.arrow_forward_rounded;
      case HandleType.target:
        return Icons.arrow_back_rounded;
      case HandleType.both:
        return Icons.circle;
    }
  }

  /// Get icon color based on state
  Color _getIconColor(bool isTargeted, bool isNodeSelected) {
    if (isTargeted) return Colors.white;
    if (_isHovered || _isConnecting) return Colors.white;
    if (isNodeSelected) return Colors.white;
    return Colors.grey.shade600;
  }

  /// Get handle color based on state
  Color _getHandleColor(bool isTargeted) {
    if (isTargeted) return Colors.green;
    if (_isHovered || _isConnecting) return widget.hoverColor;
    return widget.color;
  }

  /// Get border color based on state
  Color _getBorderColor(bool isTargeted, bool isNodeSelected) {
    if (isTargeted) return Colors.green;
    if (_isHovered || _isConnecting) return widget.hoverColor;
    if (isNodeSelected) return Colors.blue;
    return widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(flowControllerProvider);

    // Check if this handle is being targeted during connection
    final isTargeted = controller.connection?.hoveredTargetKey ==
        '${widget.nodeId}/${widget.id}';

    // Check if parent node is selected
    final isNodeSelected = controller.selectedNodes.contains(widget.nodeId);

    return Transform.translate(
      offset: _getOffset(),
      child: Align(
        alignment: _getAlignment(),
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _animationController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            if (!_isConnecting) {
              _animationController.reverse();
            }
          },
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanEnd: _onPanEnd,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    key: _key,
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: _getHandleColor(isTargeted),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getBorderColor(isTargeted, isNodeSelected),
                        width: 2.0,
                      ),
                      boxShadow: (_isHovered || _isConnecting || isTargeted)
                          ? [
                              BoxShadow(
                                color:
                                    _getHandleColor(isTargeted).withAlpha(100),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: widget.isConnectable
                        ? Icon(
                            _getHandleIcon(),
                            size: widget.size * 0.6,
                            color: _getIconColor(isTargeted, isNodeSelected),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

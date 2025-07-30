import 'package:flutter/material.dart';
import 'package:flutter_flow_canvas/flutter_flow_canvas.dart';

class ExampleNodeData extends NodeData {
  final String label;
  final IconData? icon;
  final Color? color;

  ExampleNodeData({
    required this.label,
    this.icon,
    this.color,
  });
}

class ExampleNode extends StatefulWidget {
  final ExampleNodeData data;
  final FlowNode node;

  const ExampleNode({
    super.key,
    required this.data,
    required this.node,
  });

  @override
  State<ExampleNode> createState() => _ExampleNodeState();
}

class _ExampleNodeState extends State<ExampleNode>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
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
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodeColor = widget.data.color ?? Colors.white;
    final isSelected = widget.node.isSelected;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.node.size.width,
              height: widget.node.size.height,
              decoration: BoxDecoration(
                color: nodeColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue
                      : (_isHovered
                          ? Colors.blue.shade300
                          : Colors.grey.shade300),
                  width: isSelected ? 3.0 : (_isHovered ? 2.0 : 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Colors.blue.withAlpha(75)
                        : Colors.black.withAlpha(_isHovered ? 25 : 15),
                    blurRadius: isSelected ? 15 : (_isHovered ? 12 : 8),
                    offset: Offset(0, isSelected ? 6 : (_isHovered ? 4 : 2)),
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.data.icon != null) ...[
                          Icon(
                            widget.data.icon,
                            size: 24,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          widget.data.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Connection handles
                  Handle(
                    nodeId: widget.node.id,
                    id: 'input',
                    position: HandlePosition.left,
                    type: HandleType.target,
                    color: Colors.grey.shade100,
                    borderColor: Colors.grey.shade400,
                    hoverColor: Colors.green,
                  ),

                  Handle(
                    nodeId: widget.node.id,
                    id: 'output',
                    position: HandlePosition.right,
                    type: HandleType.source,
                    color: Colors.grey.shade100,
                    borderColor: Colors.grey.shade400,
                    hoverColor: Colors.blue,
                  ),

                  Handle(
                    nodeId: widget.node.id,
                    id: 'top',
                    position: HandlePosition.top,
                    type: HandleType.both,
                    size: 10,
                    color: Colors.grey.shade100,
                    borderColor: Colors.grey.shade400,
                    hoverColor: Colors.orange,
                  ),

                  Handle(
                    nodeId: widget.node.id,
                    id: 'bottom',
                    position: HandlePosition.bottom,
                    type: HandleType.both,
                    size: 10,
                    color: Colors.grey.shade100,
                    borderColor: Colors.grey.shade400,
                    hoverColor: Colors.orange,
                  ),

                  // Selection indicator
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                  // Resize handle (bottom-right corner)
                  if (isSelected)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Icon(
                          Icons.drag_handle,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

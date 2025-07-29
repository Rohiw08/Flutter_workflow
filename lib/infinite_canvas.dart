import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/models/flow_edge.dart';
import 'package:flutter_workflow/models/flow_node.dart';
import 'package:flutter_workflow/providers/canvas_provider.dart';
import 'package:flutter_workflow/providers/connection_state_provider.dart';
import 'package:flutter_workflow/providers/edge_provider.dart';
import 'package:flutter_workflow/providers/handle_registory_provider.dart';
import 'package:flutter_workflow/providers/node_providers.dart';
import 'package:flutter_workflow/widgets/background/background.dart';
import 'package:flutter_workflow/widgets/controls/controls.dart';
import 'package:flutter_workflow/widgets/edges/edges.dart';
// ... other imports
import 'package:flutter_workflow/widgets/nodes/default_node_widget.dart';
import 'package:flutter_workflow/widgets/nodes/node_container.dart';

class FlowCanvas extends ConsumerStatefulWidget {
  const FlowCanvas({super.key});

  @override
  ConsumerState<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends ConsumerState<FlowCanvas> {
  final double canvasSize = 5000;

  // A map to build the correct widget based on a node's 'type' property
  static final Map<String, Widget Function(FlowNode node)> _nodeTypeBuilder = {
    'default': (node) => DefaultNodeWidget(node: node),
    // Add other node types here, e.g. 'custom': (node) => MyCustomNode(...)
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Center the view
      ref.read(transformationControllerProvider).value = Matrix4.identity()
        ..translate(-canvasSize / 2, -canvasSize / 2);

      // Initialize with some default nodes
      final initialNodes = [
        FlowNode(
          id: 'node-1',
          position: Offset(canvasSize / 2 - 250, canvasSize / 2),
          data: NodeData(label: 'Drag Me'),
        ),
        FlowNode(
          id: 'node-2',
          position: Offset(canvasSize / 2 + 50, canvasSize / 2 + 50),
          data: NodeData(label: 'Connect To Me'),
        ),
      ];
      ref.read(nodesProvider.notifier).initNodes(initialNodes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transformationController = ref.watch(
      transformationControllerProvider,
    );
    final isInteractive = ref.watch(isInteractiveProvider);
    final nodes = ref.watch(nodesProvider); // Watch the list of nodes

    return Scaffold(
      body: Listener(
        onPointerMove: (details) {
          ref.read(connectionStateProvider.notifier).update((state) {
            if (state == null) return null;
            state.endPosition = details.position;
            final handleRegistry = ref.read(handleRegistryProvider);
            String? hoveredKey;
            for (final entry in handleRegistry.entries) {
              final renderBox = entry.value.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null &&
                  renderBox.size.contains(
                    renderBox.globalToLocal(details.position),
                  )) {
                hoveredKey = entry.key;
                break;
              }
            }
            state.hoveredTargetKey = hoveredKey;
            return state;
          });
        },
        onPointerUp: (details) {
          final connection = ref.read(connectionStateProvider);
          if (connection?.hoveredTargetKey != null) {
            final targetKeyParts = connection!.hoveredTargetKey!.split('/');
            final newEdge = Edge(
              id: 'e${Random().nextInt(9999)}',
              sourceNodeId: connection.fromNodeId,
              sourceHandleId: connection.fromHandleId,
              targetNodeId: targetKeyParts[0],
              targetHandleId: targetKeyParts[1].isEmpty ? null : targetKeyParts[1],
            );
            ref.read(edgesProvider.notifier).addEdge(newEdge);
          }
          ref.read(connectionStateProvider.notifier).state = null;
        },
        child: Stack(
          children: [
            InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 5.0,
              transformationController: transformationController,
              panEnabled: isInteractive,
              scaleEnabled: isInteractive,
              child: SizedBox(
                width: canvasSize,
                height: canvasSize,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: InfiniteGridPainter(
                        variant: BackgroundVariant.dots,
                        gap: 30,
                      ),
                      size: Size.infinite,
                    ),
                    CustomPaint(
                      painter: EdgePainter(
                        edges: ref.watch(edgesProvider),
                        handleRegistry: ref.watch(handleRegistryProvider),
                        connectionState: ref.watch(connectionStateProvider),
                        matrix: transformationController.value,
                      ),
                      size: Size.infinite,
                    ),
                    ...nodes.map((node) {
                      final nodeBuilder =
                          _nodeTypeBuilder[node.type] ??
                          _nodeTypeBuilder['default']!;
                      return NodeContainer(
                        key: ValueKey(node.id),
                        node: node,
                        child: nodeBuilder(node),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const Controls(position: PanelPosition.bottomLeft),
          ],
        ),
      ),
    );
  }}
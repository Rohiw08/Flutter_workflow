class Edge {
  final String id;
  final String sourceNodeId;
  final String? sourceHandleId;
  final String targetNodeId;
  final String? targetHandleId;

  Edge({
    required this.id,
    required this.sourceNodeId,
    this.sourceHandleId,
    required this.targetNodeId,
    this.targetHandleId,
  });
}
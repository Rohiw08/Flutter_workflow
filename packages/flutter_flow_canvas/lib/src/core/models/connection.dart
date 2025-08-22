class Connection {
  final String sourceNodeId;
  final String sourceHandleId;
  final String targetNodeId;
  final String targetHandleId;

  const Connection({
    required this.sourceNodeId,
    required this.sourceHandleId,
    required this.targetNodeId,
    required this.targetHandleId,
  });
}

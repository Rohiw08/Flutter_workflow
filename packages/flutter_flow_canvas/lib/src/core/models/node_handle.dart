import 'dart:ui';
import '../enums.dart';

class NodeHandle {
  final String id;
  final HandleType type;
  final Offset position;
  final bool isConnectable;

  NodeHandle({
    required this.id,
    required this.type,
    required this.position,
    this.isConnectable = true,
  });
}

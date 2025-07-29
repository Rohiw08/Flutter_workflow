import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/models/flow_edge.dart';

class EdgesNotifier extends StateNotifier<List<Edge>> {
  EdgesNotifier(super.initialNodes);

  void addEdge(Edge edge) {
    state = [...state, edge];
  }

  void removeEdge(String edgeId) {
    state = state.where((edge) => edge.id != edgeId).toList();
  }

  void updateEdge(String edgeId, Edge updatedEdge) {
    state = [
      for (final edge in state)
        if (edge.id == edgeId) updatedEdge else edge,
    ];
  }
}

final edgesProvider = StateNotifierProvider<EdgesNotifier, List<Edge>>((ref) {
  return EdgesNotifier([]);
});
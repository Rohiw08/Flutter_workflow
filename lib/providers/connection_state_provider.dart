import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_workflow/models/connection_state.dart';

final connectionStateProvider = StateProvider<ConnectionState?>((ref) => null);
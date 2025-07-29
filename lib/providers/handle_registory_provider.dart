import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final handleRegistryProvider = StateProvider<Map<String, GlobalKey>>((ref) => {});
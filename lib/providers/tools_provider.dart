import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tern/core/di/service_locator.dart';

class ToolsState {
  final Set<String> disabledTools;
  final Map<String, int> callCounts;

  const ToolsState({this.disabledTools = const {}, this.callCounts = const {}});

  ToolsState copyWith({Set<String>? disabledTools, Map<String, int>? callCounts}) =>
      ToolsState(disabledTools: disabledTools ?? this.disabledTools,
          callCounts: callCounts ?? this.callCounts);

  bool isEnabled(String name) => !disabledTools.contains(name);
}

class ToolsNotifier extends StateNotifier<ToolsState> {
  ToolsNotifier() : super(const ToolsState());

  void toggleTool(String name) {
    final updated = Set<String>.from(state.disabledTools);
    if (updated.contains(name)) {
      updated.remove(name);
      ServiceLocator.toolRegistry.enable(name);
    } else {
      updated.add(name);
      ServiceLocator.toolRegistry.disable(name);
    }
    state = state.copyWith(disabledTools: updated);
  }

  bool isEnabled(String name) => !state.disabledTools.contains(name);
  bool isDisabled(String name) => state.disabledTools.contains(name);
}

final toolsProvider = StateNotifierProvider<ToolsNotifier, ToolsState>((ref) => ToolsNotifier());

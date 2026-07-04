import "dart:async";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../agent/agent_state.dart';
import '../core/di/service_locator.dart';

class AgentProviderState {
  final AgentState state;
  final String? currentTool;
  final int steps;
  final List<String> toolLog;

  const AgentProviderState({
    this.state = AgentState.idle,
    this.currentTool,
    this.steps = 0,
    this.toolLog = const [],
  });

  AgentProviderState copyWith({
    AgentState? state, String? currentTool, int? steps, List<String>? toolLog,
  }) => AgentProviderState(
    state: state ?? this.state,
    currentTool: currentTool ?? this.currentTool,
    steps: steps ?? this.steps,
    toolLog: toolLog ?? this.toolLog,
  );

  bool get isRunning => state.isRunning;
  bool get isIdle => state.isIdle;
}

class AgentProvider extends StateNotifier<AgentProviderState> {
  StreamSubscription? _stateSub;
  StreamSubscription? _toolSub;

  AgentProvider() : super(const AgentProviderState());

  void start() {
    final agent = ServiceLocator.agentController;
    state = const AgentProviderState(state: AgentState.thinking);

    _stateSub?.cancel();
    _stateSub = agent.stateStream.listen((s) {
      state = state.copyWith(state: s);
    });

    _toolSub?.cancel();
    _toolSub = agent.toolCallStream.listen((tool) {
      final name = tool['name'] as String? ?? 'unknown';
      state = state.copyWith(
        currentTool: name,
        steps: state.steps + 1,
        toolLog: [...state.toolLog, '$name(${tool['args']})'],
      );
    });
  }

  void stop() {
    _stateSub?.cancel();
    _toolSub?.cancel();
    ServiceLocator.agentController.stop();
    state = state.copyWith(state: AgentState.stopped);
  }

  void reset() {
    _stateSub?.cancel();
    _toolSub?.cancel();
    state = const AgentProviderState();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _toolSub?.cancel();
    super.dispose();
  }
}

final agentProvider = StateNotifierProvider<AgentProvider, AgentProviderState>((ref) => AgentProvider());

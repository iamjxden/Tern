import 'dart:async';
import 'package:tern/models/message.dart';
import 'agent_loop.dart';
import 'agent_state.dart';

class AgentController {
  final AgentLoop agentLoop;
  bool _running = false;
  StreamSubscription<AgentState>? _stateSub;
  StreamSubscription<String>? _outputSub;
  StreamSubscription<Map<String, dynamic>>? _toolSub;

  AgentController({required this.agentLoop});

  bool get isRunning => _running;

  void setModel(String modelId) => agentLoop.setModel(modelId);
  void setMaxSteps(int steps) => agentLoop.setMaxSteps(steps);

  Stream<AgentState> get stateStream => agentLoop.stateStream;
  Stream<String> get outputStream => agentLoop.outputStream;
  Stream<Map<String, dynamic>> get toolCallStream => agentLoop.toolCallStream;
  AgentState get state => agentLoop.state;
  int get stepCount => agentLoop.stepCount;

  Future<void> start(List<Message> messages) async {
    if (_running) return;
    _running = true;
    try {
      await agentLoop.run(messages);
    } finally {
      _running = false;
    }
  }

  void stop() {
    agentLoop.interrupt();
    _running = false;
  }

  void listen({
    void Function(AgentState state)? onState,
    void Function(String chunk)? onOutput,
    void Function(Map<String, dynamic> toolCall)? onToolCall,
  }) {
    _stateSub?.cancel();
    _stateSub = agentLoop.stateStream.listen(onState);
    _outputSub?.cancel();
    _outputSub = agentLoop.outputStream.listen(onOutput);
    _toolSub?.cancel();
    _toolSub = agentLoop.toolCallStream.listen(onToolCall);
  }

  void dispose() {
    _stateSub?.cancel();
    _outputSub?.cancel();
    _toolSub?.cancel();
    agentLoop.dispose();
  }
}

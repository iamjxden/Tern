import 'dart:async';
import 'dart:convert';
import 'package:tern/models/message.dart';
import 'package:tern/config/app_config.dart';
import 'package:tern/core/logger/humannode_logger.dart';
import 'package:tern/core/extensions/string_ext.dart';
import 'package:tern/inference/ollama_inference_engine.dart';
import 'package:tern/inference/ollama_client.dart';
import 'agent_state.dart';
import 'agent_memory.dart';
import 'ollama_prompt_builder.dart';
import 'tool_call_parser.dart';
import 'tools/tool_registry.dart';
import 'tools/tool_result.dart';
import 'reflexion.dart';
import 'nudge.dart';

class AgentLoop {
  final OllamaInferenceEngine inferenceEngine;
  final ToolRegistry toolRegistry;
  final AgentMemory agentMemory;
  final OllamaPromptBuilder promptBuilder;
  final Reflexion reflexion = Reflexion();
  final Nudge nudge = Nudge();

  final _stateController = StreamController<AgentState>.broadcast();
  final _outputController = StreamController<String>.broadcast();
  final _toolCallController = StreamController<Map<String, dynamic>>.broadcast();

  AgentState _state = AgentState.idle;
  bool _interruptRequested = false;
  String _modelId = '';
  int _stepCount = 0;
  int _maxSteps = AppConfig.maxAgentSteps;

  AgentLoop({
    required this.inferenceEngine,
    required this.toolRegistry,
    required this.agentMemory,
    required this.promptBuilder,
  });

  Stream<AgentState> get stateStream => _stateController.stream;
  Stream<String> get outputStream => _outputController.stream;
  Stream<Map<String, dynamic>> get toolCallStream => _toolCallController.stream;
  AgentState get state => _state;
  int get stepCount => _stepCount;

  void setModel(String modelId) => _modelId = modelId;
  void setMaxSteps(int steps) => _maxSteps = steps;

  Future<void> run(List<Message> messages) async {
    if (_modelId.isEmpty) {
      _emit('No model selected. Please install and select a model from the Models screen.');
      _setState(AgentState.errored);
      return;
    }

    _interruptRequested = false;
    reflexion.reset();
    nudge.reset();
    toolRegistry.resetCallCounts();
    _stepCount = 0;
    _setState(AgentState.thinking);

    final history = messages
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    try {
      await promptBuilder.loadPrompts();
      final systemMessage = await promptBuilder.buildSystemMessage(agentMode: true);

      List<OllamaChatMessage> ollamaMessages = promptBuilder.buildMessages(
        systemMessage: systemMessage,
        history: history,
      );

      while (!_interruptRequested && _stepCount < _maxSteps) {
        _setState(AgentState.thinking);

        final rawResponse = await _generate(ollamaMessages);
        if (_interruptRequested) break;
        if (rawResponse == null) {
          _setState(AgentState.errored);
          break;
        }

        final parsed = ToolCallParser.parse(rawResponse);

        if (!parsed.hasToolCall) {
          final displayText = ToolCallParser.sanitizeForDisplay(parsed.finalText);
          if (displayText.isNotEmpty) {
            _emit(displayText);
          }
          agentMemory.add(Message.assistant(displayText));
          _setState(AgentState.idle);
          return;
        }

        final toolCall = parsed.toolCall!;
        _setState(AgentState.acting);

        if (!_toolCallController.isClosed) {
          _toolCallController.add({'name': toolCall.name, 'args': toolCall.args});
        }

        final result = await toolRegistry.execute(toolCall.name, toolCall.args);

        final resultStr = switch (result) {
          ToolSuccess<String>(data: final d) => d,
          ToolFailure(error: final e, detail: final d) =>
            d != null && d.isNotEmpty ? '$e: $d' : e,
          ToolSuccess(data: final d) => d.toString(),
        };

        agentMemory.add(Message.toolResult(name: toolCall.name, result: resultStr));

        ollamaMessages = [
          ...ollamaMessages,
          OllamaChatMessage(role: 'assistant', content: rawResponse),
          promptBuilder.buildToolResultMessage(toolCall.name, resultStr),
        ];

        if (result is ToolFailure && reflexion.canRetry) {
          final correction = reflexion.correct(
            resultStr,
            jsonEncode({'name': toolCall.name, 'args': toolCall.args}),
          );
          ollamaMessages = [
            ...ollamaMessages,
            OllamaChatMessage(role: 'user', content: correction),
          ];
        }

        _stepCount++;
      }

      if (_interruptRequested) {
        _setState(AgentState.interrupted);
        _emit('\n[Stopped]');
      } else if (_stepCount >= _maxSteps) {
        _setState(AgentState.stopped);
        _emit('\n[Maximum agent steps reached]');
      }
    } catch (e, st) {
      HumanNodeLogger.error('Agent loop crashed', e, st);
      _setState(AgentState.errored);
      _emit('\n[Error: ${e.toString().truncate(200)}]');
    }
  }

  Future<String?> _generate(List<OllamaChatMessage> messages) async {
    final buffer = StringBuffer();
    try {
      final stream = inferenceEngine.generateStream(
        modelId: _modelId,
        messages: messages,
        temperature: AppConfig.defaultTemperature,
        topP: AppConfig.defaultTopP,
        maxTokens: AppConfig.defaultMaxTokens,
      );
      await for (final chunk in stream) {
        if (_interruptRequested) break;
        buffer.write(chunk);
      }
    } catch (e) {
      HumanNodeLogger.error('Inference error in agent loop', e);
      _emit('\n[Inference error: $e]');
      return null;
    }
    return buffer.toString();
  }

  void _emit(String text) {
    if (!_outputController.isClosed) _outputController.add(text);
  }

  void _setState(AgentState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) _stateController.add(newState);
  }

  void interrupt() {
    _interruptRequested = true;
    inferenceEngine.stop();
  }

  void dispose() {
    _stateController.close();
    _outputController.close();
    _toolCallController.close();
  }
}

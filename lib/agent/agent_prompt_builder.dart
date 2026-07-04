import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../config/environment.dart';
import 'tools/tool_registry.dart';
import 'agent_memory.dart';

class AgentPromptBuilder {
  final ToolRegistry toolRegistry;
  final AgentMemory agentMemory;
  String _defaultPrompt = '';
  String _agentPrompt = '';
  String _currentSystemPrompt = '';

  AgentPromptBuilder({required this.toolRegistry, required this.agentMemory});

  Future<void> loadDefaultPrompt() async {
    try {
      _defaultPrompt =
          await rootBundle.loadString(AppConfig.defaultSystemPromptAsset);
    } catch (_) {}

    try {
      _agentPrompt =
          await rootBundle.loadString(AppConfig.agentSystemPromptAsset);
    } catch (_) {}

    if (_defaultPrompt.isEmpty) {
      _defaultPrompt =
          'You are Tern, an AI assistant made by Aetheron, a helpful AI assistant running locally on mobile. '
          'You are concise, direct, and privacy-conscious. '
          'You help with reasoning, coding, writing, and analysis. '
          'You have access to tools to complete tasks. Use them when needed.';
    }

    if (_agentPrompt.isEmpty) {
      _agentPrompt =
          'You are Tern in AGENTIC MODE. You have access to tools. '
          'Think step by step. Use tools by outputting <tool_call>{"name":"...","args":{...}}</tool_call>. '
          'When finished, output <final_answer> with your response. '
          'One tool call per turn. Be persistent.';
    }

    _currentSystemPrompt = _defaultPrompt;
  }

  void setSystemPrompt(String prompt) => _currentSystemPrompt = prompt;
  void resetToDefault() => _currentSystemPrompt = _defaultPrompt;

  Future<String> build({
    required List<Map<String, String>> messages,
    bool agentMode = false,
    String? customSystemPrompt,
  }) async {
    final systemPrompt = customSystemPrompt ?? _currentSystemPrompt;
    final buffer = StringBuffer();

    buffer.writeln('<system>');
    buffer.writeln(systemPrompt);
    buffer.writeln();
    if (Env.enableDebugScreen) {
      final now = DateTime.now();
      buffer.writeln('Current date: ${now.toIso8601String().substring(0, 10)}');
      buffer.writeln('Current time: ${now.toIso8601String().substring(11, 19)}');
      buffer.writeln('Timezone: UTC');
    }
    buffer.writeln('</system>');
    buffer.writeln();

    if (agentMode) {
      buffer.writeln('<agent_mode>');
      buffer.writeln(
          'You are operating in agentic mode with access to tools.');
      buffer.writeln(
          'TOOL CALL FORMAT: <tool_call>{"name":"tool_name","args":{"key":"value"}}</tool_call>');
      buffer.writeln(
          'When all tasks are done, simply respond with your answer.');
      buffer.writeln('You may call tools multiple times in sequence.');
      buffer.writeln(
          'If a tool returns an error, analyze it and try to correct your approach.');
      buffer.writeln('</agent_mode>');
      buffer.writeln();

      buffer.writeln(toolRegistry.getToolSchemasXml());
      buffer.writeln();

      final memorySection = await agentMemory.buildMemorySection();
      if (memorySection.isNotEmpty) {
        buffer.writeln(memorySection);
        buffer.writeln();
      }
    }

    if (messages.isNotEmpty) {
      buffer.writeln('<conversation>');
      for (final msg in messages) {
        final role = msg['role'] ?? 'unknown';
        final content = msg['content'] ?? '';
        final truncatedContent =
            agentMode && content.length > 2000
                ? '${content.substring(0, 2000)}...'
                : content;
        buffer.writeln('  <$role>$truncatedContent</$role>');
      }
      buffer.writeln('</conversation>');
    }

    buffer.writeln();
    buffer.writeln('<assistant>');
    return buffer.toString();
  }

  String buildContinuation(String toolResult) {
    final buffer = StringBuffer();
    buffer.writeln();
    buffer.writeln('<tool_result>');
    final truncated = toolResult.length > AppConfig.maxToolOutputLength
        ? '${toolResult.substring(0, AppConfig.maxToolOutputLength)}\n[output truncated]'
        : toolResult;
    buffer.writeln(truncated);
    buffer.writeln('</tool_result>');
    buffer.writeln();
    buffer.writeln(
        'Continue based on the tool result above. '
        'If it succeeded, proceed with your task. '
        'If it failed, analyze the error and try a different approach. '
        'If the task is complete, provide your final answer.');
    buffer.writeln();
    buffer.writeln('<assistant>');
    return buffer.toString();
  }
}

import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../inference/ollama_client.dart';
import 'tools/tool_registry.dart';
import 'agent_memory.dart';

/// Builds a proper Ollama chat message list instead of flattening
/// everything into one giant XML-tagged string. This is what the old
/// AgentPromptBuilder did, and it was the cause of raw system-prompt
/// tags leaking directly into the chat UI: the mock engine echoed the
/// prompt back verbatim, and there was nothing to strip because the
/// "prompt" and the "message" were the same string.
///
/// Ollama's /api/chat takes a real messages array, so the system
/// prompt, tool schema and memory live in a dedicated `system` message
/// that is never rendered in the UI - only `user` and `assistant`
/// messages are ever shown to the person.
class OllamaPromptBuilder {
  final ToolRegistry toolRegistry;
  final AgentMemory agentMemory;
  String _basePrompt = '';
  String _agentPrompt = '';

  OllamaPromptBuilder({required this.toolRegistry, required this.agentMemory});

  Future<void> loadPrompts() async {
    try {
      _basePrompt = await rootBundle.loadString(AppConfig.defaultSystemPromptAsset);
    } catch (_) {
      _basePrompt = _fallbackBasePrompt;
    }
    try {
      _agentPrompt = await rootBundle.loadString(AppConfig.agentSystemPromptAsset);
    } catch (_) {
      _agentPrompt = _fallbackAgentPrompt;
    }
    if (_basePrompt.trim().isEmpty) _basePrompt = _fallbackBasePrompt;
    if (_agentPrompt.trim().isEmpty) _agentPrompt = _fallbackAgentPrompt;
  }

  static const String _fallbackBasePrompt =
      'You are Tern, an AI assistant made by Aetheron. '
      'You are clear, direct and helpful. You help with reasoning, '
      'coding, writing and analysis.';

  static const String _fallbackAgentPrompt =
      'You can use tools to complete tasks. To call a tool, respond with '
      'ONLY a single line of JSON in this exact shape and nothing else: '
      '{"tool_call":{"name":"tool_name","args":{"key":"value"}}}. '
      'Never invent a tool name that is not in the tool list below. '
      'Once you have everything you need, respond normally in plain text '
      'with your final answer - do not wrap it in any tags.';

  Future<String> buildSystemMessage({
    required bool agentMode,
    String? customInstructions,
    String? projectInstructions,
  }) async {
    if (_basePrompt.isEmpty) await loadPrompts();

    final parts = <String>[_basePrompt];

    if (customInstructions != null && customInstructions.trim().isNotEmpty) {
      parts.add(customInstructions.trim());
    }
    if (projectInstructions != null && projectInstructions.trim().isNotEmpty) {
      parts.add('Project instructions: ${projectInstructions.trim()}');
    }

    if (agentMode) {
      parts.add(_agentPrompt);
      final tools = toolRegistry.getToolSchemasJson();
      if (tools.isNotEmpty) {
        parts.add('Available tools:\n$tools');
      }
      final memorySection = await agentMemory.buildMemorySection();
      if (memorySection.trim().isNotEmpty) {
        parts.add(memorySection.trim());
      }
    }

    return parts.join('\n\n');
  }

  List<OllamaChatMessage> buildMessages({
    required String systemMessage,
    required List<Map<String, String>> history,
  }) {
    final messages = <OllamaChatMessage>[
      OllamaChatMessage(role: 'system', content: systemMessage),
    ];

    for (final msg in history) {
      final role = msg['role'] ?? 'user';
      final content = msg['content'] ?? '';
      if (content.trim().isEmpty) continue;
      // Only ever forward user/assistant turns - tool results are
      // injected as a normal user-role message with a clear label so
      // the model can see them, but they are never displayed as-is.
      final ollamaRole = (role == 'assistant') ? 'assistant' : 'user';
      messages.add(OllamaChatMessage(role: ollamaRole, content: content));
    }

    return messages;
  }

  OllamaChatMessage buildToolResultMessage(String toolName, String result) {
    final truncated = result.length > AppConfig.maxToolOutputLength
        ? '${result.substring(0, AppConfig.maxToolOutputLength)}\n[output truncated]'
        : result;
    return OllamaChatMessage(
      role: 'user',
      content: 'Tool "$toolName" returned:\n$truncated\n\n'
          'Continue the task. If it succeeded, proceed. If it failed, try a '
          'different approach. If you are done, give your final answer in '
          'plain text.',
    );
  }
}

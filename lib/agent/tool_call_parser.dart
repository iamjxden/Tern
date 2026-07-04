import 'dart:convert';

class ParsedToolCall {
  final String name;
  final Map<String, dynamic> args;

  const ParsedToolCall({required this.name, required this.args});
}

class ToolCallParseResult {
  final ParsedToolCall? toolCall;
  final String finalText;

  const ToolCallParseResult({this.toolCall, required this.finalText});

  bool get hasToolCall => toolCall != null;
}

/// Strictly extracts a `{"tool_call": {...}}` JSON object from a model
/// response. Unlike the old approach (regex over flattened XML), this
/// only recognises a tool call if it is valid, well-formed JSON with a
/// `name` field that is non-empty - so prompt instructions or example
/// text can never be mistaken for a real call, which is what produced
/// the "Unknown tool: tool_name" loop in the old build.
class ToolCallParser {
  static final RegExp _jsonBlock = RegExp(r'\{[\s\S]*\}');

  static ToolCallParseResult parse(String response) {
    final trimmed = response.trim();
    if (trimmed.isEmpty) {
      return const ToolCallParseResult(finalText: '');
    }

    final match = _jsonBlock.firstMatch(trimmed);
    if (match == null) {
      return ToolCallParseResult(finalText: trimmed);
    }

    final candidate = match.group(0)!;
    try {
      final decoded = jsonDecode(candidate);
      if (decoded is! Map<String, dynamic>) {
        return ToolCallParseResult(finalText: trimmed);
      }

      final callBlock = decoded['tool_call'];
      if (callBlock is! Map<String, dynamic>) {
        return ToolCallParseResult(finalText: trimmed);
      }

      final name = callBlock['name'];
      if (name is! String || name.trim().isEmpty) {
        return ToolCallParseResult(finalText: trimmed);
      }

      final rawArgs = callBlock['args'];
      final args = (rawArgs is Map<String, dynamic>)
          ? rawArgs
          : <String, dynamic>{};

      return ToolCallParseResult(
        toolCall: ParsedToolCall(name: name.trim(), args: args),
        finalText: '',
      );
    } catch (_) {
      return ToolCallParseResult(finalText: trimmed);
    }
  }

  /// Removes any stray JSON tool-call blocks or leftover prompt
  /// scaffolding from text before it is shown to the user, as a last
  /// line of defence against leakage.
  static String sanitizeForDisplay(String text) {
    var cleaned = text;
    cleaned = cleaned.replaceAll(RegExp(r'<[a-z_]+>|</[a-z_]+>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\{"tool_call":[\s\S]*?\}\}'), '');
    return cleaned.trim();
  }
}

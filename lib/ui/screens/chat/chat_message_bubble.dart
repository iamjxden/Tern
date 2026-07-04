import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tern/config/theme.dart';
import 'package:tern/models/message.dart';

String _sanitize(String raw) {
  // Strip XML-style system/agent tags the model leaks into output
  final tags = [
    'system', 'agent_mode', 'available_tools', 'session_memory',
    'recent_messages', 'msg', 'tool_result', 'tool_call',
  ];
  var text = raw;
  for (final tag in tags) {
    text = text.replaceAll(RegExp('<$tag[^>]*>', caseSensitive: false), '');
    text = text.replaceAll(RegExp('</$tag>', caseSensitive: false), '');
  }
  // Strip inline tool_call JSON blocks
  text = text.replaceAll(
      RegExp(r'<tool_call>\{.*?\}</tool_call>', dotAll: true, caseSensitive: false), '');
  // Remove leftover blank lines (more than 2 in a row)
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) return const SizedBox.shrink();
    if (message.isToolResult) return _ToolResultBubble(message: message);
    return message.isUser
        ? _UserBubble(message: message)
        : _AssistantBubble(message: message);
  }
}

class _UserBubble extends StatelessWidget {
  final Message message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Copied'),
                  duration: Duration(seconds: 1)),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                    color: HumanNodeTheme.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final Message message;
  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final display = _sanitize(message.content);
    if (display.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 48, bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 8, top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF818CF8), Color(0xFF4338CA)],
            ),
            boxShadow: [
              BoxShadow(
                  color: HumanNodeTheme.primary.withAlpha(80),
                  blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.travel_explore_rounded,
              color: Colors.white, size: 14),
        ),
        Flexible(
          child: GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Copied'),
                    duration: Duration(seconds: 1)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HumanNodeTheme.surfaceCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                    color: HumanNodeTheme.border, width: 0.5),
              ),
              child: MarkdownBody(
                data: display,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontSize: 14,
                      height: 1.6),
                  code: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFF818CF8),
                    backgroundColor: Color(0xFF1E1B4B),
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: HumanNodeTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: HumanNodeTheme.border, width: 0.5),
                  ),
                  h1: const TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontWeight: FontWeight.w700),
                  h2: const TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontWeight: FontWeight.w700),
                  h3: const TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontWeight: FontWeight.w600),
                  strong: const TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontWeight: FontWeight.w700),
                  em: const TextStyle(
                      color: HumanNodeTheme.textSecondary,
                      fontStyle: FontStyle.italic),
                  listBullet: const TextStyle(
                      color: HumanNodeTheme.primary),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ToolResultBubble extends StatelessWidget {
  final Message message;
  const _ToolResultBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1A0C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF166534), width: 0.5),
        ),
        child: Row(children: [
          const Icon(Icons.build_circle_rounded,
              size: 14, color: Color(0xFF22C55E)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.content.length > 120
                  ? '${message.content.substring(0, 120)}...'
                  : message.content,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF86EFAC)),
            ),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChatToolCallCard extends StatelessWidget {
  final String toolName;
  final Map<String, dynamic> args;
  final String? result;
  final bool isRunning;

  const ChatToolCallCard({super.key, required this.toolName, this.args = const {}, this.result, this.isRunning = false});

  static const _icons = {
    'web_search': Icons.search,
    'calculator': Icons.calculate,
    'datetime': Icons.schedule,
    'bash': Icons.terminal,
    'file_read': Icons.description,
    'file_write': Icons.edit_note,
    'fetch_url': Icons.link,
    'note_create': Icons.note_add,
    'note_search': Icons.find_in_page,
    'summary': Icons.summarize,
    'memory': Icons.memory,
  };

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = _icons[toolName] ?? Icons.handyman;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.tertiary.withAlpha(30)),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: cs.tertiary),
        const SizedBox(width: 10),
        Expanded(child: Text(toolName.replaceAll('_', ' '), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        if (isRunning)
          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: cs.tertiary)),
        if (result != null) Icon(Icons.check_circle, size: 16, color: Colors.green),
      ]),
    );
  }
}

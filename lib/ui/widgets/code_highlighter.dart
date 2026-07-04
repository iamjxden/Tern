import 'package:flutter/material.dart';
class CodeHighlighter extends StatelessWidget {
  final String code; final String? language;
  const CodeHighlighter({super.key, required this.code, this.language});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12)),
    child: SelectableText(code,
        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
  );
}

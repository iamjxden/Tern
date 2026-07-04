import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownRenderer extends StatelessWidget {
  final String text;
  final bool selectable;
  const MarkdownRenderer({super.key, required this.text, this.selectable = true});

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MarkdownBody(
      data: text,
      selectable: selectable,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyMedium,
        h1: Theme.of(context).textTheme.headlineMedium,
        h2: Theme.of(context).textTheme.titleLarge,
        h3: Theme.of(context).textTheme.titleMedium,
        code: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, backgroundColor: cs.surfaceContainerHighest),
        codeblockDecoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
        blockquoteDecoration: BoxDecoration(border: Border(left: BorderSide(color: cs.primary, width: 3))),
        blockquote: TextStyle(color: cs.onSurface.withAlpha(180), fontStyle: FontStyle.italic),
        listBullet: TextStyle(color: cs.primary),
        tableHead: TextStyle(fontWeight: FontWeight.w700),
        tableBody: Theme.of(context).textTheme.bodySmall,
        horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outline.withAlpha(40)))),
      ),
    );
  }
}

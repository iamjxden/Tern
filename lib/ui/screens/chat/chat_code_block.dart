import 'package:flutter/material.dart';
import '../../../utils/clipboard_util.dart';

class ChatCodeBlock extends StatefulWidget {
  final String code;
  final String? language;
  const ChatCodeBlock({super.key, required this.code, this.language});
  @override State<ChatCodeBlock> createState() => _ChatCodeBlockState();
}

class _ChatCodeBlockState extends State<ChatCodeBlock> {
  bool _copied = false;

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
          ),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF5F56))),
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFBD2E))),
            const SizedBox(width: 6),
            Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF27C93F))),
            const SizedBox(width: 16),
            Text(widget.language ?? 'code', style: TextStyle(fontSize: 11, fontFamily: 'JetBrainsMono',
                color: Theme.of(context).colorScheme.onSurface.withAlpha(100))),
            const Spacer(),
            InkWell(
              onTap: () {
                ClipboardUtil.copy(widget.code);
                setState(() => _copied = true);
                Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copied = false); });
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_copied ? Icons.check : Icons.copy, size: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
                const SizedBox(width: 4),
                Text(_copied ? 'Copied' : 'Copy', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: SelectableText(
            widget.code,
            style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ]),
    );
  }
}

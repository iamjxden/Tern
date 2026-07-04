import 'package:flutter/material.dart';

class ContextUsageBar extends StatelessWidget {
  final int usedTokens;
  final int maxTokens;
  const ContextUsageBar({super.key, required this.usedTokens, required this.maxTokens});

  @override Widget build(BuildContext context) {
    final ratio = maxTokens > 0 ? (usedTokens / maxTokens).clamp(0.0, 1.0) : 0.0;
    final color = ratio > 0.9 ? Colors.red : ratio > 0.7 ? Colors.orange : Theme.of(context).colorScheme.primary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Context', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withAlpha(100))),
        Text('$usedTokens / $maxTokens', style: const TextStyle(fontSize: 11, fontFamily: 'JetBrainsMono')),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(value: ratio, minHeight: 3,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, color: color),
      ),
    ]);
  }
}

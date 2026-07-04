import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/agent_provider.dart';

class ChatAgentStatusBar extends ConsumerWidget {
  const ChatAgentStatusBar({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final agent = ref.watch(agentProvider);
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: cs.tertiaryContainer.withAlpha(50),
      child: Row(children: [
        SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.tertiary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Agent working... Step ${agent.steps}${agent.currentTool != null ? ' — ${agent.currentTool}' : ''}',
            style: TextStyle(fontSize: 13, color: cs.tertiary, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => ref.read(agentProvider.notifier).stop(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.error.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Stop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.error)),
          ),
        ),
      ]),
    );
  }
}

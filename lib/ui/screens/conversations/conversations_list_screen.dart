import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/conversations_provider.dart';
import '../../../providers/chat_provider.dart';
import 'conversation_tile.dart';

class ConversationsListScreen extends ConsumerStatefulWidget {
  const ConversationsListScreen({super.key});
  @override ConsumerState<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends ConsumerState<ConversationsListScreen> {
  @override void initState() {
    super.initState();
    Future.microtask(() => ref.read(conversationsProvider.notifier).load());
  }

  @override Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);
    final sorted = [...state.conversations]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final pinned = sorted.where((c) => c.pinned).toList();
    final unpinned = sorted.where((c) => !c.pinned).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: sorted.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No conversations', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Your chats will appear here', style: TextStyle(fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100))),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: pinned.length + (pinned.isNotEmpty && unpinned.isNotEmpty ? 1 : 0) + unpinned.length,
              itemBuilder: (context, i) {
                if (i < pinned.length) return ConversationTile(conversation: pinned[i]);
                if (i == pinned.length && pinned.isNotEmpty && unpinned.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  );
                }
                final unpinnedIdx = i - pinned.length - (pinned.isNotEmpty && unpinned.isNotEmpty ? 1 : 0);
                return ConversationTile(conversation: unpinned[unpinnedIdx]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(chatProvider.notifier).newConversation();
          Navigator.pop(context);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

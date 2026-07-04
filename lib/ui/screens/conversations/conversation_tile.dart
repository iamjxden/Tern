import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/conversation.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/conversations_provider.dart';
import '../../../core/extensions/datetime_ext.dart';

class ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  const ConversationTile({super.key, required this.conversation});

  @override Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: Text('Delete "${conversation.title}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => ref.read(conversationsProvider.notifier).delete(conversation.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.chat_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(
            '${conversation.messageCount} messages · ${conversation.updatedAt.relative}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(100)),
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (conversation.pinned)
              const Icon(Icons.push_pin_rounded, size: 16),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 18),
              onPressed: () => _showContextMenu(context, ref),
            ),
          ]),
          onTap: () {
            ref.read(chatProvider.notifier).selectConversation(conversation);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(ctx);
              _showRenameDialog(context, ref);
            },
          ),
          ListTile(
            leading: Icon(conversation.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined),
            title: Text(conversation.pinned ? 'Unpin' : 'Pin'),
            onTap: () {
              ref.read(conversationsProvider.notifier).togglePinned(conversation.id);
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              ref.read(conversationsProvider.notifier).delete(conversation.id);
            },
          ),
        ]),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: conversation.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: controller, autofocus: true,
            decoration: const InputDecoration(hintText: 'Conversation name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(conversationsProvider.notifier).rename(conversation.id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tern/providers/conversations_provider.dart';
import 'package:tern/models/conversation.dart';
import 'conversation_tile.dart';

class ConversationSearchDelegate extends SearchDelegate<Conversation?> {
  @override List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear_rounded), tooltip: 'Clear',
          onPressed: () => query = ''),
  ];
  @override Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back_rounded), tooltip: 'Back',
          onPressed: () => close(context, null));
  @override String get searchFieldLabel => 'Search conversations...';

  @override Widget buildResults(BuildContext context) => _buildList(context);
  @override Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final state = ref.watch(conversationsProvider);
      final results = state.conversations
          .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (results.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.search_off_rounded, size: 56,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(60)),
            const SizedBox(height: 12),
            Text('No conversations match "$query"',
                style: TextStyle(fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
          ]),
        );
      }
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, i) => ConversationTile(conversation: results[i]),
      );
    });
  }
}

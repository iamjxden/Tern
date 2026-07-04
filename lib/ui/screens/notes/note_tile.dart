import 'package:flutter/material.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String preview;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const NoteTile({super.key, required this.title, required this.preview,
      required this.date, required this.onTap, required this.onDelete});

  @override Widget build(BuildContext context) {
    return Dismissible(
      key: Key('$title-$date'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Delete "$title"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: const Text('Delete')),
          ],
        )) ?? false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(title.isNotEmpty ? title : 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 2),
            Text(preview.length > 80 ? '${preview.substring(0, 80)}...' : preview.isEmpty ? 'Empty note' : preview,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(100))),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withAlpha(60))),
          ]),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: onTap,
        ),
      ),
    );
  }
}

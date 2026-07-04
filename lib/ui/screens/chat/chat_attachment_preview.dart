import 'package:flutter/material.dart';

class ChatAttachmentPreview extends StatelessWidget {
  final String fileName;
  final String? mimeType;
  final VoidCallback onRemove;
  const ChatAttachmentPreview({super.key, required this.fileName, this.mimeType, required this.onRemove});

  @override Widget build(BuildContext context) {
    final isImage = mimeType?.startsWith('image/') ?? false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isImage ? Icons.image_rounded : Icons.insert_drive_file_rounded, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(fileName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
        const SizedBox(width: 8),
        InkWell(onTap: onRemove, child: const Icon(Icons.close_rounded, size: 18)),
      ]),
    );
  }
}

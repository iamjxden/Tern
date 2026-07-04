import 'package:flutter/material.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteId;
  final String title;
  final String content;
  const NoteEditorScreen({super.key, required this.noteId, required this.title, required this.content});
  @override State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final FocusNode _contentFocus = FocusNode();
  bool _modified = false;

  @override void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.title);
    _contentCtrl = TextEditingController(text: widget.content);
    _titleCtrl.addListener(() => setState(() => _modified = true));
    _contentCtrl.addListener(() => setState(() => _modified = true));
  }

  @override Widget build(BuildContext context) {
    final isNew = widget.title.isEmpty && widget.content.isEmpty;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_modified) {
          _showUnsavedDialog();
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isNew ? 'New Note' : widget.title),
          actions: [
            TextButton(
              onPressed: _modified ? () => Navigator.pop(context, {
                'noteId': widget.noteId,
                'title': _titleCtrl.text,
                'content': _contentCtrl.text,
              }) : null,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextField(
              controller: _titleCtrl,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Note title',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _contentFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                focusNode: _contentFocus,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(60)),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showUnsavedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Discard changes to this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Editing')),
          OutlinedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Discard'),
          ),
          FilledButton(onPressed: () {
            Navigator.pop(ctx);
            Navigator.pop(context, {
              'noteId': widget.noteId,
              'title': _titleCtrl.text,
              'content': _contentCtrl.text,
            });
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  @override void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _contentFocus.dispose();
    super.dispose();
  }
}
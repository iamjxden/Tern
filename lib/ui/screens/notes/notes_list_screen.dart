import 'package:flutter/material.dart';
import 'package:tern/config/theme.dart';
import 'package:tern/core/di/service_locator.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await ServiceLocator.noteDao.getAll();
    if (mounted) setState(() => _notes = notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: const SizedBox(width: 56),
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: HumanNodeTheme.textSecondary),
            onPressed: _createNote,
          ),
        ],
      ),
      body: _notes.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: HumanNodeTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: HumanNodeTheme.border, width: 0.5),
                  ),
                  child: const Icon(Icons.sticky_note_2_outlined,
                      size: 40, color: HumanNodeTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                const Text('No notes yet',
                    style: TextStyle(
                        color: HumanNodeTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                const SizedBox(height: 8),
                const Text('Tap + to create your first note',
                    style: TextStyle(
                        color: HumanNodeTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _createNote,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New Note'),
                ),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (ctx, i) {
                final n = _notes[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: HumanNodeTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: HumanNodeTheme.border, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    title: Text(
                      n['title'] as String? ?? 'Untitled',
                      style: const TextStyle(
                          color: HumanNodeTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    subtitle: Text(
                      n['content'] as String? ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: HumanNodeTheme.textSecondary,
                          fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: HumanNodeTheme.textSecondary, size: 18),
                      onPressed: () => _delete(n['id'] as String),
                    ),
                    onTap: () => _openNote(i),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        backgroundColor: HumanNodeTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _createNote() async {
    final result = await _showEditor(context);
    if (result != null && mounted) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      await ServiceLocator.noteDao.insert(
          id, result['title'] ?? 'Untitled', result['content'] ?? '');
      await _load();
    }
  }

  Future<void> _openNote(int i) async {
    final n = _notes[i];
    final result = await _showEditor(context,
        title: n['title'] as String? ?? '',
        content: n['content'] as String? ?? '');
    if (result != null && mounted) {
      await ServiceLocator.noteDao.update(
          n['id'] as String, result['title'] ?? '', result['content'] ?? '');
      await _load();
    }
  }

  Future<void> _delete(String id) async {
    await ServiceLocator.noteDao.delete(id);
    await _load();
  }

  Future<Map<String, String>?> _showEditor(BuildContext ctx,
      {String title = '', String content = ''}) {
    final titleCtrl = TextEditingController(text: title);
    final contentCtrl = TextEditingController(text: content);
    return showModalBottomSheet<Map<String, String>>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: HumanNodeTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: HumanNodeTheme.border,
                  borderRadius: BorderRadius.circular(2))),
          TextField(
            controller: titleCtrl,
            style: const TextStyle(
                color: HumanNodeTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
          const Divider(color: HumanNodeTheme.border),
          TextField(
            controller: contentCtrl,
            style: const TextStyle(
                color: HumanNodeTheme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Write something...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
            maxLines: 8,
            minLines: 4,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, {
              'title': titleCtrl.text,
              'content': contentCtrl.text,
            }),
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

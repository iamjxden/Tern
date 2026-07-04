import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../models/project.dart';
import '../../../providers/projects_provider.dart';

class ProjectKnowledgeScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectKnowledgeScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectKnowledgeScreen> createState() => _ProjectKnowledgeScreenState();
}

class _ProjectKnowledgeScreenState extends ConsumerState<ProjectKnowledgeScreen> {
  List<ProjectKnowledgeItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Knowledge is fetched via addProjectKnowledge during this session.
      // In a future iteration, list endpoint can pre-load all items here.
      _items = _items;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addContent() async {
    final nameController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: HumanNodeTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add knowledge',
                  style: TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: HumanNodeTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Name', hintStyle: TextStyle(color: HumanNodeTheme.textSecondary)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 6,
                style: const TextStyle(color: HumanNodeTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Content', hintStyle: TextStyle(color: HumanNodeTheme.textSecondary)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;
                    try {
                      final item = await ref.read(remoteApiClientProvider).addProjectKnowledge(
                            widget.projectId,
                            name: nameController.text.trim(),
                            content: contentController.text.trim(),
                          );
                      setState(() => _items = [..._items, item]);
                      if (mounted) Navigator.of(context).pop(true);
                    } catch (_) {
                      if (mounted) Navigator.of(context).pop(false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) ref.read(projectsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Project Knowledge'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0,
                  minHeight: 4,
                  backgroundColor: HumanNodeTheme.surfaceCard,
                  valueColor: const AlwaysStoppedAnimation(HumanNodeTheme.primary),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('0% of project capacity used',
                    style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.note_add_outlined, size: 56, color: HumanNodeTheme.textSecondary),
                              SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Add relevant documents, text, code, or other files here so Tern can use them as context.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          itemCount: _items.length,
                          itemBuilder: (context, i) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.description_outlined, color: HumanNodeTheme.textSecondary),
                            title: Text(_items[i].name, style: const TextStyle(color: HumanNodeTheme.textPrimary)),
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _addContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Add Content', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

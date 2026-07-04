import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../providers/projects_provider.dart';
import 'create_project_sheet.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(projectsProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsProvider);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? state.projects
        : state.projects.where((p) => p.name.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // space for hamburger overlay
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'Projects',
                    style: TextStyle(
                      color: HumanNodeTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: HumanNodeTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: HumanNodeTheme.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search projects',
                        hintStyle: TextStyle(color: HumanNodeTheme.textSecondary),
                        prefixIcon: Icon(Icons.search, color: HumanNodeTheme.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: state.isLoading && state.projects.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                state.projects.isEmpty ? 'No projects yet' : 'No matches',
                                style: const TextStyle(color: HumanNodeTheme.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final project = filtered[i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    project.name,
                                    style: const TextStyle(
                                      color: HumanNodeTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Edited ${DateFormat.yMMMd().format(project.updatedAt)}',
                                    style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13),
                                  ),
                                  onTap: () => context.push('/home/projects/${project.id}'),
                                );
                              },
                            ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onPressed: () async {
                  final created = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const CreateProjectSheet(),
                  );
                  if (created == true) {
                    ref.read(projectsProvider.notifier).load();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('New project', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

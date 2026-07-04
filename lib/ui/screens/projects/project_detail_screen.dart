import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../providers/projects_provider.dart';
import 'custom_instructions_dialog.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).projects;
    final project = projects.where((p) => p.id == projectId).firstOrNull;

    if (project == null) {
      return const Scaffold(
        backgroundColor: HumanNodeTheme.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: const TextStyle(
                  color: HumanNodeTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (project.description != null && project.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(project.description!,
                    style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 14)),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: HumanNodeTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      project.isPrivate ? Icons.lock_outline : Icons.public,
                      size: 14,
                      color: HumanNodeTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.isPrivate ? 'Private' : 'Public',
                      style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Project knowledge',
                      actionLabel: project.knowledgeCount == 0 ? 'Add knowledge' : 'View knowledge',
                      onTap: () => context.push('/home/projects/$projectId/knowledge'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Custom instructions',
                      actionLabel: project.instructions == null ? 'Add instructions' : 'Edit instructions',
                      onTap: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (_) => CustomInstructionsDialog(
                            initialValue: project.instructions,
                          ),
                        );
                        if (result != null) {
                          await ref.read(projectsProvider.notifier).updateInstructions(
                                projectId,
                                result,
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 56, color: HumanNodeTheme.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Chats you\'ve had with Tern will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => context.go('/home', extra: {'projectId': projectId}),
        icon: const Icon(Icons.add),
        label: const Text('New chat', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _InfoCard({required this.title, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HumanNodeTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: HumanNodeTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(actionLabel,
                style: const TextStyle(color: HumanNodeTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../models/model_info.dart';
import '../../../providers/models_provider.dart';
import '../../../inference/ollama_client.dart';

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen> {
  final Map<String, Stream<OllamaModelStatus>> _activeInstalls = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(modelsProvider.notifier).refresh());
  }

  void _install(ModelInfo model) {
    final stream = ref.read(modelsProvider.notifier).installModel(model.id);
    setState(() => _activeInstalls[model.id] = stream);
    stream.listen(
      (status) {
        if (status.installed || status.error != null) {
          if (mounted) setState(() => _activeInstalls.remove(model.id));
          if (status.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Install failed: ${status.error}')),
            );
          }
        }
      },
      onError: (_) {
        if (mounted) setState(() => _activeInstalls.remove(model.id));
      },
    );
  }

  Future<void> _confirmRemove(ModelInfo model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HumanNodeTheme.surfaceElevated,
        title: Text('Remove ${model.displayName}?',
            style: const TextStyle(color: HumanNodeTheme.textPrimary)),
        content: Text(
          'This will delete ${model.sizeLabel} from your device.',
          style: const TextStyle(color: HumanNodeTheme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(modelsProvider.notifier).removeModel(model.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modelsProvider);

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60), // space for hamburger overlay
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text('Models',
                  style: TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.ollamaReachable ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.ollamaReachable ? 'Ollama connected' : 'Ollama not running',
                    style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: HumanNodeTheme.textSecondary, size: 20),
                    onPressed: () => ref.read(modelsProvider.notifier).refresh(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoadingCatalog
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: state.availableModels.length,
                      itemBuilder: (context, i) {
                        final model = state.availableModels[i];
                        final installed = state.installedModels.any(
                          (m) => m == model.id || m.startsWith('${model.id.split(':').first}:'),
                        );
                        final downloading = _activeInstalls.containsKey(model.id);
                        final progress = state.downloadProgress[model.id];

                        return _ModelCard(
                          model: model,
                          installed: installed,
                          downloading: downloading,
                          progress: progress,
                          onInstall: () => _install(model),
                          onRemove: () => _confirmRemove(model),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final ModelInfo model;
  final bool installed;
  final bool downloading;
  final double? progress;
  final VoidCallback onInstall;
  final VoidCallback onRemove;

  const _ModelCard({
    required this.model,
    required this.installed,
    required this.downloading,
    required this.progress,
    required this.onInstall,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HumanNodeTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.displayName,
                        style: const TextStyle(
                            color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(model.tagline,
                        style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('${model.sizeLabel} · ${model.contextLabel}',
                        style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (downloading)
                SizedBox(
                  width: 72,
                  height: 34,
                  child: Center(
                    child: Text(
                      progress != null ? '${(progress! * 100).toInt()}%' : '...',
                      style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13),
                    ),
                  ),
                )
              else if (installed)
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  child: const Text('Remove'),
                )
              else if (!model.cloud)
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onInstall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                    child: const Text('Install', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: HumanNodeTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Cloud', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                ),
            ],
          ),
          if (downloading && progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: HumanNodeTheme.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation(HumanNodeTheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

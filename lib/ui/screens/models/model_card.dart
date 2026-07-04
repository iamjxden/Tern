import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/inference_provider.dart';
import '../../../core/di/service_locator.dart';
import 'model_detail_sheet.dart';

class ModelCard extends ConsumerWidget {
  final String modelName;
  const ModelCard({super.key, required this.modelName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infState = ref.watch(inferenceProvider);
    final cleanName = modelName.replaceAll('.gguf', '');
    final displayName = cleanName
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    final isActive = infState.modelName == cleanName;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: cs.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleTap(ref),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(colors: [cs.primary, cs.tertiary])
                    : null,
                color: isActive ? null : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? Icons.smart_toy : Icons.smart_toy_outlined,
                color: isActive ? Colors.white : cs.onSurface,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(displayName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurface)),
                const SizedBox(height: 2),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      isActive ? 'Active' : 'Tap to load',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('GGUF · Q4_K_M',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withAlpha(100))),
                ]),
              ]),
            ),
            if (isActive)
              IconButton(
                icon: Icon(Icons.eject_rounded, color: cs.error),
                tooltip: 'Unload',
                onPressed: () =>
                    ref.read(inferenceProvider.notifier).unloadModel(),
              ),
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              onPressed: () => _showDetail(context),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleTap(WidgetRef ref) {
    final infState = ref.read(inferenceProvider);
    final cleanName = modelName.replaceAll('.gguf', '');
    if (infState.isLoaded && infState.modelName == cleanName) {
      ref.read(inferenceProvider.notifier).unloadModel();
    } else {
      ServiceLocator.fileCache.getModelPath(modelName).then((path) {
        ref.read(inferenceProvider.notifier).loadModel(path);
      });
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ModelDetailSheet(modelName: modelName),
    );
  }
}

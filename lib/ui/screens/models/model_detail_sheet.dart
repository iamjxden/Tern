import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/models_provider.dart';
import '../../../core/extensions/num_ext.dart';

class ModelDetailSheet extends ConsumerWidget {
  final String modelName;
  const ModelDetailSheet({super.key, required this.modelName});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final displayName = modelName.replaceAll('.gguf', '');
    return SizedBox(
      height: 340,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 32, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          Text(displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _row(context, 'Architecture', 'Llama'),
          _row(context, 'Format', 'GGUF'),
          _row(context, 'Quantization', 'Q4_K_M'),
          _row(context, 'Context Length', '8,192 tokens'),
          _row(context, 'Parameters', '3.2B'),
          _row(context, 'Size', (4 * 1024 * 1024 * 1024).fileSizeFormatted),
          const Spacer(),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(modelsProvider.notifier).remove(modelName);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(120), fontSize: 14)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
    ]),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class ModelsSettings extends ConsumerWidget {
  const ModelsSettings({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('GPU Acceleration'),
          subtitle: const Text('Use hardware acceleration for inference'),
          value: s.gpuAcceleration,
          onChanged: (v) => ref.read(settingsProvider.notifier).setGpuAcceleration(v),
        ),
        ListTile(
          title: const Text('Context Window'),
          subtitle: Text('${s.maxTokens} tokens'),
          trailing: SizedBox(
            width: 120,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () => ref.read(settingsProvider.notifier).setMaxTokens(s.maxTokens - 1024)),
              Text('${s.maxTokens ~/ 1024}K', style: const TextStyle(fontWeight: FontWeight.w500)),
              IconButton(icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () => ref.read(settingsProvider.notifier).setMaxTokens(s.maxTokens + 1024)),
            ]),
          ),
        ),
      ]),
    );
  }
}

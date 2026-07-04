import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class GenerationSettings extends ConsumerWidget {
  const GenerationSettings({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Generation')),
      body: ListView(children: [
        ListTile(
          title: const Text('Temperature'),
          subtitle: Text('Higher = more creative, lower = more focused'),
          trailing: SizedBox(
            width: 170,
            child: Slider(
              value: s.temperature, min: 0, max: 2, divisions: 40,
              label: s.temperature.toStringAsFixed(2),
              onChanged: (v) => ref.read(settingsProvider.notifier).setTemperature(v),
            ),
          ),
        ),
        ListTile(title: const Text('Top P'), subtitle: Text('${s.topP.toStringAsFixed(2)} — Nucleus sampling threshold'),
            trailing: SizedBox(width: 170,
                child: Slider(value: s.topP, min: 0, max: 1, divisions: 20,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setTopP(v)))),
        ListTile(
          title: const Text('Max Output Tokens'),
          subtitle: Text('${s.maxTokens} tokens per response'),
          trailing: SizedBox(width: 120, child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => ref.read(settingsProvider.notifier).setMaxTokens(s.maxTokens - 512)),
            Text('${s.maxTokens}', style: const TextStyle(fontFamily: 'JetBrainsMono')),
            IconButton(icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => ref.read(settingsProvider.notifier).setMaxTokens(s.maxTokens + 512)),
          ])),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';

class GeneralSettings extends ConsumerWidget {
  const GeneralSettings({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: ListView(children: [
        SwitchListTile(title: const Text('Dark Mode'), value: s.darkMode,
            onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v)),
        ListTile(
          title: const Text('Font Size'),
          subtitle: Text('${s.fontSize.toStringAsFixed(0)}px'),
          trailing: SizedBox(width: 160,
              child: Slider(value: s.fontSize, min: 12, max: 32, divisions: 10,
                  label: '${s.fontSize.toStringAsFixed(0)}px',
                  onChanged: (v) => ref.read(settingsProvider.notifier).setFontSize(v))),
        ),
        SwitchListTile(title: const Text('Haptic Feedback'), value: s.hapticFeedback,
            onChanged: (v) => ref.read(settingsProvider.notifier).setHaptic(v)),
        SwitchListTile(title: const Text('Sound Effects'), value: s.soundsEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setSounds(v)),
        SwitchListTile(title: const Text('Voice Input'), subtitle: const Text('Enable microphone for speech-to-text'),
            value: s.voiceInput, onChanged: (v) => ref.read(settingsProvider.notifier).setVoiceInput(v)),
        SwitchListTile(title: const Text('Read Aloud'), subtitle: const Text('Speak assistant responses'),
            value: s.readAloud, onChanged: (v) => ref.read(settingsProvider.notifier).setReadAloud(v)),
        SwitchListTile(title: const Text('Developer Mode'), value: s.developerMode,
            onChanged: (v) => ref.read(settingsProvider.notifier).toggleDeveloper()),
      ]),
    );
  }
}

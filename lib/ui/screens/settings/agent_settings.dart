import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/tools_provider.dart';

class AgentSettings extends ConsumerWidget {
  const AgentSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Agent')),
      body: ListView(children: [
        ListTile(
          title: const Text('Max Steps'),
          subtitle: Text('${s.maxAgentSteps} steps per agent run'),
          trailing: SizedBox(
            width: 170,
            child: Slider(
              value: s.maxAgentSteps.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: '${s.maxAgentSteps}',
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setMaxSteps(v.round()),
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Reflexion'),
          subtitle: const Text('Auto-correct on tool failures'),
          value: s.agentReflexion,
          onChanged: (_) =>
              ref.read(settingsProvider.notifier).toggleReflexion(),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text('ENABLED TOOLS',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ),
        _toolTile(ref, 'web_search', 'Web Search', Icons.search_rounded),
        _toolTile(ref, 'calculator', 'Calculator', Icons.calculate_rounded),
        _toolTile(ref, 'datetime', 'Date & Time', Icons.schedule_rounded),
        _toolTile(ref, 'bash', 'Shell', Icons.terminal_rounded),
        _toolTile(ref, 'file_read', 'Read Files', Icons.description_rounded),
        _toolTile(ref, 'file_write', 'Write Files', Icons.edit_note_rounded),
        _toolTile(ref, 'fetch_url', 'Fetch URL', Icons.link_rounded),
        _toolTile(ref, 'note_create', 'Create Notes', Icons.note_add_rounded),
        _toolTile(ref, 'note_search', 'Search Notes', Icons.find_in_page_rounded),
        _toolTile(ref, 'memory', 'Memory', Icons.memory_rounded),
        _toolTile(ref, 'summary', 'Summarizer', Icons.summarize_rounded),
      ]),
    );
  }

  Widget _toolTile(WidgetRef ref, String name, String label, IconData icon) {
    final enabled = ref.watch(toolsProvider).isEnabled(name);
    return SwitchListTile(
      secondary: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: enabled,
      onChanged: (_) => ref.read(toolsProvider.notifier).toggleTool(name),
    );
  }
}

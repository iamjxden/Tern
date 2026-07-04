import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/inference_provider.dart';
import '../../../providers/agent_provider.dart';
import '../../../core/di/service_locator.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final inf = ref.watch(inferenceProvider);
    final agent = ref.watch(agentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section(context, 'Inference'),
        _kv(context, 'Model Loaded', '${inf.isLoaded}'),
        _kv(context, 'Model Name', inf.modelName ?? 'none'),
        _kv(context, 'Generating', '${inf.isGenerating}'),
        _kv(context, 'Context Size', '${inf.contextSize ?? '-'}'),
        _kv(context, 'Tok/s', inf.tokensPerSecond?.toStringAsFixed(1) ?? '-'),
        _kv(context, 'Total Tokens', '${inf.totalTokens ?? 0}'),
        const SizedBox(height: 16),
        _section(context, 'Agent'),
        _kv(context, 'State', agent.state.name),
        _kv(context, 'Running', '${agent.isRunning}'),
        _kv(context, 'Steps', '${agent.steps}'),
        _kv(context, 'Current Tool', agent.currentTool ?? '-'),
        if (agent.toolLog.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...agent.toolLog.reversed.take(5).map((l) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(l, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11)),
          )),
        ],
        const SizedBox(height: 16),
        _section(context, 'Cache'),
        FutureBuilder<int>(
          future: ServiceLocator.fileCache.getCacheSize(),
          builder: (context, snap) => _kv(context, 'Cache Size', '${snap.data ?? 0} bytes'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.troubleshoot_rounded), label: const Text('Run Diagnostics')),
      ]),
    );
  }

  Widget _section(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary, letterSpacing: 1)),
  );

  Widget _kv(BuildContext context, String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(key, style: const TextStyle(fontSize: 14)),
      Text(value, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13)),
    ]),
  );
}

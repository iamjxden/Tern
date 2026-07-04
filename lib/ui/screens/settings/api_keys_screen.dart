import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';

class ApiKeysScreen extends StatefulWidget {
  const ApiKeysScreen({super.key});
  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _openaiCtrl = TextEditingController();
  final _anthropicCtrl = TextEditingController();
  final _openrouterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final openai = await ServiceLocator.secureStore.getApiKey('openai');
    final anthropic = await ServiceLocator.secureStore.getApiKey('anthropic');
    final openrouter =
        await ServiceLocator.secureStore.getApiKey('openrouter');
    if (!mounted) return;
    setState(() {
      _openaiCtrl.text = openai ?? '';
      _anthropicCtrl.text = anthropic ?? '';
      _openrouterCtrl.text = openrouter ?? '';
    });
  }

  Future<void> _save() async {
    await ServiceLocator.secureStore
        .saveApiKey('openai', _openaiCtrl.text);
    await ServiceLocator.secureStore
        .saveApiKey('anthropic', _anthropicCtrl.text);
    await ServiceLocator.secureStore
        .saveApiKey('openrouter', _openrouterCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API keys saved securely')));
  }

  Future<void> _clearAll() async {
    await ServiceLocator.secureStore.clearAll();
    if (!mounted) return;
    setState(() {
      _openaiCtrl.clear();
      _anthropicCtrl.clear();
      _openrouterCtrl.clear();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('All keys cleared')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Keys')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(
          'These keys are stored encrypted in the device keystore. '
          'They are never sent to any server except the API provider you choose.',
          style: TextStyle(
              fontSize: 13,
              color:
                  Theme.of(context).colorScheme.onSurface.withAlpha(120)),
        ),
        const SizedBox(height: 20),
        _keyField(_openaiCtrl, 'OpenAI API Key', 'sk-...'),
        const SizedBox(height: 16),
        _keyField(_anthropicCtrl, 'Anthropic API Key', 'sk-ant-...'),
        const SizedBox(height: 16),
        _keyField(_openrouterCtrl, 'OpenRouter API Key', 'sk-or-...'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save Keys'),
          style:
              FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _clearAll,
          icon: const Icon(Icons.delete_sweep_rounded),
          label: const Text('Clear All Keys'),
          style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error),
        ),
      ]),
    );
  }

  Widget _keyField(
      TextEditingController ctrl, String label, String hint) =>
      TextField(
        controller: ctrl,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.key_rounded, size: 20),
          border: const OutlineInputBorder(),
        ),
      );

  @override
  void dispose() {
    _openaiCtrl.dispose();
    _anthropicCtrl.dispose();
    _openrouterCtrl.dispose();
    super.dispose();
  }
}

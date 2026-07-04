import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

enum ToolAccessMode { auto, onDemand, alwaysAvailable }

class CapabilitiesScreen extends StatefulWidget {
  const CapabilitiesScreen({super.key});

  @override
  State<CapabilitiesScreen> createState() => _CapabilitiesScreenState();
}

class _CapabilitiesScreenState extends State<CapabilitiesScreen> {
  bool _webSearch = true;
  final bool _artifacts = true;
  bool _codeExecution = true;
  bool _switchOnFlag = true;
  bool _generateMemory = true;
  ToolAccessMode _toolAccess = ToolAccessMode.alwaysAvailable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Capabilities'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _toggleTile(
              icon: Icons.public,
              title: 'Web search',
              subtitle: 'Tern will automatically search the web when it determines it needs current information',
              value: _webSearch,
              onChanged: (v) => setState(() => _webSearch = v),
            ),
            _toggleTile(
              icon: Icons.description_outlined,
              title: 'Artifacts',
              subtitle: 'Required by code execution',
              value: _artifacts,
              onChanged: null,
            ),
            _toggleTile(
              icon: Icons.code,
              title: 'Code execution and file creation',
              subtitle: 'Allow Tern to execute code and create and edit docs, spreadsheets, presentations, PDFs, and data reports.',
              value: _codeExecution,
              onChanged: (v) => setState(() => _codeExecution = v),
            ),
            _toggleTile(
              icon: Icons.swap_vert,
              title: 'Switch models when a message is flagged',
              subtitle: 'When safety measures flag a message, automatically switch to a different model to keep chatting. When off, your chat will pause instead.',
              value: _switchOnFlag,
              onChanged: (v) => setState(() => _switchOnFlag = v),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
              child: Text('Memory', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
            ),
            _toggleTile(
              icon: Icons.psychology_outlined,
              title: 'Generate memory from chat history',
              subtitle: 'Allow Tern to remember relevant context from your chats. This setting controls memory for both chats and projects.',
              value: _generateMemory,
              onChanged: (v) => setState(() => _generateMemory = v),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: HumanNodeTheme.surfaceCard, borderRadius: BorderRadius.circular(14)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Memory from past chats', style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Synced from your chats', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
              child: Text('Tool access', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
            ),
            _radioTile('Auto', 'Tern chooses for you', ToolAccessMode.auto),
            _radioTile('On demand', 'Load when needed. More messages, lower accuracy', ToolAccessMode.onDemand),
            _radioTile('Always available', 'Ready from start. Fewer messages, better accuracy', ToolAccessMode.alwaysAvailable),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: HumanNodeTheme.surfaceCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onChanged == null ? HumanNodeTheme.textSecondary : HumanNodeTheme.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: onChanged == null ? HumanNodeTheme.textSecondary : HumanNodeTheme.textPrimary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: HumanNodeTheme.primary),
        ],
      ),
    );
  }

  Widget _radioTile(String title, String subtitle, ToolAccessMode mode) {
    final selected = _toolAccess == mode;
    return InkWell(
      onTap: () => setState(() => _toolAccess = mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: HumanNodeTheme.surfaceCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: selected ? HumanNodeTheme.primary : HumanNodeTheme.textPrimary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check, color: HumanNodeTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

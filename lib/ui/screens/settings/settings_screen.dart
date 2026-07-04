import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: const SizedBox(width: 56),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Account'),
          _tile(context, Icons.person_outline, 'Profile', '/home/settings/profile'),
          _section('Tern'),
          _tile(context, Icons.toggle_on_outlined, 'Capabilities', '/home/settings/capabilities'),
          _tile(context, Icons.lock_outline, 'Permissions', '/home/settings/permissions'),
          _tile(context, Icons.link, 'Connectors', '/home/settings/connectors'),
          _section('Preferences'),
          _tile(context, Icons.tune_rounded, 'General', '/home/settings/general'),
          _tile(context, Icons.smart_toy_rounded, 'Models', '/home/settings/models'),
          _tile(context, Icons.thermostat_rounded, 'Generation', '/home/settings/generation'),
          _tile(context, Icons.auto_awesome_rounded, 'Agent', '/home/settings/agent'),
          _section('Providers'),
          _tile(context, Icons.vpn_key_rounded, 'API Keys', '/home/settings/api-keys'),
          _section('Data'),
          _tile(context, Icons.storage_rounded, 'Storage', '/home/settings/storage'),
          _section('Info'),
          _tile(context, Icons.info_outline_rounded, 'About', '/home/settings/about'),
          _tile(context, Icons.bug_report_rounded, 'Debug', '/home/settings/debug'),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Text('Tern',
                    style: TextStyle(color: HumanNodeTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  'by Aetheron · v1.0.0${user != null ? ' · ${user.displayName ?? user.email}' : ''}',
                  style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  child: const Text('Sign out', style: TextStyle(color: HumanNodeTheme.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: HumanNodeTheme.textSecondary, letterSpacing: 1.2),
        ),
      );

  Widget _tile(BuildContext ctx, IconData icon, String title, String route) => Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: HumanNodeTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HumanNodeTheme.border, width: 0.5),
        ),
        child: ListTile(
          leading: Icon(icon, size: 20, color: HumanNodeTheme.textSecondary),
          title: Text(title,
              style: const TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: HumanNodeTheme.textSecondary),
          onTap: () => ctx.push(route),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

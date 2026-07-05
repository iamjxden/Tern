import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _preferencesController;
  bool _savingProfile = false;
  bool _savingPreferences = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    final prefs = user?.preferences;
    _preferencesController = TextEditingController(
      text: prefs == null ? '' : jsonEncode(prefs),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _savingProfile = true);
    await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          displayName: _displayNameController.text.trim(),
        );
    if (mounted) setState(() => _savingProfile = false);
  }

  Future<void> _savePreferences() async {
    setState(() => _savingPreferences = true);
    final raw = _preferencesController.text.trim();
    Map<String, dynamic>? parsed;
    if (raw.isNotEmpty) {
      try {
        parsed = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {
        parsed = {'value': raw};
      }
    }
    await ref.read(authProvider.notifier).updateProfile(preferences: parsed);
    if (mounted) setState(() => _savingPreferences = false);
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HumanNodeTheme.surfaceElevated,
        title: const Text('Delete account?', style: TextStyle(color: HumanNodeTheme.textPrimary)),
        content: const Text(
          'This permanently deletes your account, chats, projects and memory. This cannot be undone.',
          style: TextStyle(color: HumanNodeTheme.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).deleteAccount();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Profile'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Full name', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            _field(_nameController),
            const SizedBox(height: 16),
            const Text('What should we call you?', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            _field(_displayNameController),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _savingProfile ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HumanNodeTheme.surfaceElevated,
                  foregroundColor: HumanNodeTheme.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: _savingProfile
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Update Profile', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 28),
            const Text('What personal preferences should Tern consider in responses?',
                style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('Your preferences will apply to all conversations.',
                style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            _field(_preferencesController, maxLines: 5),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _savingPreferences ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HumanNodeTheme.surfaceElevated,
                  foregroundColor: HumanNodeTheme.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: _savingPreferences
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 36),
            const Text('Account Actions', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _confirmDeleteAccount,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HumanNodeTheme.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: HumanNodeTheme.textPrimary),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
      ),
    );
  }
}

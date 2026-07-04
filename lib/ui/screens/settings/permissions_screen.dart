import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Permissions'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: HumanNodeTheme.surfaceCard, borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.near_me_outlined, color: HumanNodeTheme.textPrimary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location', style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('To allow access to your location, turn on the permission in your system settings.',
                            style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse('app-settings:')),
                    child: const Text('Settings', style: TextStyle(color: HumanNodeTheme.textPrimary)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: HumanNodeTheme.surfaceCard, borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_today_outlined, color: HumanNodeTheme.textPrimary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calendar', style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Tern can create and manage events in your calendar app.',
                            style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Text('Read & Write', style: TextStyle(color: HumanNodeTheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

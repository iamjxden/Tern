import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';

class ConnectorsScreen extends StatefulWidget {
  const ConnectorsScreen({super.key});

  @override
  State<ConnectorsScreen> createState() => _ConnectorsScreenState();
}

class _ConnectorsScreenState extends State<ConnectorsScreen> {
  bool _discoveryEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Connectors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/home/settings/connectors/browse'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: HumanNodeTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: HumanNodeTheme.textPrimary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connector discovery',
                            style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Tern will help you find available connectors in your directory.',
                            style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _discoveryEnabled,
                    onChanged: (v) => setState(() => _discoveryEnabled = v),
                    activeColor: HumanNodeTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: HumanNodeTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  Icon(Icons.cloud_outlined, color: HumanNodeTheme.textPrimary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Google Drive', style: TextStyle(color: HumanNodeTheme.textPrimary)),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: HumanNodeTheme.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

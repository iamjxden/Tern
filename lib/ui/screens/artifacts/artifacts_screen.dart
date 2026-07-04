import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class ArtifactsScreen extends StatelessWidget {
  const ArtifactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: HumanNodeTheme.textPrimary),
                    onPressed: Scaffold.of(context).openDrawer,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Text(
                'Artifacts',
                style: TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
              ),
            ),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Artifacts you've had with Tern will show up here.",
                    style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

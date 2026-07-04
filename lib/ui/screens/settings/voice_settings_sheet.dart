import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class VoicePersonality {
  final String name;
  final Color glowColor;
  const VoicePersonality({required this.name, required this.glowColor});
}

const _personalities = [
  VoicePersonality(name: 'Buttery', glowColor: Color(0xFFDA7756)),
  VoicePersonality(name: 'Airy', glowColor: Color(0xFFDA7756)),
  VoicePersonality(name: 'Mellow', glowColor: Color(0xFF8B5CF6)),
  VoicePersonality(name: 'Crisp', glowColor: Color(0xFF06B6D4)),
  VoicePersonality(name: 'Warm', glowColor: Color(0xFFF59E0B)),
];

class VoiceSettingsSheet extends StatefulWidget {
  const VoiceSettingsSheet({super.key});

  @override
  State<VoiceSettingsSheet> createState() => _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends State<VoiceSettingsSheet> {
  int _selectedIndex = 1;
  String _language = 'English';
  String _pace = 'Normal';
  String _mode = 'Standard';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HumanNodeTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: HumanNodeTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: HumanNodeTheme.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Voice settings',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: HumanNodeTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.5,
                initialPage: _selectedIndex,
              ),
              onPageChanged: (i) => setState(() => _selectedIndex = i),
              itemCount: _personalities.length,
              itemBuilder: (context, i) {
                final p = _personalities[i];
                final selected = i == _selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: selected ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: HumanNodeTheme.surfaceCard,
                    boxShadow: selected
                        ? [BoxShadow(color: p.glowColor.withOpacity(0.4), blurRadius: 24, spreadRadius: 4)]
                        : [],
                    gradient: selected
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [HumanNodeTheme.surfaceCard, p.glowColor.withOpacity(0.3)],
                          )
                        : null,
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    p.name,
                    style: TextStyle(
                      color: selected ? HumanNodeTheme.textPrimary : HumanNodeTheme.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_personalities.length, (i) {
              return Container(
                width: i == _selectedIndex ? 8 : 6,
                height: i == _selectedIndex ? 8 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _selectedIndex
                      ? HumanNodeTheme.textPrimary
                      : HumanNodeTheme.textSecondary.withOpacity(0.4),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          _settingRow('Language', _language, 'BETA', () {}),
          Divider(color: HumanNodeTheme.border, height: 1),
          _settingRow('Pace', _pace, null, () {}),
          Divider(color: HumanNodeTheme.border, height: 1),
          _settingRow('Mode', _mode, null, () {}),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _settingRow(String label, String value, String? badge, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: HumanNodeTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badge, style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 10)),
              ),
            ],
            const Spacer(),
            Text(value, style: const TextStyle(color: HumanNodeTheme.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: HumanNodeTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

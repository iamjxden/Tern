import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tern/config/theme.dart';
import 'package:tern/providers/auth_provider.dart';
import 'package:tern/providers/models_provider.dart';
import 'package:tern/ui/widgets/tern_logo.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  static const _items = [
    (Icons.chat_bubble_rounded, Icons.chat_bubble_outlined, 'Chat', '/home'),
    (Icons.forum_rounded, Icons.forum_outlined, 'Chats', '/home/conversations'),
    (Icons.folder_rounded, Icons.folder_outlined, 'Projects', '/home/projects'),
    (Icons.auto_awesome_rounded, Icons.auto_awesome_outlined, 'Artifacts', '/home/artifacts'),
    (Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'Models', '/home/models'),
    (Icons.settings_rounded, Icons.settings_outlined, 'Settings', '/home/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    if (_open) {
      _ctrl.reverse().then((_) => setState(() => _open = false));
    } else {
      setState(() => _open = true);
      _ctrl.forward();
    }
  }

  void _navigate(String route) {
    _ctrl.reverse().then((_) {
      setState(() => _open = false);
      if (mounted) context.go(route);
    });
  }

  String _active(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).uri.toString();
    if (loc.startsWith('/home/conversations')) return '/home/conversations';
    if (loc.startsWith('/home/projects')) return '/home/projects';
    if (loc.startsWith('/home/artifacts')) return '/home/artifacts';
    if (loc.startsWith('/home/models')) return '/home/models';
    if (loc.startsWith('/home/settings')) return '/home/settings';
    return '/home';
  }

  @override
  Widget build(BuildContext context) {
    final active = _active(context);
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: Stack(children: [
        widget.child,
        if (_open) ...[
          FadeTransition(
            opacity: _fade,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.black.withAlpha(140)),
            ),
          ),
          SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              alignment: Alignment.centerLeft,
              child: _DrawerPanel(
                active: active,
                items: _items,
                onNavigate: _navigate,
              ),
            ),
          ),
        ],
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: _HamburgerButton(open: _open, onTap: _toggle),
          ),
        ),
      ]),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;
  const _HamburgerButton({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: HumanNodeTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HumanNodeTheme.border, width: 0.5),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            open ? Icons.close_rounded : Icons.menu_rounded,
            key: ValueKey(open),
            size: 18,
            color: HumanNodeTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DrawerPanel extends ConsumerWidget {
  final String active;
  final List<(IconData, IconData, String, String)> items;
  final void Function(String) onNavigate;

  const _DrawerPanel({
    required this.active,
    required this.items,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final modelsState = ref.watch(modelsProvider);

    return Container(
      width: 265,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: HumanNodeTheme.surfaceCard,
        border: Border(right: BorderSide(color: HumanNodeTheme.border, width: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 32, offset: Offset(8, 0))],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  TernLogo(size: 36, color: HumanNodeTheme.textPrimary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tern',
                        style: TextStyle(
                          color: HumanNodeTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Text(
                        'by Aetheron',
                        style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: HumanNodeTheme.border, height: 1),
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final (activeIcon, inactiveIcon, label, route) = item;
              final isActive = active == route;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: _NavTile(
                  icon: isActive ? activeIcon : inactiveIcon,
                  label: label,
                  isActive: isActive,
                  onTap: () => onNavigate(route),
                ),
              );
            }),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: HumanNodeTheme.border, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: modelsState.ollamaReachable ? const Color(0xFF22C55E) : Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: modelsState.ollamaReachable
                              ? const Color(0x6622C55E)
                              : Colors.redAccent.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      modelsState.ollamaReachable ? 'Ollama connected' : 'Ollama offline',
                      style: const TextStyle(fontSize: 11, color: HumanNodeTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user != null)
                    Text(
                      user.displayName ?? user.email.split('@').first,
                      style: const TextStyle(fontSize: 11, color: HumanNodeTheme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? HumanNodeTheme.primary.withAlpha(20)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: HumanNodeTheme.primary.withAlpha(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Icon(icon,
                size: 20,
                color: isActive
                    ? HumanNodeTheme.primary
                    : HumanNodeTheme.textSecondary),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? HumanNodeTheme.textPrimary
                        : HumanNodeTheme.textSecondary)),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: HumanNodeTheme.primary,
                    shape: BoxShape.circle),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

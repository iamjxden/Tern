import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tern/config/theme.dart';
import 'package:tern/core/di/service_locator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _Page(
      icon: Icons.travel_explore_rounded,
      gradient: [Color(0xFF818CF8), Color(0xFF4338CA)],
      title: 'Run AI Locally',
      subtitle:
          'Tern runs models directly on your device. No cloud, no subscriptions, complete privacy.',
    ),
    _Page(
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      title: 'Agentic Mode',
      subtitle:
          'Give Tern a task and watch it work. Web search, code execution, file management and more.',
    ),
    _Page(
      icon: Icons.lock_rounded,
      gradient: [Color(0xFF06B6D4), Color(0xFF0E7490)],
      title: 'Private by Design',
      subtitle:
          'Zero telemetry. Zero tracking. Your conversations and models stay on your device, always.',
    ),
  ];

  Future<void> _finish() async {
    await ServiceLocator.settingsDao.set('onboarding_complete', 'true');
    if (mounted) context.go('/login'); // GoRouter redirect sends signed-in users to /home
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _pages.length,
          itemBuilder: (_, i) => _PageView(page: _pages[i]),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? HumanNodeTheme.primary
                            : HumanNodeTheme.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: isLast
                        ? _finish
                        : () => _ctrl.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(isLast ? 'Get Started' : 'Next',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                if (!isLast)
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip',
                        style: TextStyle(
                            color: HumanNodeTheme.textSecondary,
                            fontSize: 14)),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Page {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;

  const _Page({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}

class _PageView extends StatelessWidget {
  final _Page page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 120, 32, 200),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: page.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                  color: page.gradient.first.withAlpha(100),
                  blurRadius: 48,
                  spreadRadius: 8)
            ],
          ),
          child: Icon(page.icon, color: Colors.white, size: 60),
        ),
        const SizedBox(height: 48),
        Text(page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: HumanNodeTheme.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 16),
        Text(page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: HumanNodeTheme.textSecondary,
                fontSize: 16,
                height: 1.6)),
      ]),
    );
  }
}

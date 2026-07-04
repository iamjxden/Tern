import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tern/config/theme.dart';
import 'package:tern/core/di/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    // Let the GoRouter auth redirect handle where to send the user.
    // The authProvider will have resolved by now (restoreSession completes fast).
    // We navigate to /login which the redirect will bounce to /home if already signed in.
    final seen = await ServiceLocator.settingsDao.get('onboarding_complete');
    if (!mounted) return;
    if (seen != 'true') {
      context.go('/onboarding');
    } else {
      // GoRouter redirect will take over from /login -> /home if signed in
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0x301E1B4B), HumanNodeTheme.surface],
              ),
            ),
          ),
        ),
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFF4338CA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                          color: HumanNodeTheme.primary.withAlpha(120),
                          blurRadius: 40,
                          spreadRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.travel_explore_rounded,
                      color: Colors.white, size: 52),
                ),
                const SizedBox(height: 28),
                const Text('Tern',
                    style: TextStyle(
                        color: HumanNodeTheme.textPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1)),
                const SizedBox(height: 6),
                const Text('by Aetheron',
                    style: TextStyle(
                        color: HumanNodeTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Your AI. Your device. Anywhere.',
                    style: TextStyle(
                        color: HumanNodeTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 52),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        HumanNodeTheme.primary.withAlpha(160)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

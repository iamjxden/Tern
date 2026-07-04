import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../config/app_config.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/tern_logo.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _emailFocused = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _continueWithEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }
    await ref.read(authProvider.notifier).requestEmailOtp(email);
    final state = ref.read(authProvider);
    if (state.status == AuthStatus.awaitingOtp && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OtpScreen()),
      );
    } else if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const TernLogo(size: 56),
              const SizedBox(height: 12),
              const Text(
                AppConfig.appName,
                style: TextStyle(
                  color: HumanNodeTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 40),
              Icon(Icons.auto_awesome_outlined,
                  size: 88, color: HumanNodeTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(height: 24),
              const Text(
                AppConfig.tagline,
                style: TextStyle(
                  color: HumanNodeTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authProvider.notifier).signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: HumanNodeTheme.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: HumanNodeTheme.border)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _emailFocused ? HumanNodeTheme.primary : HumanNodeTheme.border,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: HumanNodeTheme.textPrimary),
                  onTap: () => setState(() => _emailFocused = true),
                  onTapOutside: (_) => setState(() => _emailFocused = false),
                  onSubmitted: (_) => _continueWithEmail(),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(color: HumanNodeTheme.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    suffixIcon: authState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward, color: HumanNodeTheme.textPrimary),
                            onPressed: _continueWithEmail,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'By continuing, you agree to ${AppConfig.makerName}\'s Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

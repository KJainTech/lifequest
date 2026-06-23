import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/penny_mascot.dart';
import '../onboarding/auth_service.dart';

/// Splash / Welcome per §5.1
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  PennyGuideState _mascotState = PennyGuideState.idle;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _mascotState = PennyGuideState.wave);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: Column(
              children: [
                const Spacer(flex: 2),
                PennyMascot(state: _mascotState, size: 200)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: LQSpacing.xxxl),
                Text(
                  'LifeQuest',
                  style: LQTypography.display(colors),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: LQSpacing.sm),
                Text(
                  'Marhaba — learn money by playing',
                  style: LQTypography.body(colors),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),
                const Spacer(flex: 3),
                LQButton(
                  label: 'Get Started',
                  colors: colors,
                  expanded: true,
                  onPressed: () async {
                    final auth = ref.read(authServiceProvider);
                    try {
                      final user = await auth.signInAnonymously();
                      if (!context.mounted) return;
                      final profile = await auth.fetchProfile(user.uid);
                      if (!context.mounted) return;
                      if (profile?.onboardingComplete == true) {
                        context.go('/home');
                      } else {
                        context.go('/onboarding/age');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not start. ($e)')),
                        );
                      }
                    }
                  },
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: LQSpacing.md),
                LQButton(
                  label: 'Design Showcase',
                  colors: colors,
                  variant: LQButtonVariant.ghost,
                  expanded: true,
                  onPressed: () => context.go('/showcase'),
                ).animate().fadeIn(delay: 900.ms),
                const SizedBox(height: LQSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

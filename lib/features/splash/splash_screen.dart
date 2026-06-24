import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/audio/lq_sound_service.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../design/lq_button.dart';
import '../../design/lq_city_skyline.dart';
import '../../design/lq_immersive_scene.dart';
import '../../design/penny_mascot.dart';
import '../onboarding/auth_service.dart';

/// Splash — LifeQuest brand · Learn · Play · Feedback · 6 levels · 48 stages.
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _mascotState = PennyGuideState.happy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final compact = MediaQuery.sizeOf(context).height < 720;

    return Scaffold(
      body: LQImmersiveScene(
        colors: colors,
        intensity: 0.65,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(LQSpacing.gutter),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BrandMark(colors: colors),
                          TextButton(
                            onPressed: () => context.go('/showcase'),
                            child: Text(
                              'Preview',
                              style: LQTypography.caption(colors).copyWith(
                                color: colors.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? LQSpacing.lg : LQSpacing.xxl),
                      LQCitySkyline(
                        colors: colors,
                        height: compact ? 120 : 150,
                        progress: 0.28,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.08, end: 0),
                      SizedBox(height: compact ? LQSpacing.lg : LQSpacing.xxl),
                      Center(
                        child: LQFloaty(
                          amplitude: 5,
                          child: SizedBox(
                            width: compact ? 88 : 108,
                            height: compact ? 88 : 108,
                            child: PennyMascot(
                              state: _mascotState,
                              size: compact ? 88 : 108,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      SizedBox(height: LQSpacing.xl),
                      Text(
                        'LifeQuest',
                        style: LQTypography.display(colors).copyWith(
                          fontSize: compact ? 32 : 38,
                          color: colors.brandDeep,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 280.ms),
                      const SizedBox(height: LQSpacing.sm),
                      Text(
                        'The world teaches children what money is.',
                        style: LQTypography.body(colors).copyWith(
                          color: colors.inkSoft,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 340.ms),
                      const SizedBox(height: LQSpacing.xs),
                      Text(
                        'We teach them what to do with it.',
                        style: LQTypography.h3(colors).copyWith(
                          color: colors.gold,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: LQSpacing.xl),
                      LQCycleStrip(colors: colors)
                          .animate()
                          .fadeIn(delay: 460.ms)
                          .slideY(begin: 0.06, end: 0),
                      const SizedBox(height: LQSpacing.lg),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: LQSpacing.sm,
                        runSpacing: LQSpacing.sm,
                        children: [
                          _Chip(colors: colors, label: '$kQuestLevelCount levels'),
                          _Chip(colors: colors, label: '$kTotalStages stages'),
                          _Chip(colors: colors, label: '80% mastery'),
                          _Chip(colors: colors, label: 'Lemon City'),
                        ],
                      ).animate().fadeIn(delay: 520.ms),
                      SizedBox(height: compact ? LQSpacing.xxxl : 48),
                      LQButton(
                        label: 'Start Your Quest',
                        colors: colors,
                        expanded: true,
                        onPressed: () => _start(context),
                      ).animate().fadeIn(delay: 580.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: LQSpacing.md),
                      Text(
                        'Learn in class · Play at home · Grow your city',
                        style: LQTypography.caption(colors).copyWith(
                          color: colors.inkSoft,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 640.ms),
                      const SizedBox(height: LQSpacing.lg),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    LQSound.tap();
    final auth = ref.read(authServiceProvider);
    try {
      final user = await auth.signInAnonymously();
      if (!context.mounted) return;
      var profile = await auth.fetchProfile(user.uid);
      if (profile == null) {
        await auth.ensureChildAccount(user.uid);
        profile = await auth.fetchProfile(user.uid);
      }
      if (!context.mounted) return;
      if (profile?.onboardingComplete == true) {
        context.go('/home');
      } else {
        context.go('/onboarding/guide');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start. ($e)')),
        );
      }
    }
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.colors});
  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.brand,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.savings_rounded, color: colors.surface, size: 18),
        ),
        const SizedBox(width: LQSpacing.sm),
        Text(
          'LQ',
          style: LQTypography.h3(colors).copyWith(
            color: colors.brandDeep,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.colors, required this.label});

  final LQColors colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LQSpacing.md,
        vertical: LQSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(LQRadius.chip),
        border: Border.all(color: colors.brand.withValues(alpha: 0.2)),
        boxShadow: LQElevation.e1(colors.ink),
      ),
      child: Text(
        label,
        style: LQTypography.caption(colors).copyWith(
          color: colors.brandDeep,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

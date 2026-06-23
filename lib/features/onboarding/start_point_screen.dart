import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/lq_icons.dart';
import 'onboarding_shell.dart';
import 'onboarding_state.dart';

/// Start point per §5.4
class StartPointScreen extends ConsumerWidget {
  const StartPointScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: OnboardingShell(
              colors: colors,
              step: 3,
              totalSteps: 4,
              title: 'Where should we begin?',
              subtitle: 'You can always replay earlier lessons later.',
              onBack: () => context.go('/onboarding/guide'),
              child: Column(
                children: [
                  const Spacer(),
                  _StartCard(
                    colors: colors,
                    featured: false,
                    title: 'Start from the beginning',
                    subtitle: 'Level 1 — perfect if you\'re new to money skills.',
                    icon: LQIconType.learn,
                    onTap: () {
                      ref
                          .read(onboardingDraftProvider.notifier)
                          .setWantsScreening(false);
                      context.go('/onboarding/finish?level=1');
                    },
                  ).animate().fadeIn().slideY(begin: 0.08, end: 0),
                  const SizedBox(height: LQSpacing.lg),
                  _StartCard(
                    colors: colors,
                    featured: true,
                    title: 'Take the Screening Quest',
                    subtitle:
                        'A quick adaptive quiz to find your best starting level.',
                    icon: LQIconType.trophy,
                    onTap: () {
                      ref
                          .read(onboardingDraftProvider.notifier)
                          .setWantsScreening(true);
                      context.go('/onboarding/screening');
                    },
                  )
                      .animate(delay: 80.ms)
                      .fadeIn()
                      .slideY(begin: 0.08, end: 0),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  const _StartCard({
    required this.colors,
    required this.featured,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final LQColors colors;
  final bool featured;
  final String title;
  final String subtitle;
  final LQIconType icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LQCard(
      colors: colors,
      elevation: featured ? 3 : 1,
      onTap: onTap,
      child: Row(
        children: [
          LQDuotoneIcon(
            icon: icon,
            size: 36,
            primaryColor: featured ? colors.brand : colors.inkSoft,
            secondaryColor: featured
                ? colors.brand.withValues(alpha: 0.25)
                : colors.inkSoft.withValues(alpha: 0.2),
          ),
          const SizedBox(width: LQSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featured)
                  Container(
                    margin: const EdgeInsets.only(bottom: LQSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: LQSpacing.md,
                      vertical: LQSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brand.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(LQRadius.chip),
                    ),
                    child: Text(
                      'Recommended',
                      style: LQTypography.caption(colors).copyWith(
                        color: colors.brand,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(title, style: LQTypography.h3(colors)),
                const SizedBox(height: LQSpacing.xs),
                Text(subtitle, style: LQTypography.bodySm(colors)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.inkSoft),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/haptics/lq_haptics.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/lq_icons.dart';
import 'onboarding_shell.dart';
import 'onboarding_state.dart';

enum _StartChoice { beginning, screening }

/// Start point — pick level path, then continue (clear selected state).
class StartPointScreen extends ConsumerStatefulWidget {
  const StartPointScreen({super.key});

  @override
  ConsumerState<StartPointScreen> createState() => _StartPointScreenState();
}

class _StartPointScreenState extends ConsumerState<StartPointScreen> {
  _StartChoice? _selected;

  void _pick(_StartChoice choice) {
    LQHaptics.selectionClick();
    setState(() => _selected = choice);
    ref.read(onboardingDraftProvider.notifier).setWantsScreening(
          choice == _StartChoice.screening,
        );
  }

  void _continue() {
    if (_selected == null) return;
    if (_selected == _StartChoice.screening) {
      context.go('/onboarding/screening');
    } else {
      context.go('/onboarding/finish?level=1');
    }
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
            child: OnboardingShell(
              colors: colors,
              step: 2,
              totalSteps: 3,
              title: 'Where should we begin?',
              subtitle: 'Tap your path — you can replay any stage later.',
              onBack: () => context.go('/onboarding/guide'),
              child: Column(
                children: [
                  const SizedBox(height: LQSpacing.lg),
                  _StartCard(
                    colors: colors,
                    selected: _selected == _StartChoice.beginning,
                    title: 'Start from the beginning',
                    subtitle: 'Stage 1 of 50 — best for brand-new learners.',
                    badge: 'Beginner',
                    icon: LQIconType.learn,
                    onTap: () => _pick(_StartChoice.beginning),
                  ).animate().fadeIn().slideY(begin: 0.06, end: 0),
                  const SizedBox(height: LQSpacing.lg),
                  _StartCard(
                    colors: colors,
                    selected: _selected == _StartChoice.screening,
                    title: 'Take the Screening Quest',
                    subtitle:
                        'Quick quiz to find your best stage (1–50).',
                    badge: 'Recommended',
                    icon: LQIconType.trophy,
                    featured: true,
                    onTap: () => _pick(_StartChoice.screening),
                  ).animate(delay: 60.ms).fadeIn().slideY(begin: 0.06, end: 0),
                  const Spacer(),
                  LQButton(
                    label: _selected == _StartChoice.screening
                        ? 'Start screening'
                        : _selected == _StartChoice.beginning
                            ? 'Start at Stage 1'
                            : 'Choose a path',
                    colors: colors,
                    expanded: true,
                    onPressed: _selected == null ? null : _continue,
                  ),
                  const SizedBox(height: LQSpacing.lg),
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
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.onTap,
    this.featured = false,
  });

  final LQColors colors;
  final bool selected;
  final String title;
  final String subtitle;
  final String badge;
  final LQIconType icon;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return LQCard(
      colors: colors,
      elevation: selected ? 2 : 1,
      selected: selected,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LQDuotoneIcon(
            icon: icon,
            size: 36,
            primaryColor: selected || featured ? colors.brand : colors.inkSoft,
            secondaryColor: (selected || featured ? colors.brand : colors.inkSoft)
                .withValues(alpha: 0.25),
          ),
          const SizedBox(width: LQSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LQSpacing.md,
                        vertical: LQSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: featured
                            ? colors.brand.withValues(alpha: 0.15)
                            : colors.inkSoft.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(LQRadius.chip),
                      ),
                      child: Text(
                        badge,
                        style: LQTypography.caption(colors).copyWith(
                          color: featured ? colors.brand : colors.inkSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected) ...[
                      const Spacer(),
                      Icon(Icons.check_circle_rounded, color: colors.brand, size: 22),
                    ],
                  ],
                ),
                const SizedBox(height: LQSpacing.sm),
                Text(title, style: LQTypography.h3(colors)),
                const SizedBox(height: LQSpacing.xs),
                Text(subtitle, style: LQTypography.bodySm(colors)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

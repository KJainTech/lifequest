import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/haptics/lq_haptics.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/guide_mascot.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/penny_mascot.dart';
import 'age_band.dart';
import 'onboarding_shell.dart';
import 'onboarding_state.dart';

/// Guide pick per §5.3
class GuidePickScreen extends ConsumerStatefulWidget {
  const GuidePickScreen({super.key});

  @override
  ConsumerState<GuidePickScreen> createState() => _GuidePickScreenState();
}

class _GuidePickScreenState extends ConsumerState<GuidePickScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(onboardingDraftProvider).guide;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final age = ref.watch(onboardingDraftProvider).age;
    final guides = ['penny', 'finBot', 'atlas'];

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.gutter),
            child: OnboardingShell(
              colors: colors,
              step: 2,
              totalSteps: 4,
              title: 'Pick your guide',
              subtitle:
                  'Your guide is your buddy. Your age sets the difficulty.',
              onBack: () => context.go('/onboarding/age'),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: guides.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: LQSpacing.lg),
                      itemBuilder: (context, i) {
                        final id = guides[i];
                        final isSelected = _selected == id;
                        final g = LQGuideX.fromId(id);
                        return _GuideCard(
                          colors: colors,
                          guideId: id,
                          guide: g,
                          selected: isSelected,
                          age: age,
                          onTap: () {
                            LQHaptics.selectionClick();
                            setState(() => _selected = id);
                            ref
                                .read(onboardingDraftProvider.notifier)
                                .setGuide(id);
                            ref.read(ageWorldProvider.notifier).state =
                                guideToWorld(id);
                          },
                        )
                            .animate(delay: (i * 40).ms)
                            .fadeIn()
                            .slideY(begin: 0.06, end: 0);
                      },
                    ),
                  ),
                  const SizedBox(height: LQSpacing.lg),
                  LQButton(
                    label: 'Continue',
                    colors: colors,
                    expanded: true,
                    onPressed: _selected == null
                        ? null
                        : () => context.go('/onboarding/start'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.colors,
    required this.guideId,
    required this.guide,
    required this.selected,
    required this.age,
    required this.onTap,
  });

  final LQColors colors;
  final String guideId;
  final LQGuide guide;
  final bool selected;
  final int age;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mismatch = !guideMatchesAge(guideId, age);

    return LQCard(
      colors: colors,
      elevation: selected ? 2 : 1,
      padding: const EdgeInsets.all(LQSpacing.lg),
      onTap: onTap,
      child: Row(
        children: [
          GuideMascot(
            guide: guide,
            size: 72,
            selected: selected,
            state: selected
                ? PennyGuideState.happy
                : PennyGuideState.idle,
          ),
          const SizedBox(width: LQSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guideDisplayName(guideId),
                  style: LQTypography.h2(colors),
                ),
                const SizedBox(height: LQSpacing.xs),
                Text(
                  guidePersonality(guideId),
                  style: LQTypography.bodySm(colors),
                ),
                const SizedBox(height: LQSpacing.sm),
                Text(
                  guideAgeHint(guideId),
                  style: LQTypography.caption(colors),
                ),
                if (mismatch) ...[
                  const SizedBox(height: LQSpacing.sm),
                  Text(
                    'Content stays age-appropriate for you.',
                    style: LQTypography.caption(colors).copyWith(
                      color: colors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

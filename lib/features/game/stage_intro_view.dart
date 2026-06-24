import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/stage_activity_config.dart';
import '../../data/models/stage_activity.dart';
import '../../data/repositories/content_repository.dart';
import '../../design/guide_mascot.dart';
import '../../design/lq_button.dart';
import '../../design/penny_mascot.dart';
import '../../features/onboarding/auth_service.dart';
import '../learn/lesson_session.dart';

/// Stage intro — guide voice line before lesson content (DevPlan Day 19–20).
class StageIntroView extends ConsumerWidget {
  const StageIntroView({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider);
    if (session == null) return const SizedBox.shrink();
    final contentAsync = ref.watch(lessonContentProvider(session.lessonId));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guideId = profile?.guide ?? 'penny';
    final guide = LQGuideX.fromId(guideId);
    final name = profile?.displayName ?? 'Explorer';

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: LQButton(label: 'Continue', colors: colors, onPressed: onContinue),
      ),
      data: (content) {
        final meta = lessonById(session.lessonId);
        final intro = meta != null
            ? StageActivityConfig.introFor(meta, name)
            : StageIntroCopy(
                penny: 'Ready for ${content.title}?',
                finBot: 'Stage loaded.',
                atlas: 'Begin when ready.',
              );
        final line = switch (guideId) {
          'finBot' => intro.finBot,
          'atlas' => intro.atlas,
          _ => intro.penny,
        };

        return Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            children: [
              const Spacer(),
              if (intro.hook != null)
                Text(intro.hook!, style: LQTypography.caption(colors))
                    .animate()
                    .fadeIn(),
              const SizedBox(height: LQSpacing.lg),
              GuideMascot(guide: guide, size: 140, state: PennyGuideState.wave)
                  .animate()
                  .slideX(begin: -0.15, end: 0, curve: Curves.elasticOut),
              const SizedBox(height: LQSpacing.xxl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(LQSpacing.xl),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(LQRadius.card),
                  boxShadow: LQElevation.e1(colors.ink),
                ),
                child: Text(
                  line,
                  style: LQTypography.body(colors).copyWith(height: 1.45),
                  textAlign: TextAlign.center,
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.06, end: 0),
              const Spacer(flex: 2),
              LQButton(
                label: "Let's go!",
                colors: colors,
                expanded: true,
                onPressed: onContinue,
              ).animate(delay: 800.ms).fadeIn(),
              const SizedBox(height: LQSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

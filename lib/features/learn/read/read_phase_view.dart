import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/lq_theme.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../design/guide_mascot.dart';
import '../../../design/penny_mascot.dart';
import '../../../design/speech_card.dart';
import '../../../features/onboarding/age_band.dart';
import '../../../features/onboarding/auth_service.dart';
import '../lesson_session.dart';

/// READ phase per §5.8
class ReadPhaseView extends ConsumerWidget {
  const ReadPhaseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final session = ref.watch(lessonSessionProvider)!;
    final contentAsync = ref.watch(lessonContentProvider(session.lessonId));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final guide = LQGuideX.fromId(profile?.guide ?? 'penny');

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Let\'s try that again.', style: LQTypography.body(colors)),
      ),
      data: (content) {
        final index =
            session.readIndex.clamp(0, content.readParagraphs.length - 1);
        final paragraph = content.readParagraphs[index];

        return Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            children: [
              SegmentedProgressBar(
                colors: colors,
                total: content.readParagraphs.length,
                current: index,
              ),
              const SizedBox(height: LQSpacing.xxl),
              GuideMascot(
                guide: guide,
                size: 100,
                state: PennyGuideState.idle,
              ),
              const SizedBox(height: LQSpacing.xxl),
              Expanded(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(lessonSessionProvider.notifier)
                        .advanceRead(content.readParagraphs.length),
                    child: SpeechCard(
                      colors: colors,
                      guideName: guideDisplayName(profile?.guide ?? 'penny'),
                      text: paragraph.text,
                      trailing: Text(
                        index < content.readParagraphs.length - 1
                            ? 'Tap to continue'
                            : 'Tap to start quiz',
                        style: LQTypography.caption(colors).copyWith(
                          color: colors.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

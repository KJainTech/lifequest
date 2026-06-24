import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_button.dart';
import '../../design/lq_card.dart';
import '../../design/lq_immersive_scene.dart';
import '../../design/stat_pill.dart';
import '../../features/city/city_buildings.dart';
import '../../features/city/city_map_widget.dart';
import '../../features/city/city_providers.dart';
import '../../features/onboarding/age_band.dart';
import '../../data/providers/notification_providers.dart';
import '../../features/notifications/notifications_sheet.dart';
import '../../design/guide_mascot.dart';
import '../../design/penny_mascot.dart';

/// Home — play hub only. Balance & card live under Me.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWorldFromProfile());
  }

  void _syncWorldFromProfile() {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile?.guide != null) {
      ref.read(ageWorldProvider.notifier).state = guideToWorld(profile!.guide!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final lessonsAsync = ref.watch(userLessonsProvider);
    final guide = profile?.guide ?? 'penny';
    final name = profile?.displayName ?? 'Explorer';

    return LQImmersiveScene(
      colors: colors,
      child: SafeArea(
        child: lessonsAsync.when(
          loading: () => _HomeLoading(colors: colors),
          error: (_, __) => _HomeError(colors: colors),
          data: (progress) {
            final currentLesson = LessonProgression.currentLesson(progress, profile);
            final journeyDone = LessonProgression.isJourneyComplete(progress, profile);
            final completed = LessonProgression.completedCount(progress, profile);
            final journeyPct = LessonProgression.journeyProgress(progress, profile);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(LQSpacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HomeHeader(
                          colors: colors,
                          name: name,
                          guide: guide,
                          streak: stats.streak.count,
                          notificationCount:
                              ref.watch(unreadNotificationCountProvider),
                          onNotifications: () => NotificationsSheet.show(context),
                          onProfile: () => context.go('/profile'),
                        ),
                        const SizedBox(height: LQSpacing.xl),
                        Text('Your quest', style: LQTypography.h2(colors)),
                        const SizedBox(height: LQSpacing.sm),
                        _TodayQuestCard(
                          colors: colors,
                          current: currentLesson,
                          journeyDone: journeyDone,
                          completed: completed,
                        ).animate().fadeIn().slideY(begin: 0.06, end: 0),
                        const SizedBox(height: LQSpacing.lg),
                        LQButton(
                          label: 'View full quest map',
                          colors: colors,
                          variant: LQButtonVariant.secondary,
                          expanded: true,
                          onPressed: () => context.go('/learn'),
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        _JourneyStrip(
                          colors: colors,
                          completed: completed,
                          journeyPct: journeyPct,
                        ),
                        const SizedBox(height: LQSpacing.lg),
                        _CityTeaser(colors: colors),
                        const SizedBox(height: LQSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading({required this.colors});
  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.brand),
          const SizedBox(height: LQSpacing.lg),
          Text('Loading your quest…', style: LQTypography.bodySm(colors)),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.colors});
  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.gutter),
        child: Text(
          'Could not load your progress. Pull to refresh or try again.',
          style: LQTypography.bodySm(colors),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.colors,
    required this.name,
    required this.guide,
    required this.streak,
    required this.notificationCount,
    required this.onNotifications,
    required this.onProfile,
  });

  final LQColors colors;
  final String name;
  final String guide;
  final int streak;
  final int notificationCount;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GuideMascot(
          guide: LQGuideX.fromId(guide),
          size: 52,
          state: PennyGuideState.happy,
        ),
        const SizedBox(width: LQSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hey, $name!', style: LQTypography.h2(colors)),
              if (streak > 0)
                Text(
                  '$streak-day streak — keep it going!',
                  style: LQTypography.bodySm(colors),
                )
              else
                Text(
                  'Ready for today\'s adventure?',
                  style: LQTypography.bodySm(colors),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: onNotifications,
          icon: Badge(
            isLabelVisible: notificationCount > 0,
            label: Text('$notificationCount'),
            child: Icon(Icons.notifications_outlined, color: colors.ink),
          ),
        ),
        IconButton(
          tooltip: 'My profile & coins',
          onPressed: onProfile,
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: colors.accentMint,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'E',
              style: LQTypography.label(colors).copyWith(color: colors.brand),
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayQuestCard extends StatelessWidget {
  const _TodayQuestCard({
    required this.colors,
    required this.current,
    required this.journeyDone,
    required this.completed,
  });

  final LQColors colors;
  final LessonMeta? current;
  final bool journeyDone;
  final int completed;

  @override
  Widget build(BuildContext context) {
    if (journeyDone) {
      return LQCard(
        colors: colors,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatPill(colors: colors, label: 'Programme complete', variant: StatPillVariant.xp),
            const SizedBox(height: LQSpacing.lg),
            Text('Chief Money Officer!', style: LQTypography.h2(colors)),
            const SizedBox(height: LQSpacing.sm),
            Text(
              'You finished all $kTotalStages stages. Replay or grow your city!',
              style: LQTypography.bodySm(colors),
            ),
            const SizedBox(height: LQSpacing.xl),
            LQButton(
              label: 'Pick a lesson',
              colors: colors,
              expanded: true,
              onPressed: () => context.go('/learn'),
            ),
          ],
        ),
      );
    }

    final lesson = current ?? kCurriculum.first;
    return LQCard(
      colors: colors,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatPill(
                colors: colors,
                label: 'Level ${lesson.questLevel} · Stage ${lesson.stageInLevel}',
                variant: StatPillVariant.xp,
              ),
              const Spacer(),
              StatPill(
                colors: colors,
                label: LessonProgression.xpLabelFor(lesson),
                variant: StatPillVariant.coins,
              ),
            ],
          ),
          const SizedBox(height: LQSpacing.lg),
          Text(lesson.title, style: LQTypography.h2(colors)),
          const SizedBox(height: LQSpacing.xs),
          Text(lesson.subtitle, style: LQTypography.bodySm(colors)),
          const SizedBox(height: LQSpacing.xl),
          LQButton(
            label: 'Play now',
            colors: colors,
            expanded: true,
            onPressed: () {
              if (current != null) {
                context.push('/lesson/${current!.id}');
              } else {
                context.go('/learn');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _JourneyStrip extends StatelessWidget {
  const _JourneyStrip({
    required this.colors,
    required this.completed,
    required this.journeyPct,
  });

  final LQColors colors;
  final int completed;
  final double journeyPct;

  @override
  Widget build(BuildContext context) {
    return LQCard(
      colors: colors,
      onTap: () => context.go('/awards'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Journey progress', style: LQTypography.h3(colors)),
                const SizedBox(height: LQSpacing.xs),
                Text(
                  '$completed / $kTotalStages stages · ${(journeyPct * 100).round()}%',
                  style: LQTypography.bodySm(colors),
                ),
              ],
            ),
          ),
          Icon(Icons.emoji_events_outlined, color: colors.gold, size: 28),
        ],
      ),
    );
  }
}

class _CityTeaser extends ConsumerWidget {
  const _CityTeaser({required this.colors});
  final LQColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final towers = ref.watch(userTowersProvider).valueOrNull ?? const [];
    final lessons = ref.watch(userLessonsProvider).valueOrNull ?? const [];
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final snapshot = buildCityProgress(
      lessonProgress: lessons,
      towers: towers,
      profile: profile,
    );

    return LQCard(
      colors: colors,
      onTap: () => context.go('/city'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Build Lemon City', style: LQTypography.h3(colors)),
          const SizedBox(height: LQSpacing.xs),
          Text(
            snapshot.builtCount == 0
                ? 'Complete a lesson to raise your first building'
                : '${snapshot.builtCount} buildings so far — tap to visit',
            style: LQTypography.bodySm(colors),
          ),
          const SizedBox(height: LQSpacing.md),
          CityMapPreview(colors: colors, snapshot: snapshot),
        ],
      ),
    );
  }
}

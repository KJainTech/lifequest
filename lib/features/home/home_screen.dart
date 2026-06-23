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
import '../../design/lq_badge.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/lq_icons.dart';
import '../../features/city/city_preview_painter.dart';
import '../../features/city/city_providers.dart';
import '../../features/onboarding/age_band.dart';
import '../../features/onboarding/auth_service.dart';
import '../../data/providers/app_providers.dart';
import '../../design/stat_pill.dart';

/// Home dashboard per §5.6 — daily hub
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
    final progress = lessonsAsync.valueOrNull ?? const <LessonProgress>[];
    final currentLesson = LessonProgression.currentLesson(progress, profile);
    final journeyDone = LessonProgression.isJourneyComplete(progress, profile);
    final name = profile?.displayName ?? 'Explorer';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'E';
    final xpForLevel = stats.level * 100;
    final xpProgress = xpForLevel > 0
        ? (stats.xp % xpForLevel) / xpForLevel
        : 0.0;

    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(LQSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(colors, name: name, initial: initial),
                    const SizedBox(height: LQSpacing.xxl),
                    LQHeroCard(
                      colors: colors,
                      level: stats.level,
                      xp: stats.xp,
                      xpProgress: xpProgress.clamp(0.0, 1.0),
                      lqScore: stats.lqScore,
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: LQSpacing.lg),
                    _buildTodayLesson(colors, currentLesson, journeyDone),
                    const SizedBox(height: LQSpacing.xxl),
                    Text('Your Badges', style: LQTypography.h2(colors)),
                    const SizedBox(height: LQSpacing.lg),
                    _buildBadgeShelf(colors),
                    const SizedBox(height: LQSpacing.xxl),
                    _buildCityPreview(colors),
                    const SizedBox(height: LQSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(LQColors colors,
      {required String name, required String initial}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.brand.withValues(alpha: 0.2),
          child: Text(
            initial,
            style: LQTypography.h3(colors).copyWith(color: colors.brand),
          ),
        ),
        const SizedBox(width: LQSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Marhaba, $name', style: LQTypography.h2(colors)),
              Text('Ready for today\'s quest?', style: LQTypography.bodySm(colors)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: LQDuotoneIcon(
            icon: LQIconType.notification,
            primaryColor: colors.inkSoft,
            secondaryColor: colors.inkSoft.withValues(alpha: 0.2),
          ),
        ),
        IconButton(
          onPressed: () => context.go('/showcase'),
          icon: LQDuotoneIcon(
            icon: LQIconType.settings,
            primaryColor: colors.inkSoft,
            secondaryColor: colors.inkSoft.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayLesson(
    LQColors colors,
    LessonMeta? current,
    bool journeyDone,
  ) {
    if (journeyDone) {
      return LQCard(
        colors: colors,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatPill(colors: colors, label: 'Complete', variant: StatPillVariant.xp),
                const Spacer(),
                StatPill(colors: colors, label: '6/6', variant: StatPillVariant.coins),
              ],
            ),
            const SizedBox(height: LQSpacing.lg),
            Text('Coin Keeper champion!', style: LQTypography.h2(colors)),
            const SizedBox(height: LQSpacing.sm),
            Text(
              'Replay lessons, grow your city, and keep your streak alive.',
              style: LQTypography.bodySm(colors),
            ),
            const SizedBox(height: LQSpacing.xxl),
            LQButton(
              label: 'Replay a lesson',
              colors: colors,
              expanded: true,
              onPressed: () => context.go('/learn'),
            ),
          ],
        ),
      ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0);
    }

    final lesson = current ?? kCurriculum.first;
    final stageLabel = 'Stage ${lesson.conceptOrder}';

    return LQCard(
      colors: colors,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatPill(colors: colors, label: stageLabel, variant: StatPillVariant.xp),
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
          const SizedBox(height: LQSpacing.sm),
          Text(lesson.subtitle, style: LQTypography.bodySm(colors)),
          const SizedBox(height: LQSpacing.xxl),
          LQButton(
            label: current == null ? 'Explore path' : 'Start',
            colors: colors,
            expanded: true,
            onPressed: () {
              if (current != null) {
                context.go('/lesson/${current.id}');
              } else {
                context.go('/learn');
              }
            },
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildBadgeShelf(LQColors colors) {
    final badgesAsync = ref.watch(userBadgesProvider);

    return badgesAsync.when(
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => Text('Badges unavailable', style: LQTypography.bodySm(colors)),
      data: (badges) {
        if (badges.isEmpty) {
          return LQCard(
            colors: colors,
            child: Text(
              'Complete your first lesson to earn badges',
              style: LQTypography.bodySm(colors),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: badges.map((b) {
              return Padding(
                padding: const EdgeInsets.only(right: LQSpacing.md),
                child: LQBadge(
                  colors: colors,
                  title: badgeTitle(b.id),
                  subtitle: 'Earned',
                  icon: LQDuotoneIcon(
                    icon: LQIconType.trophy,
                    size: 28,
                    primaryColor: colors.gold,
                    secondaryColor: colors.gold.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCityPreview(LQColors colors) {
    final towersAsync = ref.watch(userTowersProvider);
    final count = towersAsync.valueOrNull?.length ?? 0;
    final towers = towersAsync.valueOrNull ?? const [];

    return LQCard(
      colors: colors,
      onTap: () => context.go('/city'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your City', style: LQTypography.h3(colors)),
                const SizedBox(height: LQSpacing.xs),
                Text(
                  towersAsync.isLoading
                      ? 'Loading skyline…'
                      : count == 0
                          ? 'Build your first tower'
                          : '$count ${count == 1 ? 'tower' : 'towers'} built · Tap to visit',
                  style: LQTypography.bodySm(colors),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            height: 48,
            child: CustomPaint(
              painter: CityPreviewPainter(towers: towers, colors: colors),
            ),
          ),
        ],
      ),
    );
  }
}

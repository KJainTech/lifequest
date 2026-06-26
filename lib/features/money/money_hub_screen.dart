import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_immersive_scene.dart';
import '../../design/lq_money_tiles.dart';
import '../../data/content/lesson_catalog.dart';
import '../../features/city/city_buildings.dart';
import '../../features/city/city_providers.dart';
import '../../features/money/money_hub_snapshot.dart';
import '../../features/onboarding/auth_service.dart';

/// GoHenry-style Money hub — card, savings, tasks, spending, awards tiles.
class MoneyHubScreen extends ConsumerWidget {
  const MoneyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final lessons = ref.watch(userLessonsProvider).valueOrNull ?? const [];
    final badges = ref.watch(userBadgesProvider).valueOrNull ?? const [];
    final towers = ref.watch(userTowersProvider).valueOrNull ?? const [];
    final citySnapshot = buildCityProgress(
      lessonProgress: lessons,
      towers: towers,
      profile: profile,
    );

    final snap = MoneyHubSnapshot.from(
      stats: stats,
      lessons: lessons,
      profile: profile,
      badgeCount: badges.length,
      cityBuildings: citySnapshot.builtCount,
    );

    final current = LessonProgression.currentLesson(lessons, profile);

    return LQImmersiveScene(
      colors: colors,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LQSpacing.sm,
                  LQSpacing.xs,
                  LQSpacing.sm,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back to Me',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/profile');
                        }
                      },
                      icon: Icon(Icons.arrow_back_rounded, color: colors.ink),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Home',
                      onPressed: () => context.go('/home'),
                      icon: Icon(Icons.cottage_outlined, color: colors.ink),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(LQSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Money', style: LQTypography.display(colors)),
                    const SizedBox(height: LQSpacing.xs),
                    Text(
                      snap.questName,
                      style: LQTypography.label(colors).copyWith(color: colors.brand),
                    ),
                    const SizedBox(height: LQSpacing.xl),
                    LQBalanceHero(
                      colors: colors,
                      coins: snap.coins,
                      subtitle: '${snap.availableCoins} to spend · ${snap.savingsJar} in save jar',
                    ),
                    const SizedBox(height: LQSpacing.xxl),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: LQSpacing.md,
                      crossAxisSpacing: LQSpacing.md,
                      childAspectRatio: 1.05,
                      children: [
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'My Card',
                          subtitle: 'LQ ${snap.lqScore} · Mastery ID',
                          icon: Icons.credit_card_rounded,
                          iconBg: colors.brand,
                          trailing: LQCardMiniPreview(
                            colors: colors,
                            lqScore: snap.lqScore,
                          ),
                          onTap: () => context.push('/wallet'),
                        ).animate().fadeIn(delay: 40.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'Savings',
                          subtitle: '${snap.savingsJar} coins for goals — not for spending today',
                          icon: Icons.savings_rounded,
                          iconBg: colors.blue,
                          onTap: () => context.go('/awards'),
                        ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'Daily Quest',
                          subtitle: snap.currentTaskLabel,
                          icon: Icons.task_alt_rounded,
                          iconBg: colors.warn,
                          onTap: () {
                            if (current != null) {
                              context.push('/lesson/${current.id}');
                            } else {
                              context.go('/learn');
                            }
                          },
                        ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'Streak Bonus',
                          subtitle: snap.streakBonusLabel,
                          icon: Icons.local_fire_department_rounded,
                          iconBg: colors.coral,
                          onTap: () => context.go('/awards'),
                        ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'This Week',
                          subtitle: '${snap.weeklySessions} stage${snap.weeklySessions == 1 ? '' : 's'} completed',
                          icon: Icons.pie_chart_outline_rounded,
                          iconBg: colors.gold,
                          onTap: () => context.go('/awards'),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'Awards',
                          subtitle: '${snap.badgeCount} badge${snap.badgeCount == 1 ? '' : 's'} earned',
                          icon: Icons.emoji_events_outlined,
                          iconBg: colors.gold,
                          onTap: () => context.go('/awards'),
                        ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'Lemon City',
                          subtitle: '${snap.cityBuildings}/$kTotalStages buildings',
                          icon: Icons.location_city_outlined,
                          iconBg: colors.brand,
                          onTap: () => context.go('/city'),
                        ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.06, end: 0),
                        LQMoneyFeatureTile(
                          colors: colors,
                          title: 'Business IQ',
                          subtitle: '${snap.businessIQAvg}/100 avg score',
                          icon: Icons.insights_rounded,
                          iconBg: colors.info,
                          onTap: () => context.go('/awards'),
                        ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.06, end: 0),
                      ],
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    SizedBox(
                      height: 72,
                      child: LQMoneyFeatureTile(
                        colors: colors,
                        title: 'Learn & Earn',
                        subtitle: 'Complete stages to grow coins and your city',
                        icon: Icons.school_outlined,
                        iconBg: colors.brandDeep,
                        wide: true,
                        onTap: () => context.go('/learn'),
                      ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.04, end: 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

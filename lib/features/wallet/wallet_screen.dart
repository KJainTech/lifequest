import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_card.dart';
import '../../design/lq_immersive_scene.dart';
import '../../design/lq_mastery_card.dart';
import '../../design/lq_quest_ladder.dart';
import '../../features/onboarding/auth_service.dart';

/// Wallet hub — mastery card, coins balance, quest ladder (GoHenry-inspired).
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final lessons = ref.watch(userLessonsProvider).valueOrNull ?? const [];
    final name = profile?.displayName ?? 'Explorer';
    final questLevel = LessonProgression.displayQuestLevel(lessons, profile);
    final questName = LessonProgression.displayQuestLevelName(lessons, profile);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: LQImmersiveScene(
        colors: colors,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LQSpacing.sm,
                    vertical: LQSpacing.xs,
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
                        icon: Icon(Icons.arrow_back_ios_new, color: colors.ink, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          'My Card',
                          style: LQTypography.h3(colors),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Me',
                        onPressed: () => context.go('/profile'),
                        icon: Icon(Icons.person_outline_rounded, color: colors.ink, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LQSpacing.gutter,
                    0,
                    LQSpacing.gutter,
                    LQSpacing.gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Coins you earn stay yours — no fake bank, just real progress',
                        style: LQTypography.bodySm(colors),
                      ),
                      const SizedBox(height: LQSpacing.xl),
                      _BalanceHeader(colors: colors, coins: stats.coins),
                      const SizedBox(height: LQSpacing.lg),
                      LQMasteryCard(
                        colors: colors,
                        displayName: name,
                        coins: stats.coins,
                        lqScore: stats.lqScore,
                        questLevelName: questName,
                        streakDays: stats.streak.count,
                        questLevel: questLevel,
                      ),
                      const SizedBox(height: LQSpacing.lg),
                      LQCardQuickActions(
                        colors: colors,
                        onEarn: () => context.go('/learn'),
                        onSave: () {},
                        onCity: () => context.go('/city'),
                        onProgress: () => context.go('/awards'),
                      ),
                      const SizedBox(height: LQSpacing.xxl),
                      LQCard(
                        colors: colors,
                        child: LQQuestLadder(
                          colors: colors,
                          progress: lessons,
                          profile: profile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.colors, required this.coins});

  final LQColors colors;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LQSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.brand, colors.brandDeep],
        ),
        borderRadius: BorderRadius.circular(LQRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your coin balance',
            style: LQTypography.bodySm(colors).copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: LQSpacing.xs),
          Text(
            '$coins',
            style: LQTypography.display(colors).copyWith(
              color: colors.gold,
              fontSize: 40,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

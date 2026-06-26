import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/lq_theme.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../design/lq_immersive_scene.dart';
import 'concept_game_types.dart';

/// Browse and play all five money concept mini-games.
class ConceptGamesHubScreen extends ConsumerWidget {
  const ConceptGamesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);

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
                  LQSpacing.gutter,
                  LQSpacing.md,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.canPop() ? context.pop() : context.go('/learn'),
                      icon: Icon(Icons.arrow_back_rounded, color: colors.ink),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Concept Games', style: LQTypography.display(colors)),
                          Text(
                            'Five quick games — tap any to practice',
                            style: LQTypography.bodySm(colors),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: LQSpacing.gutter),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final id = kAllConceptGames[i];
                    final info = infoFor(id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: LQSpacing.md),
                      child: _GameCard(
                        colors: colors,
                        info: info,
                        delay: (i * 60).ms,
                        onTap: () {
                          if (id == ConceptGameId.lemonCity) {
                            context.push('/lesson/lesson_6');
                          } else {
                            context.push('/concept-games/${id.name}');
                          }
                        },
                      ),
                    );
                  },
                  childCount: kAllConceptGames.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: LQSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.colors,
    required this.info,
    required this.delay,
    required this.onTap,
  });

  final LQColors colors;
  final ConceptGameInfo info;
  final Duration delay;
  final VoidCallback onTap;

  IconData get _icon => switch (info.icon) {
        'sort' => Icons.swap_horiz_rounded,
        'jar' => Icons.savings_rounded,
        'jars' => Icons.account_balance_wallet_outlined,
        'deal' => Icons.local_offer_outlined,
        _ => Icons.local_cafe_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final accent = Color(info.accent);
    final surface = Color(info.surface);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(LQRadius.card),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LQRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LQRadius.card),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
            gradient: LinearGradient(
              colors: [surface, surface.withValues(alpha: 0.6)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(LQSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(LQRadius.control),
                  ),
                  child: Icon(_icon, color: accent, size: 28),
                ),
                const SizedBox(width: LQSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: LQTypography.h3(colors).copyWith(color: accent),
                      ),
                      Text(info.subtitle, style: LQTypography.bodySm(colors)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(LQRadius.pill),
                        ),
                        child: Text(
                          info.conceptLabel,
                          style: LQTypography.micro(colors).copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_fill_rounded, color: accent, size: 36),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: delay).fadeIn().slideX(begin: 0.06, end: 0);
  }
}

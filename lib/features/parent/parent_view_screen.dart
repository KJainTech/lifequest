import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/models/lq_models.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../features/onboarding/auth_service.dart';

/// Parent view behind gate — Business IQ + coach note (lightweight §5.14).
class ParentViewScreen extends ConsumerWidget {
  const ParentViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final name = profile?.displayName ?? 'your child';

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
                    Text('Parent view', style: LQTypography.display(colors)),
                    const SizedBox(height: LQSpacing.sm),
                    Text(
                      'Summary for $name — calm and specific',
                      style: LQTypography.bodySm(colors),
                    ),
                    const SizedBox(height: LQSpacing.xxl),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Business IQ', style: LQTypography.h3(colors)),
                          const SizedBox(height: LQSpacing.lg),
                          _RowStat(colors: colors, label: 'Profit sense', value: stats.businessIQ.profit),
                          _RowStat(colors: colors, label: 'Decision quality', value: stats.businessIQ.decision),
                          _RowStat(colors: colors, label: 'Resilience', value: stats.businessIQ.resilience),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This week', style: LQTypography.h3(colors)),
                          const SizedBox(height: LQSpacing.sm),
                          Text(
                            'LQ ${stats.lqScore} · Level ${stats.level} · '
                            '${stats.streak.count}-day streak',
                            style: LQTypography.bodySm(colors),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ParentCoach tip', style: LQTypography.h3(colors)),
                          const SizedBox(height: LQSpacing.sm),
                          Text(
                            stats.businessIQ.profit >= 10
                                ? '$name is building strong profit sense. '
                                    'Try a real AED purchase together: need or want?'
                                : '$name is just getting started. '
                                    'Talk about one thing they wanted vs needed this week.',
                            style: LQTypography.bodySm(colors),
                          ),
                          const SizedBox(height: LQSpacing.md),
                          Text(
                            'Activity: Pick one small purchase and decide together.',
                            style: LQTypography.label(colors).copyWith(color: colors.brand),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    Text(
                      'For full reports and controls, use the web dashboard.',
                      style: LQTypography.micro(colors),
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

class _RowStat extends StatelessWidget {
  const _RowStat({
    required this.colors,
    required this.label,
    required this.value,
  });

  final LQColors colors;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LQSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: LQTypography.bodySm(colors))),
          Text('$value/100', style: LQTypography.label(colors)),
        ],
      ),
    );
  }
}

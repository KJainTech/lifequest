import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_canvas.dart';

/// FAQ — Kids / Parents / Schools (DevPlan Phase 6).
class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _kids = [
    ('What is LifeQuest?', 'A game that teaches money skills through stories and play.'),
    ('Do I lose progress if I stop?', 'Never — your city and stages stay saved.'),
    ('Can I change my guide?', 'Yes — open Profile and pick Penny, FinBot, or Atlas.'),
  ];
  static const _parents = [
    ('Is my child\'s data safe?', 'We show streaks and milestones — not specific wrong answers.'),
    ('What currency is used?', 'AED throughout, with UAE-friendly examples.'),
    ('How long should they play?', 'About 20 minutes a day is ideal; break reminders appear at 30.'),
  ];
  static const _schools = [
    ('Can teachers track classes?', 'Teacher dashboard supports class codes (pilot).'),
    ('Alignment?', '48 stages across 6 quest levels — Coin Keeper through CMO.'),
    ('Pilot support?', 'Contact Amara Wealth AI for school onboarding.'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);

    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(LQSpacing.gutter),
              child: Text('FAQ', style: LQTypography.display(colors)),
            ),
            TabBar(
              controller: _tabs,
              labelColor: colors.brand,
              tabs: const [
                Tab(text: 'Kids'),
                Tab(text: 'Parents'),
                Tab(text: 'Schools'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _FaqList(colors: colors, items: _kids),
                  _FaqList(colors: colors, items: _parents),
                  _FaqList(colors: colors, items: _schools),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.colors, required this.items});

  final LQColors colors;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(LQSpacing.gutter),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: LQSpacing.md),
      itemBuilder: (context, i) {
        final (q, a) = items[i];
        return Container(
          padding: const EdgeInsets.all(LQSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(LQRadius.control),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q, style: LQTypography.h3(colors)),
              const SizedBox(height: LQSpacing.sm),
              Text(a, style: LQTypography.bodySm(colors)),
            ],
          ),
        );
      },
    );
  }
}

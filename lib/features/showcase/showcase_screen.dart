import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/motion/lq_motion.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_badge.dart';
import '../../design/lq_bottom_nav.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/lq_icons.dart';
import '../../design/penny_mascot.dart';
import '../../design/progress_arc.dart';
import '../../design/stat_pill.dart';

/// Phase 1 showcase — every design-system component + Penny's 8 states
class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen> {
  PennyGuideState _pennyState = PennyGuideState.idle;
  LQNavTab _navTab = LQNavTab.home;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final world = ref.watch(ageWorldProvider);

    return Scaffold(
      body: LQCanvas(
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
                      _buildHeader(colors),
                      const SizedBox(height: LQSpacing.xxl),
                      _buildWorldSwitcher(colors, world),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Penny — 8 Expression States'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildPennySection(colors),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Buttons'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildButtons(colors),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Cards & Hero Progress'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildCards(colors),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Stat Pills'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildStatPills(colors),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Progress Arc'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildProgressArc(colors),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Badges'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildBadges(colors),
                      const SizedBox(height: LQSpacing.xxxl),
                      _sectionTitle(colors, 'Duotone Icons'),
                      const SizedBox(height: LQSpacing.lg),
                      _buildIcons(colors),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: LQBottomNav(
        colors: colors,
        current: _navTab,
        onChanged: (tab) => setState(() => _navTab = tab),
      ),
    );
  }

  Widget _buildHeader(LQColors colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LifeQuest', style: LQTypography.display(colors)),
              Text(
                'Design System Showcase · Phase 1',
                style: LQTypography.bodySm(colors),
              ),
            ],
          ),
        ),
        PennyMascot(state: _pennyState, size: 72),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildWorldSwitcher(LQColors colors, AgeWorld current) {
    return Wrap(
      spacing: LQSpacing.sm,
      children: AgeWorld.values.map((world) {
        final isActive = world == current;
        final label = switch (world) {
          AgeWorld.penny => 'Penny (5–8)',
          AgeWorld.finBot => 'FinBot (9–12)',
          AgeWorld.atlas => 'Atlas (13–17)',
        };
        return GestureDetector(
          onTap: () => ref.read(ageWorldProvider.notifier).state = world,
          child: AnimatedContainer(
            duration: LQMotion.adaptiveDuration(const Duration(milliseconds: 200)),
            padding: const EdgeInsets.symmetric(
              horizontal: LQSpacing.lg,
              vertical: LQSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive ? colors.brand : colors.surface,
              borderRadius: BorderRadius.circular(LQRadius.chip),
              boxShadow: isActive ? LQElevation.e1(colors.ink) : null,
              border: Border.all(
                color: isActive
                    ? colors.brand
                    : colors.inkSoft.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              label,
              style: LQTypography.caption(colors).copyWith(
                color: isActive ? Colors.white : colors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(LQColors colors, String title) {
    return Text(title, style: LQTypography.h2(colors));
  }

  Widget _buildPennySection(LQColors colors) {
    return LQCard(
      colors: colors,
      child: Column(
        children: [
          Center(
            child: PennyMascot(
              key: ValueKey(_pennyState),
              state: _pennyState,
              size: 180,
            ),
          ),
          const SizedBox(height: LQSpacing.xxl),
          Text(
            _stateLabel(_pennyState),
            style: LQTypography.h3(colors),
          ),
          const SizedBox(height: LQSpacing.lg),
          Wrap(
            spacing: LQSpacing.sm,
            runSpacing: LQSpacing.sm,
            alignment: WrapAlignment.center,
            children: PennyGuideState.values.map((state) {
              final isActive = state == _pennyState;
              return GestureDetector(
                onTap: () => setState(() => _pennyState = state),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LQSpacing.md,
                    vertical: LQSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.brand.withValues(alpha: 0.15)
                        : colors.canvasEnd,
                    borderRadius: BorderRadius.circular(LQRadius.control),
                    border: Border.all(
                      color: isActive ? colors.brand : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    _stateLabel(state),
                    style: LQTypography.caption(colors).copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? colors.brand : colors.inkSoft,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildButtons(LQColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LQButton(
          label: 'Start Lesson',
          colors: colors,
          onPressed: () {},
          expanded: true,
        ),
        const SizedBox(height: LQSpacing.md),
        Row(
          children: [
            Expanded(
              child: LQButton(
                label: 'Secondary',
                colors: colors,
                variant: LQButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: LQSpacing.md),
            Expanded(
              child: LQButton(
                label: 'Ghost',
                colors: colors,
                variant: LQButtonVariant.ghost,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCards(LQColors colors) {
    return Column(
      children: [
        LQHeroCard(
          colors: colors,
          level: 7,
          xp: 9450,
          xpProgress: 0.72,
          lqScore: 642,
          trendLabel: 'On track',
        ),
        const SizedBox(height: LQSpacing.lg),
        LQCard(
          colors: colors,
          child: Row(
            children: [
              LQDuotoneIcon(
                icon: LQIconType.coffee,
                primaryColor: colors.brand,
                secondaryColor: colors.brand.withValues(alpha: 0.2),
              ),
              const SizedBox(width: LQSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Mission", style: LQTypography.caption(colors)),
                    Text(
                      'Save AED 10 on coffee this week',
                      style: LQTypography.h3(colors),
                    ),
                  ],
                ),
              ),
              LQButton(
                label: 'Skip',
                colors: colors,
                variant: LQButtonVariant.ghost,
                size: LQButtonSize.sm,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatPills(LQColors colors) {
    return Wrap(
      spacing: LQSpacing.sm,
      runSpacing: LQSpacing.sm,
      children: [
        StatPill(
          colors: colors,
          label: '450 XP',
          variant: StatPillVariant.xp,
          icon: LQDuotoneIcon(
            icon: LQIconType.progress,
            size: 16,
            primaryColor: colors.accentViolet,
            secondaryColor: colors.accentViolet.withValues(alpha: 0.3),
          ),
        ),
        StatPill(
          colors: colors,
          label: '120 Coins',
          variant: StatPillVariant.coins,
          icon: LQDuotoneIcon(
            icon: LQIconType.coin,
            size: 16,
            primaryColor: colors.gold,
            secondaryColor: colors.gold.withValues(alpha: 0.3),
          ),
        ),
        StatPill(
          colors: colors,
          label: '+3%',
          variant: StatPillVariant.trend,
        ),
        StatPill(
          colors: colors,
          label: '5-day streak',
          variant: StatPillVariant.streak,
        ),
      ],
    );
  }

  Widget _buildProgressArc(LQColors colors) {
    return Center(
      child: SpendingArc(
        colors: colors,
        total: 'AED 3,201',
        percentUsed: 0.62,
        segments: [
          ArcSegment(value: 0.35, color: colors.success),
          ArcSegment(value: 0.27, color: colors.accentViolet),
          ArcSegment(value: 0.38, color: colors.blue),
        ],
        centerWidget: PennyMascot(state: PennyGuideState.idle, size: 80),
      ),
    );
  }

  Widget _buildBadges(LQColors colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          LQBadge(
            colors: colors,
            title: 'Level 4',
            subtitle: 'AED 100 Saved',
            icon: PennyMascot(state: PennyGuideState.happy, size: 40),
          ),
          LQBadge(
            colors: colors,
            title: '10 Cups',
            subtitle: 'AED 30 Saved',
            icon: LQDuotoneIcon(
              icon: LQIconType.coffee,
              size: 28,
              primaryColor: colors.brand,
              secondaryColor: colors.brand.withValues(alpha: 0.3),
            ),
          ),
          LQBadge(
            colors: colors,
            title: 'Grocery Guru',
            subtitle: 'AED 60 Saved',
            icon: LQDuotoneIcon(
              icon: LQIconType.piggyBank,
              size: 28,
              primaryColor: colors.gold,
              secondaryColor: colors.gold.withValues(alpha: 0.3),
            ),
          ),
          LQBadge(
            colors: colors,
            title: 'Super Saver',
            subtitle: 'Locked',
            locked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildIcons(LQColors colors) {
    return Wrap(
      spacing: LQSpacing.xl,
      runSpacing: LQSpacing.xl,
      children: LQIconType.values.map((icon) {
        return Column(
          children: [
            LQDuotoneIcon(
              icon: icon,
              size: 32,
              primaryColor: colors.brand,
              secondaryColor: colors.brand.withValues(alpha: 0.25),
            ),
            const SizedBox(height: LQSpacing.xs),
            Text(
              icon.name,
              style: LQTypography.micro(colors),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _stateLabel(PennyGuideState state) => switch (state) {
        PennyGuideState.idle => 'Idle',
        PennyGuideState.happy => 'Happy',
        PennyGuideState.think => 'Think',
        PennyGuideState.worried => 'Worried',
        PennyGuideState.celebrate => 'Celebrate',
        PennyGuideState.wave => 'Wave',
        PennyGuideState.sleep => 'Sleep',
        PennyGuideState.levelUp => 'Level Up',
      };
}

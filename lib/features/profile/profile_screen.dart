import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/lq_sound_service.dart';
import '../../app/bootstrap/firebase_providers.dart';
import '../../app/locale/locale_provider.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/lq_mastery_card.dart';
import '../../design/lq_money_tiles.dart';
import '../../design/guide_mascot.dart';
import '../../design/penny_mascot.dart';
import '../../features/city/city_providers.dart';
import '../../features/money/money_hub_snapshot.dart';
import '../../features/onboarding/age_band.dart';
import '../../features/onboarding/auth_service.dart';
import '../../features/parent/parental_gate.dart';
import '../../features/parent/parent_view_screen.dart';

/// Me — identity, balance, mastery card, settings. (Play lives on Home.)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _soundOn = LQSound.enabled;
  bool _savingGuide = false;

  Future<void> _setLocale(String locale) async {
    ref.read(appLocaleProvider.notifier).state = locale;
    final user = ref.read(authProvider).valueOrNull;
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (user != null && profile != null) {
      await ref.read(profileRepositoryProvider).saveProfile(
            UserProfile(
              uid: profile.uid,
              role: profile.role,
              displayName: profile.displayName,
              ageBand: profile.ageBand,
              guide: profile.guide,
              proficiencyLevel: profile.proficiencyLevel,
              locale: locale,
              region: profile.region,
              onboardingComplete: profile.onboardingComplete,
              age: profile.age,
            ),
          );
    }
  }

  Future<void> _setGuide(String guideId) async {
    if (_savingGuide) return;
    setState(() => _savingGuide = true);
    ref.read(ageWorldProvider.notifier).state = guideToWorld(guideId);
    final user = ref.read(authProvider).valueOrNull;
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (user != null && profile != null) {
      await ref.read(profileRepositoryProvider).saveProfile(
            UserProfile(
              uid: profile.uid,
              role: profile.role,
              displayName: profile.displayName,
              ageBand: profile.ageBand,
              guide: guideId,
              proficiencyLevel: profile.proficiencyLevel,
              locale: profile.locale,
              region: profile.region,
              onboardingComplete: profile.onboardingComplete,
              age: profile.age,
            ),
          );
      ref.invalidate(userProfileProvider);
    }
    if (mounted) setState(() => _savingGuide = false);
  }

  void _openParentArea() {
    final colors = ref.read(lqColorsProvider);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ParentalGate(
          colors: colors,
          onUnlocked: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ParentViewScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final stats = ref.watch(userStatsProvider).valueOrNull ?? UserStats.empty;
    final lessons = ref.watch(userLessonsProvider).valueOrNull ?? const [];
    final badges = ref.watch(userBadgesProvider).valueOrNull ?? const [];
    final towers = ref.watch(userTowersProvider).valueOrNull ?? const [];
    final locale = ref.watch(appLocaleProvider);
    final guide = profile?.guide ?? 'penny';
    final name = profile?.displayName ?? 'Explorer';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'E';
    final questLevel = LessonProgression.displayQuestLevel(lessons, profile);
    final questName = LessonProgression.displayQuestLevelName(lessons, profile);
    final snap = MoneyHubSnapshot.from(
      stats: stats,
      lessons: lessons,
      profile: profile,
      badgeCount: badges.length,
      cityBuildings: towers.length,
    );

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
                    Text('Me', style: LQTypography.display(colors)),
                    const SizedBox(height: LQSpacing.xs),
                    Text(
                      'Your coins, card & settings',
                      style: LQTypography.bodySm(colors),
                    ),
                    const SizedBox(height: LQSpacing.xl),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colors.accentMint,
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
                              Text(name, style: LQTypography.h2(colors)),
                              Text(questName, style: LQTypography.bodySm(colors)),
                            ],
                          ),
                        ),
                        GuideMascot(
                          guide: LQGuideX.fromId(guide),
                          size: 44,
                          state: PennyGuideState.idle,
                        ),
                      ],
                    ),
                    const SizedBox(height: LQSpacing.xl),
                    _SectionLabel(title: 'My balance', colors: colors),
                    const SizedBox(height: LQSpacing.sm),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LQBalanceHero(
                            colors: colors,
                            coins: snap.coins,
                            subtitle: 'Total coins earned',
                          ),
                          const SizedBox(height: LQSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: _BalanceChip(
                                  colors: colors,
                                  label: 'Available',
                                  value: '${snap.availableCoins}',
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ),
                              const SizedBox(width: LQSpacing.sm),
                              Expanded(
                                child: _BalanceChip(
                                  colors: colors,
                                  label: 'Savings jar',
                                  value: '${snap.savingsJar}',
                                  icon: Icons.savings_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LQSpacing.sm),
                          Text(
                            snap.streakBonusLabel,
                            style: LQTypography.micro(colors),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    _SectionLabel(title: 'Mastery card', colors: colors),
                    const SizedBox(height: LQSpacing.sm),
                    LQMasteryCard(
                      colors: colors,
                      displayName: name,
                      coins: stats.coins,
                      lqScore: stats.lqScore,
                      questLevelName: questName,
                      streakDays: stats.streak.count,
                      questLevel: questLevel,
                      onTap: () => context.push('/wallet'),
                    ),
                    const SizedBox(height: LQSpacing.xxl),
                    _SectionLabel(title: 'Settings', colors: colors),
                    const SizedBox(height: LQSpacing.sm),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Guide', style: LQTypography.h3(colors)),
                          const SizedBox(height: LQSpacing.md),
                          ...['penny', 'finBot', 'atlas'].map((id) {
                            final selected = guide == id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: LQSpacing.sm),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: GuideMascot(
                                  guide: LQGuideX.fromId(id),
                                  size: 44,
                                  state: selected
                                      ? PennyGuideState.happy
                                      : PennyGuideState.idle,
                                ),
                                title: Text(
                                  guideDisplayName(id),
                                  style: LQTypography.body(colors).copyWith(
                                    fontWeight:
                                        selected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                trailing: selected
                                    ? Icon(Icons.check_circle_rounded, color: colors.brand)
                                    : null,
                                onTap: _savingGuide ? null : () => _setGuide(id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Language', style: LQTypography.h3(colors)),
                          const SizedBox(height: LQSpacing.md),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'en', label: Text('English')),
                              ButtonSegment(value: 'ar', label: Text('العربية')),
                            ],
                            selected: {locale},
                            onSelectionChanged: (s) => _setLocale(s.first),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Sound', style: LQTypography.bodySm(colors)),
                        value: _soundOn,
                        onChanged: (v) {
                          setState(() => _soundOn = v);
                          LQSound.enabled = v;
                          if (v) LQSound.tap();
                        },
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      onTap: () => context.push('/money'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Money hub', style: LQTypography.h3(colors)),
                                const SizedBox(height: LQSpacing.xs),
                                Text(
                                  'Balance, savings, streak, and city progress',
                                  style: LQTypography.bodySm(colors),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: colors.inkSoft),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      onTap: () => context.push('/faq'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('FAQ', style: LQTypography.h3(colors)),
                          ),
                          Icon(Icons.chevron_right_rounded, color: colors.inkSoft),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      onTap: _openParentArea,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parents', style: LQTypography.h3(colors)),
                                Text(
                                  'Grown-up summary · tap to unlock',
                                  style: LQTypography.bodySm(colors),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.lock_outline_rounded, color: colors.inkSoft),
                        ],
                      ),
                    ),
                    const SizedBox(height: LQSpacing.xxl),
                    LQButton(
                      label: 'Sign out',
                      colors: colors,
                      variant: LQButtonVariant.secondary,
                      expanded: true,
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) context.go('/');
                      },
                    ),
                    const SizedBox(height: 88),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.colors});
  final String title;
  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: LQTypography.micro(colors).copyWith(
        letterSpacing: 1,
        fontWeight: FontWeight.w700,
        color: colors.inkSoft,
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.colors,
    required this.label,
    required this.value,
    required this.icon,
  });

  final LQColors colors;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LQSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(LQRadius.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.brand),
          const SizedBox(height: LQSpacing.xs),
          Text(value, style: LQTypography.h3(colors)),
          Text(label, style: LQTypography.micro(colors)),
        ],
      ),
    );
  }
}

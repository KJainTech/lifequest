import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/locale/locale_provider.dart';
import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/models/lq_models.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../features/onboarding/age_band.dart';
import '../../features/onboarding/auth_service.dart';
import '../../features/parent/parental_gate.dart';
import '../../features/parent/parent_view_screen.dart';

/// Profile tab — settings, locale, parent gate entry.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _parentUnlocked = false;
  bool _soundOn = true;

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

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final locale = ref.watch(appLocaleProvider);
    final guide = profile?.guide ?? 'penny';

    if (!_parentUnlocked) {
      return ParentalGate(
        colors: colors,
        onUnlocked: () => setState(() => _parentUnlocked = true),
      );
    }

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
                    Row(
                      children: [
                        Expanded(
                          child: Text('Profile', style: LQTypography.display(colors)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _parentUnlocked = false),
                          child: Text('Lock', style: LQTypography.label(colors)),
                        ),
                      ],
                    ),
                    const SizedBox(height: LQSpacing.xxl),
                    LQCard(
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Guide', style: LQTypography.h3(colors)),
                          Text(
                            guideDisplayName(guide),
                            style: LQTypography.h2(colors),
                          ),
                          Text(guidePersonality(guide), style: LQTypography.bodySm(colors)),
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
                        title: Text('Sound', style: LQTypography.bodySm(colors)),
                        value: _soundOn,
                        onChanged: (v) => setState(() => _soundOn = v),
                      ),
                    ),
                    const SizedBox(height: LQSpacing.lg),
                    LQCard(
                      colors: colors,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ParentViewScreen(),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parent summary', style: LQTypography.h3(colors)),
                                Text(
                                  'Business IQ and coach tips',
                                  style: LQTypography.bodySm(colors),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: colors.inkSoft),
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory onboarding draft — persisted to Firestore on completion.
class OnboardingDraft {
  const OnboardingDraft({
    this.age = 8,
    this.guide = 'penny',
    this.wantsScreening = false,
    this.displayName = 'Explorer',
    this.locale = 'en',
  });

  final int age;
  final String guide;
  final bool wantsScreening;
  final String displayName;
  final String locale;

  OnboardingDraft copyWith({
    int? age,
    String? guide,
    bool? wantsScreening,
    String? displayName,
    String? locale,
  }) {
    return OnboardingDraft(
      age: age ?? this.age,
      guide: guide ?? this.guide,
      wantsScreening: wantsScreening ?? this.wantsScreening,
      displayName: displayName ?? this.displayName,
      locale: locale ?? this.locale,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingDraft> {
  OnboardingNotifier() : super(const OnboardingDraft());

  void setAge(int age) => state = state.copyWith(age: age.clamp(5, 17));
  void setGuide(String guide) => state = state.copyWith(guide: guide);
  void setWantsScreening(bool value) =>
      state = state.copyWith(wantsScreening: value);
  void setDisplayName(String name) => state = state.copyWith(displayName: name);
  void setLocale(String locale) => state = state.copyWith(locale: locale);
}

final onboardingDraftProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingDraft>(
  (ref) => OnboardingNotifier(),
);

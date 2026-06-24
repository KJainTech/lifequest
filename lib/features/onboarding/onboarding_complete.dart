import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../../app/theme/lq_theme.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_progression.dart';
import 'age_band.dart';
import 'auth_service.dart';
import 'onboarding_state.dart';

class ScreeningResult {
  const ScreeningResult({
    required this.placementLevel,
    required this.skipAhead,
    required this.message,
    required this.correct,
    required this.total,
  });

  final int placementLevel;
  final bool skipAhead;
  final String message;
  final int correct;
  final int total;
}

final screeningResultProvider = StateProvider<ScreeningResult?>((ref) => null);

Future<void> completeOnboarding({
  required WidgetRef ref,
  required int proficiencyLevel,
}) async {
  final auth = ref.read(authServiceProvider);
  final draft = ref.read(onboardingDraftProvider);
  final user = await auth.signInAnonymously();

  await auth.saveOnboardingProfile(
    uid: user.uid,
    age: draft.age,
    ageBand: ageToBand(draft.age),
    guide: draft.guide,
    proficiencyLevel: proficiencyLevel,
    locale: draft.locale,
    displayName: draft.displayName,
  );

  final startOrder = LessonProgression.startingOrderFromLevel(proficiencyLevel);
  final startLesson = kCurriculum.firstWhere((l) => l.conceptOrder == startOrder);
  await ref.read(progressRepositoryProvider).ensureLessonAvailable(
        user.uid,
        startLesson.id,
      );

  ref.read(ageWorldProvider.notifier).state = guideToWorld(draft.guide);
}

Future<ScreeningResult> submitScreeningToServer({
  required WidgetRef ref,
  required List<Map<String, dynamic>> answerPayload,
}) async {
  final functions = ref.read(cloudFunctionsProvider);
  final data = await functions.runScreening(answers: answerPayload);
  return ScreeningResult(
    placementLevel: (data['placementLevel'] as num?)?.toInt() ?? 1,
    skipAhead: data['skipAhead'] as bool? ?? false,
    message: data['message'] as String? ?? 'Let\'s start at the beginning',
    correct: (data['correct'] as num?)?.toInt() ?? 0,
    total: (data['total'] as num?)?.toInt() ?? answerPayload.length,
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/firebase_providers.dart';
import '../content/lesson_progression.dart';
import '../models/lq_models.dart';
import '../scoring/lq_scoring.dart';
import 'cloud_functions_service.dart';

/// Completes a lesson via Cloud Functions, with a Firestore fallback so kids
/// never get stuck when the backend hiccups.
class LessonCompletionService {
  LessonCompletionService({
    required CloudFunctionsService functions,
    required this.uid,
    required this.getStats,
    required this.markLessonCompleted,
    required this.ensureLessonAvailable,
  }) : _functions = functions;

  final CloudFunctionsService _functions;
  final String uid;
  final Future<UserStats> Function() getStats;
  final Future<void> Function(String lessonId) markLessonCompleted;
  final Future<void> Function(String lessonId) ensureLessonAvailable;

  Future<LessonCompletionResult> complete({
    required String lessonId,
    required int quizScore,
    required bool gameWon,
    required double gameProfit,
  }) async {
    try {
      final result = await _functions.completeLesson(
        lessonId: lessonId,
        quizScore: quizScore,
        gameWon: gameWon,
        gameProfit: gameProfit,
      );
      await _unlockNext(lessonId);
      return result;
    } catch (_) {
      return _completeLocally(
        lessonId: lessonId,
        quizScore: quizScore,
        gameWon: gameWon,
        gameProfit: gameProfit,
      );
    }
  }

  Future<LessonCompletionResult> _completeLocally({
    required String lessonId,
    required int quizScore,
    required bool gameWon,
    required double gameProfit,
  }) async {
    final stats = await getStats();
    final result = LQScoring.computeFallbackCompletion(
      lessonId: lessonId,
      quizScore: quizScore,
      gameWon: gameWon,
      gameProfit: gameProfit,
      stats: stats,
    );

    try {
      await markLessonCompleted(lessonId);
      await _unlockNext(lessonId);
    } catch (_) {
      // UI still advances — progress may sync on next successful completion.
    }

    return result;
  }

  Future<void> _unlockNext(String completedLessonId) async {
    final next = LessonProgression.nextAfter(completedLessonId);
    if (next == null) return;
    try {
      await ensureLessonAvailable(next.id);
    } catch (_) {}
  }
}

final lessonCompletionServiceProvider = Provider<LessonCompletionService?>((ref) {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return null;
  final progressRepo = ref.watch(progressRepositoryProvider);
  return LessonCompletionService(
    functions: ref.watch(cloudFunctionsProvider),
    uid: user.uid,
    getStats: () => ref.read(statsRepositoryProvider).getStats(user.uid),
    markLessonCompleted: (lessonId) =>
        progressRepo.markLessonCompleted(user.uid, lessonId),
    ensureLessonAvailable: (lessonId) =>
        progressRepo.ensureLessonAvailable(user.uid, lessonId),
  );
});

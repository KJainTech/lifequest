import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson_content.dart';
import '../../data/repositories/content_repository.dart';

enum LessonPhase { read, quiz, game, reward }

class LessonSession {
  const LessonSession({
    required this.lessonId,
    this.phase = LessonPhase.read,
    this.readIndex = 0,
    this.quizQuestionIndex = 0,
    this.quizAnswers = const [],
    this.hearts = 3,
    this.quizScore,
    this.quizSubmitted = false,
    this.gameWon,
    this.gameProfit,
    this.gameRevenue,
    this.gameCost,
    this.completionResult,
    this.isLoading = false,
    this.error,
  });

  final String lessonId;
  final LessonPhase phase;
  final int readIndex;
  final int quizQuestionIndex;
  final List<int> quizAnswers;
  final int hearts;
  final int? quizScore;
  final bool quizSubmitted;
  final bool? gameWon;
  final double? gameProfit;
  final double? gameRevenue;
  final double? gameCost;
  final Map<String, dynamic>? completionResult;
  final bool isLoading;
  final String? error;

  LessonSession copyWith({
    LessonPhase? phase,
    int? readIndex,
    int? quizQuestionIndex,
    List<int>? quizAnswers,
    int? hearts,
    int? quizScore,
    bool? quizSubmitted,
    bool? gameWon,
    double? gameProfit,
    double? gameRevenue,
    double? gameCost,
    Map<String, dynamic>? completionResult,
    bool? isLoading,
    String? error,
  }) {
    return LessonSession(
      lessonId: lessonId,
      phase: phase ?? this.phase,
      readIndex: readIndex ?? this.readIndex,
      quizQuestionIndex: quizQuestionIndex ?? this.quizQuestionIndex,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      hearts: hearts ?? this.hearts,
      quizScore: quizScore ?? this.quizScore,
      quizSubmitted: quizSubmitted ?? this.quizSubmitted,
      gameWon: gameWon ?? this.gameWon,
      gameProfit: gameProfit ?? this.gameProfit,
      gameRevenue: gameRevenue ?? this.gameRevenue,
      gameCost: gameCost ?? this.gameCost,
      completionResult: completionResult ?? this.completionResult,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LessonSessionNotifier extends StateNotifier<LessonSession?> {
  LessonSessionNotifier() : super(null);

  void start(String lessonId) {
    state = LessonSession(lessonId: lessonId);
  }

  void clear() => state = null;

  void advanceRead(int totalParagraphs) {
    if (state == null) return;
    if (state!.readIndex + 1 >= totalParagraphs) {
      state = state!.copyWith(phase: LessonPhase.quiz, readIndex: 0);
    } else {
      state = state!.copyWith(readIndex: state!.readIndex + 1);
    }
  }

  void recordQuizAnswer(int answerIndex, {required bool correct}) {
    if (state == null) return;

    if (!correct) {
      state = state!.copyWith(
        hearts: (state!.hearts - 1).clamp(0, 3),
      );
      return;
    }

    final answers = [...state!.quizAnswers, answerIndex];
    final nextQ = state!.quizQuestionIndex + 1;
    state = state!.copyWith(
      quizAnswers: answers,
      quizQuestionIndex: nextQ,
    );
  }

  void setQuizSubmitted(int score) {
    if (state == null) return;
    state = state!.copyWith(
      quizScore: score,
      quizSubmitted: true,
      phase: LessonPhase.game,
    );
  }

  void setGameResult({
    required bool won,
    required double profit,
    required double revenue,
    required double cost,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      gameWon: won,
      gameProfit: profit,
      gameRevenue: revenue,
      gameCost: cost,
      phase: LessonPhase.reward,
    );
  }

  void setCompletion(Map<String, dynamic> result) {
    if (state == null) return;
    state = state!.copyWith(completionResult: result, isLoading: false);
  }

  void setLoading(bool loading) {
    if (state == null) return;
    state = state!.copyWith(isLoading: loading, error: null);
  }

  void setError(String message) {
    if (state == null) return;
    state = state!.copyWith(isLoading: false, error: message);
  }
}

final lessonSessionProvider =
    StateNotifierProvider<LessonSessionNotifier, LessonSession?>(
  (ref) => LessonSessionNotifier(),
);

final activeLessonContentProvider = Provider<LessonContent?>((ref) {
  final session = ref.watch(lessonSessionProvider);
  if (session == null) return null;
  return ref.watch(lessonContentProvider(session.lessonId)).valueOrNull;
});

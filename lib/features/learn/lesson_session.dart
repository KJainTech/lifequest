import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/content/lesson_catalog.dart';
import '../../data/models/lesson_content.dart';
import '../../data/repositories/content_repository.dart';
import 'quiz/quiz_shuffle.dart';

enum LessonPhase {
  stageIntro,
  read,
  quiz,
  game,
  reward,
  exitChallenge,
  levelComplete,
  wisdomLetter,
  bragCard,
  cityFinale,
}

class LessonSession {
  const LessonSession({
    required this.lessonId,
    this.phase = LessonPhase.stageIntro,
    this.readIndex = 0,
    this.quizQuestionIndex = 0,
    this.quizAnswers = const [],
    this.quizOptionPermutations = const [],
    this.hearts = 3,
    this.quizScore,
    this.quizSubmitted = false,
    this.gameWon,
    this.gameProfit,
    this.gameRevenue,
    this.gameCost,
    this.completionResult,
    this.pendingQuestLevel,
    this.isLoading = false,
    this.error,
  });

  final String lessonId;
  final LessonPhase phase;
  final int readIndex;
  final int quizQuestionIndex;
  final List<int> quizAnswers;
  final List<List<int>> quizOptionPermutations;
  final int hearts;
  final int? quizScore;
  final bool quizSubmitted;
  final bool? gameWon;
  final double? gameProfit;
  final double? gameRevenue;
  final double? gameCost;
  final Map<String, dynamic>? completionResult;
  final int? pendingQuestLevel;
  final bool isLoading;
  final String? error;

  LessonSession copyWith({
    LessonPhase? phase,
    int? readIndex,
    int? quizQuestionIndex,
    List<int>? quizAnswers,
    List<List<int>>? quizOptionPermutations,
    int? hearts,
    int? quizScore,
    bool? quizSubmitted,
    bool? gameWon,
    double? gameProfit,
    double? gameRevenue,
    double? gameCost,
    Map<String, dynamic>? completionResult,
    int? pendingQuestLevel,
    bool? isLoading,
    String? error,
  }) {
    return LessonSession(
      lessonId: lessonId,
      phase: phase ?? this.phase,
      readIndex: readIndex ?? this.readIndex,
      quizQuestionIndex: quizQuestionIndex ?? this.quizQuestionIndex,
      quizAnswers: quizAnswers ?? this.quizAnswers,
      quizOptionPermutations:
          quizOptionPermutations ?? this.quizOptionPermutations,
      hearts: hearts ?? this.hearts,
      quizScore: quizScore ?? this.quizScore,
      quizSubmitted: quizSubmitted ?? this.quizSubmitted,
      gameWon: gameWon ?? this.gameWon,
      gameProfit: gameProfit ?? this.gameProfit,
      gameRevenue: gameRevenue ?? this.gameRevenue,
      gameCost: gameCost ?? this.gameCost,
      completionResult: completionResult ?? this.completionResult,
      pendingQuestLevel: pendingQuestLevel ?? this.pendingQuestLevel,
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

  void advanceStageIntro() {
    if (state == null) return;
    state = state!.copyWith(phase: LessonPhase.read);
  }

  void advanceRead(int totalParagraphs) {
    if (state == null) return;
    if (state!.readIndex + 1 >= totalParagraphs) {
      final shuffle = QuizOptionShuffle.create(5);
      state = state!.copyWith(
        phase: LessonPhase.quiz,
        readIndex: 0,
        quizOptionPermutations: shuffle.permutations,
      );
    } else {
      state = state!.copyWith(readIndex: state!.readIndex + 1);
    }
  }

  List<int> originalQuizAnswers() {
    if (state == null || state!.quizAnswers.isEmpty) return const [];
    if (state!.quizOptionPermutations.isEmpty) {
      return List<int>.from(state!.quizAnswers);
    }
    final shuffle =
        QuizOptionShuffle.fromPermutations(state!.quizOptionPermutations);
    return shuffle.mapSubmittedAnswers(state!.quizAnswers);
  }

  void penalizeWrongQuizAnswer() {
    if (state == null) return;
    state = state!.copyWith(hearts: (state!.hearts - 1).clamp(0, 3));
  }

  void recordCorrectQuizAnswer(int answerIndex) {
    if (state == null) return;
    state = state!.copyWith(quizAnswers: [...state!.quizAnswers, answerIndex]);
  }

  void advanceQuizQuestion() {
    if (state == null) return;
    state = state!.copyWith(quizQuestionIndex: state!.quizQuestionIndex + 1);
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

  /// After reward saved — chain ceremonies when appropriate.
  void beginPostRewardCeremony() {
    if (state == null) return;
    final meta = lessonById(state!.lessonId);
    if (meta == null) return;

    if (meta.conceptOrder >= kTotalStages) {
      state = state!.copyWith(phase: LessonPhase.cityFinale);
      return;
    }

    if (meta.stageInLevel == stagesInQuestLevel(meta.questLevel)) {
      state = state!.copyWith(
        phase: LessonPhase.exitChallenge,
        pendingQuestLevel: meta.questLevel,
      );
      return;
    }
  }

  void advanceExitChallenge({required bool passed}) {
    if (state == null || !passed) return;
    state = state!.copyWith(phase: LessonPhase.levelComplete);
  }

  void advanceLevelComplete() {
    if (state == null) return;
    state = state!.copyWith(phase: LessonPhase.wisdomLetter);
  }

  void advanceWisdomLetter() {
    if (state == null) return;
    state = state!.copyWith(phase: LessonPhase.bragCard);
  }

  void finishCeremony() => clear();

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

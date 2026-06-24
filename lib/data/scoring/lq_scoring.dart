import 'dart:math' as math;

import '../content/lesson_catalog.dart';
import '../models/lq_models.dart';

/// Client-side mirror of server economy math — used when Cloud Functions fail.
class LQScoring {
  const LQScoring._();

  static int computeStars(int quizScore, bool gameWon) {
    final quizStars =
        quizScore >= 5 ? 3 : quizScore >= 3 ? 2 : quizScore >= 1 ? 1 : 0;
    final gameStars = gameWon ? 3 : 1;
    return (quizStars + gameStars).clamp(0, 6);
  }

  static int computeLqDelta(int stars, bool gameWon) =>
      stars * 8 + (gameWon ? 12 : 4);

  static int levelFromXp(int xp) {
    if (xp <= 0) return 1;
    return math.max(1, math.sqrt(xp / 50).floor() + 1);
  }

  static int xpThresholdForLevel(int level) {
    if (level <= 1) return 0;
    return (level - 1) * (level - 1) * 50;
  }

  static double xpProgressInLevel(int xp, int level) {
    final start = xpThresholdForLevel(level);
    final next = xpThresholdForLevel(level + 1);
    if (next <= start) return 0;
    return ((xp - start) / (next - start)).clamp(0.0, 1.0);
  }

  static ({int xp, int coins}) scoreQuiz(int quizScore) {
    final allCorrect = quizScore >= 5;
    final xp = quizScore * 10 + (allCorrect ? 20 : 0);
    final coins = allCorrect ? 15 : quizScore * 2;
    return (xp: xp, coins: coins);
  }

  static ({int xp, int coins}) scoreGame(bool gameWon, double gameProfit) {
    final xp = gameWon ? 30 : 10;
    final coins = gameWon ? gameProfit.floor().clamp(0, 50) : 5;
    return (xp: xp, coins: coins);
  }

  static String towerNameForLesson(String lessonId) {
    const towerNames = {
      'lesson_1': 'Coin Mint',
      'lesson_2': 'Piggy Shop',
      'lesson_3': 'Needs Mart',
      'lesson_4': 'Want Arcade',
      'lesson_5': 'First Stand',
      'lesson_6': 'Super Market',
    };
    if (towerNames.containsKey(lessonId)) return towerNames[lessonId]!;

    final match = RegExp(r'^lesson_(\d+)$').firstMatch(lessonId);
    if (match == null) return 'Skill Tower';
    final order = int.parse(match.group(1)!);
    final meta = kCurriculum.where((m) => m.id == lessonId).firstOrNull;
    if (meta != null) {
      return meta.title.split(' ').take(2).join(' ');
    }
    return 'Stage $order Tower';
  }

  static LessonCompletionResult computeFallbackCompletion({
    required String lessonId,
    required int quizScore,
    required bool gameWon,
    required double gameProfit,
    required UserStats stats,
  }) {
    final quiz = scoreQuiz(quizScore);
    final game = scoreGame(gameWon, gameProfit);
    final xp = quiz.xp + game.xp;
    final coins = quiz.coins + game.coins;
    final stars = computeStars(quizScore, gameWon);
    final lqDelta = computeLqDelta(stars, gameWon);
    final newXp = stats.xp + xp;
    final newLevel = levelFromXp(newXp);
    final newLq = (stats.lqScore + lqDelta).clamp(0, 900);

    return LessonCompletionResult(
      xp: xp,
      coins: coins,
      lqScore: newLq,
      level: newLevel,
      stars: stars,
      towerName: towerNameForLesson(lessonId),
      idempotent: false,
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

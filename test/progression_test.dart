import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/models/lq_models.dart';
import 'package:lifequest/data/scoring/lq_scoring.dart';

void main() {
  test('fallback completion awards xp and stars', () {
    const stats = UserStats(
      xp: 100,
      level: 2,
      coins: 10,
      lqScore: 50,
      businessIQ: BusinessIQ(profit: 0, decision: 0, resilience: 0),
      streak: Streak(count: 1, lastActive: null),
    );

    final result = LQScoring.computeFallbackCompletion(
      lessonId: 'lesson_2',
      quizScore: 4,
      gameWon: true,
      gameProfit: 12,
      stats: stats,
    );

    expect(result.xp, greaterThan(0));
    expect(result.stars, greaterThan(0));
    expect(result.towerName, 'Piggy Shop');
    expect(result.lqScore, greaterThan(stats.lqScore));
  });

  test('level from xp matches server formula', () {
    expect(LQScoring.levelFromXp(0), 1);
    expect(LQScoring.levelFromXp(50), 2);
    expect(LQScoring.levelFromXp(200), 3);
  });

  test('xp progress within level', () {
    expect(LQScoring.xpProgressInLevel(0, 1), 0);
    expect(LQScoring.xpProgressInLevel(50, 2), 0);
    expect(LQScoring.xpProgressInLevel(125, 2), closeTo(0.5, 0.01));
    expect(LQScoring.xpProgressInLevel(200, 3), 0);
  });

  test('scoreQuiz matches server partial credit', () {
    expect(LQScoring.scoreQuiz(2).xp, 20);
    expect(LQScoring.scoreQuiz(2).coins, 4);
    expect(LQScoring.scoreQuiz(5).xp, 70);
  });
}

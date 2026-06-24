import '../../data/content/lesson_catalog.dart';
import '../../data/content/lesson_progression.dart';
import '../../data/models/lq_models.dart';

/// Computed Money hub stats — GoHenry-style labels on LifeQuest data.
class MoneyHubSnapshot {
  const MoneyHubSnapshot({
    required this.coins,
    required this.savingsJar,
    required this.availableCoins,
    required this.streakDays,
    required this.streakBonusLabel,
    required this.weeklySessions,
    required this.badgeCount,
    required this.cityBuildings,
    required this.currentTaskLabel,
    required this.lqScore,
    required this.questName,
    required this.businessIQAvg,
  });

  final int coins;
  final int savingsJar;
  final int availableCoins;
  final int streakDays;
  final String streakBonusLabel;
  final int weeklySessions;
  final int badgeCount;
  final int cityBuildings;
  final String currentTaskLabel;
  final int lqScore;
  final String questName;
  final int businessIQAvg;

  factory MoneyHubSnapshot.from({
    required UserStats stats,
    required List<LessonProgress> lessons,
    required UserProfile? profile,
    required int badgeCount,
    required int cityBuildings,
  }) {
    final savingsJar = (stats.coins * 0.35).round();
    final available = (stats.coins - savingsJar).clamp(0, stats.coins);
    final weekly = _weeklySessions(lessons);
    final current = LessonProgression.currentLesson(lessons, profile);
    final journeyDone = LessonProgression.isJourneyComplete(lessons, profile);
    final taskLabel = journeyDone
        ? 'Replay any stage'
        : current != null
            ? current.title
            : 'Pick your next stage';
    final questName = LessonProgression.displayQuestLevelName(lessons, profile);
    final biq = stats.businessIQ;
    final avg = ((biq.profit + biq.decision + biq.resilience) / 3).round();

    return MoneyHubSnapshot(
      coins: stats.coins,
      savingsJar: savingsJar,
      availableCoins: available,
      streakDays: stats.streak.count,
      streakBonusLabel: _streakBonusLabel(stats.streak.count),
      weeklySessions: weekly,
      badgeCount: badgeCount,
      cityBuildings: cityBuildings,
      currentTaskLabel: taskLabel,
      lqScore: stats.lqScore,
      questName: questName,
      businessIQAvg: avg,
    );
  }

  static int _weeklySessions(List<LessonProgress> lessons) {
    final now = DateTime.now();
    return lessons.where((l) {
      if (l.status != LessonStatus.completed || l.completedAt == null) {
        return false;
      }
      final dt = DateTime.tryParse(l.completedAt!);
      if (dt == null) return false;
      return now.difference(dt).inDays < 7;
    }).length;
  }

  static String _streakBonusLabel(int streak) {
    if (streak >= 7) return '+15 coins at 7 days ✓';
    if (streak == 0) return 'Start today for bonus';
    final left = 7 - streak;
    return '$left day${left == 1 ? '' : 's'} to bonus';
  }
}

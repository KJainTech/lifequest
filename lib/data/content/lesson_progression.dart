import '../models/lq_models.dart';
import 'lesson_catalog.dart';

/// Resolves lesson availability from Firestore progress + screening placement.
/// Stage-to-stage: always advances on completion. Level-to-level: requires 80% avg mastery.
class LessonProgression {
  const LessonProgression._();

  static int startingOrderFromLevel(int proficiencyLevel) {
    final level = proficiencyLevel.clamp(1, kQuestLevelCount);
    return firstOrderForQuestLevel(level);
  }

  static int startingOrder(UserProfile? profile) {
    return startingOrderFromLevel(profile?.proficiencyLevel ?? 1);
  }

  /// 80%+ quiz — shown in UI; gates next quest level (not next stage).
  static bool meetsMastery(LessonProgress? stored) {
    if (stored == null || stored.status != LessonStatus.completed) {
      return false;
    }
    return (stored.quizScore ?? 5) >= kMasteryQuizScore;
  }

  static DateTime? _levelGateAnchor(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    if (questLevel <= 1) return null;
    final prevLessons = lessonsForQuestLevel(questLevel - 1);
    DateTime? latest;
    for (final meta in prevLessons) {
      final stored = _stored(meta.id, progress);
      if (stored?.completedAt != null) {
        final dt = DateTime.tryParse(stored!.completedAt!);
        if (dt != null && (latest == null || dt.isAfter(latest))) {
          latest = dt;
        }
      }
    }
    return latest;
  }

  static bool isQuestLevelUnlocked(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    if (questLevel <= 1) return true;

    final prevLevel = questLevel - 1;
    final prevLessons = lessonsForQuestLevel(prevLevel);
    for (final meta in prevLessons) {
      if (statusFor(meta, progress, profile) != LessonStatus.completed) {
        return false;
      }
    }

    if (priorLevelMasteryAverage(prevLevel, progress, profile) <
        kMasteryQuizScore) {
      return false;
    }

    if (isLevelGateActive(questLevel, progress, profile)) {
      return false;
    }

    return true;
  }

  /// Average quiz score (0–5) for a quest level; placement skips count as 5.
  static double priorLevelMasteryAverage(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    final lessons = lessonsForQuestLevel(questLevel);
    if (lessons.isEmpty) return 0;
    var sum = 0.0;
    for (final meta in lessons) {
      sum += effectiveQuizScore(meta, progress, profile);
    }
    return sum / lessons.length;
  }

  static int effectiveQuizScore(
    LessonMeta meta,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    final stored = _stored(meta.id, progress);
    if (stored?.quizScore != null) return stored!.quizScore!;
    if (statusFor(meta, progress, profile) == LessonStatus.completed) {
      // Screening placement — skipped stages count as mastered.
      if (meta.conceptOrder < startingOrder(profile)) return 5;
      // Offline complete without quizScore — do not assume mastery.
      return 0;
    }
    return 0;
  }

  static bool needsMasteryReplay(
    LessonMeta meta,
    List<LessonProgress> progress,
  ) {
    final stored = _stored(meta.id, progress);
    if (stored == null || stored.status != LessonStatus.completed) {
      return false;
    }
    return (stored.quizScore ?? 0) < kMasteryQuizScore;
  }

  static String levelUnlockHint(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    if (questLevel <= 1) return '';
    final avg = priorLevelMasteryAverage(questLevel - 1, progress, profile);
    if (avg >= kMasteryQuizScore) return '';
    final pct = (avg / 5 * 100).round();
    return 'Reach 80% mastery on Level ${questLevel - 1} (now $pct%)';
  }

  static int daysUntilLevelUnlock(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    final gateDays = kLevelTimeGateDays[questLevel - 1];
    if (gateDays <= 0) return 0;
    final anchor = _levelGateAnchor(questLevel, progress, profile);
    if (anchor == null) return gateDays;
    final elapsed = DateTime.now().difference(anchor).inDays;
    return (gateDays - elapsed).clamp(0, gateDays);
  }

  static bool isLevelGateActive(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    if (kLevelTimeGateDays[questLevel - 1] <= 0) return false;
    // Screening placement at this level — no wait required.
    if ((profile?.proficiencyLevel ?? 1) >= questLevel) return false;
    return daysUntilLevelUnlock(questLevel, progress, profile) > 0;
  }

  static double levelProgress(
    int questLevel,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    final lessons = lessonsForQuestLevel(questLevel);
    if (lessons.isEmpty) return 0;
    final done = lessons
        .where((m) => statusFor(m, progress, profile) == LessonStatus.completed)
        .length;
    return done / lessons.length;
  }

  static LessonStatus statusFor(
    LessonMeta meta,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    final stored = _stored(meta.id, progress);
    if (stored != null) return stored.status;

    final start = startingOrder(profile);
    if (meta.conceptOrder < start) return LessonStatus.completed;

    if (!isQuestLevelUnlocked(meta.questLevel, progress, profile)) {
      return LessonStatus.locked;
    }

    if (meta.prerequisiteId == null) return LessonStatus.available;

    final prereq = lessonById(meta.prerequisiteId!);
    if (prereq == null) return LessonStatus.available;

    final prereqStatus = statusFor(prereq, progress, profile);
    if (prereqStatus == LessonStatus.completed) return LessonStatus.available;
    return LessonStatus.locked;
  }

  static LessonMeta? currentLesson(
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    for (final meta in kCurriculum) {
      final status = statusFor(meta, progress, profile);
      if (status == LessonStatus.available ||
          status == LessonStatus.inProgress) {
        return meta;
      }
    }
    return null;
  }

  static int completedCount(
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    return kCurriculum
        .where((m) => statusFor(m, progress, profile) == LessonStatus.completed)
        .length;
  }

  static bool isJourneyComplete(
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    return kCurriculum.every(
      (m) => statusFor(m, progress, profile) == LessonStatus.completed,
    );
  }

  static LessonMeta? nextAfter(String completedLessonId) {
    final idx = kCurriculum.indexWhere((l) => l.id == completedLessonId);
    if (idx < 0 || idx >= kCurriculum.length - 1) return null;
    return kCurriculum[idx + 1];
  }

  /// Quest level (1–6) for UI — never rolls over to a non-existent Level 7.
  static int displayQuestLevel(
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    if (isJourneyComplete(progress, profile)) return kQuestLevelCount;
    final current = currentLesson(progress, profile);
    if (current != null) return current.questLevel;
    for (var level = kQuestLevelCount; level >= 1; level--) {
      if (isQuestLevelUnlocked(level, progress, profile)) return level;
    }
    final startOrder = startingOrder(profile);
    final startMeta = lessonByOrder(startOrder);
    return startMeta?.questLevel ?? 1;
  }

  static String displayQuestLevelName(
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    if (isJourneyComplete(progress, profile)) {
      return kQuestLevelNames[kQuestLevelCount - 1];
    }
    final current = currentLesson(progress, profile);
    if (current != null) return current.questLevelName;
    final level = displayQuestLevel(progress, profile);
    return kQuestLevelNames[level.clamp(1, kQuestLevelCount) - 1];
  }

  static String xpLabelFor(LessonMeta meta) {
    // Max: 70 quiz (5/5) + 30 game win = 100 XP
    return '+100 XP';
  }

  static double journeyProgress(
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    return completedCount(progress, profile) / kTotalStages;
  }

  static LessonProgress? _stored(String lessonId, List<LessonProgress> progress) {
    return progress.where((x) => x.lessonId == lessonId).firstOrNull;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

import '../models/lq_models.dart';
import 'lesson_catalog.dart';

/// Resolves lesson availability from Firestore progress + screening placement.
class LessonProgression {
  const LessonProgression._();

  /// First lesson index (1-based) after onboarding screening.
  static int startingOrder(UserProfile? profile) {
    final level = profile?.proficiencyLevel ?? 1;
    if (level >= 2) return 3;
    return 1;
  }

  static LessonStatus statusFor(
    LessonMeta meta,
    List<LessonProgress> progress,
    UserProfile? profile,
  ) {
    final stored = progress.where((x) => x.lessonId == meta.id).firstOrNull;
    if (stored != null) return stored.status;

    final start = startingOrder(profile);
    if (meta.conceptOrder < start) return LessonStatus.completed;

    if (meta.prerequisiteId == null) return LessonStatus.available;

    final prereqStatus = statusFor(
      lessonById(meta.prerequisiteId!)!,
      progress,
      profile,
    );
    if (prereqStatus == LessonStatus.completed) return LessonStatus.available;
    return LessonStatus.locked;
  }

  /// Next lesson the child should play (available or in-progress).
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

  static String xpLabelFor(LessonMeta meta) {
    return meta.conceptOrder <= 2 ? '+40 XP' : '+50 XP';
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/lesson_progression.dart';
import 'package:lifequest/data/models/lq_models.dart';

/// Simulates completing every stage in order — ensures nothing locks the path.
void main() {
  // Backdated so time gates (14/30/90/180 days) never block sequential test.
  final completedAt = DateTime.utc(2020, 1, 1).toIso8601String();

  test('all 48 stages unlock sequentially when each is completed with mastery', () {
    final progress = <LessonProgress>[];

    for (final meta in kCurriculum) {
      final status = LessonProgression.statusFor(meta, progress, null);
      expect(
        status,
        isIn([LessonStatus.available, LessonStatus.inProgress]),
        reason: 'Stage ${meta.id} should be playable, got $status',
      );

      progress.add(
        LessonProgress(
          lessonId: meta.id,
          status: LessonStatus.completed,
          quizScore: 5,
          stars: 6,
          completedAt: completedAt,
        ),
      );
    }

    expect(LessonProgression.completedCount(progress, null), kTotalStages);
    expect(LessonProgression.isJourneyComplete(progress, null), isTrue);
    expect(LessonProgression.currentLesson(progress, null), isNull);
  });

  test('low quiz score still unlocks next stage (no stuck path)', () {
    const low = LessonProgress(
      lessonId: 'lesson_1',
      status: LessonStatus.completed,
      quizScore: 2,
    );
    final next = LessonProgression.statusFor(
      lessonById('lesson_2')!,
      [low],
      null,
    );
    expect(next, LessonStatus.available);
  });

  test('all quest levels reachable with mastery scores', () {
    final progress = <LessonProgress>[];
    final completedAt = DateTime.utc(2020, 1, 1).toIso8601String();
    for (var level = 1; level <= kQuestLevelCount; level++) {
      expect(
        LessonProgression.isQuestLevelUnlocked(level, progress, null),
        isTrue,
        reason: 'Level $level should be unlocked',
      );
      for (final meta in lessonsForQuestLevel(level)) {
        progress.add(
          LessonProgress(
            lessonId: meta.id,
            status: LessonStatus.completed,
            quizScore: 4,
            completedAt: completedAt,
          ),
        );
      }
    }
  });

  test('screening placement opens correct first stage for each level', () {
    for (var level = 1; level <= kQuestLevelCount; level++) {
      final profile = UserProfile(
        uid: 'test',
        role: 'child',
        displayName: 'Test',
        proficiencyLevel: level,
        onboardingComplete: true,
      );
      final start = LessonProgression.startingOrder(profile);
      final first = lessonByOrder(start);
      expect(first?.questLevel, level);
      expect(
        LessonProgression.statusFor(first!, [], profile),
        LessonStatus.available,
      );
    }
  });

  test('nextAfter chains through entire curriculum', () {
    var id = 'lesson_1';
    var count = 0;
    while (true) {
      final next = LessonProgression.nextAfter(id);
      if (next == null) break;
      count++;
      id = next.id;
    }
    expect(count, kTotalStages - 1);
    expect(id, 'lesson_$kTotalStages');
  });
}

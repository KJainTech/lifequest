import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/concept_skills.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/lesson_progression.dart';
import 'package:lifequest/data/models/lq_models.dart';

void main() {
  test('screening placement uses 6 levels max', () {
    for (var level = 1; level <= 6; level++) {
      final start = LessonProgression.startingOrderFromLevel(level);
      expect(start, firstOrderForQuestLevel(level));
    }
    expect(
      LessonProgression.startingOrderFromLevel(10),
      firstOrderForQuestLevel(6),
    );
  });

  test('level 2 locked until level 1 has 80% average mastery', () {
    final progress = <LessonProgress>[
      for (var i = 1; i <= 5; i++)
        LessonProgress(
          lessonId: 'lesson_$i',
          status: LessonStatus.completed,
          quizScore: 2,
        ),
    ];
    expect(
      LessonProgression.isQuestLevelUnlocked(2, progress, null),
      isFalse,
    );

    final mastered = <LessonProgress>[
      for (var i = 1; i <= 5; i++)
        LessonProgress(
          lessonId: 'lesson_$i',
          status: LessonStatus.completed,
          quizScore: 4,
        ),
    ];
    expect(
      LessonProgression.isQuestLevelUnlocked(2, mastered, null),
      isTrue,
    );
  });

  test('low quiz on one stage still unlocks next stage', () {
    const low = LessonProgress(
      lessonId: 'lesson_1',
      status: LessonStatus.completed,
      quizScore: 2,
    );
    expect(
      LessonProgression.statusFor(lessonById('lesson_2')!, [low], null),
      LessonStatus.available,
    );
  });

  test('concept skill updates blend quiz scores', () {
    var skills = baselineScreeningSkills();
    skills = updateConceptSkill(skills, 'L1', 5);
    skills = updateConceptSkill(skills, 'L1', 2);
    expect(skills['L1'], lessThan(100));
    expect(skills['L1'], greaterThan(40));
  });

  test('skill labels match quest level names', () {
    expect(skillLabel('L1'), kQuestLevelNames[0]);
    expect(skillLabel('L6'), kQuestLevelNames[5]);
  });
}

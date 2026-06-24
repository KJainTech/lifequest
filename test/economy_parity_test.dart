import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/concept_skills.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/lesson_definitions.dart';
import 'package:lifequest/data/content/lesson_progression.dart';
import 'package:lifequest/data/content/lesson_templates.dart';
import 'package:lifequest/data/content/stage_teen_variants.dart';
import 'package:lifequest/data/models/lq_models.dart';
import 'package:lifequest/data/scoring/lq_scoring.dart';

/// Client-side parity with packages/types/src/scoring.ts
void main() {
  group('answer keys', () {
    test('all 48 lessons have 5-question keys', () {
      for (final meta in kCurriculum) {
        final key = quizAnswerKeyFor(meta.id);
        expect(key, hasLength(5), reason: meta.id);
        for (final idx in key) {
          expect(idx, inInclusiveRange(0, 3), reason: '${meta.id} index $idx');
        }
      }
    });

    test('template key formula matches server', () {
      for (var order = 7; order <= 48; order++) {
        expect(
          templateQuizAnswerKey(order),
          quizAnswerKeyFor('lesson_$order'),
        );
      }
    });
  });

  group('scoring formulas (server parity)', () {
    for (var score = 0; score <= 5; score++) {
      test('quiz score $score XP and coins', () {
        final result = LQScoring.scoreQuiz(score);
        final allCorrect = score == 5;
        expect(result.xp, score * 10 + (allCorrect ? 20 : 0));
        expect(result.coins, allCorrect ? 15 : score * 2);
      });
    }

    test('perfect lesson awards 100 XP', () {
      const stats = UserStats(
        xp: 0,
        level: 1,
        coins: 0,
        lqScore: 0,
        businessIQ: BusinessIQ(profit: 0, decision: 0, resilience: 0),
        streak: Streak(count: 0, lastActive: null),
      );
      final result = LQScoring.computeFallbackCompletion(
        lessonId: 'lesson_1',
        quizScore: 5,
        gameWon: true,
        gameProfit: 20,
        stats: stats,
      );
      expect(result.xp, 100);
      expect(result.stars, 6);
      expect(result.lqScore, 60);
    });

    test('stars combine quiz and game capped at 6', () {
      expect(LQScoring.computeStars(5, true), 6);
      expect(LQScoring.computeStars(3, false), 3);
      expect(LQScoring.computeStars(0, false), 1);
    });

    test('game difficulty scales with concept skills', () {
      expect(
        gameDifficultyForConceptSkills({'L4': 80}, 'lesson_19'),
        4,
      );
      expect(
        gameDifficultyForConceptSkills({'L4': 30}, 'lesson_19'),
        1,
      );
    });
  });

  group('progression rules', () {
    test('replay does not block next stage', () {
      const replay = LessonProgress(
        lessonId: 'lesson_3',
        status: LessonStatus.completed,
        quizScore: 2,
      );
      expect(
        LessonProgression.statusFor(lessonById('lesson_4')!, [replay], null),
        LessonStatus.available,
      );
    });

    test('time gate blocks level 3 without elapsed days', () {
      final progress = <LessonProgress>[
        for (var i = 1; i <= 11; i++)
          LessonProgress(
            lessonId: 'lesson_$i',
            status: LessonStatus.completed,
            quizScore: 5,
            completedAt: DateTime.now().toUtc().toIso8601String(),
          ),
      ];
      expect(
        LessonProgression.isQuestLevelUnlocked(3, progress, null),
        isFalse,
      );
      expect(
        LessonProgression.isLevelGateActive(3, progress, null),
        isTrue,
      );
    });

    test('needsMasteryReplay flags sub-80% completed lessons', () {
      const low = LessonProgress(
        lessonId: 'lesson_5',
        status: LessonStatus.completed,
        quizScore: 2,
      );
      expect(
        LessonProgression.needsMasteryReplay(lessonById('lesson_5')!, [low]),
        isTrue,
      );
    });
  });

  group('content coverage', () {
    test('all L4-L6 stages have teen variants', () {
      for (final meta in kCurriculum.where((m) => m.questLevel >= 4)) {
        expect(hasTeenVariant(meta.title), isTrue, reason: meta.id);
      }
    });

    test('teen L4 lesson differs from standard band', () {
      final teen = buildTemplateLesson(lessonById('lesson_19')!, '13-17');
      final mid = buildTemplateLesson(lessonById('lesson_19')!, '9-12');
      expect(teen.quizQuestions.first.prompt, isNot(mid.quizQuestions.first.prompt));
      expect(teen.gameConfig.unitCost, greaterThan(mid.gameConfig.unitCost));
    });
  });
}

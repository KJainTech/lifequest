import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/lesson_content_cache.dart';
import 'package:lifequest/data/content/lesson_definitions.dart';
import 'package:lifequest/data/content/stage_teen_variants.dart';
import 'package:lifequest/data/models/lesson_content.dart';

void main() {
  test('curriculum has 48 stages across 6 levels', () {
    expect(kCurriculum.length, kTotalStages);
    expect(kCurriculum.first.id, 'lesson_1');
    expect(kCurriculum.last.id, 'lesson_48');
    expect(kCurriculum.last.questLevel, kQuestLevelCount);
  });

  test('all curriculum lessons have content', () {
    for (final meta in kCurriculum) {
      final content = LessonContentCache.get(meta.id, '9-12');
      expect(content.lessonId, meta.id);
      expect(content.quizQuestions.length, 5);
      expect(content.readParagraphs.length, 4);
      expect(quizAnswerKeyFor(meta.id).length, 5);
    }
  });

  test('lesson_6 young band game config', () {
    final young = LessonContentCache.get('lesson_6', '5-8');
    expect(young.gameConfig.unitCost, 2);
    final teen = LessonContentCache.get('lesson_6', '13-17');
    expect(teen.gameConfig.unitCost, 2.5);
  });

  test('template lessons reference stage title in read copy', () {
    final wait = LessonContentCache.get('lesson_7', '9-12');
    expect(wait.readParagraphs.first.text, contains('Wait a Day'));

    final detective = LessonContentCache.get('lesson_8', '9-12');
    expect(detective.readParagraphs.first.text, contains('Deal Detective'));
    expect(detective.quizQuestions.first.prompt, contains('Fake deals'));
  });

  test('each template stage has unique title in read intro', () {
    for (final meta in kCurriculum.where((m) => m.conceptOrder > 6)) {
      final content = LessonContentCache.get(meta.id, '9-12');
      expect(
        content.readParagraphs.first.text,
        contains(meta.title),
        reason: meta.id,
      );
    }
  });

  test('L4-L6 teen band uses hand-authored variants', () {
    final meta = lessonById('lesson_19')!; // Stand Setup, L4
    final teen = LessonContentCache.get('lesson_19', '13-17');
    final mid = LessonContentCache.get('lesson_19', '9-12');

    expect(teen.readParagraphs.first.text, contains('COGS'));
    expect(teen.quizQuestions.first.prompt, isNot(mid.quizQuestions.first.prompt));
    expect(teen.gameConfig.unitCost, greaterThan(mid.gameConfig.unitCost));
    expect(teen.gameConfig.customerCount, greaterThanOrEqualTo(10));

    final grad = LessonContentCache.get('lesson_48', '13-17');
    expect(grad.readParagraphs.first.text, contains('Chief Money Officer'));
    expect(grad.quizQuestions.last.level, CognitiveLevel.solve);
  });

  test('all L4-L6 stages have teen variants', () {
    for (final meta in kCurriculum.where((m) => m.questLevel >= 4)) {
      expect(
        hasTeenVariant(meta.title),
        isTrue,
        reason: '${meta.id} ${meta.title}',
      );
    }
  });
}

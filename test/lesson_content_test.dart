import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/content/lesson_content_cache.dart';
import 'package:lifequest/data/content/lesson_definitions.dart';

void main() {
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
}

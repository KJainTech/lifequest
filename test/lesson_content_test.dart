import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_content_cache.dart';

void main() {
  test('lesson_6 content loads for age bands', () {
    final young = LessonContentCache.get('lesson_6', '5-8');
    expect(young.quizQuestions.length, 5);
    expect(young.readParagraphs.length, 4);
    expect(young.gameConfig.unitCost, 2);

    final teen = LessonContentCache.get('lesson_6', '13-17');
    expect(teen.gameConfig.unitCost, 2.5);
  });

  test('lesson_6 answer key matches 5 questions', () {
    expect(lesson6AnswerKey.length, 5);
  });
}

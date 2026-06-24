import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest/data/content/stage_activity_config.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';
import 'package:lifequest/data/models/lesson_content.dart';

void main() {
  test('slider activity uses percentage of income not raw income', () {
    final meta = lessonById('lesson_1');
    expect(meta, isNotNull);
    final questions = [
      const QuizQuestion(
        id: 'q1',
        prompt: 'AED 100 income. 50% needs. How much for needs?',
        options: ['AED 50', 'AED 100', 'AED 25'],
        explanation: 'Half of 100 is 50.',
        level: CognitiveLevel.apply,
      ),
    ];
    final activities = StageActivityConfig.activitiesFor(meta!, questions, '8-12');
    expect(activities.first.sliderCorrect, 50);
  });
}

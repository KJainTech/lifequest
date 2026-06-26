import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';

void main() {
  test('curriculum has 48 stages across 6 levels', () {
    expect(kCurriculum.length, 48);
    expect(kTotalStages, 48);
    expect(kQuestLevelCount, 6);
    expect(kStagesPerLevel.reduce((a, b) => a + b), 48);
    expect(lessonById('lesson_1')?.title, 'Counting the Cost');
    expect(lessonById('lesson_5')?.title, 'Exit Challenge');
    expect(kQuestLevelNames.first, 'Coin Keeper');
    expect(kQuestLevelNames.last, 'Chief Money Officer');
  });
}

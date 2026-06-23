import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';

void main() {
  test('curriculum has lesson_6', () {
    expect(lessonById('lesson_6')?.title, 'Profit = Revenue − Cost');
    expect(kCurriculum.length, greaterThanOrEqualTo(6));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/data/content/curriculum_builder.dart';
import 'package:lifequest/data/content/lesson_catalog.dart';

void main() {
  test('Level 1 stages use product names and labels', () {
    final l1 = lessonsForQuestLevel(1);
    expect(l1.length, 5);
    expect(l1[0].title, 'Counting the Cost');
    expect(stageLabel(l1[0]), '1.1');
    expect(stageCoinPreview(l1[0]), 10);
    expect(stageCoinPreview(l1[4]), 25);
    expect(l1[4].title, 'Exit Challenge');
  });
}

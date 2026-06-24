import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/features/learn/lesson_session.dart';

void main() {
  test('starts at stage intro', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(lessonSessionProvider.notifier).start('lesson_1');
    expect(container.read(lessonSessionProvider)!.phase, LessonPhase.stageIntro);
  });

  test('correct answer does not advance question until continue', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(lessonSessionProvider.notifier);
    notifier.start('lesson_1');

    notifier.recordCorrectQuizAnswer(2);
    var session = container.read(lessonSessionProvider)!;
    expect(session.quizQuestionIndex, 0);
    expect(session.quizAnswers, [2]);

    notifier.advanceQuizQuestion();
    session = container.read(lessonSessionProvider)!;
    expect(session.quizQuestionIndex, 1);
    expect(session.quizAnswers, [2]);
  });

  test('wrong answer only reduces hearts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(lessonSessionProvider.notifier);
    notifier.start('lesson_1');

    notifier.penalizeWrongQuizAnswer();
    final session = container.read(lessonSessionProvider)!;
    expect(session.hearts, 2);
    expect(session.quizQuestionIndex, 0);
    expect(session.quizAnswers, isEmpty);
  });
}

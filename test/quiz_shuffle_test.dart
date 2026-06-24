import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/learn/quiz/quiz_shuffle.dart';

void main() {
  test('shuffle maps displayed picks back to original indices', () {
    const permutations = [
      [2, 0, 3, 1],
      [1, 3, 0, 2],
      [0, 1, 2, 3],
      [3, 2, 1, 0],
      [2, 1, 0, 3],
    ];
    final shuffle = QuizOptionShuffle.fromPermutations(permutations);
    const options = ['A', 'B', 'C', 'D'];

    expect(shuffle.shuffledOptions(options, 0), ['C', 'A', 'D', 'B']);
    expect(shuffle.displayedToOriginal(0, 0), 2);
    expect(shuffle.displayedToOriginal(0, 3), 1);

    final displayed = [3, 1, 0, 2, 1];
    expect(shuffle.mapSubmittedAnswers(displayed), [1, 3, 0, 1, 1]);
  });

  test('create produces varied order per question', () {
    final shuffle = QuizOptionShuffle.create(5, seed: 42);
    expect(shuffle.permutations.length, 5);
    expect(shuffle.permutations.toSet().length, greaterThan(1));
  });
}

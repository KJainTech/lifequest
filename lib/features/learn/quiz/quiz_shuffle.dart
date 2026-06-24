import 'dart:math';

/// Per-question option order shuffle — maps displayed index → original index.
class QuizOptionShuffle {
  QuizOptionShuffle._(this.permutations);

  final List<List<int>> permutations;

  List<List<int>> get optionPermutations => permutations;

  static QuizOptionShuffle create(int questionCount, {int seed = 0}) {
    final rng = Random(seed == 0 ? DateTime.now().microsecondsSinceEpoch : seed);
    final permutations = List.generate(questionCount, (_) {
      final order = List.generate(4, (i) => i);
      order.shuffle(rng);
      return order;
    });
    return QuizOptionShuffle._(permutations);
  }

  static QuizOptionShuffle fromPermutations(List<List<int>> permutations) {
    return QuizOptionShuffle._(permutations);
  }

  List<String> shuffledOptions(List<String> options, int questionIndex) {
    final perm = permutations[questionIndex.clamp(0, permutations.length - 1)];
    return perm.map((i) => options[i]).toList(growable: false);
  }

  int displayedToOriginal(int questionIndex, int displayedIndex) {
    final perm = permutations[questionIndex.clamp(0, permutations.length - 1)];
    return perm[displayedIndex.clamp(0, perm.length - 1)];
  }

  List<int> mapSubmittedAnswers(List<int> displayedAnswers) {
    return List.generate(displayedAnswers.length, (q) {
      return displayedToOriginal(q, displayedAnswers[q]);
    });
  }
}

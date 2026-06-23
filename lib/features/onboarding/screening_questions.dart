/// Adaptive screening items — difficulty steps with each correct answer.
class ScreeningQuestion {
  const ScreeningQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.explanation,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final int difficulty;
  final String explanation;
}

const screeningQuestionBank = [
  ScreeningQuestion(
    id: 's1',
    difficulty: 1,
    prompt: 'You sell lemonade for AED 2. It costs AED 1 to make. What is profit?',
    options: ['AED 0', 'AED 1', 'AED 2', 'AED 3'],
    correctIndex: 1,
    explanation: 'Profit = money in − money out. AED 2 − AED 1 = AED 1.',
  ),
  ScreeningQuestion(
    id: 's2',
    difficulty: 2,
    prompt: 'Which is a NEED, not a want?',
    options: ['New game', 'School lunch', 'Extra toy', 'Movie ticket'],
    correctIndex: 1,
    explanation: 'Needs keep you healthy and safe. Lunch is a need.',
  ),
  ScreeningQuestion(
    id: 's3',
    difficulty: 2,
    prompt: 'You earn AED 10 and spend AED 12. What happened?',
    options: ['Profit', 'Loss', 'Saving', 'Investment'],
    correctIndex: 1,
    explanation: 'Spending more than you earn is a loss.',
  ),
  ScreeningQuestion(
    id: 's4',
    difficulty: 3,
    prompt: 'Revenue is AED 50, costs are AED 35. Profit is…',
    options: ['AED 85', 'AED 15', 'AED 35', 'AED 50'],
    correctIndex: 1,
    explanation: 'Profit = revenue − cost = AED 15.',
  ),
  ScreeningQuestion(
    id: 's5',
    difficulty: 3,
    prompt: 'Why save before spending on wants?',
    options: [
      'To impress friends',
      'For emergencies and goals',
      'Because saving is boring',
      'To avoid learning',
    ],
    correctIndex: 1,
    explanation: 'Saving builds resilience for surprises and big goals.',
  ),
  ScreeningQuestion(
    id: 's6',
    difficulty: 4,
    prompt: 'A stand sells 8 cups at AED 3 each. Costs are AED 14. Profit?',
    options: ['AED 10', 'AED 24', 'AED 14', 'AED 8'],
    correctIndex: 0,
    explanation: 'Revenue AED 24 − cost AED 14 = profit AED 10.',
  ),
];

List<ScreeningQuestion> buildScreeningSet({int startDifficulty = 1}) {
  final pool = screeningQuestionBank
      .where((q) => q.difficulty >= startDifficulty)
      .toList();
  return pool.take(5).toList();
}

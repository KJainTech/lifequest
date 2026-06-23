import '../models/lesson_content.dart';

/// Cached lesson variants keyed by (lessonId, ageBand).
/// Server answer keys in functions/src/content/answerKeys.ts must match quiz order.
class LessonContentCache {
  static LessonContent get(String lessonId, String ageBand) {
    if (lessonId == 'lesson_6') {
      return _lesson6(ageBand);
    }
    throw LessonContentNotFoundException(lessonId);
  }
}

class LessonContentNotFoundException implements Exception {
  LessonContentNotFoundException(this.lessonId);
  final String lessonId;
  @override
  String toString() => 'Lesson not found: $lessonId';
}

/// Server-matched answer indices for lesson_6 quiz (see functions answerKeys.ts)
const lesson6AnswerKey = [1, 2, 0, 3, 1];

LessonContent _lesson6(String ageBand) {
  final isYoung = ageBand == '5-8';
  final isTeen = ageBand == '13-17';

  return LessonContent(
    lessonId: 'lesson_6',
    concept: 'profit_revenue_cost',
    title: 'Profit = Revenue − Cost',
    readParagraphs: [
      ReadParagraph(
        text: isYoung
            ? 'When you run a tiny stand, you spend money on cups and lemons. That is your **cost**.'
            : isTeen
                ? 'Every business has costs — ingredients, time, and supplies. That is money going out.'
                : 'Running a lemonade stand costs money: lemons, cups, and your time. That is called **cost**.',
      ),
      ReadParagraph(
        text: isYoung
            ? 'When someone buys your drink, you get **revenue** — money coming in.'
            : 'When customers pay you, the total money you collect is called **revenue**.',
      ),
      ReadParagraph(
        text: isYoung
            ? '**Profit** is what is left: revenue minus cost. If you sell for less than it costs, you lose money!'
            : isTeen
                ? 'Profit = revenue − cost. Price below cost means you lose on every sale — no amount of hustle fixes bad maths.'
                : 'Profit is revenue minus cost. If your price is lower than what it costs to make each cup, you lose money on every sale.',
      ),
      ReadParagraph(
        text: 'In Lemon City you will set a price and serve customers. '
            'The only way to win is to charge more than your cost and sell enough cups.',
      ),
    ],
    quizQuestions: [
      QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'What is **revenue**?',
        options: [
          'Money you spend',
          'Money customers pay you',
          'Money you save',
          'Money you borrow',
        ],
        explanation: 'Revenue is all the money coming in from sales.',
      ),
      QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'Each cup costs AED 2 to make. You sell 5 cups. What is your **cost**?',
        options: ['AED 5', 'AED 7', 'AED 10', 'AED 12'],
        explanation: 'Cost = 5 cups × AED 2 = AED 10.',
      ),
      QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'Profit equals…',
        options: ['Revenue − Cost', 'Cost − Revenue', 'Revenue + Cost', 'Cost × Revenue'],
        explanation: 'Profit is what remains after costs: revenue − cost.',
      ),
      QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'You price a cup at AED 1 but it costs AED 2 to make. How do you feel as a business owner?',
        options: [
          'Great — low prices always win',
          'Confused — sales are high',
          'Unsure — it depends on weather',
          'Worried — you lose money on every cup',
        ],
        explanation: 'Selling below cost means a loss on every sale — that is worrying!',
      ),
      QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'Cost is AED 2 per cup. You sell 4 cups at AED 4 each. What is profit?',
        options: ['AED 4', 'AED 8', 'AED 16', 'AED 6'],
        explanation: 'Revenue AED 16 − cost AED 8 = profit AED 8.',
      ),
    ],
    gameConfig: LemonCityConfig(
      unitCost: isYoung ? 2 : isTeen ? 2.5 : 2,
      daySeconds: isYoung ? 50 : 45,
      customerCount: isYoung ? 8 : isTeen ? 12 : 10,
      minPrice: 1,
      maxPrice: 6,
      defaultPrice: isYoung ? 2 : 3,
    ),
  );
}

import '../models/lesson_content.dart';
import 'lesson_catalog.dart';
import 'lesson_templates.dart';

/// Server-matched quiz answer indices (see functions/src/content/answerKeys.ts).
const kQuizAnswerKeys = <String, List<int>>{
  'lesson_1': [1, 1, 0, 1, 1],
  'lesson_2': [1, 1, 1, 0, 1],
  'lesson_3': [0, 0, 0, 0, 1],
  'lesson_4': [0, 1, 0, 0, 0],
  'lesson_5': [0, 1, 0, 0, 0],
  'lesson_6': [1, 2, 0, 3, 1],
};

List<int> quizAnswerKeyFor(String lessonId) {
  if (kQuizAnswerKeys.containsKey(lessonId)) {
    return kQuizAnswerKeys[lessonId]!;
  }
  final meta = lessonById(lessonId);
  if (meta != null) return templateQuizAnswerKey(meta.conceptOrder);
  return List.filled(5, 0);
}

LessonContent buildLessonContent(String lessonId, String ageBand) {
  final meta = lessonById(lessonId);
  if (meta == null) throw LessonContentNotFoundException(lessonId);

  if (meta.conceptOrder <= 6) {
    switch (lessonId) {
      case 'lesson_1':
        return _lesson1(ageBand);
      case 'lesson_2':
        return _lesson2(ageBand);
      case 'lesson_3':
        return _lesson3(ageBand);
      case 'lesson_4':
        return _lesson4(ageBand);
      case 'lesson_5':
        return _lesson5(ageBand);
      case 'lesson_6':
        return _lesson6(ageBand);
    }
  }
  return buildTemplateLesson(meta, ageBand);
}

class LessonContentNotFoundException implements Exception {
  LessonContentNotFoundException(this.lessonId);
  final String lessonId;
  @override
  String toString() => 'Lesson not found: $lessonId';
}

LessonContent _lesson1(String ageBand) {
  final young = ageBand == '5-8';
  return LessonContent(
    lessonId: 'lesson_1',
    concept: 'needs_vs_wants',
    title: 'Needs vs Wants',
    readParagraphs: [
      ReadParagraph(
        text: young
            ? 'A **need** is something you must have to stay healthy and safe — food, water, school supplies, and a home.'
            : '**Needs** are must-pay costs: food, shelter, clothes for school, and getting there safely.',
      ),
      ReadParagraph(
        text: young
            ? 'A **want** is extra fun — a toy, candy, or game skin. Nice to have, but you could wait.'
            : '**Wants** are optional extras — snacks, trendy gear, or in-app upgrades. Fun, not required.',
      ),
      ReadParagraph(
        text: '**Spending** means using coins now. Before you spend, ask: "Is this a need or a want?" Pay needs first.',
      ),
      ReadParagraph(
        text: 'In Lemon City you will choose prices wisely — just like picking needs before wants in real life.',
      ),
    ],
    quizQuestions: _quiz1(),
    gameConfig: _game(young: young, unitCost: 1.5, defaultPrice: 2, customers: 8),
  );
}

LessonContent _lesson2(String ageBand) {
  final young = ageBand == '5-8';
  return LessonContent(
    lessonId: 'lesson_2',
    concept: 'saving_jar',
    title: 'Saving Jar',
    readParagraphs: [
      ReadParagraph(
        text: 'A **saving jar** is for money you do **not** spend today. It sits aside for something you want later.',
      ),
      ReadParagraph(
        text: young
            ? 'Pick one goal — a book, bike, or trip. Drop a few coins in the jar each time you get allowance.'
            : 'Name one goal with a target and date — e.g. "AED 50 by Friday." Add a slice every time money arrives.',
      ),
      ReadParagraph(
        text: '**Save first, spend second.** Move coins to the jar before buying wants — that is how big goals happen.',
      ),
      ReadParagraph(
        text: 'In Lemon City, keep part of your stand profit for the jar, not just pocket money for today.',
      ),
    ],
    quizQuestions: _quiz2(),
    gameConfig: _game(young: young, unitCost: 1.5, defaultPrice: 3, customers: 9),
  );
}

LessonContent _lesson3(String ageBand) {
  final young = ageBand == '5-8';
  return LessonContent(
    lessonId: 'lesson_3',
    concept: 'smart_spending',
    title: 'Smart Spending',
    readParagraphs: [
      ReadParagraph(
        text: '**Smart spending** means using coins on purpose — not because an ad or friend rushed you.',
      ),
      ReadParagraph(
        text: 'Compare before you buy: same item, different shops, different prices. Check quality too.',
      ),
      ReadParagraph(
        text: young
            ? 'On big wants, wait one day. If you still want it tomorrow, it may be worth your coins.'
            : 'Use the 24-hour rule on wants over AED 20 — impulse fades, good choices stay.',
      ),
      ReadParagraph(
        text: 'In Lemon City, pick a price customers will pay **and** that covers what the drink cost you.',
      ),
    ],
    quizQuestions: _quiz3(),
    gameConfig: _game(young: young, unitCost: 2, defaultPrice: 3, customers: 10),
  );
}

LessonContent _lesson4(String ageBand) {
  final young = ageBand == '5-8';
  return LessonContent(
    lessonId: 'lesson_4',
    concept: 'budget_basics',
    title: 'Budget Basics',
    readParagraphs: [
      ReadParagraph(
        text: 'A **budget** is a plan that gives every coin a job before you spend — needs, save, and wants.',
      ),
      ReadParagraph(
        text: young
            ? 'Try three jars: **Spend** (this week\'s needs and wants), **Save** (your goal jar), **Share** (helping others).'
            : 'A simple split: about 50% needs, 30% wants, 20% save — adjust with your family.',
      ),
      ReadParagraph(
        text: '**Needs** cover must-haves. **Save** is for future-you. **Wants** are fun left after the first two.',
      ),
      ReadParagraph(
        text: 'Your Lemon City stand is a mini-budget: what you spend to make drinks, what you charge, and what you keep.',
      ),
    ],
    quizQuestions: _quiz4(),
    gameConfig: _game(young: young, unitCost: 2, defaultPrice: 3, customers: 10),
  );
}

LessonContent _lesson5(String ageBand) {
  final young = ageBand == '5-8';
  final teen = ageBand == '13-17';
  return LessonContent(
    lessonId: 'lesson_5',
    concept: 'cost_of_goods',
    title: 'Cost of Goods',
    readParagraphs: [
      ReadParagraph(
        text: young
            ? '**Cost of goods** is what you spend to make one item — lemons, cups, ice.'
            : 'Cost of goods (COGS) is every direct cost to produce one unit you sell.',
      ),
      ReadParagraph(
        text: teen
            ? 'Include ingredients **and** your time if you could be doing something else paid.'
            : 'Count lemons, sugar, cups — and a little for your time running the stand.',
      ),
      ReadParagraph(
        text: 'If you ignore costs, revenue looks great while your wallet shrinks. Ouch!',
      ),
      ReadParagraph(
        text: 'Next up: Lemon City shows how **revenue − cost = profit**. You are ready!',
      ),
    ],
    quizQuestions: _quiz5(),
    gameConfig: _game(young: young, unitCost: 2, defaultPrice: 3, customers: 11),
  );
}

LessonContent _lesson6(String ageBand) {
  final young = ageBand == '5-8';
  final teen = ageBand == '13-17';
  return LessonContent(
    lessonId: 'lesson_6',
    concept: 'profit_revenue_cost',
    title: 'Profit = Revenue − Cost',
    readParagraphs: [
      ReadParagraph(
        text: young
            ? 'When you run a tiny stand, you spend money on cups and lemons. That is your **cost**.'
            : teen
                ? 'Every business has costs — ingredients, time, and supplies. That is money going out.'
                : 'Running a lemonade stand costs money: lemons, cups, and your time. That is **cost**.',
      ),
      ReadParagraph(
        text: young
            ? 'When someone buys your drink, you get **revenue** — money coming in.'
            : 'When customers pay you, the total money you collect is called **revenue**.',
      ),
      ReadParagraph(
        text: young
            ? '**Profit** is what is left: revenue minus cost. If you sell for less than it costs, you lose money!'
            : teen
                ? 'Profit = revenue − cost. Price below cost means you lose on every sale.'
                : 'Profit is revenue minus cost. Price below cost means you lose on every sale.',
      ),
      ReadParagraph(
        text: 'In Lemon City you will set a price and serve customers. '
            'Charge more than your cost and sell enough cups to win!',
      ),
    ],
    quizQuestions: _quiz6(),
    gameConfig: LemonCityConfig(
      unitCost: young ? 2 : teen ? 2.5 : 2,
      daySeconds: young ? 50 : 45,
      customerCount: young ? 8 : teen ? 12 : 10,
      minPrice: 1,
      maxPrice: 6,
      defaultPrice: young ? 2 : 3,
    ),
  );
}

LemonCityConfig _game({
  required bool young,
  required double unitCost,
  required double defaultPrice,
  required int customers,
}) {
  return LemonCityConfig(
    unitCost: unitCost,
    daySeconds: young ? 50 : 45,
    customerCount: customers,
    minPrice: 1,
    maxPrice: 6,
    defaultPrice: defaultPrice,
  );
}

List<QuizQuestion> _quiz1() => [
      const QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'Which is a **need**?',
        options: ['New video game', 'Lunch', 'Sticker pack', 'Extra dessert'],
        explanation: 'Lunch keeps you healthy — that is a need.',
      ),
      const QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'You have AED 20. School shoes are AED 18. Candy is AED 5. What first?',
        options: ['Buy candy', 'Buy shoes', 'Save all', 'Borrow more'],
        explanation: 'Shoes are a need; candy is a want. Needs first!',
      ),
      const QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'Needs vs wants — which rule is best?',
        options: ['Needs before wants', 'Wants always win', 'Spend everything', 'Never save'],
        explanation: 'Cover needs first, then plan wants with what is left.',
      ),
      const QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'Your friend buys a toy you want. You only have lunch money. You feel…',
        options: ['Jealous — spend anyway', 'Okay — my needs matter', 'Angry at friend', 'Give up eating'],
        explanation: 'It is normal to want things — protect your needs first.',
      ),
      const QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'AED 10 for transport (need) and AED 8 for toy (want). You have AED 10. Best move?',
        options: ['Buy toy', 'Pay transport', 'Buy both', 'Hide money'],
        explanation: 'Transport is the need — pay that first.',
      ),
    ];

List<QuizQuestion> _quiz2() => [
      const QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'What is a saving jar for?',
        options: ['Spending on snacks today', 'A goal you are working toward', 'Paying strangers', 'Hiding coins forever'],
        explanation: 'The jar holds coins for a future goal — not for spending right now.',
      ),
      const QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'Goal: AED 40. You save AED 10/week. How many weeks?',
        options: ['2', '4', '6', '8'],
        explanation: '40 ÷ 10 = 4 weeks if you save steadily.',
      ),
      const QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'Best saving habit?',
        options: ['Save whatever is left (often zero)', 'Save first when coins arrive', 'Never look at jar', 'Spend then borrow'],
        explanation: 'Pay-yourself-first beats leftovers.',
      ),
      const QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'Jar is half full but friends want to spend out. You feel…',
        options: ['Proud — stick to goal', 'Embarrassed — empty jar', 'Bored — quit saving', 'Confused — hide jar'],
        explanation: 'Halfway is progress — goals take patience.',
      ),
      const QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'You earn AED 12. Save 25% for jar. How much to save?',
        options: ['AED 2', 'AED 3', 'AED 4', 'AED 6'],
        explanation: '25% of 12 = AED 3 for your jar.',
      ),
    ];

List<QuizQuestion> _quiz3() => [
      const QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'Smart spending starts with…',
        options: ['Comparing options', 'Buying instantly', 'Ignoring price', 'Borrowing always'],
        explanation: 'Compare price and quality before you buy.',
      ),
      const QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'Same notebook: Shop A AED 8, Shop B AED 6. Same quality. Pick?',
        options: ['Shop B', 'Shop A', 'Both', 'Neither'],
        explanation: 'Same quality, lower price — smart pick!',
      ),
      const QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'The 24-hour rule helps you…',
        options: ['Beat impulse buys', 'Spend faster', 'Forget goals', 'Avoid all fun'],
        explanation: 'Waiting cools impulse on big wants.',
      ),
      const QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'Flash sale on a want you did not plan. You feel pulled. Best step?',
        options: ['Pause and check budget', 'Buy before sale ends', 'Feel guilty forever', 'Buy two'],
        explanation: 'Pause — sales press feelings, not needs.',
      ),
      const QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'Budget AED 15 fun money. Game AED 9 + snack AED 7. What works?',
        options: ['Both today', 'One now, one later', 'Borrow AED 1', 'Skip budget'],
        explanation: '9 + 7 = 16 — pick one now or wait for more coins.',
      ),
    ];

List<QuizQuestion> _quiz4() => [
      const QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'A budget is…',
        options: ['A plan for money', 'A type of bank', 'A lucky charm', 'Free money'],
        explanation: 'Budgets plan where money goes.',
      ),
      const QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'AED 100 income. 50% needs. How much for needs?',
        options: ['AED 30', 'AED 50', 'AED 70', 'AED 100'],
        explanation: '50% of 100 = AED 50 for needs.',
      ),
      const QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'Why track spending for a week?',
        options: ['See where money really goes', 'Impress friends', 'Avoid math', 'Spend more'],
        explanation: 'Tracking reveals surprises in your habits.',
      ),
      const QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'You overspent fun jar mid-week. Best response?',
        options: ['Adjust — less fun till next week', 'Give up budgeting', 'Steal from needs', 'Ignore it'],
        explanation: 'Budgets flex — learn and adjust, do not quit.',
      ),
      const QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'Needs AED 40, save AED 20, fun AED 20. Income AED 70. Problem?',
        options: ['Over by AED 10', 'Perfect', 'Under by AED 10', 'No plan needed'],
        explanation: '40+20+20=80 but income is 70 — trim AED 10 somewhere.',
      ),
    ];

List<QuizQuestion> _quiz5() => [
      const QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'Cost of goods includes…',
        options: ['Ingredients for one sale', 'Only rent', 'Only profit', 'Customer names'],
        explanation: 'COGS is direct cost to make what you sell.',
      ),
      const QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'Lemons AED 4 + cups AED 2 for 4 drinks. Cost per drink?',
        options: ['AED 1', 'AED 1.50', 'AED 2', 'AED 6'],
        explanation: '(4+2) ÷ 4 = AED 1.50 per drink.',
      ),
      const QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'High revenue but ignoring costs means…',
        options: ['You might still lose money', 'Automatic profit', 'Free lemons', 'No math needed'],
        explanation: 'Revenue without cost control can hide losses.',
      ),
      const QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'Costs went up. Old price feels too low. You should…',
        options: ['Recalculate price', 'Panic and quit', 'Hide from customers', 'Sell at a loss'],
        explanation: 'Good owners update prices when costs change.',
      ),
      const QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'Cost AED 2/cup. Sell 5 at AED 4. Revenue? Cost total? Profit?',
        options: ['Profit AED 10', 'Profit AED 6', 'Profit AED 20', 'Loss AED 2'],
        explanation: 'Revenue 20 − cost 10 = profit AED 10.',
      ),
    ];

List<QuizQuestion> _quiz6() => [
      const QuizQuestion(
        id: 'q1',
        level: CognitiveLevel.recall,
        prompt: 'What is **revenue**?',
        options: ['Money you spend', 'Money customers pay you', 'Money you save', 'Money you borrow'],
        explanation: 'Revenue is all the money coming in from sales.',
      ),
      const QuizQuestion(
        id: 'q2',
        level: CognitiveLevel.apply,
        prompt: 'Each cup costs AED 2 to make. You sell 5 cups. What is your **cost**?',
        options: ['AED 5', 'AED 7', 'AED 10', 'AED 12'],
        explanation: 'Cost = 5 cups × AED 2 = AED 10.',
      ),
      const QuizQuestion(
        id: 'q3',
        level: CognitiveLevel.recognise,
        prompt: 'Profit equals…',
        options: ['Revenue − Cost', 'Cost − Revenue', 'Revenue + Cost', 'Cost × Revenue'],
        explanation: 'Profit is what remains after costs.',
      ),
      const QuizQuestion(
        id: 'q4',
        level: CognitiveLevel.feel,
        prompt: 'You price a cup at AED 1 but it costs AED 2. How do you feel?',
        options: ['Great — low prices win', 'Confused', 'Unsure', 'Worried — lose on every cup'],
        explanation: 'Selling below cost loses money every sale.',
      ),
      const QuizQuestion(
        id: 'q5',
        level: CognitiveLevel.solve,
        prompt: 'Cost AED 2/cup. Sell 4 at AED 4 each. Profit?',
        options: ['AED 4', 'AED 8', 'AED 16', 'AED 6'],
        explanation: 'Revenue AED 16 − cost AED 8 = profit AED 8.',
      ),
    ];

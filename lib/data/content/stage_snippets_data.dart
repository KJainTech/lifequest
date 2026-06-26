/// Title-keyed teaching copy for all 48 curriculum stages.
/// Keys match `LessonMeta.title` from [curriculum_builder.dart].
class StageCopy {
  const StageCopy({
    required this.learn,
    required this.apply,
    required this.quiz,
  });

  final String learn;
  final String apply;
  final List<StageQuizItem> quiz;
}

class StageQuizItem {
  const StageQuizItem(this.prompt, this.correct, this.wrong);
  final String prompt;
  final String correct;
  final List<String> wrong;
}

const kStageCopyByTitle = <String, StageCopy>{
  // L1 — Coin Keeper
  'Hello Coins': StageCopy(
    learn:
        'Money comes as coins and notes. We use it to trade for things people make and sell.',
    apply: 'Find three coins or notes at home and name what each could buy.',
    quiz: [
      StageQuizItem('Money helps us…', 'Trade for goods and services', [
        'Win every game',
        'Avoid school',
        'Hide forever',
      ]),
      StageQuizItem('Coins and notes are…', 'Tools for buying', [
        'Only for collecting',
        'Worthless paper',
        'Secret codes',
      ]),
      StageQuizItem('Where does money usually live safely?', 'A wallet or bank', [
        'On the floor',
        'In random pockets',
        'Lost outside',
      ]),
      StageQuizItem('Learning about coins helps you…', 'Count what you have', [
        'Spend without thinking',
        'Ignore prices',
        'Skip saving',
      ]),
      StageQuizItem('Why meet money early?', 'Make smarter choices later', [
        'Spend everything fast',
        'Never plan',
        'Avoid math',
      ]),
    ],
  ),
  'Needs First': StageCopy(
    learn: 'Needs are must-haves — food, shelter, school. Pay these before fun spending.',
    apply: 'Name one need you covered today before any fun spending.',
    quiz: [
      StageQuizItem('A **need** is something that…', 'Keeps you safe and healthy', [
        'Is always fun',
        'Costs the most',
        'Never matters',
      ]),
      StageQuizItem('Which is usually a need?', 'School lunch', [
        'Extra candy only',
        'Rare collectible',
        'Brand new game',
      ]),
      StageQuizItem('Needs before wants means…', 'Essentials first', [
        'Fun first always',
        'Buy everything',
        'Skip meals',
      ]),
      StageQuizItem('Smart first step with AED 15?', 'Pay needs, then wants', [
        'Buy all wants first',
        'Spend everything',
        'Guess prices',
      ]),
      StageQuizItem('Needs vs wants — why care?', 'Money lasts longer', [
        'To waste money',
        'To confuse parents',
        'To avoid saving',
      ]),
    ],
  ),
  'Want Later': StageCopy(
    learn: 'Wants are fun extras — games, treats, trends. They can wait until needs and save are covered.',
    apply: 'Pick one want and write why it can wait until next week.',
    quiz: [
      StageQuizItem('A **want** is…', 'Nice but not essential', [
        'Always required',
        'Same as rent',
        'Never optional',
      ]),
      StageQuizItem('Want later teaches…', 'Patience with spending', [
        'Instant buying',
        'Hiding receipts',
        'Borrowing secretly',
      ]),
      StageQuizItem('You see a toy and lunch. Pick first.', 'Buy lunch first', [
        'Buy the toy first',
        'Buy both without thinking',
        'Skip lunch',
      ]),
      StageQuizItem('Waiting on wants helps…', 'Avoid regret', [
        'Spend faster',
        'Ignore budgets',
        'Skip goals',
      ]),
      StageQuizItem('Fun stuff can wait when…', 'Needs are not covered yet', [
        'You have extra savings',
        'It is on sale',
        'Friends buy it',
      ]),
    ],
  ),
  'Coin Count': StageCopy(
    learn: 'Adding small piles of coins quickly shows how much you really have to spend.',
    apply: 'Count coins in one jar and write the total in AED.',
    quiz: [
      StageQuizItem('Counting coins helps you…', 'Know what you have', [
        'Confuse you',
        'Waste time',
        'Avoid saving',
      ]),
      StageQuizItem('AED 5 + AED 3 equals…', 'AED 8', ['AED 2', 'AED 15', 'AED 53']),
      StageQuizItem('Before spending, you should…', 'Know your total', [
        'Guess randomly',
        'Spend first',
        'Ignore small coins',
      ]),
      StageQuizItem('Small coins matter because…', 'They add up', [
        'They are worthless',
        'Shops reject them',
        'They disappear',
      ]),
      StageQuizItem('Fast counting helps at…', 'The checkout line', [
        'Only video games',
        'Never in real life',
        'Only banks',
      ]),
    ],
  ),
  'First Choice': StageCopy(
    learn: 'Your first money choice sets a habit — pick the option that matches your goal.',
    apply: 'Make one small spend today and explain why it was smart.',
    quiz: [
      StageQuizItem('A smart first choice…', 'Matches your goal', [
        'Spends everything',
        'Ignores needs',
        'Copies friends blindly',
      ]),
      StageQuizItem('Before choosing, ask…', 'Need or want?', [
        'Who is fastest?',
        'What is trending?',
        'Can I borrow?'],
      ),
      StageQuizItem('Pick one smart spend means…', 'Think before paying', [
        'Tap instantly',
        'Never compare',
        'Hide the receipt',
      ]),
      StageQuizItem('Good habits start when…', 'You practice small choices', [
        'You spend all at once',
        'You skip planning',
        'You avoid tracking',
      ]),
      StageQuizItem('Why learn early choices?', 'Build lifelong skills', [
        'Spend faster',
        'Ignore prices',
        'Never plan',
      ]),
    ],
  ),
  // Legacy L1 titles (lessons 1–5 bespoke — kept for bank completeness)
  'Needs vs Wants': StageCopy(
    learn: 'Spending uses coins now. Ask first: is it a need (must-have) or a want (extra fun)?',
    apply: 'Sort one purchase today into need or want.',
    quiz: [
      StageQuizItem('A need is…', 'Essential for health or school', [
        'Always the fun option',
        'Whatever ads say',
        'Never important',
      ]),
      StageQuizItem('Water on a hot day is a…', 'Need', ['Want only', 'Never buy', 'Game prize']),
      StageQuizItem('Wants are okay when…', 'Needs are covered first', [
        'You skip meals',
        'You borrow secretly',
        'You hide receipts',
      ]),
      StageQuizItem('Spot the difference to…', 'Spend more wisely', [
        'Spend faster',
        'Avoid math',
        'Never save',
      ]),
      StageQuizItem('Before buying, ask…', 'Need or want?', [
        'Is it viral?',
        'Who bought first?',
        'Can I hide it?',
      ]),
    ],
  ),
  'Saving Jar': StageCopy(
    learn: 'A saving jar is not for spending today — it holds coins for one goal you want later.',
    apply: 'Name your goal and move AED 2 into the jar before any want-spending.',
    quiz: [
      StageQuizItem('A saving jar is for…', 'Future goals', [
        'Instant spending',
        'Random toys today',
        'Secret debt',
      ]),
      StageQuizItem('Goals should be…', 'Specific and dated', [
        'Vague and never',
        'Impossible always',
        'Ignored',
      ]),
      StageQuizItem('Watching the jar grow teaches…', 'Delayed gratification', [
        'Spend everything',
        'Skip tracking',
        'Borrow more',
      ]),
      StageQuizItem('Every coin in the jar…', 'Moves you closer', [
        'Disappears',
        'Is wasted',
        'Is forbidden',
      ]),
      StageQuizItem('Saving first helps…', 'Reach big dreams', [
        'Avoid planning',
        'Spend randomly',
        'Ignore needs',
      ]),
    ],
  ),
  'Smart Spending': StageCopy(
    learn: 'Smart spending means choosing on purpose — compare price, check quality, skip impulse buys.',
    apply: 'Check two prices for one item you want this week.',
    quiz: [
      StageQuizItem('Compare before you buy to…', 'Find better value', [
        'Spend faster',
        'Ignore quality',
        'Buy the first thing',
      ]),
      StageQuizItem('Same snack, different cost means…', 'Shop around helps', [
        'Price never changes',
        'All shops identical',
        'Skip thinking',
      ]),
      StageQuizItem('Smart spending feels…', 'In control', [
        'Stressful always',
        'Random',
        'Impossible',
      ]),
      StageQuizItem('A real deal still…', 'Gets what you need', [
        'Is always 90% off',
        'Needs no checking',
        'Ignores quality',
      ]),
      StageQuizItem('Before paying, check…', 'Price and need', [
        'Only color',
        'Only ads',
        'Only friends',
      ]),
    ],
  ),
  'Budget Basics': StageCopy(
    learn: 'A budget gives every coin a job: needs (must-pay), save (future-you), wants (fun left over).',
    apply: 'Split this week\'s AED into one need line, one save line, and one want line.',
    quiz: [
      StageQuizItem('A budget is…', 'A money plan', [
        'A type of game',
        'A bank loan',
        'A shopping mall',
      ]),
      StageQuizItem('Plan your AED for the week means…', 'Assign every dirham', [
        'Spend without limits',
        'Borrow every week',
        'Ignore totals',
      ]),
      StageQuizItem('If you overspend one line…', 'Adjust other buckets', [
        'Give up forever',
        'Delete all money',
        'Stop learning',
      ]),
      StageQuizItem('Budget basics protect…', 'Essentials first', [
        'Only toys',
        'Only games',
        'Only candy',
      ]),
      StageQuizItem('Review your plan to…', 'Fix mistakes early', [
        'Never improve',
        'Waste time',
        'Skip goals',
      ]),
    ],
  ),
  'Cost of Goods': StageCopy(
    learn: 'Making something costs materials and time — that is the cost of goods.',
    apply: 'List two costs to make one lemonade cup at a stand.',
    quiz: [
      StageQuizItem('Cost of goods includes…', 'Materials and time', [
        'Only profit',
        'Only revenue',
        'Only tax',
      ]),
      StageQuizItem('If lemons cost AED 2, that is…', 'Part of cost', [
        'Pure profit',
        'Free money',
        'Revenue only',
      ]),
      StageQuizItem('Higher material cost means…', 'You must price carefully', [
        'Automatic profit',
        'No planning needed',
        'Customers pay double',
      ]),
      StageQuizItem('Knowing costs helps…', 'Set a fair price', [
        'Hide expenses',
        'Sell below cost',
        'Ignore math',
      ]),
      StageQuizItem('Cost of goods is paid…', 'Before you earn revenue', [
        'After all profit',
        'Never tracked',
        'Only by banks',
      ]),
    ],
  ),
  'Profit = Revenue − Cost': StageCopy(
    learn: 'Revenue is money in from sales; cost is money out; profit is what remains.',
    apply: 'Run Lemon City — price above cost to earn on each cup.',
    quiz: [
      StageQuizItem('Profit equals…', 'Revenue minus cost', [
        'Cost minus revenue',
        'Revenue plus tax only',
        'Random luck',
      ]),
      StageQuizItem('Price below cost means…', 'Loss on each sale', [
        'Big profit',
        'Break even always',
        'Double revenue',
      ]),
      StageQuizItem('Revenue is…', 'Money from customers', [
        'Money you spend',
        'Only savings',
        'Only tax',
      ]),
      StageQuizItem('To earn profit, price must be…', 'Above unit cost', [
        'Below cost',
        'Equal to zero',
        'Hidden',
      ]),
      StageQuizItem('Lemon City teaches…', 'Price above cost to win', [
        'Give cups free',
        'Ignore customers',
        'Skip counting',
      ]),
    ],
  ),
  // L2 — Smart Spender
  'Compare Prices': StageCopy(
    learn: 'The same item can cost different amounts — compare shops before you pay.',
    apply: 'Check two prices for one snack online or in a store.',
    quiz: [
      StageQuizItem('Compare prices to…', 'Find the best value', [
        'Spend faster',
        'Ignore quality',
        'Buy the first thing',
      ]),
      StageQuizItem('Same snack, different cost means…', 'Shop around helps', [
        'All prices equal',
        'Never compare',
        'Quality never matters',
      ]),
      StageQuizItem('Before buying, check…', 'At least two prices', [
        'Only the ad',
        'Only color',
        'Only brand hype',
      ]),
      StageQuizItem('Cheapest is best when…', 'Quality still meets your need', [
        'It breaks instantly',
        'You never use it',
        'It is expired',
      ]),
      StageQuizItem('Compare prices saves…', 'AED for other goals', [
        'Nothing ever',
        'Only time',
        'Your receipt',
      ]),
    ],
  ),
  'Wait a Day': StageCopy(
    learn: 'Sleep on big wants — tomorrow you may not want it as much.',
    apply: 'Write one want you will wait 24 hours before buying.',
    quiz: [
      StageQuizItem('Waiting a day before buying helps…', 'Avoid impulse buys', [
        'Spend faster',
        'Hide money',
        'Skip thinking',
      ]),
      StageQuizItem('Impulse buying means…', 'Buying without thinking', [
        'Planning ahead',
        'Saving every coin',
        'Comparing shops',
      ]),
      StageQuizItem('Emotions calm down when you…', 'Wait before paying', [
        'Tap instantly',
        'Borrow secretly',
        'Skip meals',
      ]),
      StageQuizItem('Sleep on big wants teaches…', 'Patience', [
        'Instant gratification',
        'Ignoring budgets',
        'Random spending',
      ]),
      StageQuizItem('After waiting, you might…', 'Decide you do not need it', [
        'Always buy more',
        'Forget your budget',
        'Spend double',
      ]),
    ],
  ),
  'Deal Detective': StageCopy(
    learn: 'Spot real vs fake deals — check the original price and the fine print.',
    apply: 'Find a “sale” sign and verify the price before and after the discount.',
    quiz: [
      StageQuizItem('Fake deals often…', 'Hide the true price', [
        'Always save money',
        'Teach math',
        'Help charities',
      ]),
      StageQuizItem('A deal detective checks…', 'Original price and need', [
        'Only bright colors',
        'Only loud music',
        'Only friend opinions',
      ]),
      StageQuizItem('"Buy two get one" may…', 'Make you spend more than planned', [
        'Always save AED',
        'Never affect budget',
        'Replace saving',
      ]),
      StageQuizItem('Real savings mean…', 'You pay less than usual for same item', [
        'You buy extra wants',
        'Price does not matter',
        'No comparison needed',
      ]),
      StageQuizItem('Before a flash sale, ask…', 'Do I still need this?', [
        'Who is fastest?',
        'Is it trending?',
        'Can I borrow?',
      ]),
    ],
  ),
  'Shopping List': StageCopy(
    learn: 'A shopping list keeps you on plan — stick to it to avoid surprise spending.',
    apply: 'Write a list before your next shop trip and follow it.',
    quiz: [
      StageQuizItem('A shopping list stops you from…', 'Random extra spending', [
        'Saving more',
        'Learning prices',
        'Helping friends',
      ]),
      StageQuizItem('Stick to your plan means…', 'Buy listed items first', [
        'Grab every aisle deal',
        'Skip needs',
        'Forget totals',
      ]),
      StageQuizItem('Lists help because…', 'You decide before shopping', [
        'Stores choose for you',
        'Ads disappear',
        'Prices vanish',
      ]),
      StageQuizItem('If not on the list…', 'Pause and ask why', [
        'Always buy it',
        'Borrow for it',
        'Hide it',
      ]),
      StageQuizItem('Planning the list saves…', 'Time and money', [
        'Nothing',
        'Only receipts',
        'Your password',
      ]),
    ],
  ),
  'Small Budget': StageCopy(
    learn: 'AED 20 for the week means every dirham has a job — plan before spending.',
    apply: 'Split AED 20 into needs, wants, and save on paper.',
    quiz: [
      StageQuizItem('AED 20 weekly budget means…', 'Plan every dirham', [
        'Spend without limits',
        'Borrow every week',
        'Ignore totals',
      ]),
      StageQuizItem('Small budgets teach…', 'Trade-offs', [
        'Unlimited buying',
        'Ignoring needs',
        'Secret debt',
      ]),
      StageQuizItem('When money is limited…', 'Prioritize needs', [
        'Buy everything',
        'Skip tracking',
        'Guess prices',
      ]),
      StageQuizItem('Leftover dirhams can…', 'Go to savings', [
        'Disappear',
        'Must be wasted',
        'Never count',
      ]),
      StageQuizItem('Tracking AED 20 helps…', 'See where money went', [
        'Hide from parents',
        'Spend faster',
        'Avoid learning',
      ]),
    ],
  ),
  'Spend Smart': StageCopy(
    learn: 'Every dirham has a job — spend, save, or give on purpose.',
    apply: 'Give each AED in your allowance a job on paper tonight.',
    quiz: [
      StageQuizItem('Smart spending feels…', 'In control', [
        'Stressful always',
        'Random',
        'Impossible',
      ]),
      StageQuizItem('Every dirham has a job means…', 'Plan before spending', [
        'Spend instantly',
        'Never save',
        'Ignore lists',
      ]),
      StageQuizItem('Before spending, ask…', 'Does this match my plan?', [
        'Is it viral?',
        'Who bought first?',
        'Can I hide it?',
      ]),
      StageQuizItem('Smart spenders…', 'Track results', [
        'Avoid math',
        'Skip receipts',
        'Never review',
      ]),
      StageQuizItem('Purposeful spending builds…', 'Long-term habits', [
        'Random luck',
        'Secret debt',
        'Instant regret',
      ]),
    ],
  ),
  // L3 — Budget Boss
  'Week Plan': StageCopy(
    learn: 'Split money into buckets — needs, wants, and savings for the week.',
    apply: 'Draw three jars and label them for this week.',
    quiz: [
      StageQuizItem('A week plan splits money into…', 'Buckets with jobs', [
        'One mystery pile',
        'Only games',
        'Random guesses',
      ]),
      StageQuizItem('A budget is…', 'A money plan', [
        'A type of game',
        'A bank loan',
        'A shopping mall',
      ]),
      StageQuizItem('Needs bucket protects…', 'Essentials first', [
        'Only toys',
        'Only candy',
        'Only apps',
      ]),
      StageQuizItem('Planning buckets helps…', 'Avoid surprise empty pockets', [
        'Spend faster',
        'Skip saving',
        'Ignore totals',
      ]),
      StageQuizItem('Review buckets to…', 'Adjust next week', [
        'Never change',
        'Delete money',
        'Stop learning',
      ]),
    ],
  ),
  'Track Spend': StageCopy(
    learn: 'Write what you buy — tracking shows where AED really goes.',
    apply: 'Log three purchases today with amounts in AED.',
    quiz: [
      StageQuizItem('Track spending to…', 'See where AED goes', [
        'Hide from parents',
        'Spend faster',
        'Avoid saving',
      ]),
      StageQuizItem('A spending log should include…', 'Item and amount', [
        'Only feelings',
        'Only colors',
        'Only ads',
      ]),
      StageQuizItem('Tracking reveals…', 'Patterns in your habits', [
        'Nothing useful',
        'Only games',
        'Secret codes',
      ]),
      StageQuizItem('If you skip tracking…', 'Surprises hit harder', [
        'You save more automatically',
        'Budgets fix themselves',
        'Prices drop',
      ]),
      StageQuizItem('Weekly totals help you…', 'Fix the plan', [
        'Ignore mistakes',
        'Spend blindly',
        'Borrow always',
      ]),
    ],
  ),
  'Oops Fix': StageCopy(
    learn: 'Overspending happens — adjust other buckets and learn for next time.',
    apply: 'If you overspent this week, move AED from wants to needs on paper.',
    quiz: [
      StageQuizItem('If you overspend one bucket…', 'Adjust other buckets', [
        'Give up forever',
        'Delete all money',
        'Stop learning',
      ]),
      StageQuizItem('Oops fix means…', 'Adjust and learn', [
        'Quit budgeting',
        'Hide errors',
        'Spend more',
      ]),
      StageQuizItem('After a mistake, you should…', 'Review what happened', [
        'Never track again',
        'Spend double',
        'Ignore parents',
      ]),
      StageQuizItem('Fixing a budget teaches…', 'Resilience', [
        'Perfection only',
        'Never spending',
        'Random luck',
      ]),
      StageQuizItem('Small fixes keep…', 'Your plan alive', [
        'Secrets safe',
        'Debt hidden',
        'Goals impossible',
      ]),
    ],
  ),
  'Needs Bucket': StageCopy(
    learn: 'Protect essentials first — the needs bucket covers food, school, and shelter items.',
    apply: 'List three needs your bucket must cover this week.',
    quiz: [
      StageQuizItem('Needs bucket protects…', 'Essentials first', [
        'Only toys',
        'Only games',
        'Only candy',
      ]),
      StageQuizItem('Before wants spending…', 'Fill needs bucket', [
        'Empty savings',
        'Borrow secretly',
        'Skip meals',
      ]),
      StageQuizItem('School supplies are usually…', 'Needs', [
        'Never required',
        'Pure wants',
        'Always free',
      ]),
      StageQuizItem('Protecting needs means…', 'Stable week', [
        'Random spending',
        'Ignoring rent',
        'Skipping lunch',
      ]),
      StageQuizItem('If needs bucket is short…', 'Cut wants first', [
        'Skip school',
        'Hide bills',
        'Spend more',
      ]),
    ],
  ),
  'Review Day': StageCopy(
    learn: 'Look back and learn — review day asks if you followed your plan.',
    apply: 'Answer: Did I follow my plan? Write one sentence why or why not.',
    quiz: [
      StageQuizItem('Review day helps you…', 'Fix mistakes early', [
        'Never improve',
        'Waste time',
        'Skip goals',
      ]),
      StageQuizItem('Weekly review asks…', 'Did I follow my plan?', [
        'Who wins online?',
        'What is trending?',
        'Ignore totals',
      ]),
      StageQuizItem('Honest review leads to…', 'Better next week', [
        'Hiding errors',
        'Random spending',
        'Giving up',
      ]),
      StageQuizItem('Compare plan vs actual to…', 'Spot gaps', [
        'Avoid math',
        'Skip saving',
        'Spend faster',
      ]),
      StageQuizItem('Review day builds…', 'Budget boss skill', [
        'Secret debt',
        'Impulse habits',
        'Ignored goals',
      ]),
    ],
  ),
  'Goal Glow': StageCopy(
    learn: 'Name your saving dream — specific goals glow brighter when you track them.',
    apply: 'Write one savings goal with a date and AED target.',
    quiz: [
      StageQuizItem('Goals should be…', 'Specific and dated', [
        'Vague and never',
        'Impossible always',
        'Ignored',
      ]),
      StageQuizItem('Goal glow means…', 'Clear picture of your dream', [
        'Random spending',
        'Hidden wishes',
        'No tracking',
      ]),
      StageQuizItem('Naming a goal helps…', 'Stay motivated', [
        'Spend faster',
        'Skip jars',
        'Borrow more',
      ]),
      StageQuizItem('Track progress to…', 'Celebrate small wins', [
        'Ignore savings',
        'Quit early',
        'Hide coins',
      ]),
      StageQuizItem('A dated goal answers…', 'When will I reach it?', [
        'Who is fastest?',
        'What is viral?',
        'Can I borrow?',
      ]),
    ],
  ),
  'Jar Rules': StageCopy(
    learn: 'Three jars, three jobs: Spend (this week), Save (your goal), Give (help others with a plan).',
    apply: 'Label Spend, Save, Give — sort today\'s coins into the right jar.',
    quiz: [
      StageQuizItem('Jar rules mean…', 'Every coin has a job', [
        'Throw coins anywhere',
        'Only one jar',
        'Never save',
      ]),
      StageQuizItem('Saving jar is for…', 'Future plans', [
        'Random toys today',
        'Instant spending',
        'Secret debt',
      ]),
      StageQuizItem('Give jar teaches…', 'Sharing with a plan', [
        'Spending all',
        'Ignoring others',
        'Hiding money',
      ]),
      StageQuizItem('Splitting coins builds…', 'Discipline', [
        'Random luck',
        'Impulse habits',
        'Secret debt',
      ]),
      StageQuizItem('When jars are labeled…', 'Choices are clearer', [
        'Math disappears',
        'Prices vanish',
        'Ads stop',
      ]),
    ],
  ),
  // L4 — Junior Investor
  'Stand Setup': StageCopy(
    learn: 'Cost to make one cup includes lemons, sugar, cups, and your time.',
    apply: 'List every cost for one lemonade cup before setting price.',
    quiz: [
      StageQuizItem('Stand setup tracks…', 'Cost per unit', [
        'Only revenue',
        'Only profit',
        'Only ads',
      ]),
      StageQuizItem('Materials for one cup are…', 'Part of unit cost', [
        'Free always',
        'Pure profit',
        'Customer tips',
      ]),
      StageQuizItem('Your time at the stand is…', 'A real cost', [
        'Worthless',
        'Not counted',
        'Only fun',
      ]),
      StageQuizItem('Knowing setup cost helps…', 'Price above cost', [
        'Sell below cost',
        'Ignore math',
        'Give cups free',
      ]),
      StageQuizItem('Lemon City stand teaches…', 'Unit economics', [
        'Random luck',
        'Only games',
        'Hidden fees',
      ]),
    ],
  ),
  'Price Pick': StageCopy(
    learn: 'Pick a price customers will pay but still covers your cost plus profit.',
    apply: 'Test two prices — which earns profit without scaring customers away?',
    quiz: [
      StageQuizItem('Price pick balances…', 'Cost and willingness to pay', [
        'Only colors',
        'Only ads',
        'Only luck',
      ]),
      StageQuizItem('Price too low means…', 'You lose money', [
        'You earn more',
        'Customers pay double',
        'Costs disappear',
      ]),
      StageQuizItem('Fair price covers…', 'Cost plus some profit', [
        'Only wants',
        'Only tax',
        'Nothing',
      ]),
      StageQuizItem('Ask customers implicitly by…', 'Watching sales at each price', [
        'Guessing once',
        'Never changing',
        'Ignoring feedback',
      ]),
      StageQuizItem('Good pricing feels…', 'Win-win', [
        'Random',
        'Impossible',
        'Always loss',
      ]),
    ],
  ),
  'Busy Day': StageCopy(
    learn: 'Serve more customers when demand is high — busy days boost revenue.',
    apply: 'In Lemon City, try a busier day with fair pricing.',
    quiz: [
      StageQuizItem('Busy days teach…', 'Volume matters', [
        'Nothing useful',
        'To stop selling',
        'To avoid work',
      ]),
      StageQuizItem('More cups sold at profit means…', 'Higher total revenue', [
        'Automatic loss',
        'Zero cost',
        'Free materials',
      ]),
      StageQuizItem('When demand is high…', 'Prepare enough stock', [
        'Close the stand',
        'Raise price randomly',
        'Ignore customers',
      ]),
      StageQuizItem('Busy day profit depends on…', 'Price above cost × cups sold', [
        'Luck only',
        'Ads only',
        'Weather only',
      ]),
      StageQuizItem('Plan for busy days by…', 'Having supplies ready', [
        'Skipping cost math',
        'Hiding prices',
        'Giving free cups',
      ]),
    ],
  ),
  'Profit Smile': StageCopy(
    learn: 'Revenue minus cost equals profit — smile when the number is positive.',
    apply: 'Calculate profit for one Lemon City day in AED.',
    quiz: [
      StageQuizItem('Profit equals…', 'Revenue minus cost', [
        'Cost minus revenue',
        'Revenue plus tax only',
        'Random luck',
      ]),
      StageQuizItem('Positive profit means…', 'You earned after costs', [
        'You lost money',
        'Price was zero',
        'Customers paid nothing',
      ]),
      StageQuizItem('Profit smile comes when…', 'Price beats unit cost', [
        'You sell below cost',
        'You skip counting',
        'You ignore customers',
      ]),
      StageQuizItem('Track both sides…', 'Revenue and cost', [
        'Only fun',
        'Only ads',
        'Only colors',
      ]),
      StageQuizItem('Reinvest profit to…', 'Grow the stand', [
        'Spend on random wants only',
        'Hide earnings',
        'Stop tracking',
      ]),
    ],
  ),
  'Reinvest': StageCopy(
    learn: 'Put some profit back into the business — better cups or more lemons grow sales.',
    apply: 'Choose one reinvestment that could earn more next week.',
    quiz: [
      StageQuizItem('Reinvest profit to…', 'Grow the stand', [
        'Spend on wants only',
        'Hide earnings',
        'Stop tracking',
      ]),
      StageQuizItem('Reinvesting means…', 'Buy tools for future revenue', [
        'Waste all profit',
        'Never save',
        'Ignore costs',
      ]),
      StageQuizItem('Smart reinvest picks…', 'Items that boost sales or cut cost', [
        'Random toys',
        'Unneeded gadgets',
        'Secret debt',
      ]),
      StageQuizItem('Grow your little business by…', 'Improving what you sell', [
        'Lowering quality',
        'Ignoring customers',
        'Skipping math',
      ]),
      StageQuizItem('Profit used wisely…', 'Comes back bigger', [
        'Disappears always',
        'Is taxed away instantly',
        'Never helps',
      ]),
    ],
  ),
  'Interest Intro': StageCopy(
    learn: 'Interest is money growing slowly when savings stay in a bank.',
    apply: 'Ask a parent how savings can earn small interest over time.',
    quiz: [
      StageQuizItem('Interest is…', 'Money growing over time', [
        'A type of game',
        'Always bad',
        'Instant rich',
      ]),
      StageQuizItem('Savings in a bank may…', 'Earn small interest', [
        'Vanish instantly',
        'Never change',
        'Become debt',
      ]),
      StageQuizItem('Interest grows when…', 'Money stays saved', [
        'You spend all',
        'You hide cash',
        'You skip school',
      ]),
      StageQuizItem('Slow growth teaches…', 'Patience', [
        'Gambling',
        'Impulse buys',
        'Secret loans',
      ]),
      StageQuizItem('Junior investors learn…', 'How money can grow', [
        'To spend faster',
        'To ignore math',
        'To avoid plans',
      ]),
    ],
  ),
  'Rainy Day': StageCopy(
    learn: 'Save for surprises — a rainy-day fund covers emergencies without panic.',
    apply: 'Move AED 2 into savings this week for a surprise.',
    quiz: [
      StageQuizItem('Emergency fund is for…', 'Surprises', [
        'Only toys',
        'Vacations only',
        'Never use',
      ]),
      StageQuizItem('Rainy-day savings protect…', 'Your plan when shocks hit', [
        'Only games',
        'Only ads',
        'Only luck',
      ]),
      StageQuizItem('Without rainy-day savings…', 'Small problems feel huge', [
        'You never need money',
        'Prices disappear',
        'Budgets vanish',
      ]),
      StageQuizItem('Start small by…', 'Saving a little regularly', [
        'Spending all now',
        'Borrowing always',
        'Ignoring needs',
      ]),
      StageQuizItem('Future you benefits when…', 'You save early', [
        'You spend all now',
        'You skip school',
        'You borrow lots',
      ]),
    ],
  ),
  'Plan Steps': StageCopy(
    learn: 'Break big goals into small steps — each step gets a date and AED amount.',
    apply: 'Split one big goal into three weekly steps.',
    quiz: [
      StageQuizItem('Plan steps break goals…', 'Into small tasks', [
        'Into confusion',
        'Into debt only',
        'Into nothing',
      ]),
      StageQuizItem('Small steps feel…', 'Achievable', [
        'Impossible',
        'Random',
        'Pointless',
      ]),
      StageQuizItem('Each step needs…', 'A target and timeline', [
        'Only luck',
        'Only ads',
        'Only friends',
      ]),
      StageQuizItem('Tracking steps shows…', 'Progress over time', [
        'Nothing',
        'Only games',
        'Secret codes',
      ]),
      StageQuizItem('Big goals succeed when…', 'Steps are followed', [
        'You skip planning',
        'You spend all',
        'You hide receipts',
      ]),
    ],
  ),
  'Future You': StageCopy(
    learn: 'Thank yourself later — choices today help future you stay calm and ready.',
    apply: 'Write a note to future you about one smart money choice you made.',
    quiz: [
      StageQuizItem('Future you benefits when…', 'You save early', [
        'You spend all now',
        'You skip school',
        'You borrow lots',
      ]),
      StageQuizItem('Long-term thinking means…', 'Weigh today vs tomorrow', [
        'Only instant fun',
        'Never planning',
        'Random clicks',
      ]),
      StageQuizItem('Saving for future you is…', 'A gift to yourself', [
        'A punishment',
        'Always boring',
        'Never useful',
      ]),
      StageQuizItem('Future goals need…', 'Consistent small actions', [
        'One lucky day',
        'Secret debt',
        'Ignoring math',
      ]),
      StageQuizItem('Thank yourself later by…', 'Following your plan now', [
        'Spending everything',
        'Hiding money',
        'Skipping reviews',
      ]),
    ],
  ),
  // L5 — Wealth Builder
  'Ad Alert': StageCopy(
    learn: 'Not every sale is real — ads make wants feel urgent; pause and compare.',
    apply: 'Spot one ad today and ask: need or want?',
    quiz: [
      StageQuizItem('Sale ads sometimes…', 'Exaggerate savings', [
        'Always tell truth',
        'Replace budgeting',
        'Guarantee profit',
      ]),
      StageQuizItem('Ad alert means…', 'Pause before buying', [
        'Buy instantly',
        'Trust every claim',
        'Skip comparison',
      ]),
      StageQuizItem('Flashy ads target…', 'Your emotions', [
        'Only math class',
        'Only banks',
        'Only teachers',
      ]),
      StageQuizItem('Before clicking buy…', 'Check need and price', [
        'Only color',
        'Only music',
        'Only friends',
      ]),
      StageQuizItem('Ads make wants feel…', 'Urgent', [
        'Free always',
        'Unimportant',
        'Impossible',
      ]),
    ],
  ),
  'Quality Check': StageCopy(
    learn: 'Cheap vs worth it — lowest price fails if the item breaks fast.',
    apply: 'Compare two similar items: price, reviews, and expected life.',
    quiz: [
      StageQuizItem('Quality means…', 'Lasts and works well', [
        'Costs the most',
        'Never matters',
        'Is always shiny',
      ]),
      StageQuizItem('Cheapest can cost more if…', 'It breaks quickly', [
        'It lasts years',
        'It fits your need',
        'It has good reviews',
      ]),
      StageQuizItem('Worth-it buys balance…', 'Price and durability', [
        'Only ads',
        'Only color',
        'Only hype',
      ]),
      StageQuizItem('Before choosing cheap…', 'Read reviews or ask', [
        'Buy blindly',
        'Skip research',
        'Ignore returns',
      ]),
      StageQuizItem('Quality check protects…', 'Your AED long term', [
        'Only stores',
        'Only ads',
        'Only luck',
      ]),
    ],
  ),
  'Review Read': StageCopy(
    learn: 'Ask before you buy — read reviews to learn from others’ experience.',
    apply: 'Find two reviews for something you might buy.',
    quiz: [
      StageQuizItem('Reviews help you…', 'Decide wisely', [
        'Spend faster',
        'Avoid thinking',
        'Skip prices',
      ]),
      StageQuizItem('Review read means…', 'Learn from others', [
        'Copy every opinion',
        'Ignore facts',
        'Buy instantly',
      ]),
      StageQuizItem('Look for reviews that…', 'Mention quality and value', [
        'Only use emojis',
        'Hide prices',
        'Are all perfect',
      ]),
      StageQuizItem('Too many perfect reviews may…', 'Be suspicious', [
        'Always guarantee quality',
        'Replace budgeting',
        'Mean free items',
      ]),
      StageQuizItem('Ask before you buy…', 'Saves regret', [
        'Wastes time always',
        'Stops all fun',
        'Is never useful',
      ]),
    ],
  ),
  'Return Rules': StageCopy(
    learn: 'Know store policies — return rules let you fix mistakes safely.',
    apply: 'Check return policy for one shop you use often.',
    quiz: [
      StageQuizItem('Return rules let you…', 'Fix mistakes', [
        'Never help',
        'Cost extra always',
        'Stop learning',
      ]),
      StageQuizItem('Before buying online…', 'Read return policy', [
        'Skip all text',
        'Trust ads only',
        'Hide receipts',
      ]),
      StageQuizItem('Keep receipts to…', 'Prove purchase if needed', [
        'Throw away',
        'Confuse stores',
        'Avoid refunds',
      ]),
      StageQuizItem('Return windows mean…', 'Limited time to bring back', [
        'Forever returns',
        'No rules ever',
        'Free money',
      ]),
      StageQuizItem('Policies protect…', 'Buyers and sellers fairly', [
        'Only stores',
        'Only scammers',
        'Nobody',
      ]),
    ],
  ),
  'Scam Shield': StageCopy(
    learn: 'Too-good offers trick us — scam shield means verify before you pay.',
    apply: 'Learn one sign of an online scam and share with a parent.',
    quiz: [
      StageQuizItem('Scam offers often…', 'Sound too perfect', [
        'Are always safe',
        'Teach math',
        'Help savings',
      ]),
      StageQuizItem('Scam shield means…', 'Verify before paying', [
        'Click every link',
        'Share passwords',
        'Send gift cards',
      ]),
      StageQuizItem('Never share…', 'Passwords or OTP codes', [
        'Your name',
        'Your hobby',
        'Your favorite color',
      ]),
      StageQuizItem('If pressured to pay fast…', 'Pause and ask an adult', [
        'Pay instantly',
        'Ignore parents',
        'Borrow secretly',
      ]),
      StageQuizItem('Free iPhone messages are usually…', 'Scams', [
        'Always real',
        'From banks',
        'Required',
      ]),
    ],
  ),
  'Split Fair': StageCopy(
    learn: 'Share costs with friends fairly — everyone pays their agreed share.',
    apply: 'Plan a group snack and split costs evenly or by what each ordered.',
    quiz: [
      StageQuizItem('Fair split means…', 'Everyone pays fairly', [
        'One person pays all',
        'Random guessing',
        'Hide costs',
      ]),
      StageQuizItem('Before group spending…', 'Agree on split rules', [
        'Assume someone else pays',
        'Skip talking',
        'Borrow secretly',
      ]),
      StageQuizItem('Split fair avoids…', 'Resentment', [
        'All fun',
        'All savings',
        'All planning',
      ]),
      StageQuizItem('Track group costs with…', 'Clear notes or app', [
        'Memory only',
        'Ignoring totals',
        'Hidden fees',
      ]),
      StageQuizItem('When costs differ by item…', 'Pay for what you ordered', [
        'Split randomly',
        'One person always pays',
        'Never discuss',
      ]),
    ],
  ),
  'Group Goal': StageCopy(
    learn: 'Save together for fun — group goals work when everyone agrees on the target.',
    apply: 'Set a small group savings goal with friends or family.',
    quiz: [
      StageQuizItem('Group goals work when…', 'Everyone agrees', [
        'One person decides',
        'No one talks',
        'Secrets only',
      ]),
      StageQuizItem('Save together for fun means…', 'Shared target and timeline', [
        'Random spending',
        'Hidden jars',
        'No tracking',
      ]),
      StageQuizItem('Group savings need…', 'Clear rules', [
        'No plan',
        'Only wants',
        'Only games',
      ]),
      StageQuizItem('Celebrate when…', 'Goal is reached together', [
        'One person quits',
        'Nobody tracks',
        'Everyone spends early',
      ]),
      StageQuizItem('Talk about money…', 'Kindly and clearly', [
        'Never',
        'Only when angry',
        'Only online strangers',
      ]),
    ],
  ),
  'Talk Money': StageCopy(
    learn: 'Kind honest conversations about money build trust with family and friends.',
    apply: 'Ask one money question to a parent or teacher today.',
    quiz: [
      StageQuizItem('Talk money with friends…', 'Kindly and clearly', [
        'Never',
        'Only when angry',
        'Only online',
      ]),
      StageQuizItem('Honest talks help…', 'Avoid surprises', [
        'Hide all spending',
        'Borrow secretly',
        'Skip budgets',
      ]),
      StageQuizItem('When discussing costs…', 'Use facts not blame', [
        'Shout',
        'Hide receipts',
        'Ignore others',
      ]),
      StageQuizItem('Money talks at home teach…', 'Shared values', [
        'Secret debt',
        'Random luck',
        'Only games',
      ]),
      StageQuizItem('Asking questions shows…', 'Curiosity and respect', [
        'Weakness',
        'Rudeness',
        'Never learning',
      ]),
    ],
  ),
  'Team Budget': StageCopy(
    learn: 'Plan a class project budget — list costs, split tasks, track totals.',
    apply: 'Draft a team budget for a small project with three line items.',
    quiz: [
      StageQuizItem('Team budget needs…', 'A shared plan', [
        'No plan',
        'Only wants',
        'Only games',
      ]),
      StageQuizItem('Plan a class project by…', 'Listing all costs', [
        'Guessing once',
        'Ignoring supplies',
        'Skipping totals',
      ]),
      StageQuizItem('Roles in team budget…', 'Who buys what', [
        'Random chaos',
        'One secret payer',
        'No tracking',
      ]),
      StageQuizItem('Track team spending to…', 'Stay on target', [
        'Hide overspend',
        'Borrow always',
        'Quit early',
      ]),
      StageQuizItem('Win together means…', 'Celebrate shared success', [
        'One winner only',
        'Ignore others',
        'Skip saving',
      ]),
    ],
  ),
  'Win Together': StageCopy(
    learn: 'Celebrate group success — winning together means everyone followed the plan.',
    apply: 'Thank one teammate for helping the budget stay on track.',
    quiz: [
      StageQuizItem('Win together means…', 'Celebrate shared success', [
        'One winner only',
        'Ignore others',
        'Skip saving',
      ]),
      StageQuizItem('Group success needs…', 'Everyone’s effort', [
        'Luck only',
        'Ads only',
        'Secrets only',
      ]),
      StageQuizItem('After reaching a group goal…', 'Reflect what worked', [
        'Spend all instantly',
        'Hide results',
        'Never plan again',
      ]),
      StageQuizItem('Shared wins build…', 'Trust', [
        'Secret debt',
        'Random spending',
        'Ignored plans',
      ]),
      StageQuizItem('Celebrate fairly by…', 'Recognizing all helpers', [
        'Taking all credit',
        'Ignoring budget',
        'Skipping thanks',
      ]),
    ],
  ),
  // L6 — Chief Money Officer
  'Master Mix': StageCopy(
    learn: 'Blend all your skills — saving, spending, investing, and giving work together.',
    apply: 'Pick one real decision this week and write pros and cons.',
    quiz: [
      StageQuizItem('Master mix means…', 'Using all money skills', [
        'Spending all fast',
        'Ignoring budgets',
        'Only games',
      ]),
      StageQuizItem('CMO skills include…', 'Plan, save, invest, give', [
        'Only spending',
        'Only borrowing',
        'Only hiding',
      ]),
      StageQuizItem('Balanced money life…', 'Matches your values', [
        'Ignores needs',
        'Skips saving',
        'Random luck',
      ]),
      StageQuizItem('Review all skills to…', 'See gaps', [
        'Never improve',
        'Spend faster',
        'Avoid math',
      ]),
      StageQuizItem('Blend skills daily by…', 'Small intentional choices', [
        'Instant clicks',
        'Secret debt',
        'No planning',
      ]),
    ],
  ),
  'Real Scenario': StageCopy(
    learn: 'Choose in a tough moment — weigh options, not just feelings.',
    apply: 'Describe one tough money choice and what you picked.',
    quiz: [
      StageQuizItem('Real scenarios need…', 'Thoughtful choices', [
        'Random guesses',
        'Instant clicks',
        'No planning',
      ]),
      StageQuizItem('Tough moments test…', 'Your habits', [
        'Only luck',
        'Only ads',
        'Only games',
      ]),
      StageQuizItem('Before deciding, list…', 'Pros and cons', [
        'Only emojis',
        'Only trends',
        'Only friends',
      ]),
      StageQuizItem('Ask for help when…', 'Stakes are high', [
        'Never',
        'Always hide',
        'Skip parents',
      ]),
      StageQuizItem('After a tough choice…', 'Review the outcome', [
        'Never learn',
        'Repeat blindly',
        'Ignore results',
      ]),
    ],
  ),
  'Give & Grow': StageCopy(
    learn: 'Charity with a plan — give thoughtfully without hurting your goals.',
    apply: 'Choose a small give amount that fits your save/spend plan.',
    quiz: [
      StageQuizItem('Give and grow balances…', 'Charity and goals', [
        'Only spending',
        'Only borrowing',
        'Only hiding',
      ]),
      StageQuizItem('Giving with a plan means…', 'Budgeted generosity', [
        'Give everything',
        'Ignore needs',
        'Secret debt',
      ]),
      StageQuizItem('Helping others feels best when…', 'It is sustainable', [
        'It breaks your budget',
        'It is random',
        'It is hidden',
      ]),
      StageQuizItem('Grow and give teaches…', 'Abundance mindset', [
        'Scarcity fear only',
        'Never saving',
        'Random luck',
      ]),
      StageQuizItem('Pick give amount by…', 'Checking your jars first', [
        'Guessing',
        'Borrowing',
        'Ignoring totals',
      ]),
    ],
  ),
  'Seed Invest': StageCopy(
    learn: 'Plant money like a seed — investing is delayed reward with risk and time.',
    apply: 'Learn one safe way kids can think about long-term investing.',
    quiz: [
      StageQuizItem('Investing is…', 'Planting money to grow', [
        'Gambling always',
        'Wasting coins',
        'Avoiding math',
      ]),
      StageQuizItem('Seed invest means…', 'Start small and wait', [
        'Spend all now',
        'Hide cash',
        'Skip school',
      ]),
      StageQuizItem('Growth takes…', 'Time and patience', [
        'One click',
        'Secret loans',
        'Ignoring plans',
      ]),
      StageQuizItem('Risk in investing means…', 'Value can go up or down', [
        'Always doubles',
        'Never changes',
        'Is free money',
      ]),
      StageQuizItem('Learn before investing…', 'Reduces mistakes', [
        'Is useless',
        'Stops all fun',
        'Is only for adults',
      ]),
    ],
  ),
  'Portfolio Play': StageCopy(
    learn: 'Spread risk wisely — do not put every dirham in one place.',
    apply: 'Sketch three buckets: save, invest learning, spend — with percentages.',
    quiz: [
      StageQuizItem('Portfolio play means…', 'Spread risk wisely', [
        'All in one bet',
        'Ignore diversification',
        'Random guessing',
      ]),
      StageQuizItem('Diversification reduces…', 'Big losses from one mistake', [
        'All learning',
        'All saving',
        'All giving',
      ]),
      StageQuizItem('Multiple buckets help when…', 'One area dips', [
        'Everything fails',
        'You never track',
        'You spend all',
      ]),
      StageQuizItem('Spread risk wisely is…', 'Not putting all eggs in one basket', [
        'Buying one item only',
        'Hiding everything',
        'Skipping plans',
      ]),
      StageQuizItem('Review portfolio to…', 'Rebalance over time', [
        'Never change',
        'Spend all',
        'Ignore math',
      ]),
    ],
  ),
  'Tax Basics': StageCopy(
    learn: 'Some money goes to taxes — they fund roads, schools, and public services.',
    apply: 'Ask a parent what taxes pay for in your community.',
    quiz: [
      StageQuizItem('Tax basics teach…', 'Money funds public services', [
        'To avoid all money',
        'To spend faster',
        'To skip school',
      ]),
      StageQuizItem('Taxes help pay for…', 'Roads and schools', [
        'Only toys',
        'Only games',
        'Private secrets',
      ]),
      StageQuizItem('When you earn later…', 'Taxes may apply', [
        'Never',
        'Only on games',
        'Only on gifts',
      ]),
      StageQuizItem('Understanding tax…', 'Makes adult money clearer', [
        'Is useless',
        'Stops fun',
        'Is only scary',
      ]),
      StageQuizItem('Community services need…', 'Shared funding', [
        'One person only',
        'Random ads',
        'Hidden coins',
      ]),
    ],
  ),
  'Side Hustle': StageCopy(
    learn: 'Earn beyond allowance — small jobs teach work, pricing, and responsibility.',
    apply: 'List one safe side hustle you could try with a parent’s OK.',
    quiz: [
      StageQuizItem('Side hustle is…', 'Extra earned work', [
        'Secret debt',
        'Only gifts',
        'Only games',
      ]),
      StageQuizItem('Before hustling…', 'Get parent permission', [
        'Hide work',
        'Skip safety',
        'Ignore rules',
      ]),
      StageQuizItem('Price your hustle by…', 'Covering cost and time', [
        'Guessing zero',
        'Underpricing always',
        'Ignoring effort',
      ]),
      StageQuizItem('Extra income should…', 'Fit your plan', [
        'Disappear',
        'Replace school',
        'Hide from family',
      ]),
      StageQuizItem('Side hustle teaches…', 'Entrepreneurship basics', [
        'Only spending',
        'Only luck',
        'Only ads',
      ]),
    ],
  ),
  'Negotiate': StageCopy(
    learn: 'Ask for fair value — polite negotiation is part of real-world money.',
    apply: 'Role-play asking for fair pay on a small job with a parent.',
    quiz: [
      StageQuizItem('Negotiate fairly means…', 'Ask for fair value', [
        'Take without asking',
        'Hide prices',
        'Ignore people',
      ]),
      StageQuizItem('Good negotiation is…', 'Polite and clear', [
        'Angry demands',
        'Secret threats',
        'Ignoring others',
      ]),
      StageQuizItem('Prepare to negotiate by…', 'Knowing your costs', [
        'Guessing',
        'Skipping math',
        'Hiding effort',
      ]),
      StageQuizItem('Fair value considers…', 'Work, time, and skill', [
        'Only luck',
        'Only ads',
        'Only color',
      ]),
      StageQuizItem('Walk away when…', 'Deal is unfair or unsafe', [
        'Always accept',
        'Never speak',
        'Hide feelings',
      ]),
    ],
  ),
  'Lead & Teach': StageCopy(
    learn: 'Help others learn — sharing what you know makes the whole team stronger.',
    apply: 'Teach one money tip you learned to a friend or sibling.',
    quiz: [
      StageQuizItem('Lead and teach others by…', 'Sharing what you learned', [
        'Showing off only',
        'Keeping secrets',
        'Skipping practice',
      ]),
      StageQuizItem('Teaching money skills…', 'Builds your mastery', [
        'Wastes time',
        'Stops learning',
        'Is never useful',
      ]),
      StageQuizItem('Good teachers…', 'Use simple examples', [
        'Use jargon only',
        'Ignore questions',
        'Hide steps',
      ]),
      StageQuizItem('Leadership in money means…', 'Model smart habits', [
        'Spend recklessly',
        'Hide budgets',
        'Skip planning',
      ]),
      StageQuizItem('Help others learn to…', 'Strengthen community', [
        'Create secrets',
        'Avoid math',
        'Ignore needs',
      ]),
    ],
  ),
  'Big Decision': StageCopy(
    learn: 'Weigh every option — big decisions need time, research, and advice.',
    apply: 'Use a pros/cons list for one decision you face this month.',
    quiz: [
      StageQuizItem('Big decisions need…', 'Comparing all options', [
        'First guess only',
        'No research',
        'Only wants',
      ]),
      StageQuizItem('Before big spends…', 'Sleep and research', [
        'Tap instantly',
        'Borrow secretly',
        'Skip parents',
      ]),
      StageQuizItem('Pros and cons help…', 'See trade-offs', [
        'Hide facts',
        'Avoid math',
        'Spend faster',
      ]),
      StageQuizItem('Ask trusted adults when…', 'Stakes are high', [
        'Never',
        'Always hide',
        'Only online strangers',
      ]),
      StageQuizItem('After deciding…', 'Track results and learn', [
        'Never review',
        'Repeat blindly',
        'Ignore outcomes',
      ]),
    ],
  ),
  'Graduation': StageCopy(
    learn: 'Chief Money Officer — you blend saving, spending, investing, giving, and leading.',
    apply: 'Write your personal money pledge for the next year.',
    quiz: [
      StageQuizItem('Graduation skill is…', 'Leading your money life', [
        'Ignoring plans',
        'Never saving',
        'Only wants',
      ]),
      StageQuizItem('A CMO…', 'Uses all six level skills', [
        'Only spends',
        'Only games',
        'Only luck',
      ]),
      StageQuizItem('Your money pledge should…', 'Match your values', [
        'Copy ads',
        'Ignore needs',
        'Hide budgets',
      ]),
      StageQuizItem('Keep learning because…', 'Money rules change', [
        'You know everything',
        'Math stops',
        'Plans never break',
      ]),
      StageQuizItem('Celebrate graduation by…', 'Setting next goal', [
        'Spending all',
        'Quitting tracking',
        'Ignoring future you',
      ]),
    ],
  ),
};

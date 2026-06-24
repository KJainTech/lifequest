import 'stage_snippets_data.dart';

/// Hand-authored teen-band (13–17) variants for L4–L6 high-stakes stages.
/// Used when [LessonMeta.questLevel] >= 4 and age band is 13–17.
const kTeenStageCopyByTitle = <String, StageCopy>{
  // L4 — Junior Investor
  'Stand Setup': StageCopy(
    learn:
        'Unit economics start with **COGS**: every dirham spent on lemons, cups, ice, and your time to make one sellable cup.',
    apply:
        'Build a one-cup P&L: list materials, estimate minutes, assign AED cost per cup before pricing.',
    quiz: [
      StageQuizItem('COGS per unit includes…', 'Direct materials + production time', [
        'Only marketing',
        'Only profit',
        'Customer tips',
      ]),
      StageQuizItem('Lemons AED 6 + cups AED 4 for 10 drinks. COGS per drink?', 'AED 1', [
        'AED 10',
        'AED 0.50',
        'AED 6',
      ]),
      StageQuizItem('Ignoring your time in COGS leads to…', 'Underpricing and hidden loss', [
        'Automatic profit',
        'Free inventory',
        'Higher revenue only',
      ]),
      StageQuizItem('Costs jumped 20%. Your gut says keep old price. You should…', 'Recalculate break-even first', [
        'Panic quit',
        'Sell at a loss',
        'Ignore customers',
      ]),
      StageQuizItem('Cost AED 2.50/cup. Sell 8 at AED 4. Total profit?', 'AED 12', [
        'AED 32',
        'AED 8',
        'AED 20',
      ]),
    ],
  ),
  'Price Pick': StageCopy(
    learn:
        'Pricing is a signal: too low erodes margin; too high kills volume. Find the band where customers say yes and you stay profitable.',
    apply:
        'Survey three friends: highest price they would pay for your cup; compare to your unit cost + target margin.',
    quiz: [
      StageQuizItem('Good price covers…', 'COGS plus target margin', [
        'Only vibes',
        'Only competitors\' logos',
        'Nothing — price is random',
      ]),
      StageQuizItem('Unit cost AED 3. Target 25% margin on price. Minimum price?', 'AED 4', [
        'AED 3',
        'AED 2',
        'AED 10',
      ]),
      StageQuizItem('Raising price 10% with same volume…', 'Increases profit if cost fixed', [
        'Always kills sales',
        'Eliminates COGS',
        'Is always illegal',
      ]),
      StageQuizItem('Customers hesitate at AED 6 but buy at AED 5. You feel pressure to drop. Best move?', 'Test value — maybe bundle or smaller size', [
        'Give up selling',
        'Hide costs',
        'Price at AED 2',
      ]),
      StageQuizItem('Cost AED 2, price AED 5, 6 cups sold. Profit?', 'AED 18', [
        'AED 30',
        'AED 12',
        'AED 6',
      ]),
    ],
  ),
  'Busy Day': StageCopy(
    learn:
        'Throughput day: when demand spikes, revenue scales only if you prepared stock and kept price above COGS on every cup.',
    apply:
        'Plan a “busy day” checklist: max cups you can serve, prep time, and minimum price that holds margin at peak volume.',
    quiz: [
      StageQuizItem('Busy-day revenue scales with…', 'Cups sold × (price − COGS)', [
        'Luck only',
        'Ad spend only',
        'Ignoring costs',
      ]),
      StageQuizItem('COGS AED 2. Price AED 4. 15 cups sold. Profit?', 'AED 30', [
        'AED 60',
        'AED 15',
        'AED 45',
      ]),
      StageQuizItem('Running out of cups mid-rush means…', 'Lost revenue you cannot recover', [
        'Free marketing',
        'Lower COGS',
        'Automatic refund',
      ]),
      StageQuizItem('Rush feels chaotic. Price drifts down to “move cups.” You should…', 'Hold margin — speed ≠ discount', [
        'Give everything free',
        'Skip counting',
        'Close early always',
      ]),
      StageQuizItem('Prep 20 cups, sell 14 at AED 5 (COGS AED 2). Profit?', 'AED 42', [
        'AED 70',
        'AED 28',
        'AED 10',
      ]),
    ],
  ),
  'Profit Smile': StageCopy(
    learn:
        'P&L in one line: **Profit = Revenue − COGS (and overhead)**. Positive profit funds reinvest and savings.',
    apply:
        'After Lemon City, write revenue, total COGS, and profit in AED — one sentence on what you would change.',
    quiz: [
      StageQuizItem('Profit equals…', 'Revenue minus cost', [
        'Cost minus revenue',
        'Revenue × tax',
        'Revenue + cost',
      ]),
      StageQuizItem('Revenue AED 80, COGS AED 50. Profit?', 'AED 30', [
        'AED 130',
        'AED 50',
        'AED 80',
      ]),
      StageQuizItem('High revenue with negative profit means…', 'Costs or price are wrong', [
        'You are winning',
        'Customers are free',
        'Math is optional',
      ]),
      StageQuizItem('You feel great about sales but wallet is flat. Likely cause?', 'Price below true cost', [
        'Too much saving',
        'Customers paid twice',
        'COGS is zero',
      ]),
      StageQuizItem('COGS AED 3/cup × 10 cups. Revenue AED 55. Profit?', 'AED 25', [
        'AED 85',
        'AED 30',
        'AED 15',
      ]),
    ],
  ),
  'Reinvest': StageCopy(
    learn:
        'Retained earnings fuel growth: reinvest profit into better tools, bulk supplies, or marketing that lowers COGS or lifts sales.',
    apply:
        'Pick one reinvestment under AED 50 that could lower cost per cup or attract more customers next week.',
    quiz: [
      StageQuizItem('Smart reinvest targets…', 'Lower COGS or increase qualified demand', [
        'Random luxury wants',
        'Ignoring books',
        'Secret debt',
      ]),
      StageQuizItem('Profit AED 40. Reinvest AED 25 in bulk lemons (saves AED 0.50/cup). Break-even cups to recover?', '50 cups', [
        '5 cups',
        '0 cups',
        '1000 cups',
      ]),
      StageQuizItem('Reinvesting all profit with zero emergency fund…', 'Raises risk if sales dip', [
        'Is always optimal',
        'Eliminates tax',
        'Guarantees fame',
      ]),
      StageQuizItem('Friend says spend profit on sneakers now. You want growth. You…', 'Split: save + reinvest + small reward', [
        'Spend all instantly',
        'Hide profit',
        'Quit the stand',
      ]),
      StageQuizItem('AED 30 profit → AED 20 better sign, AED 10 save. Next month sign lifts sales 15%. This is…', 'ROI thinking', [
        'Gambling',
        'Waste',
        'Ignoring COGS',
      ]),
    ],
  ),
  'Interest Intro': StageCopy(
    learn:
        'Compound interest: savings earn a percentage over time — money makes money when left in a regulated account.',
    apply:
        'Use a calculator: AED 100 at 4% annual for 1 year — estimate interest earned (simple, not compound).',
    quiz: [
      StageQuizItem('Interest on savings is…', 'Payment for letting bank use your money', [
        'A game fee',
        'Always negative',
        'Same as tax',
      ]),
      StageQuizItem('AED 200 at 5% simple interest 1 year earns…', 'AED 10', [
        'AED 100',
        'AED 5',
        'AED 200',
      ]),
      StageQuizItem('Compound vs simple: compound pays interest on…', 'Principal + prior interest', [
        'Only fees',
        'Only loans',
        'Nothing',
      ]),
      StageQuizItem('Friend wants to “invest” in a random app promising 50%/week. You feel FOMO. Best step?', 'Research + ask adult — likely scam', [
        'Transfer immediately',
        'Borrow to invest',
        'Share password',
      ]),
      StageQuizItem('Goal AED 500 in 10 months. Save AED 50/month. Interest small. On track?', 'Yes — consistent saves', [
        'No — impossible',
        'Only if you gamble',
        'Skip tracking',
      ]),
    ],
  ),
  'Rainy Day': StageCopy(
    learn:
        'Emergency fund: 3–6 months of essential expenses in accessible savings — shocks happen (repairs, medical, job loss).',
    apply:
        'Estimate your share of monthly essentials in AED; set a first milestone at one week of essentials.',
    quiz: [
      StageQuizItem('Emergency fund covers…', 'Unexpected essential costs', [
        'Only vacation',
        'Only gadgets',
        'Luxury always',
      ]),
      StageQuizItem('Essentials AED 400/month. Starter goal = 1 week. Target?', 'AED 100', [
        'AED 4000',
        'AED 10',
        'AED 0',
      ]),
      StageQuizItem('Investing emergency fund in volatile crypto…', 'Wrong bucket — too risky', [
        'Is always smart',
        'Is required',
        'Beats savings always',
      ]),
      StageQuizItem('Phone breaks — repair AED 350. No fund. You feel stressed. Lesson?', 'Rainy-day fund reduces panic', [
        'Debt is free',
        'Ignore it',
        'Never save',
      ]),
      StageQuizItem('Income AED 200/month. Save AED 40/month to e-fund. Months to AED 200?', '5 months', [
        '1 month',
        '40 months',
        'Never',
      ]),
    ],
  ),
  'Plan Steps': StageCopy(
    learn:
        'SMART goals decompose: Specific, Measurable, Achievable, Relevant, Time-bound — break AED targets into weekly deposits.',
    apply:
        'Convert one big goal (e.g. AED 600 laptop) into 12 weekly AED amounts; note start date.',
    quiz: [
      StageQuizItem('SMART goal needs…', 'Clear amount and deadline', [
        'Vague someday',
        'No numbers',
        'Only luck',
      ]),
      StageQuizItem('AED 480 in 12 weeks requires weekly save of…', 'AED 40', [
        'AED 12',
        'AED 480',
        'AED 4',
      ]),
      StageQuizItem('Missing a weekly deposit should trigger…', 'Adjust plan, not quit', [
        'Abandon goal',
        'Hide from family',
        'Borrow secretly',
      ]),
      StageQuizItem('Goal feels far away — motivation dips. Best habit?', 'Automate weekly transfer', [
        'Hope only',
        'Delete goal',
        'Spend to feel better',
      ]),
      StageQuizItem('AED 300 goal, 10 weeks left, AED 120 saved. Weekly need?', 'AED 18', [
        'AED 300',
        'AED 0',
        'AED 50',
      ]),
    ],
  ),
  'Future You': StageCopy(
    learn:
        'Intertemporal choice: spending now vs. investing in future you — education, skills, and savings compound over decades.',
    apply:
        'Write a 3-line letter from “future you at 25” thanking present you for one money habit you start today.',
    quiz: [
      StageQuizItem('Future you benefits most from…', 'Consistent save + skill invest', [
        'Spending every dirham now',
        'Avoiding all risk',
        'Never learning tax',
      ]),
      StageQuizItem('AED 50/month invested 5 years beats one AED 300 splurge because…', 'Time + habit compound', [
        'Splurge always wins',
        'Math stops',
        'Banks forbid saving',
      ]),
      StageQuizItem('Opportunity cost of AED 200 sneakers today might be…', 'AED 200 not saved or invested', [
        'Free money',
        'Zero trade-off',
        'Automatic refund',
      ]),
      StageQuizItem('Peer pressure to spend on nights out. Future-you voice says…', 'Budget fun without killing goals', [
        'Spend all always',
        'Never go out',
        'Hide debt',
      ]),
      StageQuizItem('Pick one: AED 30/week save vs. random AED 120/month. Better for habit?', 'AED 30/week automate', [
        'Random is always best',
        'Never save',
        'Borrow weekly',
      ]),
    ],
  ),
  // L5 — Wealth Builder
  'Ad Alert': StageCopy(
    learn:
        'Performance marketing targets your dopamine — “limited time” and influencer codes are designed to bypass your budget.',
    apply:
        'Screenshot one ad; list three tactics it uses (urgency, social proof, discount framing).',
    quiz: [
      StageQuizItem('Influencer code often…', 'Makes wants feel like deals', [
        'Guarantees quality',
        'Replaces research',
        'Is always cheapest',
      ]),
      StageQuizItem('“Only 2 left!” triggers…', 'Scarcity bias', [
        'Better math',
        'Free shipping always',
        'Automatic refund',
      ]),
      StageQuizItem('Compare final checkout price because…', 'Fees and shipping change total', [
        'Ads never lie',
        'Stars are enough',
        'Color matters most',
      ]),
      StageQuizItem('Drop feels irresistible at midnight. Budget says wait. You…', 'Sleep — revisit with list', [
        'Buy on credit instantly',
        'Share card details',
        'Ignore budget forever',
      ]),
      StageQuizItem('AED 199 “sale” item was AED 189 last month. This is…', 'Fake urgency / inflated anchor', [
        'Always honest',
        'Required by law to buy',
        'Best quality signal',
      ]),
    ],
  ),
  'Quality Check': StageCopy(
    learn:
        'Total cost of ownership: cheap upfront + short life can beat “premium” — calculate cost per use or per year.',
    apply:
        'Compare two headphones: price ÷ expected months of use = monthly cost.',
    quiz: [
      StageQuizItem('AED 60 item lasting 2 years vs AED 30 lasting 4 months. Cheaper per month?', 'AED 60 / 24 months', [
        'AED 30 always',
        'Price tag only',
        'Whichever is shiny',
      ]),
      StageQuizItem('Quality signal includes…', 'Materials, warranty, reviews', [
        'Only influencer',
        'Only color',
        'Only box size',
      ]),
      StageQuizItem('“Too cheap to be true” often means…', 'Hidden failure or scam', [
        'Best value always',
        'Free forever',
        'No returns ever good',
      ]),
      StageQuizItem('You regret cheap shoes after 2 weeks. Emotion?', 'Lesson — factor durability', [
        'Never buy again',
        'Blame luck only',
        'Ignore budget',
      ]),
      StageQuizItem('AED 120 jacket, 3 winters. AED 40 jacket, 1 winter. Cost per winter?', 'AED 40 vs AED 40 — tie on paper; check comfort', [
        'AED 120 is always worse',
        'Cannot calculate',
        'Free second jacket',
      ]),
    ],
  ),
  'Review Read': StageCopy(
    learn:
        'Crowd wisdom is noisy — weight verified purchases, detailed pros/cons, and photos over star spam.',
    apply:
        'Read 5 reviews for one product; note one red flag and one green flag.',
    quiz: [
      StageQuizItem('Verified purchase tag means…', 'Reviewer likely bought item', [
        'Perfect product',
        'Paid advertisement',
        'No returns',
      ]),
      StageQuizItem('All 5-star, zero detail reviews suggest…', 'Possible fake reviews', [
        'Must buy instantly',
        'Guaranteed quality',
        'Lowest price ever',
      ]),
      StageQuizItem('Compare reviews across…', 'Multiple sites and dates', [
        'One emoji tweet',
        'Only influencer story',
        'Packaging color',
      ]),
      StageQuizItem('Reviews say “great” but photos show damage. You feel uneasy. Trust…', 'Photos + detailed negatives', [
        'Stars only',
        'Hype only',
        'Ignore gut',
      ]),
      StageQuizItem('Before AED 400 purchase, minimum research time?', 'Enough to read 10+ substantive reviews', [
        '0 seconds — buy',
        'Only watch unboxing',
        'Never compare',
      ]),
    ],
  ),
  'Return Rules': StageCopy(
    learn:
        'Consumer rights vary by retailer — know return window, restocking fees, and condition rules before big buys.',
    apply:
        'Find return policy for a store you use; note days, receipt need, and refund type.',
    quiz: [
      StageQuizItem('Return window starts usually from…', 'Purchase date', [
        'Your birthday',
        'Never ends',
        'Random guess',
      ]),
      StageQuizItem('Opened electronics may…', 'Have restocking fee or shorter window', [
        'Always full refund anytime',
        'Never return',
        'Double your money',
      ]),
      StageQuizItem('Keep receipt/digital proof to…', 'Validate purchase date', [
        'Impress friends',
        'Avoid tax forever',
        'Skip warranty',
      ]),
      StageQuizItem('Final sale tag makes you nervous. You should…', 'Decide if risk worth discount', [
        'Buy without reading',
        'Assume full refund',
        'Hide from seller',
      ]),
      StageQuizItem('Online return: who pays shipping back?', 'Check policy — often buyer unless defective', [
        'Always seller',
        'Always free',
        'Never specified',
      ]),
    ],
  ),
  'Scam Shield': StageCopy(
    learn:
        'Social engineering: urgency + secrecy + irreversible payment (gift cards, crypto, wire) = scam pattern.',
    apply:
        'Review UAE/common scam signs with a parent; agree on a code word before sending money online.',
    quiz: [
      StageQuizItem('Gift card payment for “refund” is…', 'Almost always scam', [
        'Bank standard',
        'Required for school',
        'Tax refund path',
      ]),
      StageQuizItem('OTP/code request from “bank” DM…', 'Never share — call official number', [
        'Share fast',
        'Post publicly',
        'Forward to friends',
      ]),
      StageQuizItem('Too-good job paying AED 500/day for clicks…', 'Verify company — likely fraud', [
        'Start immediately',
        'Pay signup fee',
        'Share ID photo',
      ]),
      StageQuizItem('Pressure + secrecy (“don’t tell parents”) feels wrong. You…', 'Pause and tell trusted adult', [
        'Obey stranger',
        'Send money',
        'Delete evidence',
      ]),
      StageQuizItem('Secure habit: verify URL and…', 'Use official app, not random links', [
        'Click all ads',
        'Reuse one password',
        'Share screen',
      ]),
    ],
  ),
  'Split Fair': StageCopy(
    learn:
        'Cost allocation in groups: agree method upfront — equal split, by item, or by income share.',
    apply:
        'Plan a AED 120 group meal; assign who pays what before ordering.',
    quiz: [
      StageQuizItem('Fair split starts with…', 'Agreed rules before spending', [
        'Surprise bill at end',
        'One person guesses',
        'Ignore vegetarians',
      ]),
      StageQuizItem('Three friends, unequal orders. Fairest default?', 'Pay for what you ordered', [
        'Split total equally always',
        'Loudest person pays zero',
        'Random',
      ]),
      StageQuizItem('Someone cannot pay share. Group should…', 'Discuss kindly — adjust plan', [
        'Public shame',
        'Ghost them',
        'Hide total',
      ]),
      StageQuizItem('You ordered less but feel guilty. Emotion vs math?', 'Speak up — fairness helps friendship', [
        'Pay for everyone silently',
        'Leave without talking',
        'Borrow secretly',
      ]),
      StageQuizItem('AED 90 bill, you ate AED 25. Others split rest. Your share?', 'AED 25', [
        'AED 90',
        'AED 45',
        'AED 0',
      ]),
    ],
  ),
  'Group Goal': StageCopy(
    learn:
        'Shared sinking fund: transparent ledger, deadline, and what happens if someone drops out.',
    apply:
        'Draft group trip fund: target AED, weekly deposit per person, treasurer role.',
    quiz: [
      StageQuizItem('Group savings need…', 'Written agreement', [
        'Verbal vibe only',
        'One secret holder',
        'No deadline',
      ]),
      StageQuizItem('Treasurer should…', 'Share ledger weekly', [
        'Hide balance',
        'Spend early',
        'Never receipt',
      ]),
      StageQuizItem('Member misses two deposits. Team…', 'Talk early — adjust or exit rule', [
        'Ignore forever',
        'Split silently',
        'Cancel goal with no plan',
      ]),
      StageQuizItem('Excitement fades mid-way. Motivation tool?', 'Visual progress + small milestone reward', [
        'Spend fund on snacks',
        'Quit quietly',
        'Borrow to cover',
      ]),
      StageQuizItem('AED 600 goal, 4 people, 10 weeks. Each per week?', 'AED 15', [
        'AED 600',
        'AED 4',
        'AED 60',
      ]),
    ],
  ),
  'Talk Money': StageCopy(
    learn:
        'Financial transparency with friends reduces conflict — discuss budgets before plans, not after the bill.',
    apply:
        'Before next outing, message: “My budget is AED X — what works for you?”',
    quiz: [
      StageQuizItem('Talking money early…', 'Prevents awkward splits', [
        'Ruins all fun',
        'Is always rude',
        'Is only for adults',
      ]),
      StageQuizItem('Friend spends freely; you cannot. Healthy response?', 'Suggest lower-cost plan', [
        'Borrow to match',
        'Ghost them',
        'Shame them',
      ]),
      StageQuizItem('“I can’t afford that” is…', 'Honest boundary', [
        'Always failure',
        'Never say aloud',
        'Only online',
      ]),
      StageQuizItem('Group chat plans expensive trip. You feel anxious. First step?', 'Share your range privately or in chat', [
        'Say yes then panic',
        'Lie about reason',
        'Cancel last second',
      ]),
      StageQuizItem('Good money talk is…', 'Clear, kind, specific', [
        'Vague and delayed',
        'Only after debt',
        'Always public fight',
      ]),
    ],
  ),
  'Team Budget': StageCopy(
    learn:
        'Project budget: line items, owners, contingency (10–15%), and sign-off before spending club/class funds.',
    apply:
        'Budget a AED 500 class event: venue, food, materials, buffer — assign owners.',
    quiz: [
      StageQuizItem('Contingency buffer covers…', 'Surprise costs', [
        'Leader’s sneakers',
        'Only profit',
        'Nothing',
      ]),
      StageQuizItem('AED 500 budget, 10% buffer reserved. Spendable plan?', 'AED 450 base + AED 50 buffer', [
        'AED 550',
        'AED 500 no buffer',
        'AED 400',
      ]),
      StageQuizItem('No owner on a line item means…', 'Risk nobody tracks it', [
        'Automatic success',
        'Free money',
        'Teacher pays',
      ]),
      StageQuizItem('Mid-project overrun on food. Team should…', 'Use buffer or trim another line', [
        'Ignore total',
        'Hide receipts',
        'Quit event',
      ]),
      StageQuizItem('Sign-off before spend prevents…', 'Unauthorized purchases', [
        'All learning',
        'All fun',
        'All saving',
      ]),
    ],
  ),
  'Win Together': StageCopy(
    learn:
        'Close the loop: retrospective on budget vs actual, thank contributors, document lessons for next event.',
    apply:
        'After a group project, run 15-min retro: what worked, what cost surprised us.',
    quiz: [
      StageQuizItem('Retrospective asks…', 'Plan vs actual and why', [
        'Who to blame only',
        'Nothing',
        'Only selfies',
      ]),
      StageQuizItem('Celebrating success includes…', 'Recognizing finance lead', [
        'Ignoring helpers',
        'Spending leftover secretly',
        'Deleting ledger',
      ]),
      StageQuizItem('Leftover AED 40 in club fund should…', 'Follow agreed policy (roll or donate)', [
        'Split randomly',
        'Disappear',
        'One person keeps',
      ]),
      StageQuizItem('Team tension after overspend. Leader should…', 'Facilitate calm review', [
        'Quit silently',
        'Hide numbers',
        'Shame individuals',
      ]),
      StageQuizItem('Documenting lessons helps…', 'Next team start stronger', [
        'Nothing ever',
        'Only teachers',
        'Avoid all events',
      ]),
    ],
  ),
  // L6 — Chief Money Officer
  'Master Mix': StageCopy(
    learn:
        'Personal finance stack: earn → budget → save → invest → protect → give — tune weights to life stage.',
    apply:
        'Draw your money stack with % targets for each layer this month.',
    quiz: [
      StageQuizItem('CMO mindset balances…', 'Today’s joy and tomorrow’s security', [
        'Only spending',
        'Only hiding cash',
        'Only games',
      ]),
      StageQuizItem('Income AED 800/month. Needs 50%, save 20%, invest learning 10%, fun 20%. Fun AED?', 'AED 160', [
        'AED 800',
        'AED 80',
        'AED 400',
      ]),
      StageQuizItem('Skipping insurance/protection layer…', 'Exposes you to big shocks', [
        'Is always smart',
        'Is illegal',
        'Is free',
      ]),
      StageQuizItem('Every dirham perfect stress. Healthier view?', 'Directionally correct beats perfect', [
        'Quit tracking',
        'All or nothing',
        'Never adjust',
      ]),
      StageQuizItem('Review stack quarterly to…', 'Rebalance life changes', [
        'Never change',
        'Spend all',
        'Avoid tax',
      ]),
    ],
  ),
  'Real Scenario': StageCopy(
    learn:
        'Decision matrix: list options, score impact on goals, risk, and reversibility — then choose.',
    apply:
        'Apply a 3-column matrix to one real choice: buy used phone now vs. save 2 more months.',
    quiz: [
      StageQuizItem('Reversible decision (small buy) vs irreversible (contract)…', 'Spend more research on irreversible', [
        'Treat same',
        'Ignore contracts',
        'Always rush',
      ]),
      StageQuizItem('Option A: AED 200 now. Option B: AED 240 in 3 months with save plan. Matrix checks…', 'Goal fit and cash flow', [
        'Only color',
        'Only ads',
        'Only friends',
      ]),
      StageQuizItem('Sunk cost fallacy: keeping bad purchase because…', 'You already paid', [
        'Is always rational',
        'Improves profit',
        'Is required',
      ]),
      StageQuizItem('Pressure to decide in 5 minutes on AED 2000 laptop. You…', 'Walk away — high stakes need time', [
        'Sign immediately',
        'Borrow max',
        'Share OTP',
      ]),
      StageQuizItem('After choice, schedule…', 'Review date to learn outcome', [
        'Never think again',
        'Hide receipt',
        'Blame others only',
      ]),
    ],
  ),
  'Give & Grow': StageCopy(
    learn:
        'Effective altruism lite: give with intention — % of income, vetted causes, tax-aware where applicable.',
    apply:
        'Pick a cause; set give cap (e.g. 3% of allowance) that does not break emergency fund.',
    quiz: [
      StageQuizItem('Sustainable giving means…', 'Budgeted % not guilt spikes', [
        'Give until broke',
        'Never track',
        'Only random',
      ]),
      StageQuizItem('Income AED 400, give cap 5%. Max give/month?', 'AED 20', [
        'AED 400',
        'AED 200',
        'AED 0 always',
      ]),
      StageQuizItem('Verify charity via…', 'Registered status + impact reports', [
        'Random DM',
        'Gift cards',
        'Secret links',
      ]),
      StageQuizItem('Friend fundraises; you are tight this month. You…', 'Small amount or honest “not this month”', [
        'Borrow to donate',
        'Shame yourself',
        'Fake transfer',
      ]),
      StageQuizItem('Give & grow links generosity to…', 'Long-term values and planning', [
        'Impulse only',
        'Public praise only',
        'Tax evasion',
      ]),
    ],
  ),
  'Seed Invest': StageCopy(
    learn:
        'Risk/return tradeoff: diversified low-cost index concepts beat stock-picking for most beginners.',
    apply:
        'Read one page on diversification; list three asset types (cash, bonds, equities).',
    quiz: [
      StageQuizItem('Diversification reduces…', 'Single-company risk', [
        'All risk to zero',
        'Need to learn',
        'Tax always',
      ]),
      StageQuizItem('“Guaranteed 20% monthly” investment is…', 'Likely fraud', [
        'Bank default',
        'School requirement',
        'Same as savings',
      ]),
      StageQuizItem('Emergency fund before aggressive invest because…', 'Avoid selling at loss in shock', [
        'Banks forbid save',
        'Invest is illegal',
        'Cash earns most',
      ]),
      StageQuizItem('Friend mocks “boring” index fund. You feel FOMO on meme stock. You…', 'Stick to plan — hype ≠ strategy', [
        'All-in meme',
        'Borrow to trade',
        'Share login',
      ]),
      StageQuizItem('Time horizon 10+ years allows…', 'More equity risk tolerance', [
        'Only gambling',
        'No planning',
        'Daily panic sell',
      ]),
    ],
  ),
  'Portfolio Play': StageCopy(
    learn:
        'Asset allocation by age/goals: younger long horizon → higher equity share; near goal → shift to stability.',
    apply:
        'Sketch sample split for age 16 vs age 60 (not advice — learning exercise).',
    quiz: [
      StageQuizItem('Portfolio spread means…', 'Not all eggs one basket', [
        'One hot stock',
        'Hide all cash',
        'Ignore fees',
      ]),
      StageQuizItem('Rebalancing sells winners partly to…', 'Maintain target mix', [
        'Maximize tax always',
        'Eliminate profit',
        'Avoid all gain',
      ]),
      StageQuizItem('High fee fund 2%/year vs index 0.2% over decades…', 'Fees compound against you', [
        'Fees do not matter',
        'Higher fee always wins',
        'Math stops',
      ]),
      StageQuizItem('Market drops 15%; panic sell everything. Better CMO move?', 'Review plan — maybe hold if horizon long', [
        'Sell all always',
        'Borrow more stock',
        'Never look again',
      ]),
      StageQuizItem('Goal in 2 years (laptop fund) should be mostly…', 'Stable/savings-like', [
        'Volatile crypto',
        'Single stock',
        'Leveraged bets',
      ]),
    ],
  ),
  'Tax Basics': StageCopy(
    learn:
        'Tax funds public goods — income/VAT concepts; keep records if you earn beyond allowance.',
    apply:
        'With a parent, find one public service taxes fund in your emirate.',
    quiz: [
      StageQuizItem('VAT is…', 'Consumption tax on goods/services', [
        'Video game rank',
        'Bank password',
        'Allowance fee',
      ]),
      StageQuizItem('Side income may…', 'Require tracking for tax reporting', [
        'Never matter',
        'Is always illegal',
        'Is tax-free always',
      ]),
      StageQuizItem('Keeping simple income log helps…', 'Accurate reporting if required', [
        'Avoid school',
        'Hide savings',
        'Skip budget',
      ]),
      StageQuizItem('“Cash only so no tax” from friend sounds…', 'Risky / possibly illegal advice', [
        'Expert finance',
        'School rule',
        'Required',
      ]),
      StageQuizItem('Taxes and fees are…', 'Part of real-world money math', [
        'Optional fiction',
        'Only for companies',
        'Never in UAE',
      ]),
    ],
  ),
  'Side Hustle': StageCopy(
    learn:
        'Micro-business: validate demand, price above cost, track revenue/expense, comply with family/school rules.',
    apply:
        'Draft one-page hustle plan: offer, price, cost, hours, parent approval checkbox.',
    quiz: [
      StageQuizItem('Validate hustle by…', 'Small test before big spend', [
        'Buy inventory truck',
        'Quit school',
        'Ignore costs',
      ]),
      StageQuizItem('Revenue AED 300, expenses AED 180. Profit?', 'AED 120', [
        'AED 480',
        'AED 180',
        'AED 300',
      ]),
      StageQuizItem('Underpricing to beat friends…', 'May not cover time + materials', [
        'Always wins long-term',
        'Is tax free',
        'Is required',
      ]),
      StageQuizItem('Hustle grows; school suffers. Balance move?', 'Cap hours — protect education', [
        'Drop school',
        'Hide grades',
        'Sleep 2 hours',
      ]),
      StageQuizItem('Separate hustle ledger helps…', 'See true profit', [
        'Mix with lunch money randomly',
        'Avoid all math',
        'Never invoice',
      ]),
    ],
  ),
  'Negotiate': StageCopy(
    learn:
        'BATNA: Best Alternative To Negotiated Agreement — know your walk-away before talking price.',
    apply:
        'Role-play tutoring rate: your cost (time), market rate, minimum acceptable.',
    quiz: [
      StageQuizItem('BATNA is…', 'Your best option if deal fails', [
        'Always accept first offer',
        'Random number',
        'Friend’s opinion only',
      ]),
      StageQuizItem('Employer offers AED 40/hr; your BATNA is AED 35 elsewhere. Leverage?', 'Moderate — know floor', [
        'Must take AED 10',
        'No research needed',
        'Walk always rude',
      ]),
      StageQuizItem('Polite negotiation includes…', 'Data on value you deliver', [
        'Threats',
        'Ghosting',
        'Lies on resume',
      ]),
      StageQuizItem('Pressure “sign now or lose offer.” You feel rushed. You…', 'Ask time to review — legit offers wait', [
        'Sign blank',
        'Share bank login',
        'Accept any wage',
      ]),
      StageQuizItem('Win-win deal means…', 'Both sides gain vs alternatives', [
        'Winner takes all',
        'Secret sabotage',
        'Ignore costs',
      ]),
    ],
  ),
  'Lead & Teach': StageCopy(
    learn:
        'Teaching solidifies mastery — explain concepts simply (Feynman) to spot gaps in your own understanding.',
    apply:
        'Teach a younger sibling “profit = revenue − cost” with a 3-minute example.',
    quiz: [
      StageQuizItem('Explain simply to…', 'Find gaps in your knowledge', [
        'Show off only',
        'Confuse them',
        'Skip practice',
      ]),
      StageQuizItem('Good mentor…', 'Asks questions back', [
        'Gives all answers',
        'Mocks mistakes',
        'Ignores budget',
      ]),
      StageQuizItem('Peer asks risky “investment.” You lead by…', 'Sharing scam signs + adult referral', [
        'Join blindly',
        'Share passwords',
        'Pressure them',
      ]),
      StageQuizItem('Nervous teaching. Growth mindset says…', 'Practice improves clarity', [
        'Never try',
        'Only experts teach',
        'Hide knowledge',
      ]),
      StageQuizItem('Lead & teach builds…', 'Community financial literacy', [
        'Secret clubs',
        'More debt',
        'Less math',
      ]),
    ],
  ),
  'Big Decision': StageCopy(
    learn:
        'Major forks (university path, first car, gap year) need multi-criteria analysis + advisor input.',
    apply:
        'List 3 criteria for one big decision; score two options 1–5 each.',
    quiz: [
      StageQuizItem('Big decision checklist includes…', 'Cost, timeline, reversibility', [
        'Only Instagram polls',
        'Only luck',
        'Only color',
      ]),
      StageQuizItem('AED 15,000 over 4 years vs AED 25,000 over 2 years — compare…', 'Total cost and opportunity', [
        'Only logo',
        'Only friends',
        'Only hype',
      ]),
      StageQuizItem('Consult mentors because…', 'They see blind spots', [
        'They decide for you',
        'You avoid thinking',
        'Rules never change',
      ]),
      StageQuizItem('Fear of missing out on path friends chose. You…', 'Run your own matrix', [
        'Copy without research',
        'Borrow to match',
        'Hide feelings only',
      ]),
      StageQuizItem('Document decision rationale to…', 'Learn from future outcomes', [
        'Never review',
        'Blame others',
        'Avoid all change',
      ]),
    ],
  ),
  'Graduation': StageCopy(
    learn:
        'Chief Money Officer pledge: continuous learning, ethical earning, transparent giving, and calm under market noise.',
    apply:
        'Write your CMO pledge: 3 habits you keep, 2 you stop, 1 person you will mentor.',
    quiz: [
      StageQuizItem('CMO graduation means…', 'Owning your full money life', [
        'Knowing everything forever',
        'Never mistakes',
        'Only spending',
      ]),
      StageQuizItem('Lifelong learning because…', 'Rules, tools, and scams evolve', [
        'Finance never changes',
        'Apps replace thinking',
        'School was enough',
      ]),
      StageQuizItem('Ethical earning excludes…', 'Scams and hidden harm', [
        'All business',
        'All saving',
        'All teaching',
      ]),
      StageQuizItem('Calm under noise (hype, crashes) comes from…', 'Written plan + emergency fund', [
        'Panic always',
        'Ignore all news',
        'All-in daily',
      ]),
      StageQuizItem('Next quest after graduation is…', 'Apply stack in real adult milestones', [
        'Stop tracking',
        'Spend all',
        'Avoid tax forever',
      ]),
    ],
  ),
};

bool hasTeenVariant(String title) => kTeenStageCopyByTitle.containsKey(title);

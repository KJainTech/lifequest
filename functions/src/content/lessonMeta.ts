/** Curriculum metadata for server-side template fallback (mirrors curriculum_builder.dart). */

export const STAGES_PER_LEVEL = [5, 6, 7, 9, 10, 11] as const;

export const QUEST_LEVEL_NAMES = [
  'Coin Keeper',
  'Smart Spender',
  'Budget Boss',
  'Junior Investor',
  'Wealth Builder',
  'Chief Money Officer',
] as const;

const LEGACY_FIRST_SIX = [
  { title: 'Needs vs Wants', subtitle: 'Spot the difference before you spend' },
  { title: 'Saving Jar', subtitle: 'Set a goal and watch it grow' },
  { title: 'Smart Spending', subtitle: 'Compare before you buy' },
  { title: 'Budget Basics', subtitle: 'Plan your AED for the week' },
  { title: 'Cost of Goods', subtitle: 'What it takes to make something' },
  { title: 'Profit = Revenue − Cost', subtitle: 'Run your stand and learn when you earn' },
];

const LEVEL_STAGE_TITLES: { title: string; subtitle: string }[][] = [
  [
    { title: 'Hello Coins', subtitle: 'Meet money and where it lives' },
    { title: 'Needs First', subtitle: 'Food and shelter before fun' },
    { title: 'Want Later', subtitle: 'Fun stuff can wait' },
    { title: 'Coin Count', subtitle: 'Add up small piles fast' },
    { title: 'First Choice', subtitle: 'Pick one smart spend' },
  ],
  [
    { title: 'Compare Prices', subtitle: 'Same snack, different cost' },
    { title: 'Wait a Day', subtitle: 'Sleep on big wants' },
    { title: 'Deal Detective', subtitle: 'Spot real vs fake deals' },
    { title: 'Shopping List', subtitle: 'Stick to your plan' },
    { title: 'Small Budget', subtitle: 'AED 20 for the week' },
    { title: 'Spend Smart', subtitle: 'Every dirham has a job' },
  ],
  [
    { title: 'Week Plan', subtitle: 'Split money into buckets' },
    { title: 'Track Spend', subtitle: 'Write what you buy' },
    { title: 'Oops Fix', subtitle: 'Adjust when you overspend' },
    { title: 'Needs Bucket', subtitle: 'Protect essentials first' },
    { title: 'Review Day', subtitle: 'Look back and learn' },
    { title: 'Goal Glow', subtitle: 'Name your saving dream' },
    { title: 'Jar Rules', subtitle: 'Every coin has a job' },
  ],
  [
    { title: 'Stand Setup', subtitle: 'Cost to make one cup' },
    { title: 'Price Pick', subtitle: 'What customers will pay' },
    { title: 'Busy Day', subtitle: 'Serve more, earn more' },
    { title: 'Profit Smile', subtitle: 'Revenue minus cost' },
    { title: 'Reinvest', subtitle: 'Grow your little business' },
    { title: 'Interest Intro', subtitle: 'Money can grow slowly' },
    { title: 'Rainy Day', subtitle: 'Save for surprises' },
    { title: 'Plan Steps', subtitle: 'Break big goals small' },
    { title: 'Future You', subtitle: 'Thank yourself later' },
  ],
  [
    { title: 'Ad Alert', subtitle: 'Not every sale is real' },
    { title: 'Quality Check', subtitle: 'Cheap vs worth it' },
    { title: 'Review Read', subtitle: 'Ask before you buy' },
    { title: 'Return Rules', subtitle: 'Know store policies' },
    { title: 'Scam Shield', subtitle: 'Too-good offers trick us' },
    { title: 'Split Fair', subtitle: 'Share costs with friends' },
    { title: 'Group Goal', subtitle: 'Save together for fun' },
    { title: 'Talk Money', subtitle: 'Kind honest conversations' },
    { title: 'Team Budget', subtitle: 'Plan a class project' },
    { title: 'Win Together', subtitle: 'Celebrate group success' },
  ],
  [
    { title: 'Master Mix', subtitle: 'Blend all your skills' },
    { title: 'Real Scenario', subtitle: 'Choose in a tough moment' },
    { title: 'Give & Grow', subtitle: 'Charity with a plan' },
    { title: 'Seed Invest', subtitle: 'Plant money like a seed' },
    { title: 'Portfolio Play', subtitle: 'Spread risk wisely' },
    { title: 'Tax Basics', subtitle: 'Where some money goes' },
    { title: 'Side Hustle', subtitle: 'Earn beyond allowance' },
    { title: 'Negotiate', subtitle: 'Ask for fair value' },
    { title: 'Lead & Teach', subtitle: 'Help others learn' },
    { title: 'Big Decision', subtitle: 'Weigh every option' },
    { title: 'Graduation', subtitle: 'Chief Money Officer' },
  ],
];

export interface LessonMetaLite {
  order: number;
  title: string;
  subtitle: string;
  questLevel: number;
  stageInLevel: number;
  questLevelName: string;
}

export function parseLessonOrder(lessonId: string): number | null {
  const match = /^lesson_(\d+)$/.exec(lessonId);
  if (!match) return null;
  return Number.parseInt(match[1], 10);
}

export function lessonMetaForOrder(order: number): LessonMetaLite | null {
  if (order < 1 || order > 48) return null;
  let remaining = order;
  for (let level = 1; level <= 6; level++) {
    const count = STAGES_PER_LEVEL[level - 1];
    if (remaining <= count) {
      const legacy = order <= 6 ? LEGACY_FIRST_SIX[order - 1] : null;
      const stage = LEVEL_STAGE_TITLES[level - 1][remaining - 1];
      return {
        order,
        title: legacy?.title ?? stage.title,
        subtitle: legacy?.subtitle ?? stage.subtitle,
        questLevel: level,
        stageInLevel: remaining,
        questLevelName: QUEST_LEVEL_NAMES[level - 1],
      };
    }
    remaining -= count;
  }
  return null;
}

export function lessonMetaForId(lessonId: string): LessonMetaLite | null {
  const order = parseLessonOrder(lessonId);
  if (order == null) return null;
  return lessonMetaForOrder(order);
}

export function skillKeyForQuestLevel(questLevel: number): string {
  return `L${Math.min(Math.max(questLevel, 1), 6)}`;
}

export function difficultyFromMastery(mastery: number): number {
  if (mastery >= 75) return 4;
  if (mastery >= 55) return 3;
  if (mastery >= 40) return 2;
  return 1;
}

export function masteryTierLabel(mastery: number): string {
  if (mastery >= 75) return 'advanced';
  if (mastery >= 55) return 'intermediate';
  if (mastery >= 40) return 'developing';
  return 'foundational';
}

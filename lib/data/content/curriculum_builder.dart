import 'lesson_catalog.dart';

/// Six quest levels · forty-eight stages — aligned to LifeQuest curriculum doc.
const kQuestLevelCount = 6;
const kTotalStages = 48;

/// Stages per level: L1=5, L2=6, L3=7, L4=9, L5=10, L6=11 → 48 total.
const kStagesPerLevel = <int>[5, 6, 7, 9, 10, 11];

/// Back-compat alias — max stages in any single level.
int get kStagesPerQuestLevel =>
    kStagesPerLevel.reduce((a, b) => a > b ? a : b);

const kQuestLevelNames = <String>[
  'Coin Keeper',
  'Smart Spender',
  'Budget Boss',
  'Junior Investor',
  'Wealth Builder',
  'Chief Money Officer',
];

enum QuestTier { foundation, intermediate, advanced }

const kQuestLevelTiers = <QuestTier>[
  QuestTier.foundation,
  QuestTier.foundation,
  QuestTier.intermediate,
  QuestTier.intermediate,
  QuestTier.advanced,
  QuestTier.advanced,
];

/// Days before the next level unlocks (0 = no gate).
const kLevelTimeGateDays = <int>[0, 0, 14, 30, 90, 180];

/// 80% mastery on 5-question quiz.
const kMasteryQuizScore = 4;

const kLegacyFirstSix = <({String title, String subtitle, String concept})>[
  (
    title: 'Counting the Cost',
    subtitle: 'Add up what things really cost in AED',
    concept: 'counting_cost',
  ),
  (
    title: 'The Trade-off',
    subtitle: 'When you pick one thing, you give up another',
    concept: 'trade_off',
  ),
  (
    title: 'Needs Before Wants',
    subtitle: 'Must-haves before fun spending',
    concept: 'needs_before_wants',
  ),
  (
    title: 'Work and Get Paid',
    subtitle: 'Earn AED by helping out and doing jobs',
    concept: 'work_and_paid',
  ),
  (
    title: 'Exit Challenge',
    subtitle: 'Show what you learned in Level 1',
    concept: 'exit_challenge',
  ),
  (
    title: 'Profit = Revenue − Cost',
    subtitle: 'Run your stand and learn when you earn',
    concept: 'cost_profit',
  ),
];

const kLevelStageTitles = <List<({String title, String subtitle})>>[
  [
    (title: 'Counting the Cost', subtitle: 'Add up what things really cost in AED'),
    (title: 'The Trade-off', subtitle: 'When you pick one thing, you give up another'),
    (title: 'Needs Before Wants', subtitle: 'Must-haves before fun spending'),
    (title: 'Work and Get Paid', subtitle: 'Earn AED by helping out and doing jobs'),
    (title: 'Exit Challenge', subtitle: 'Show what you learned in Level 1'),
  ],
  [
    (title: 'Compare Prices', subtitle: 'Same snack, different cost'),
    (title: 'Wait a Day', subtitle: 'Sleep on big wants'),
    (title: 'Deal Detective', subtitle: 'Spot real vs fake deals'),
    (title: 'Shopping List', subtitle: 'Stick to your plan'),
    (title: 'Small Budget', subtitle: 'Split AED 20 into jobs'),
    (title: 'Spend Smart', subtitle: 'Every dirham has a job'),
  ],
  [
    (title: 'Week Plan', subtitle: 'Split money into buckets'),
    (title: 'Track Spend', subtitle: 'Write what you buy'),
    (title: 'Oops Fix', subtitle: 'Adjust when you overspend'),
    (title: 'Needs Bucket', subtitle: 'Protect essentials first'),
    (title: 'Review Day', subtitle: 'Look back and learn'),
    (title: 'Goal Glow', subtitle: 'Name what your jar is for'),
    (title: 'Jar Rules', subtitle: 'Spend, Save, and Give jars'),
  ],
  [
    (title: 'Stand Setup', subtitle: 'Cost to make one cup'),
    (title: 'Price Pick', subtitle: 'What customers will pay'),
    (title: 'Busy Day', subtitle: 'Serve more, earn more'),
    (title: 'Profit Smile', subtitle: 'Revenue minus cost'),
    (title: 'Reinvest', subtitle: 'Grow your little business'),
    (title: 'Interest Intro', subtitle: 'Money can grow slowly'),
    (title: 'Rainy Day', subtitle: 'Save for surprises'),
    (title: 'Plan Steps', subtitle: 'Break big goals small'),
    (title: 'Future You', subtitle: 'Thank yourself later'),
  ],
  [
    (title: 'Ad Alert', subtitle: 'Not every sale is real'),
    (title: 'Quality Check', subtitle: 'Cheap vs worth it'),
    (title: 'Review Read', subtitle: 'Ask before you buy'),
    (title: 'Return Rules', subtitle: 'Know store policies'),
    (title: 'Scam Shield', subtitle: 'Too-good offers trick us'),
    (title: 'Split Fair', subtitle: 'Share costs with friends'),
    (title: 'Group Goal', subtitle: 'Save together for fun'),
    (title: 'Talk Money', subtitle: 'Kind honest conversations'),
    (title: 'Team Budget', subtitle: 'Plan a class project'),
    (title: 'Win Together', subtitle: 'Celebrate group success'),
  ],
  [
    (title: 'Master Mix', subtitle: 'Blend all your skills'),
    (title: 'Real Scenario', subtitle: 'Choose in a tough moment'),
    (title: 'Give & Grow', subtitle: 'Charity with a plan'),
    (title: 'Seed Invest', subtitle: 'Plant money like a seed'),
    (title: 'Portfolio Play', subtitle: 'Spread risk wisely'),
    (title: 'Tax Basics', subtitle: 'Where some money goes'),
    (title: 'Side Hustle', subtitle: 'Earn beyond allowance'),
    (title: 'Negotiate', subtitle: 'Ask for fair value'),
    (title: 'Lead & Teach', subtitle: 'Help others learn'),
    (title: 'Big Decision', subtitle: 'Weigh every option'),
    (title: 'Graduation', subtitle: 'Chief Money Officer'),
  ],
];

int stagesInQuestLevel(int questLevel) =>
    kStagesPerLevel[(questLevel - 1).clamp(0, kQuestLevelCount - 1)];

/// 1-based concept order for the first stage of a quest level.
int firstOrderForQuestLevel(int questLevel) {
  var order = 1;
  for (var l = 1; l < questLevel; l++) {
    order += stagesInQuestLevel(l);
  }
  return order;
}

List<LessonMeta> buildCurriculum() {
  final lessons = <LessonMeta>[];
  var order = 1;
  for (var level = 1; level <= kQuestLevelCount; level++) {
    final stageCount = stagesInQuestLevel(level);
    final levelTitles = kLevelStageTitles[level - 1];
    for (var stage = 1; stage <= stageCount; stage++) {
      final legacy =
          order <= kLegacyFirstSix.length ? kLegacyFirstSix[order - 1] : null;
      final stageTopic = levelTitles[stage - 1];
      final title = legacy?.title ?? stageTopic.title;
      final subtitle = legacy?.subtitle ?? stageTopic.subtitle;
      final baseConcept = legacy?.concept ?? 'stage_${level}_$stage';
      lessons.add(
        LessonMeta(
          id: 'lesson_$order',
          title: title,
          subtitle: subtitle,
          conceptOrder: order,
          questLevel: level,
          stageInLevel: stage,
          questLevelName: kQuestLevelNames[level - 1],
          conceptSlug: '${baseConcept}_L$level',
          prerequisiteId: order == 1 ? null : 'lesson_${order - 1}',
        ),
      );
      order++;
    }
  }
  return lessons;
}

String tierLabel(QuestTier tier) => switch (tier) {
      QuestTier.foundation => 'Foundation',
      QuestTier.intermediate => 'Intermediate',
      QuestTier.advanced => 'Advanced',
    };

String timeGateLabel(int questLevel) {
  final days = kLevelTimeGateDays[questLevel - 1];
  if (days <= 0) return 'No gate';
  if (days < 30) return '$days-day gate';
  if (days < 90) return '${days ~/ 30} month gate';
  return '${days ~/ 30} months gate';
}

/// Stage label shown in UI — e.g. 1.1 for Level 1 Stage 1.
String stageLabel(LessonMeta meta) => '${meta.questLevel}.${meta.stageInLevel}';

/// Final stage of each level — level-end Exit Challenge (not a full lesson loop).
bool isExitChallengeStage(LessonMeta meta) =>
    meta.stageInLevel == stagesInQuestLevel(meta.questLevel);

/// Estimated coins on a strong finish (quiz + game) — shown on the quest map.
int stageCoinPreview(LessonMeta meta) {
  if (isExitChallengeStage(meta)) return 25;
  if (meta.questLevel == 1) {
    return switch (meta.stageInLevel) {
      1 || 2 => 10,
      3 || 4 => 15,
      _ => 25,
    };
  }
  final base = 8 + meta.questLevel * 2;
  return base;
}

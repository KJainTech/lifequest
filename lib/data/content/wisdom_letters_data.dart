/// Money Wisdom Letters — 6 levels × 3 guides (DevPlan Day 29).
class WisdomLetter {
  const WisdomLetter({
    required this.level,
    required this.rule,
    required this.pennyBody,
    required this.finBotBody,
    required this.atlasBody,
  });

  final int level;
  final String rule;
  final String pennyBody;
  final String finBotBody;
  final String atlasBody;

  String bodyForGuide(String guideId) => switch (guideId) {
        'finBot' => finBotBody,
        'atlas' => atlasBody,
        _ => pennyBody,
      };

  String signoffForGuide(String guideId) => switch (guideId) {
        'finBot' => '— FinBot ⚡',
        'atlas' => 'Stay the course. — Atlas 🧭',
        _ => 'Warmly, Penny 🦋',
      };
}

const kWisdomLetters = <WisdomLetter>[
  WisdomLetter(
    level: 1,
    rule: 'Money spent without a plan goes to places you never intended.',
    pennyBody:
        'You learned that needs come before wants — and that every coin can have a job. '
        'That small habit will protect you on busy days.',
    finBotBody:
        'Needs-first ordering reduces impulse spend. Your choices today follow a logical sequence.',
    atlasBody:
        'Foundation first. You are building the discipline that every later decision rests on.',
  ),
  WisdomLetter(
    level: 2,
    rule: 'Waiting one day on a want often turns a “must have” into “never mind.”',
    pennyBody:
        'Comparison shopping and patience saved you real AED. Deals are only deals when the value is real.',
    finBotBody:
        'Price comparison and delay functions reduce regret purchases. Data beats hype.',
    atlasBody:
        'Patience is leverage. You traded impulse for information — that is how smart spenders win.',
  ),
  WisdomLetter(
    level: 3,
    rule: 'A budget is not a cage — it is a map.',
    pennyBody:
        'You split money into buckets and tracked where it went. When plans wobble, you adjust — that is mastery.',
    finBotBody:
        'Bucket allocation and review loops create feedback. Overspend in one line → rebalance others.',
    atlasBody:
        'Maps change when terrain changes. You did not quit the plan — you steered it.',
  ),
  WisdomLetter(
    level: 4,
    rule: 'Profit is what is left after honest costs — not wishful math.',
    pennyBody:
        'You priced fairly, served customers, and felt the difference between revenue and cost. '
        'That is how real businesses breathe.',
    finBotBody:
        'Unit economics and reinvestment decisions compound. You simulated profit under pressure.',
    atlasBody:
        'Investing time in understanding cost today prevents expensive mistakes tomorrow.',
  ),
  WisdomLetter(
    level: 5,
    rule: 'Your credit story is built one decision at a time.',
    pennyBody:
        'You weighed quality, spotted traps, and thought about how groups share money fairly. '
        'These skills protect you in the real market.',
    finBotBody:
        'Credit behaviour, review literacy, and group budgeting reduce long-term friction costs.',
    atlasBody:
        'Wealth is not loud spending — it is quiet systems that keep working when life gets noisy.',
  ),
  WisdomLetter(
    level: 6,
    rule: 'A Chief Money Officer leads with clarity, not fear.',
    pennyBody:
        'You finished the full journey — tax basics, negotiation, giving with purpose, and big decisions. '
        'You are ready to teach what you know.',
    finBotBody:
        'Full-stack financial literacy achieved. Continue logging decisions and refining models.',
    atlasBody:
        'Graduation is not an ending — it is permission to build bigger plans with confidence.',
  ),
];

WisdomLetter? wisdomLetterForLevel(int level) {
  for (final l in kWisdomLetters) {
    if (l.level == level) return l;
  }
  return null;
}

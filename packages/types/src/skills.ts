/** Six quest-level skill keys — aligned with curriculum levels L1–L6. */
export const SKILL_KEYS = ['L1', 'L2', 'L3', 'L4', 'L5', 'L6'] as const;
export type SkillKey = (typeof SKILL_KEYS)[number];

export const QUEST_LEVEL_NAMES = [
  'Coin Keeper',
  'Smart Spender',
  'Budget Boss',
  'Junior Investor',
  'Wealth Builder',
  'Chief Money Officer',
] as const;

const STAGES_PER_LEVEL = [5, 6, 7, 9, 10, 11];

export function parseLessonOrder(lessonId: string): number | null {
  const match = /^lesson_(\d+)$/.exec(lessonId);
  if (!match) return null;
  return Number.parseInt(match[1], 10);
}

export function questLevelForLesson(lessonId: string): number {
  const order = parseLessonOrder(lessonId);
  if (order == null || order < 1) return 1;
  let remaining = order;
  for (let i = 0; i < STAGES_PER_LEVEL.length; i++) {
    if (remaining <= STAGES_PER_LEVEL[i]) return i + 1;
    remaining -= STAGES_PER_LEVEL[i];
  }
  return 6;
}

export function skillKeyForLesson(lessonId: string): SkillKey {
  const level = questLevelForLesson(lessonId);
  return `L${level}` as SkillKey;
}

export function quizScoreToMastery(quizScore: number): number {
  return Math.round((Math.max(0, Math.min(5, quizScore)) / 5) * 100);
}

/** Exponential moving average — blends new quiz result into skill score. */
export function updateConceptSkill(
  current: Record<string, number> | undefined,
  skillKey: string,
  quizScore: number,
): Record<string, number> {
  const mastery = quizScoreToMastery(quizScore);
  const prev = current?.[skillKey] ?? mastery;
  const next = Math.round(prev * 0.55 + mastery * 0.45);
  return { ...(current ?? {}), [skillKey]: Math.min(100, Math.max(0, next)) };
}

export function baselineScreeningSkills(): Record<string, number> {
  return { L1: 40, L2: 40, L3: 40, L4: 40, L5: 40, L6: 40 };
}

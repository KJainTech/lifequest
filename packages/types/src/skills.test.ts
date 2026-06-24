import { describe, expect, it } from 'vitest';
import {
  baselineScreeningSkills,
  skillKeyForLesson,
  updateConceptSkill,
  questLevelForLesson,
} from '../src/skills';

describe('skills', () => {
  it('maps lesson to quest-level skill key', () => {
    expect(skillKeyForLesson('lesson_1')).toBe('L1');
    expect(skillKeyForLesson('lesson_7')).toBe('L2');
    expect(skillKeyForLesson('lesson_48')).toBe('L6');
  });

  it('computes quest level from lesson order', () => {
    expect(questLevelForLesson('lesson_6')).toBe(2);
    expect(questLevelForLesson('lesson_12')).toBe(3);
  });

  it('updates concept skill with EMA', () => {
    const base = baselineScreeningSkills();
    const next = updateConceptSkill(base, 'L2', 5);
    expect(next.L2).toBeGreaterThan(base.L2!);
    expect(next.L2).toBeLessThanOrEqual(100);
  });
});

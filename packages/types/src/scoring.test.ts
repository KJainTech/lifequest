import { describe, expect, it } from 'vitest';
import {
  computeLessonAwards,
  computeStars,
  levelFromXp,
  scoreGamePlay,
  scoreQuiz,
} from './scoring';

describe('scoreQuiz', () => {
  it('awards full XP and coins on all correct', () => {
    const result = scoreQuiz([0, 1, 2, 3, 0], [0, 1, 2, 3, 0]);
    expect(result.score).toBe(5);
    expect(result.allCorrect).toBe(true);
    expect(result.xpEarned).toBe(70);
    expect(result.coinsEarned).toBe(15);
  });

  it('awards partial credit', () => {
    const result = scoreQuiz([0, 1, 0, 0, 1], [0, 1, 2, 3, 0]);
    expect(result.score).toBe(2);
    expect(result.xpEarned).toBe(20);
    expect(result.coinsEarned).toBe(4);
  });
});

describe('scoreGamePlay', () => {
  it('rewards wins with profit bonus', () => {
    const result = scoreGamePlay(25, true);
    expect(result.xpEarned).toBe(30);
    expect(result.coinsEarned).toBe(25);
    expect(result.profitBonus).toBe(true);
  });
});

describe('computeStars', () => {
  it('combines quiz and game stars capped at 6', () => {
    expect(computeStars(5, true)).toBe(6);
    expect(computeStars(3, false)).toBe(3);
  });
});

describe('levelFromXp', () => {
  it('increases level with XP', () => {
    expect(levelFromXp(0)).toBe(1);
    expect(levelFromXp(500)).toBeGreaterThan(1);
  });
});

describe('computeLessonAwards', () => {
  const baseStats = {
    xp: 100,
    level: 2,
    coins: 50,
    lqScore: 120,
    streak: { count: 2, lastActive: null },
  };

  it('awards XP, coins, LQ, tower, and badge on first completion', () => {
    const awards = computeLessonAwards({
      currentStats: baseStats,
      quizScore: 5,
      gameWon: true,
      gameProfit: 20,
      lessonId: 'lesson_6',
      isFirstProfit: true,
      alreadyCompleted: false,
    });
    expect(awards.xp).toBeGreaterThan(0);
    expect(awards.coins).toBeGreaterThan(0);
    expect(awards.lqDelta).toBeGreaterThan(0);
    expect(awards.tower).not.toBeNull();
    expect(awards.badgeUnlocked).toBe('first_profit');
    expect(awards.newLqScore).toBe(baseStats.lqScore + awards.lqDelta);
  });

  it('is idempotent when already completed', () => {
    const awards = computeLessonAwards({
      currentStats: baseStats,
      quizScore: 5,
      gameWon: true,
      gameProfit: 20,
      lessonId: 'lesson_6',
      isFirstProfit: false,
      alreadyCompleted: true,
    });
    expect(awards.xp).toBe(0);
    expect(awards.coins).toBe(0);
    expect(awards.tower).toBeNull();
  });

  it('partial quiz score yields correct XP not full bonus', () => {
    const awards = computeLessonAwards({
      currentStats: baseStats,
      quizScore: 2,
      gameWon: true,
      gameProfit: 10,
      lessonId: 'lesson_2',
      isFirstProfit: false,
      alreadyCompleted: false,
    });
    expect(awards.xp).toBe(50);
    expect(awards.coins).toBe(14);
  });
});

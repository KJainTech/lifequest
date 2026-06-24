import { describe, expect, it } from 'vitest';
import { getQuizAnswerKey } from '../content/answerKeys';
import {
  computeLessonAwards,
  scoreQuiz,
  scoreQuizFromCount,
} from '@lifequest/types';

describe('economy integration', () => {
  it('loads server-side quiz answer keys', () => {
    expect(getQuizAnswerKey('lesson_6')).toHaveLength(5);
    expect(getQuizAnswerKey('lesson_48')).toHaveLength(5);
    expect(getQuizAnswerKey('unknown')).toBeNull();
  });

  it('scores lesson_6 quiz with server key', () => {
    const key = getQuizAnswerKey('lesson_6')!;
    const result = scoreQuiz(key, key);
    expect(result.allCorrect).toBe(true);
    expect(result.xpEarned).toBe(70);
  });

  it('scoreQuizFromCount awards partial credit correctly', () => {
    expect(scoreQuizFromCount(2).xpEarned).toBe(20);
    expect(scoreQuizFromCount(2).coinsEarned).toBe(4);
    expect(scoreQuizFromCount(0).xpEarned).toBe(0);
    expect(scoreQuizFromCount(0).coinsEarned).toBe(0);
  });

  it('completeLesson awards are deterministic at perfect score', () => {
    const awards = computeLessonAwards({
      currentStats: {
        xp: 0,
        level: 1,
        coins: 0,
        lqScore: 0,
        streak: { count: 0, lastActive: null },
      },
      quizScore: 5,
      gameWon: true,
      gameProfit: 15,
      lessonId: 'lesson_6',
      isFirstProfit: true,
      alreadyCompleted: false,
    });
    expect(awards.xp).toBe(100);
    expect(awards.tower?.name).toBe('Super Market');
    expect(awards.badgeUnlocked).toBe('first_profit');
  });

  it('completeLesson awards partial quiz score correctly', () => {
    const awards = computeLessonAwards({
      currentStats: {
        xp: 0,
        level: 1,
        coins: 0,
        lqScore: 0,
        streak: { count: 0, lastActive: null },
      },
      quizScore: 2,
      gameWon: false,
      gameProfit: -5,
      lessonId: 'lesson_7',
      isFirstProfit: false,
      alreadyCompleted: false,
    });
    expect(awards.xp).toBe(30);
    expect(awards.coins).toBe(9);
  });

  it('replay awards zero economy', () => {
    const awards = computeLessonAwards({
      currentStats: {
        xp: 500,
        level: 4,
        coins: 200,
        lqScore: 300,
        streak: { count: 3, lastActive: '2026-06-23' },
      },
      quizScore: 5,
      gameWon: true,
      gameProfit: 20,
      lessonId: 'lesson_3',
      isFirstProfit: false,
      alreadyCompleted: true,
    });
    expect(awards.xp).toBe(0);
    expect(awards.coins).toBe(0);
    expect(awards.tower).toBeNull();
  });
});

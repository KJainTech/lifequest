import { describe, expect, it } from 'vitest';
import { getQuizAnswerKey } from '../content/answerKeys';
import { computeLessonAwards, scoreQuiz } from '@lifequest/types';

describe('economy integration', () => {
  it('loads server-side quiz answer keys', () => {
    expect(getQuizAnswerKey('lesson_6')).toHaveLength(5);
    expect(getQuizAnswerKey('unknown')).toBeNull();
  });

  it('scores lesson_6 quiz with server key', () => {
    const key = getQuizAnswerKey('lesson_6')!;
    const result = scoreQuiz(key, key);
    expect(result.allCorrect).toBe(true);
  });

  it('completeLesson awards are deterministic', () => {
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
    expect(awards.tower?.name).toBe('Earning Tower');
    expect(awards.badgeUnlocked).toBe('first_profit');
  });
});

/** Server-side answer keys — never trust client-provided correct answers. */
const QUIZ_ANSWER_KEYS: Record<string, number[]> = {
  lesson_1: [1, 1, 0, 1, 1],
  lesson_2: [1, 1, 1, 0, 1],
  lesson_3: [0, 0, 0, 0, 1],
  lesson_4: [0, 1, 0, 0, 0],
  lesson_5: [0, 1, 0, 0, 0],
  lesson_6: [1, 2, 0, 3, 1],
};

export function getQuizAnswerKey(lessonId: string): number[] | null {
  return QUIZ_ANSWER_KEYS[lessonId] ?? null;
}

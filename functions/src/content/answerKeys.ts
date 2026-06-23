/** Server-side answer keys — never trust client-provided correct answers. */
const QUIZ_ANSWER_KEYS: Record<string, number[]> = {
  lesson_6: [1, 2, 0, 3, 1],
  lesson_1: [0, 1, 2, 1, 0],
};

export function getQuizAnswerKey(lessonId: string): number[] | null {
  return QUIZ_ANSWER_KEYS[lessonId] ?? null;
}

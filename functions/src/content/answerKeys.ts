/** Server-side answer keys — never trust client-provided correct answers. */
const QUIZ_ANSWER_KEYS: Record<string, number[]> = {
  lesson_1: [1, 1, 0, 1, 1],
  lesson_2: [1, 1, 1, 0, 1],
  lesson_3: [0, 0, 0, 0, 1],
  lesson_4: [0, 1, 0, 0, 0],
  lesson_5: [0, 1, 0, 0, 0],
  lesson_6: [1, 2, 0, 3, 1],
};

export function templateQuizAnswerKey(conceptOrder: number): number[] {
  return Array.from({ length: 5 }, (_, i) => (conceptOrder * 7 + i * 3 + 2) % 4);
}

export function parseLessonOrder(lessonId: string): number | null {
  const match = /^lesson_(\d+)$/.exec(lessonId);
  if (!match) return null;
  return Number.parseInt(match[1], 10);
}

export function getQuizAnswerKey(lessonId: string): number[] | null {
  if (QUIZ_ANSWER_KEYS[lessonId]) {
    return QUIZ_ANSWER_KEYS[lessonId];
  }
  const order = parseLessonOrder(lessonId);
  if (order != null && order >= 1 && order <= 48) {
    return templateQuizAnswerKey(order);
  }
  return null;
}

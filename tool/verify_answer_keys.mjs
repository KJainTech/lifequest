/** Cross-check Dart template keys vs functions answerKeys.ts for lessons 7-48. */
import { getQuizAnswerKey } from '../functions/lib/content/answerKeys.js';

function templateQuizAnswerKey(order) {
  return Array.from({ length: 5 }, (_, i) => (order * 7 + i * 3 + 2) % 4);
}

let failed = 0;
for (let order = 1; order <= 48; order++) {
  const id = `lesson_${order}`;
  const key = getQuizAnswerKey(id);
  const expected = order <= 6 ? key : templateQuizAnswerKey(order);
  if (!key || key.length !== 5) {
    console.error(`FAIL ${id}: missing or invalid key`, key);
    failed++;
    continue;
  }
  if (order > 6) {
    const template = templateQuizAnswerKey(order);
    if (JSON.stringify(key) !== JSON.stringify(template)) {
      console.error(`FAIL ${id}:`, key, '!=', template);
      failed++;
    }
  }
}

if (failed === 0) {
  console.log('OK: all 48 lesson answer keys valid');
  process.exit(0);
} else {
  process.exit(1);
}

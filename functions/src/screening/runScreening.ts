import { onCall } from 'firebase-functions/v2/https';
import { RunScreeningPayloadSchema } from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth } from '../lib/auth';
import { db, nowIso } from '../lib/firebase';

export const runScreening = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const payload = parsePayload(RunScreeningPayloadSchema, request.data);

  let correct = 0;
  let difficulty = 1;
  for (const answer of payload.answers) {
    const isCorrect = answer.selectedIndex === answer.correctIndex;
    if (isCorrect) {
      correct++;
      difficulty = Math.min(3, difficulty + 1);
    } else {
      difficulty = Math.max(1, difficulty - 1);
    }
  }

  const placementLevel = correct >= payload.answers.length - 1 ? 2 : 1;
  const skipAhead = placementLevel > 1;

  await db.doc(`users/${uid}`).set(
    {
      proficiencyLevel: placementLevel,
      screeningCompletedAt: nowIso(),
    },
    { merge: true },
  );

  return {
    correct,
    total: payload.answers.length,
    placementLevel,
    skipAhead,
    message: skipAhead
      ? `You can skip ahead to Level ${placementLevel}`
      : 'Let\'s start at the beginning',
  };
});

import { onCall } from 'firebase-functions/v2/https';
import {
  SubmitGamePlayPayloadSchema,
  scoreGamePlay,
} from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertChildRole } from '../lib/auth';
import { getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';
import * as admin from 'firebase-admin';

export const submitGamePlay = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertChildRole(role);

  const payload = parsePayload(SubmitGamePlayPayloadSchema, request.data);
  const result = scoreGamePlay(payload.profit, payload.won);

  const playRecord = {
    profit: payload.profit,
    revenue: payload.revenue,
    cost: payload.cost,
    won: payload.won,
    difficulty: payload.difficulty,
    playedAt: nowIso(),
  };

  await db.doc(`progress/${uid}/lessons/${payload.lessonId}`).set(
    {
      status: 'in_progress',
      gamePlays: admin.firestore.FieldValue.arrayUnion(playRecord),
      updatedAt: nowIso(),
    },
    { merge: true },
  );

  return {
    xpPreview: result.xpEarned,
    coinsPreview: result.coinsEarned,
    profitBonus: result.profitBonus,
  };
});

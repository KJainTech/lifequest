import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { LinkChildPayloadSchema } from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertParentRole } from '../lib/auth';
import { getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';

export const linkChild = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertParentRole(role);

  const payload = parsePayload(LinkChildPayloadSchema, request.data);
  const childSnap = await db.doc(`users/${payload.childUid}`).get();

  if (!childSnap.exists) {
    throw new HttpsError('not-found', 'Child account not found.');
  }
  if (childSnap.data()?.role !== 'child') {
    throw new HttpsError('invalid-argument', 'Target is not a child account.');
  }

  await db.doc(`users/${payload.childUid}`).set(
    { parentUid: uid, linkedAt: nowIso() },
    { merge: true },
  );

  return { success: true, childUid: payload.childUid };
});

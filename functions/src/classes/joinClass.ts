import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { JoinClassPayloadSchema } from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertChildRole } from '../lib/auth';
import { getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';
import * as admin from 'firebase-admin';

export const joinClass = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertChildRole(role);

  const payload = parsePayload(JoinClassPayloadSchema, request.data);

  const classesSnap = await db
    .collection('classes')
    .where('code', '==', payload.code.toUpperCase())
    .limit(1)
    .get();

  if (classesSnap.empty) {
    throw new HttpsError('not-found', 'Class code not found.');
  }

  const classDoc = classesSnap.docs[0];
  const classId = classDoc.id;

  await classDoc.ref.update({
    roster: admin.firestore.FieldValue.arrayUnion(uid),
  });

  await db.doc(`users/${uid}`).set(
    {
      classIds: admin.firestore.FieldValue.arrayUnion(classId),
      joinedClassAt: nowIso(),
    },
    { merge: true },
  );

  return { classId, className: classDoc.data().name };
});

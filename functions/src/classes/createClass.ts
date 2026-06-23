import { onCall } from 'firebase-functions/v2/https';
import { CreateClassPayloadSchema } from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertTeacherRole } from '../lib/auth';
import { generateClassCode, getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';

export const createClass = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertTeacherRole(role);

  const payload = parsePayload(CreateClassPayloadSchema, request.data);
  const classRef = db.collection('classes').doc();
  const code = generateClassCode();

  await classRef.set({
    teacherUid: uid,
    code,
    name: payload.name,
    roster: [],
    assignments: [],
    createdAt: nowIso(),
  });

  return { classId: classRef.id, code };
});

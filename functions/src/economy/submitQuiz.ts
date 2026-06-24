import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { SubmitQuizPayloadSchema, scoreQuiz } from '@lifequest/types';
import { getQuizAnswerKey } from '../content/answerKeys';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertChildRole } from '../lib/auth';
import { getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';

const ClientSubmitQuizSchema = SubmitQuizPayloadSchema.omit({
  correctAnswers: true,
});

async function resolveAnswerKey(
  uid: string,
  lessonId: string,
): Promise<number[] | null> {
  const session = await db.doc(`adaptive_sessions/${uid}/lessons/${lessonId}`).get();
  const adaptiveKey = session.data()?.answerKey as number[] | undefined;
  if (adaptiveKey?.length === 5) return adaptiveKey;
  return getQuizAnswerKey(lessonId);
}

export const submitQuiz = onCall(async (request) => {
  try {
    const uid = requireAuth(request.auth?.uid);
    const role = await getUserRole(uid);
    assertChildRole(role);

    const payload = parsePayload(ClientSubmitQuizSchema, request.data);
    const correctAnswers = await resolveAnswerKey(uid, payload.lessonId);

    if (!correctAnswers) {
      throw new HttpsError('not-found', 'Quiz not found for this lesson.');
    }

    if (payload.answers.length !== correctAnswers.length) {
      throw new HttpsError('invalid-argument', 'Expected 5 answers.');
    }

    const result = scoreQuiz(payload.answers, correctAnswers);
    const progressRef = db.doc(`progress/${uid}/lessons/${payload.lessonId}`);
    const existing = (await progressRef.get()).data();
    const wasCompleted = existing?.status === 'completed';

    await progressRef.set(
      {
        status: wasCompleted ? 'completed' : 'in_progress',
        quizScore: result.score,
        updatedAt: nowIso(),
      },
      { merge: true },
    );

    return {
      score: result.score,
      maxScore: result.maxScore,
      xpPreview: result.xpEarned,
      coinsPreview: result.coinsEarned,
      allCorrect: result.allCorrect,
    };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error('submitQuiz failed', err);
    throw new HttpsError('internal', 'Could not save quiz progress.');
  }
});

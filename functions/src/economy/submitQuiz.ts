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

export const submitQuiz = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertChildRole(role);

  const payload = parsePayload(ClientSubmitQuizSchema, request.data);
  const correctAnswers = getQuizAnswerKey(payload.lessonId);

  if (!correctAnswers) {
    throw new HttpsError('not-found', 'Quiz not found for this lesson.');
  }

  if (payload.answers.length !== correctAnswers.length) {
    throw new HttpsError('invalid-argument', 'Expected 5 answers.');
  }

  const result = scoreQuiz(payload.answers, correctAnswers);

  await db.doc(`progress/${uid}/lessons/${payload.lessonId}`).set(
    {
      status: 'in_progress',
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
});

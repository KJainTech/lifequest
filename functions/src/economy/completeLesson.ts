import { onCall } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import {
  CompleteLessonPayloadSchema,
  computeBusinessIQDelta,
  computeLessonAwards,
  clampBusinessIQ,
} from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertChildRole } from '../lib/auth';
import {
  ensureStats,
  getStats,
  getUserRole,
} from '../lib/helpers';
import { db, nowIso, todayDateStr } from '../lib/firebase';

export const completeLesson = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertChildRole(role);

  const payload = parsePayload(CompleteLessonPayloadSchema, request.data);
  const idempotencyRef = db.doc(`idempotency/${uid}_${payload.idempotencyKey}`);

  const existing = await idempotencyRef.get();
  if (existing.exists) {
    const cached = existing.data()?.result;
    return { idempotent: true, ...cached };
  }

  await ensureStats(uid);

  const progressRef = db.doc(`progress/${uid}/lessons/${payload.lessonId}`);
  const progressSnap = await progressRef.get();
  const alreadyCompleted = progressSnap.data()?.status === 'completed';

  const stats = await getStats(uid);
  const badgesSnap = await db.collection(`badges/${uid}`).get();
  const hasFirstProfit = badgesSnap.docs.some((d) => d.id === 'first_profit');

  const awards = computeLessonAwards({
    currentStats: stats,
    quizScore: payload.quizScore,
    gameWon: payload.gameWon,
    gameProfit: payload.gameProfit,
    lessonId: payload.lessonId,
    isFirstProfit: !hasFirstProfit,
    alreadyCompleted,
  });

  if (alreadyCompleted) {
    const result = {
      xp: 0,
      coins: 0,
      lqScore: stats.lqScore,
      level: stats.level,
      stars: awards.stars,
      badgeUnlocked: null,
      tower: null,
    };
    await idempotencyRef.set({ processedAt: nowIso(), result });
    return { idempotent: false, ...result };
  }

  const biqDelta = computeBusinessIQDelta(payload.gameWon, payload.gameProfit);
  const newXp = stats.xp + awards.xp;
  const newCoins = stats.coins + awards.coins;

  const batch = db.batch();

  batch.set(
    db.doc(`profiles/${uid}/stats/current`),
    {
      xp: newXp,
      level: awards.newLevel,
      coins: newCoins,
      lqScore: awards.newLqScore,
      businessIQ: {
        profit: clampBusinessIQ(stats.businessIQ.profit + biqDelta.profit),
        decision: clampBusinessIQ(stats.businessIQ.decision + biqDelta.decision),
        resilience: clampBusinessIQ(
          stats.businessIQ.resilience + biqDelta.resilience,
        ),
      },
      streak: {
        count: awards.streakCount,
        lastActive: todayDateStr(),
      },
      updatedAt: nowIso(),
    },
    { merge: true },
  );

  batch.set(
    progressRef,
    {
      status: 'completed',
      quizScore: payload.quizScore,
      stars: awards.stars,
      completedAt: nowIso(),
      updatedAt: nowIso(),
    },
    { merge: true },
  );

  if (awards.badgeUnlocked) {
    batch.set(db.doc(`badges/${uid}/${awards.badgeUnlocked}`), {
      earnedAt: nowIso(),
    });
  }

  if (awards.tower) {
    batch.set(
      db.doc(`city/${uid}`),
      {
        towers: admin.firestore.FieldValue.arrayUnion({
          ...awards.tower,
          builtAt: nowIso(),
        }),
      },
      { merge: true },
    );
  }

  await batch.commit();

  const result = {
    xp: awards.xp,
    coins: awards.coins,
    lqScore: awards.newLqScore,
    level: awards.newLevel,
    stars: awards.stars,
    lqDelta: awards.lqDelta,
    badgeUnlocked: awards.badgeUnlocked,
    tower: awards.tower,
    streakCount: awards.streakCount,
  };

  await idempotencyRef.set({ processedAt: nowIso(), result });

  return { idempotent: false, ...result };
});

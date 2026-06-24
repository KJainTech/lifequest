import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import {
  CompleteLessonPayloadSchema,
  computeBusinessIQDelta,
  computeLessonAwards,
  computeStars,
  clampBusinessIQ,
  skillKeyForLesson,
  updateConceptSkill,
} from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertChildRole } from '../lib/auth';
import {
  ensureStats,
  getStats,
  getUserRole,
} from '../lib/helpers';
import { db, nowIso, todayDateStr } from '../lib/firebase';
import { lessonMetaForId } from '../content/lessonMeta';

export const completeLesson = onCall(async (request) => {
  try {
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
    const progressData = progressSnap.data();
    const alreadyCompleted = progressData?.status === 'completed';

    // Prefer server-validated quiz score from submitQuiz when available.
    const quizScore =
      typeof progressData?.quizScore === 'number'
        ? progressData.quizScore
        : payload.quizScore;

    const stats = await getStats(uid);
    const safeStats = {
      xp: stats.xp ?? 0,
      level: stats.level ?? 1,
      coins: stats.coins ?? 0,
      lqScore: stats.lqScore ?? 0,
      businessIQ: stats.businessIQ ?? { profit: 0, decision: 0, resilience: 0 },
      streak: stats.streak ?? { count: 0, lastActive: null as string | null },
    };

    const badgesSnap = await db.collection(`badges/${uid}`).get();
    const hasFirstProfit = badgesSnap.docs.some((d) => d.id === 'first_profit');

    const awards = computeLessonAwards({
      currentStats: {
        xp: safeStats.xp,
        level: safeStats.level,
        coins: safeStats.coins,
        lqScore: safeStats.lqScore,
        streak: safeStats.streak,
      },
      quizScore,
      gameWon: payload.gameWon,
      gameProfit: payload.gameProfit,
      lessonId: payload.lessonId,
      isFirstProfit: !hasFirstProfit,
      alreadyCompleted,
    });

    const existingSkills =
      (stats.conceptSkills as Record<string, number> | undefined) ?? {};
    const skillKey = skillKeyForLesson(payload.lessonId);
    const conceptSkills = updateConceptSkill(
      existingSkills,
      skillKey,
      quizScore,
    );

    const stars = computeStars(quizScore, payload.gameWon);

    if (alreadyCompleted) {
      const batch = db.batch();
      batch.set(
        progressRef,
        {
          status: 'completed',
          quizScore,
          stars,
          updatedAt: nowIso(),
        },
        { merge: true },
      );
      batch.set(
        db.doc(`profiles/${uid}/stats/current`),
        { conceptSkills, updatedAt: nowIso() },
        { merge: true },
      );
      await batch.commit();

      const result = {
        xp: 0,
        coins: 0,
        lqScore: safeStats.lqScore,
        level: safeStats.level,
        stars,
        badgeUnlocked: null,
        tower: null,
        conceptSkills,
        streakCount: safeStats.streak.count,
        replay: true,
      };
      await idempotencyRef.set({ processedAt: nowIso(), result });
      return { idempotent: false, ...result };
    }

    const biqDelta = computeBusinessIQDelta(payload.gameWon, payload.gameProfit);
    const newXp = safeStats.xp + awards.xp;
    const newCoins = safeStats.coins + awards.coins;
    const biq = safeStats.businessIQ;

    const meta = lessonMetaForId(payload.lessonId);
    const tower = awards.tower
      ? {
          ...awards.tower,
          name: meta?.title ?? awards.tower.name,
        }
      : null;

    const batch = db.batch();

    batch.set(
      db.doc(`profiles/${uid}/stats/current`),
      {
        xp: newXp,
        level: awards.newLevel,
        coins: newCoins,
        lqScore: awards.newLqScore,
        businessIQ: {
          profit: clampBusinessIQ(biq.profit + biqDelta.profit),
          decision: clampBusinessIQ(biq.decision + biqDelta.decision),
          resilience: clampBusinessIQ(biq.resilience + biqDelta.resilience),
        },
        conceptSkills,
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
        quizScore,
        stars,
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

    if (tower) {
      batch.set(
        db.doc(`city/${uid}`),
        {
          towers: admin.firestore.FieldValue.arrayUnion({
            ...tower,
            builtAt: nowIso(),
          }),
        },
        { merge: true },
      );
    }

    const weekStart = (() => {
      const d = new Date();
      const day = d.getUTCDay();
      const diff = day === 0 ? 6 : day - 1;
      d.setUTCDate(d.getUTCDate() - diff);
      return d.toISOString().slice(0, 10);
    })();
    batch.set(
      db.doc(`activity/${uid}/weeks/${weekStart}`),
      {
        sessionCount: admin.firestore.FieldValue.increment(1),
        lastSessionAt: nowIso(),
        updatedAt: nowIso(),
      },
      { merge: true },
    );
    batch.set(
      db.doc(`activity/${uid}/sessions/${payload.lessonId}_${Date.now()}`),
      {
        lessonId: payload.lessonId,
        questLevel: meta?.questLevel ?? null,
        completedAt: nowIso(),
        quizScore,
        gameWon: payload.gameWon,
      },
    );

    await batch.commit();

    const result = {
      xp: awards.xp,
      coins: awards.coins,
      lqScore: awards.newLqScore,
      level: awards.newLevel,
      stars,
      lqDelta: awards.lqDelta,
      badgeUnlocked: awards.badgeUnlocked,
      tower,
      conceptSkills,
      streakCount: awards.streakCount,
    };

    await idempotencyRef.set({ processedAt: nowIso(), result });

    return { idempotent: false, ...result };
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    console.error('completeLesson failed', err);
    throw new HttpsError('internal', 'Could not complete lesson.');
  }
});

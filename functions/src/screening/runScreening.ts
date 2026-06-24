import { onCall } from 'firebase-functions/v2/https';
import {
  QUEST_LEVEL_NAMES,
  baselineScreeningSkills,
  updateConceptSkill,
} from '@lifequest/types';
import { RunScreeningPayloadSchema } from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth } from '../lib/auth';
import { db, nowIso } from '../lib/firebase';

/** Maps screening question ids → quest skill keys. */
const QUESTION_SKILL: Record<string, string> = {
  s1: 'L4',
  s2: 'L1',
  s3: 'L2',
  s4: 'L4',
  s5: 'L3',
  s6: 'L4',
};

export const runScreening = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const payload = parsePayload(RunScreeningPayloadSchema, request.data);

  let correct = 0;
  let difficulty = 1;
  let weightedScore = 0;
  let screeningSkills = baselineScreeningSkills();

  for (const answer of payload.answers) {
    const isCorrect = answer.selectedIndex === answer.correctIndex;
    const qId = answer.questionId ?? '';
    const skillKey = QUESTION_SKILL[qId] ?? 'L1';

    if (isCorrect) {
      correct++;
      difficulty = Math.min(5, difficulty + 1);
      weightedScore += difficulty;
      screeningSkills = updateConceptSkill(screeningSkills, skillKey, 5);
    } else {
      difficulty = Math.max(1, difficulty - 1);
      weightedScore += 0.5;
      screeningSkills = updateConceptSkill(screeningSkills, skillKey, 1);
    }
  }

  const total = payload.answers.length;
  const accuracy = total > 0 ? correct / total : 0;

  let placementLevel = 1;
  if (accuracy >= 0.9 && weightedScore >= total * 3.5) placementLevel = 6;
  else if (accuracy >= 0.85) placementLevel = 5;
  else if (accuracy >= 0.75) placementLevel = 4;
  else if (accuracy >= 0.65) placementLevel = 3;
  else if (accuracy >= 0.55) placementLevel = 2;
  else if (accuracy >= 0.35) placementLevel = 1;

  placementLevel = Math.min(6, Math.max(1, placementLevel));
  const skipAhead = placementLevel > 1;
  const levelName = QUEST_LEVEL_NAMES[placementLevel - 1];

  await db.doc(`users/${uid}`).set(
    {
      proficiencyLevel: placementLevel,
      screeningCompletedAt: nowIso(),
      screeningScore: { correct, total, accuracy, weightedScore },
      screeningSkills,
    },
    { merge: true },
  );

  // Seed concept skills on stats from screening baseline.
  await db.doc(`profiles/${uid}/stats/current`).set(
    { conceptSkills: screeningSkills, updatedAt: nowIso() },
    { merge: true },
  );

  return {
    correct,
    total,
    placementLevel,
    skipAhead,
    levelName,
    screeningSkills,
    message: skipAhead
      ? `Great start! Jump to ${levelName} (Level ${placementLevel})`
      : 'Let\'s begin at Coin Keeper — you\'ve got this!',
  };
});

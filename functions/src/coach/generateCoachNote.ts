import { onCall } from 'firebase-functions/v2/https';
import { CoachNoteOutputSchema } from '@lifequest/types';
import { requireAuth, assertParentRole } from '../lib/auth';
import { getStats, getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';
import { passesSafetyFilter } from '../content/safetyFilter';

async function callGeminiCoach(prompt: string): Promise<string | null> {
  const key = process.env.GEMINI_API_KEY;
  if (!key) return null;
  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${key}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { responseMimeType: 'application/json' },
        }),
      },
    );
    if (!res.ok) return null;
    const json = (await res.json()) as {
      candidates?: { content?: { parts?: { text?: string }[] } }[];
    };
    return json.candidates?.[0]?.content?.parts?.[0]?.text ?? null;
  } catch {
    return null;
  }
}

function buildFallbackNote(lessonsCompleted: number, lqScore: number, profit: number) {
  const text =
    lessonsCompleted > 0
      ? `Your child completed ${lessonsCompleted} lesson${lessonsCompleted > 1 ? 's' : ''} recently. Their LQ Score is ${lqScore} and they're building profit sense (${profit}/100). Keep encouraging calm saving conversations.`
      : 'Your child is just getting started. A great first activity: talk about one thing they wanted vs needed this week.';
  return {
    text,
    activity: 'Pick one small AED purchase this week and decide together: need or want?',
  };
}

/** ParentCoach — warm summary + activity; Gemini with validated fallback. */
export const generateCoachNote = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertParentRole(role);

  const { childUid } = request.data as { childUid?: string };
  if (!childUid) {
    return { note: null };
  }

  const stats = await getStats(childUid);
  const progressSnap = await db
    .collection(`progress/${childUid}/lessons`)
    .where('status', '==', 'completed')
    .limit(5)
    .get();

  const lessonsCompleted = progressSnap.size;
  let note = buildFallbackNote(
    lessonsCompleted,
    stats.lqScore,
    stats.businessIQ.profit,
  );

  const prompt = `Write JSON {text, activity} for a parent coach note. Child completed ${lessonsCompleted} lessons, LQ ${stats.lqScore}, profit sense ${stats.businessIQ.profit}/100. Warm, specific, jargon-free, no alarming language, UAE context AED.`;
  const raw = await callGeminiCoach(prompt);
  if (raw) {
    try {
      const parsed = CoachNoteOutputSchema.parse(JSON.parse(raw));
      if (passesSafetyFilter(parsed.text) && passesSafetyFilter(parsed.activity)) {
        note = parsed;
      }
    } catch {
      // keep fallback
    }
  }

  const noteRef = db.collection(`coach/${childUid}/notes`).doc();
  await noteRef.set({ ...note, createdAt: nowIso(), source: raw ? 'gemini' : 'fallback' });

  return { noteId: noteRef.id, text: note.text, activity: note.activity };
});

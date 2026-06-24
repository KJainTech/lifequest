import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import {
  GeneratedContentSchema,
  AgeBandSchema,
  GuideSchema,
  LocaleSchema,
  RegionSchema,
} from '@lifequest/types';
import { db, nowIso } from '../lib/firebase';
import { legacyProfitFallback } from './fallbackContent';
import { filterContentStrings } from './safetyFilter';

const GenerateContentPayloadSchema = z.object({
  concept: z.string().min(1),
  ageBand: AgeBandSchema,
  region: RegionSchema,
  guide: GuideSchema,
  locale: LocaleSchema,
});

async function callGeminiContent(prompt: string): Promise<string | null> {
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

/** Admin: generate + validate lesson content; cache to Firestore. */
export const generateContent = onCall(async (request) => {
  if (!request.auth?.token?.admin) {
    throw new HttpsError('permission-denied', 'Admin only.');
  }

  const params = GenerateContentPayloadSchema.parse(request.data ?? {});
  const prompt = `Generate JSON lesson content for concept "${params.concept}" age ${params.ageBand} UAE AED guide ${params.guide} locale ${params.locale}. Include readParagraphs (4), quizQuestions (5 with 4 options each), gameConfig for lemonade stand. Child-safe, no jargon.`;

  let content = legacyProfitFallback(params);
  let source = 'fallback';
  let tokensUsed = 0;

  const raw = await callGeminiContent(prompt);
  if (raw) {
    try {
      const parsed = GeneratedContentSchema.parse(JSON.parse(raw));
      const allText = [
        ...parsed.readParagraphs,
        ...parsed.quizQuestions.flatMap((q) => [q.prompt, ...q.options, q.explanation]),
      ];
      if (filterContentStrings(allText)) {
        content = { ...parsed, reviewed: false };
        source = 'gemini';
        tokensUsed = Math.ceil(raw.length / 4);
      }
    } catch {
      // keep fallback
    }
  }

  const variantId = `${params.ageBand}_${params.locale}_${params.guide}`;
  const ref = db.doc(`content/${params.concept}/variants/${variantId}`);
  await ref.set({
    ...content,
    source,
    tokensUsed,
    updatedAt: nowIso(),
  });

  await db.collection('content_queue').add({
    concept: params.concept,
    variantId,
    status: 'pending_review',
    source,
    createdAt: nowIso(),
  });

  await db.collection('audit_log').add({
    action: 'generateContent',
    actor: request.auth.uid,
    concept: params.concept,
    variantId,
    source,
    tokensUsed,
    at: nowIso(),
  });

  return { variantId, source, tokensUsed, reviewed: content.reviewed };
});

/** Admin: approve content for child serving. */
export const approveContent = onCall(async (request) => {
  if (!request.auth?.token?.admin) {
    throw new HttpsError('permission-denied', 'Admin only.');
  }
  const { concept, variantId } = request.data as {
    concept?: string;
    variantId?: string;
  };
  if (!concept || !variantId) {
    throw new HttpsError('invalid-argument', 'concept and variantId required.');
  }
  await db.doc(`content/${concept}/variants/${variantId}`).set(
    { reviewed: true, reviewedAt: nowIso(), reviewedBy: request.auth.uid },
    { merge: true },
  );
  await db.collection('audit_log').add({
    action: 'approveContent',
    actor: request.auth.uid,
    concept,
    variantId,
    at: nowIso(),
  });
  return { ok: true };
});

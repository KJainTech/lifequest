import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import {
  AgeBandSchema,
  GuideSchema,
  GeneratedContentSchema,
  GeneratedQuizQuestionSchema,
  LocaleSchema,
  skillKeyForLesson,
} from '@lifequest/types';
import { parsePayload } from '../lib/validation';
import { requireAuth, assertChildRole } from '../lib/auth';
import { getStats, getUserRole } from '../lib/helpers';
import { db, nowIso } from '../lib/firebase';
import { getQuizAnswerKey, parseLessonOrder } from '../content/answerKeys';
import { fallbackContent } from './fallbackContent';
import { filterContentStrings } from './safetyFilter';
import {
  lessonMetaForId,
  masteryTierLabel,
  skillKeyForQuestLevel,
} from './lessonMeta';
import { buildTemplateContent, seedSummaryForPrompt } from './stageSnippets';

const GenerateAdaptiveLessonSchema = z.object({
  lessonId: z.string().min(1),
  ageBand: AgeBandSchema,
  guide: GuideSchema,
  locale: LocaleSchema.default('en'),
  title: z.string().optional(),
  subtitle: z.string().optional(),
  conceptSlug: z.string().optional(),
  questLevel: z.number().int().min(1).max(6).optional(),
  stageInLevel: z.number().int().min(1).max(11).optional(),
});

async function callGemini(prompt: string): Promise<string | null> {
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

async function callAnthropic(prompt: string): Promise<string | null> {
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key) return null;
  try {
    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-3-5-haiku-latest',
        max_tokens: 2048,
        messages: [{ role: 'user', content: prompt }],
      }),
    });
    if (!res.ok) return null;
    const json = (await res.json()) as {
      content?: { type: string; text?: string }[];
    };
    const block = json.content?.find((c) => c.type === 'text');
    return block?.text ?? null;
  } catch {
    return null;
  }
}

const AdaptivePartialSchema = z.object({
  readParagraphs: z.array(z.string().min(1).max(800)).min(2).max(8),
  quizQuestions: z.array(GeneratedQuizQuestionSchema).length(5),
});

function buildPrompt(
  params: z.infer<typeof GenerateAdaptiveLessonSchema>,
  mastery: number,
): string {
  const meta = lessonMetaForId(params.lessonId);
  const seed = meta ? seedSummaryForPrompt(meta, params.ageBand) : params.title ?? 'money skills';
  const tier = masteryTierLabel(mastery);
  const localeNote =
    params.locale === 'ar'
      ? 'Write in Modern Standard Arabic suitable for UAE kids; keep AED currency.'
      : 'Write in clear English for UAE kids; use AED currency.';

  return `You are a child-safe financial literacy tutor for UAE kids (AED currency).
Generate JSON only for lesson "${params.lessonId}" age band ${params.ageBand}, guide ${params.guide}.
Topic: ${params.title ?? meta?.title ?? 'money skills'} — ${params.subtitle ?? meta?.subtitle ?? ''}.
Quest level ${params.questLevel ?? meta?.questLevel ?? 1}, stage ${params.stageInLevel ?? meta?.stageInLevel ?? 1}.
Learner mastery on this level: ${mastery}/100 (${tier} tier). ${localeNote}

Keep the SAME learning objective as this curriculum seed — rewrite vocabulary and numbers for the tier:
${seed}

Schema:
{
  "readParagraphs": ["4 short paragraphs with **bold** keywords, no jargon"],
  "quizQuestions": [
    {
      "id": "q1",
      "prompt": "question",
      "options": ["A","B","C","D"],
      "correctIndex": 0,
      "explanation": "why"
    }
  ]
}
Exactly 4 readParagraphs and 5 quizQuestions. Each correctIndex 0-3. Culturally neutral, encouraging tone.
Foundational: simpler words and smaller AED amounts. Advanced: slightly trickier scenarios, still age-appropriate.`;
}

function extractAnswerKey(content: {
  quizQuestions: { correctIndex: number }[];
}): number[] {
  return content.quizQuestions.map((q) => q.correctIndex);
}

/** Child: fetch or generate personalised lesson variant; cache answer key server-side. */
export const generateAdaptiveLesson = onCall(async (request) => {
  const uid = requireAuth(request.auth?.uid);
  const role = await getUserRole(uid);
  assertChildRole(role);

  const params = parsePayload(GenerateAdaptiveLessonSchema, request.data);
  const order = parseLessonOrder(params.lessonId);
  if (order == null || order < 1 || order > 48) {
    throw new HttpsError('invalid-argument', 'Unknown lesson.');
  }

  const sessionRef = db.doc(`adaptive_sessions/${uid}/lessons/${params.lessonId}`);
  const cached = await sessionRef.get();
  if (cached.exists) {
    const data = cached.data()!;
    const expiresAt = data.expiresAt as string | undefined;
    if (!expiresAt || expiresAt > nowIso()) {
      return {
        source: data.source ?? 'cache',
        content: data.content,
        answerKey: data.answerKey,
      };
    }
  }

  const stats = await getStats(uid);
  const skillKey =
    params.questLevel != null
      ? skillKeyForQuestLevel(params.questLevel)
      : skillKeyForLesson(params.lessonId);
  const conceptSkills =
    (stats.conceptSkills as Record<string, number> | undefined) ?? {};
  const mastery = conceptSkills[skillKey] ?? 40;

  const fallbackParams = {
    lessonId: params.lessonId,
    concept: params.conceptSlug ?? `lesson_${order}`,
    ageBand: params.ageBand,
    guide: params.guide,
    locale: params.locale,
    mastery,
  };

  let content = fallbackContent(fallbackParams);
  let answerKey = getQuizAnswerKey(params.lessonId) ?? extractAnswerKey(content);
  let source = 'template';

  const prompt = buildPrompt(params, mastery);
  const raw = (await callGemini(prompt)) ?? (await callAnthropic(prompt));

  if (raw) {
    try {
      const jsonText = raw.trim().replace(/^```json\s*/i, '').replace(/```\s*$/, '');
      const partial = AdaptivePartialSchema.parse(JSON.parse(jsonText));
      const templateBase = buildTemplateContent(fallbackParams);
      const merged = GeneratedContentSchema.parse({
        ...templateBase,
        readParagraphs: partial.readParagraphs,
        quizQuestions: partial.quizQuestions,
        reviewed: false,
      });
      const allText = [
        ...merged.readParagraphs,
        ...merged.quizQuestions.flatMap((q) => [
          q.prompt,
          ...q.options,
          q.explanation,
        ]),
      ];
      if (filterContentStrings(allText)) {
        content = merged;
        answerKey = extractAnswerKey(merged);
        source = 'ai';
      }
    } catch {
      // keep template
    }
  }

  const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7).toISOString();
  await sessionRef.set({
    content,
    answerKey,
    source,
    lessonId: params.lessonId,
    masteryAtGeneration: mastery,
    expiresAt,
    updatedAt: nowIso(),
  });

  return { source, content, answerKey };
});

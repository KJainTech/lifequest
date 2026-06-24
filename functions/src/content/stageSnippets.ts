import type { z } from 'zod';
import { GeneratedContentSchema } from '@lifequest/types';
import { getQuizAnswerKey } from './answerKeys';
import {
  difficultyFromMastery,
  lessonMetaForId,
  type LessonMetaLite,
} from './lessonMeta';
import snippets from './stageSnippets.json';

type GeneratedContent = z.infer<typeof GeneratedContentSchema>;

type StageQuizJson = {
  prompt: string;
  correct: string;
  wrong: string[];
};

type StageCopyJson = {
  learn: string;
  apply: string;
  quiz: StageQuizJson[];
};

type SnippetBundle = {
  standard: Record<string, StageCopyJson>;
  teenL4L6: Record<string, StageCopyJson>;
};

const BUNDLE = snippets as SnippetBundle;

function templateAnswerKey(order: number): number[] {
  return Array.from({ length: 5 }, (_, i) => (order * 7 + i * 3 + 2) % 4);
}

function optionsForQuiz(
  copy: StageCopyJson,
  qIndex: number,
  correctIndex: number,
): string[] {
  const item = copy.quiz[qIndex];
  const options = ['', '', '', ''];
  options[correctIndex] = item.correct;
  let d = 0;
  for (let i = 0; i < 4; i++) {
    if (i === correctIndex) continue;
    options[i] = item.wrong[d++];
  }
  return options;
}

function gameConfigFor(
  order: number,
  ageBand: string,
  difficulty: number,
  questLevel: number,
) {
  const teen = ageBand === '13-17';
  if (teen && questLevel >= 4) {
    const unitCost = 2 + (order % 4) * 0.5;
    const defaultPrice = unitCost + 1 + (order % 3) * 0.25;
    const customers = 10 + (order % 5) + Math.min(difficulty, 2);
    return {
      unitCost,
      daySeconds: Math.max(38, 42 - difficulty),
      customerCount: customers,
      minPrice: unitCost,
      maxPrice: defaultPrice + 3,
      defaultPrice,
    };
  }

  const unitCost = 1 + (order % 5) * 0.25 + (teen ? 0.5 : 0);
  const defaultPrice = unitCost + 0.5 + (order % 3) * 0.25;
  const customers = 6 + (order % 6) + Math.min(difficulty, 2);
  const daySeconds = ageBand === '5-8' ? 45 : 55 - difficulty * 2;
  return {
    unitCost,
    daySeconds: Math.max(daySeconds, 35),
    customerCount: customers,
    minPrice: unitCost,
    maxPrice: defaultPrice + 2,
    defaultPrice,
  };
}

export function stageCopyForTitle(
  title: string,
  ageBand: string,
  questLevel: number,
): StageCopyJson | null {
  const teen = ageBand === '13-17' && questLevel >= 4;
  if (teen && BUNDLE.teenL4L6[title]) {
    return BUNDLE.teenL4L6[title];
  }
  return BUNDLE.standard[title] ?? null;
}

export function buildTemplateContent(params: {
  lessonId: string;
  concept: string;
  ageBand: string;
  guide: string;
  locale: string;
  mastery?: number;
}): GeneratedContent {
  const meta = lessonMetaForId(params.lessonId);
  const order = meta?.order ?? 7;
  const questLevel = meta?.questLevel ?? 1;
  const teen = params.ageBand === '13-17';
  const teenL4L6 = teen && questLevel >= 4;

  const copy =
    (meta && stageCopyForTitle(meta.title, params.ageBand, questLevel)) ??
    ({
      learn: meta?.subtitle ?? 'Practice smart money habits.',
      apply: 'Try one smart choice today.',
      quiz: Array.from({ length: 5 }, () => ({
        prompt: 'Question',
        correct: 'Best choice',
        wrong: ['Random', 'Ignore plan', 'Spend fast'],
      })),
    } satisfies StageCopyJson);

  const difficulty = difficultyFromMastery(params.mastery ?? 40);
  const keys = getQuizAnswerKey(params.lessonId) ?? templateAnswerKey(order);
  const young = params.ageBand === '5-8';

  const readParagraphs = meta
    ? [
        young
          ? `**${meta.title}** — ${meta.subtitle}. ${copy.learn}`
          : teenL4L6
            ? `**${meta.title}** (${meta.questLevelName}): ${copy.learn}`
            : `**${meta.questLevelName}** · **${meta.title}**: ${meta.subtitle}. ${copy.learn}`,
        teenL4L6
          ? `Level ${meta.questLevel} · ${meta.questLevelName} — stage ${meta.stageInLevel}. Real scenarios, AED math, and Lemon City profit targets.`
          : `You are on **Level ${meta.questLevel}** (${meta.questLevelName}), stage ${meta.stageInLevel}.`,
        young
          ? `Try this: ${copy.apply}`
          : teenL4L6
            ? `Your move: ${copy.apply} Log results and reflect in your journal.`
            : `Apply it: ${copy.apply} Use AED and track results in your journal.`,
        teenL4L6
          ? `**Lemon City** — price above unit cost, hit positive profit, and tie the result to **${meta.title}**.`
          : `Finish in **Lemon City** — set a fair price, serve customers, and keep profit for **${meta.title}**.`,
      ]
    : [copy.learn, copy.apply, 'Track your choices in AED.', 'Practice in Lemon City with fair pricing.'];

  const quizQuestions = copy.quiz.map((item, i) => {
    const correctIndex = keys[i] ?? 0;
    const options = optionsForQuiz(copy, i, correctIndex);
    let prompt = item.prompt;
    if (meta) {
      if (young && i === 0) {
        prompt = `**${meta.title}** — ${item.prompt}`;
      } else if (!teenL4L6 && i === 1) {
        prompt = `**${meta.subtitle}** — ${item.prompt}`;
      } else if (!teenL4L6 && i === 0) {
        prompt = `**${meta.title}**: ${item.prompt}`;
      }
    }
    return {
      id: `q${i + 1}`,
      prompt,
      options,
      correctIndex,
      explanation: teenL4L6
        ? `Correct — **${meta?.title ?? 'Great job'}**: ${options[correctIndex]}. ${meta?.subtitle ?? ''}.`
        : `Nice! **${meta?.title ?? 'Great job'}** — "${options[correctIndex]}" is the best choice.`,
    };
  });

  return GeneratedContentSchema.parse({
    concept: params.concept,
    ageBand: params.ageBand,
    region: 'AE',
    guide: params.guide,
    locale: params.locale,
    readParagraphs,
    quizQuestions,
    gameConfig: gameConfigFor(order, params.ageBand, difficulty, questLevel),
    reviewed: false,
  });
}

export function seedSummaryForPrompt(meta: LessonMetaLite, ageBand = '9-12'): string {
  const copy = stageCopyForTitle(meta.title, ageBand, meta.questLevel);
  if (!copy) return `${meta.title}: ${meta.subtitle}`;
  return [
    `Title: ${meta.title}`,
    `Subtitle: ${meta.subtitle}`,
    `Learn: ${copy.learn}`,
    `Apply: ${copy.apply}`,
    `Sample quiz: ${copy.quiz[0]?.prompt} → ${copy.quiz[0]?.correct}`,
  ].join('\n');
}

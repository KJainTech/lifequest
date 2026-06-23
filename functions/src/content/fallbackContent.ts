import type { z } from 'zod';
import { GeneratedContentSchema } from '@lifequest/types';

type GeneratedContent = z.infer<typeof GeneratedContentSchema>;

/** Deterministic fallback when Gemini is unavailable or output fails validation. */
export function fallbackContent(params: {
  concept: string;
  ageBand: string;
  guide: string;
  locale: string;
}): GeneratedContent {
  const unitCost = params.ageBand === '13-17' ? 2.5 : 2;
  return {
    concept: params.concept,
    ageBand: params.ageBand as '5-8' | '9-12' | '13-17',
    region: 'AE',
    guide: params.guide as 'penny' | 'finBot' | 'atlas',
    locale: params.locale as 'en' | 'ar',
    readParagraphs: [
      'Every sale has two sides: money coming in (revenue) and money going out (cost).',
      'Profit is what is left: Revenue minus Cost. In AED, if you sell for 5 and spend 2, profit is 3.',
      'If your price is below cost, you lose on every sale — even if customers buy.',
      'In Lemon City you will set a price and serve customers. Win by pricing above cost with positive profit.',
    ],
    quizQuestions: [
      {
        id: 'q1',
        prompt: 'Profit equals…',
        options: ['Revenue + Cost', 'Revenue − Cost', 'Cost − Revenue', 'Revenue × Cost'],
        correctIndex: 1,
        explanation: 'Profit is revenue minus cost.',
      },
      {
        id: 'q2',
        prompt: 'You sell lemonade for AED 4. Each cup costs AED 2. Profit per cup?',
        options: ['AED 6', 'AED 2', 'AED 4', 'AED 8'],
        correctIndex: 1,
        explanation: '4 − 2 = 2 AED profit per cup.',
      },
      {
        id: 'q3',
        prompt: 'Price is AED 1, cost is AED 2. What happens?',
        options: ['Big profit', 'Break even', 'Loss on each cup', 'Double revenue'],
        correctIndex: 2,
        explanation: 'Price below cost means you lose on every sale.',
      },
      {
        id: 'q4',
        prompt: 'Revenue is AED 20, cost is AED 12. Profit?',
        options: ['AED 32', 'AED 8', 'AED 12', 'AED 20'],
        correctIndex: 1,
        explanation: '20 − 12 = 8 AED.',
      },
      {
        id: 'q5',
        prompt: 'To make profit, your price must be…',
        options: ['Below cost', 'Equal to cost', 'Above cost', 'Zero'],
        correctIndex: 2,
        explanation: 'Price must exceed unit cost to earn on each sale.',
      },
    ],
    gameConfig: {
      unitCost,
      daySeconds: 60,
      customerCount: 8,
      minPrice: 1,
      maxPrice: 8,
      defaultPrice: 3,
    },
    reviewed: false,
  };
}

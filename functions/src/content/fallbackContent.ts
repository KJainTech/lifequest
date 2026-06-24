import type { z } from 'zod';
import { GeneratedContentSchema } from '@lifequest/types';
import { buildTemplateContent } from './stageSnippets';

type GeneratedContent = z.infer<typeof GeneratedContentSchema>;

/** Lesson-specific fallback when AI is unavailable or output fails validation. */
export function fallbackContent(params: {
  lessonId: string;
  concept: string;
  ageBand: string;
  guide: string;
  locale: string;
  mastery?: number;
}): GeneratedContent {
  return buildTemplateContent(params);
}

/** @deprecated Use fallbackContent with lessonId */
export function legacyProfitFallback(params: {
  concept: string;
  ageBand: string;
  guide: string;
  locale: string;
}): GeneratedContent {
  return fallbackContent({ ...params, lessonId: 'lesson_6' });
}

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { AgeBandSchema, GuideSchema, LocaleSchema, RegionSchema } from '@lifequest/types';
import { legacyProfitFallback } from './fallbackContent';
import { db, nowIso } from '../lib/firebase';

const RefreshPayloadSchema = z.object({
  concept: z.string().default('profit'),
  ageBand: AgeBandSchema.default('5-8'),
  region: RegionSchema.default('AE'),
  guide: GuideSchema.default('penny'),
  locale: LocaleSchema.default('en'),
});

/** Queue content refresh — seeds fallback pack for admin review. */
export const refreshContent = onCall(async (request) => {
  if (!request.auth?.token?.admin) {
    throw new HttpsError('permission-denied', 'Admin only.');
  }

  const params = RefreshPayloadSchema.parse(request.data ?? {});
  const content = legacyProfitFallback(params);
  const variantId = `${params.ageBand}_${params.locale}_${params.guide}`;

  await db.doc(`content/${params.concept}/variants/${variantId}`).set({
    ...content,
    source: 'refresh',
    updatedAt: nowIso(),
  });

  await db.collection('content_queue').add({
    concept: params.concept,
    variantId,
    status: 'pending_review',
    source: 'refresh',
    createdAt: nowIso(),
  });

  return {
    status: 'completed',
    variantId,
    message: 'Content cached. Review in admin before serving to children.',
    params,
  };
});

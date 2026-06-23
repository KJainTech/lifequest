/**
 * Seed reviewed curriculum variants into Firestore emulator or prod.
 * Usage: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npx ts-node scripts/seedCurriculum.ts
 */
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT ?? 'lifequest-97bf9' });
}

const db = admin.firestore();

const variants = [
  { concept: 'profit', ageBand: '5-8', locale: 'en', guide: 'penny' },
  { concept: 'profit', ageBand: '9-12', locale: 'en', guide: 'finBot' },
  { concept: 'profit', ageBand: '13-17', locale: 'en', guide: 'atlas' },
];

async function main() {
  for (const v of variants) {
    const variantId = `${v.ageBand}_${v.locale}_${v.guide}`;
    await db.doc(`content/${v.concept}/variants/${variantId}`).set({
      concept: v.concept,
      ageBand: v.ageBand,
      locale: v.locale,
      guide: v.guide,
      region: 'AE',
      reviewed: true,
      reviewedAt: new Date().toISOString(),
      readParagraphs: [
        'Profit = Revenue − Cost. This is how businesses know if they truly earned.',
      ],
      quizQuestions: [],
      gameConfig: { unitCost: 2, daySeconds: 60, customerCount: 8, minPrice: 1, maxPrice: 8, defaultPrice: 3 },
      source: 'seed',
    });
    console.log(`Seeded ${v.concept}/${variantId}`);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

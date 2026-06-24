import * as admin from 'firebase-admin';
import { DEMO_VIDYA, type DemoVidyaSeedResult } from './demoVidyaConfig';
import { db, nowIso } from '../lib/firebase';

const auth = admin.auth();

async function upsertAuthUser(
  email: string,
  password: string,
  displayName: string,
): Promise<admin.auth.UserRecord> {
  try {
    const existing = await auth.getUserByEmail(email);
    await auth.updateUser(existing.uid, { password, displayName });
    return auth.getUser(existing.uid);
  } catch (e: unknown) {
    const code = (e as { code?: string }).code;
    if (code !== 'auth/user-not-found') throw e;
    return auth.createUser({ email, password, displayName, emailVerified: true });
  }
}

export async function runSeedDemoVidya(): Promise<DemoVidyaSeedResult> {
  const parent = await upsertAuthUser(
    DEMO_VIDYA.parent.email,
    DEMO_VIDYA.password,
    DEMO_VIDYA.parent.displayName,
  );
  const adminUser = await upsertAuthUser(
    DEMO_VIDYA.admin.email,
    DEMO_VIDYA.password,
    DEMO_VIDYA.admin.displayName,
  );
  const child = await upsertAuthUser(
    DEMO_VIDYA.child.email,
    DEMO_VIDYA.password,
    DEMO_VIDYA.child.displayName,
  );

  await auth.setCustomUserClaims(adminUser.uid, { admin: true });

  const ts = nowIso();

  await db.doc(`users/${parent.uid}`).set(
    {
      role: 'parent',
      displayName: DEMO_VIDYA.parent.displayName,
      locale: 'en',
      region: 'AE',
      createdAt: ts,
    },
    { merge: true },
  );

  await db.doc(`users/${child.uid}`).set(
    {
      role: 'child',
      displayName: DEMO_VIDYA.child.displayName,
      age: 10,
      ageBand: '9-12',
      guide: 'penny',
      proficiencyLevel: 1,
      locale: 'en',
      region: 'AE',
      onboardingComplete: true,
      parentUid: parent.uid,
      linkedAt: ts,
    },
    { merge: true },
  );

  await db.doc(`profiles/${child.uid}/stats/current`).set(
    {
      xp: 120,
      level: 1,
      coins: 85,
      lqScore: 42,
      businessIQ: { profit: 18, decision: 12, resilience: 8 },
      streak: { count: 3, lastActive: ts.slice(0, 10) },
      conceptSkills: { needs_wants: 2, saving: 1 },
      updatedAt: ts,
    },
    { merge: true },
  );

  await db.doc(`progress/${child.uid}/lessons/lesson_1`).set(
    {
      status: 'completed',
      quizScore: 4,
      stars: 3,
      completedAt: ts,
      updatedAt: ts,
    },
    { merge: true },
  );

  await db.doc(`progress/${child.uid}/lessons/lesson_2`).set(
    {
      status: 'available',
      updatedAt: ts,
    },
    { merge: true },
  );

  await db.doc(`notifications/${child.uid}/items/welcome`).set(
    {
      title: 'Welcome back, Vidya!',
      body: 'Your next stage is Budget Basics. Tap Play on Home to continue.',
      kind: 'quest',
      read: false,
      createdAt: ts,
    },
    { merge: true },
  );

  return {
    childUid: child.uid,
    parentUid: parent.uid,
    adminUid: adminUser.uid,
    linked: true,
  };
}

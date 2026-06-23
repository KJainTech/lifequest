import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { beforeAll, afterAll, beforeEach, describe, it } from 'vitest';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

let testEnv: RulesTestEnvironment;

const PROJECT_ID = 'lifequest-test';

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

function childContext(uid = 'child1') {
  return testEnv.authenticatedContext(uid, { email: 'child@test.com' });
}

function otherChildContext(uid = 'child2') {
  return testEnv.authenticatedContext(uid, { email: 'child2@test.com' });
}

describe('Firestore security rules', () => {
  it('allows child to read own stats', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await setDoc(doc(adminDb, 'profiles/child1/stats/current'), {
        xp: 100,
        level: 2,
        coins: 50,
        lqScore: 120,
        businessIQ: { profit: 10, decision: 10, resilience: 10 },
        streak: { count: 1, lastActive: '2026-06-23' },
        updatedAt: new Date().toISOString(),
      });
    });

    const db = childContext().firestore();
    await assertSucceeds(getDoc(doc(db, 'profiles/child1/stats/current')));
  });

  it('denies child writing own stats', async () => {
    const db = childContext().firestore();
    await assertFails(
      setDoc(doc(db, 'profiles/child1/stats/current'), {
        xp: 99999,
        level: 99,
        coins: 99999,
        lqScore: 900,
        businessIQ: { profit: 100, decision: 100, resilience: 100 },
        streak: { count: 99, lastActive: '2026-06-23' },
        updatedAt: new Date().toISOString(),
      }),
    );
  });

  it('denies cross-child stats read', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await setDoc(doc(adminDb, 'profiles/child2/stats/current'), {
        xp: 50,
        level: 1,
        coins: 10,
        lqScore: 30,
        businessIQ: { profit: 5, decision: 5, resilience: 5 },
        streak: { count: 0, lastActive: null },
        updatedAt: new Date().toISOString(),
      });
    });

    const db = childContext('child1').firestore();
    await assertFails(getDoc(doc(db, 'profiles/child2/stats/current')));
  });

  it('denies child writing stars on lesson progress', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await setDoc(doc(adminDb, 'progress/child1/lessons/lesson_6'), {
        status: 'in_progress',
      });
    });

    const db = childContext().firestore();
    await assertFails(
      updateDoc(doc(db, 'progress/child1/lessons/lesson_6'), {
        stars: 6,
        completedAt: new Date().toISOString(),
      }),
    );
  });

  it('allows child to read own user doc before profile exists', async () => {
    const db = childContext().firestore();
    await assertSucceeds(getDoc(doc(db, 'users/child1')));
  });

  it('allows child to create own user profile stub', async () => {
    const db = childContext().firestore();
    await assertSucceeds(
      setDoc(doc(db, 'users/child1'), {
        role: 'child',
        displayName: 'Explorer',
        onboardingComplete: false,
        locale: 'en',
        region: 'AE',
        proficiencyLevel: 1,
      }),
    );
  });

  it('denies unauthenticated reads', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users/child1')));
  });
});

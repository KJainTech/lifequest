import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

export const db = admin.firestore();
export { admin };

export function nowIso(): string {
  return new Date().toISOString();
}

export function todayDateStr(): string {
  return new Date().toISOString().slice(0, 10);
}

export function defaultStats() {
  return {
    xp: 0,
    level: 1,
    coins: 0,
    lqScore: 0,
    businessIQ: { profit: 0, decision: 0, resilience: 0 },
    streak: { count: 0, lastActive: null as string | null },
    updatedAt: nowIso(),
  };
}

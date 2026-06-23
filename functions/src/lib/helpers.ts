import { db } from './firebase';
import { defaultStats } from './firebase';

export async function getUserRole(uid: string): Promise<string> {
  const snap = await db.doc(`users/${uid}`).get();
  return snap.data()?.role ?? 'child';
}

export async function getStats(uid: string) {
  const snap = await db.doc(`profiles/${uid}/stats/current`).get();
  if (!snap.exists) return defaultStats();
  return snap.data() as ReturnType<typeof defaultStats>;
}

export async function ensureStats(uid: string) {
  const ref = db.doc(`profiles/${uid}/stats/current`);
  const snap = await ref.get();
  if (!snap.exists) {
    await ref.set(defaultStats());
  }
}

export function generateClassCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

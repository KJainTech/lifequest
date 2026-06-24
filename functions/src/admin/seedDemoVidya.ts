import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { runSeedDemoVidya } from './seedDemoVidyaCore';

const SEED_SECRET = process.env.DEMO_SEED_SECRET ?? 'lifequest-vidya-seed';

/** Idempotent demo account provisioning — Vidya child, parent, and admin. */
export const seedDemoVidya = onCall(async (request) => {
  const secret = (request.data as { secret?: string } | undefined)?.secret;
  const isAdmin = request.auth?.token?.admin === true;
  if (!isAdmin && secret !== SEED_SECRET) {
    throw new HttpsError('permission-denied', 'Admin or valid seed secret required.');
  }
  return runSeedDemoVidya();
});

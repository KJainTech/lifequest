#!/usr/bin/env node
/**
 * Seed Vidya demo accounts in Firebase (child, parent, admin).
 *
 * Usage:
 *   cd functions && npm run build && node ../scripts/seed-demo-vidya.mjs
 *
 * Or call the seedDemoVidya Cloud Function after deploy.
 */
import { initializeApp, applicationDefault, getApps } from 'firebase-admin/app';

if (getApps().length === 0) {
  initializeApp({
    credential: applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID ?? 'lifequest-97bf9',
  });
}

const { runSeedDemoVidya } = await import('../functions/lib/admin/seedDemoVidyaCore.js');

const result = await runSeedDemoVidya();
console.log('Vidya demo accounts ready:');
console.log(JSON.stringify(result, null, 2));
console.log('\nCredentials (password for all): Vidya2026!');
console.log('  Child:  vidya.child@lifequest.app');
console.log('  Parent: vidya.parent@lifequest.app');
console.log('  Admin:  vidya.admin@lifequest.app');

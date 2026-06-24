#!/usr/bin/env node
/**
 * Grant admin custom claim to a Firebase Auth user by email.
 *
 * Usage:
 *   cd functions && node ../scripts/grant-admin.mjs admin@example.com
 *
 * Requires Application Default Credentials or GOOGLE_APPLICATION_CREDENTIALS.
 */
import { initializeApp, applicationDefault, getApps } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const email = process.argv[2];
if (!email) {
  console.error("Usage: node scripts/grant-admin.mjs <email>");
  process.exit(1);
}

if (getApps().length === 0) {
  initializeApp({
    credential: applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID ?? "lifequest-97bf9",
  });
}

const auth = getAuth();
const user = await auth.getUserByEmail(email);
await auth.setCustomUserClaims(user.uid, { admin: true });
console.log(`Granted admin claim to ${email} (${user.uid})`);

import { HttpsError } from 'firebase-functions/v2/https';

export function requireAuth(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  return uid;
}

export function assertChildRole(role: string | undefined): void {
  if (role !== 'child') {
    throw new HttpsError('permission-denied', 'Child account required.');
  }
}

export function assertParentRole(role: string | undefined): void {
  if (role !== 'parent') {
    throw new HttpsError('permission-denied', 'Parent account required.');
  }
}

export function assertTeacherRole(role: string | undefined): void {
  if (role !== 'teacher') {
    throw new HttpsError('permission-denied', 'Teacher account required.');
  }
}

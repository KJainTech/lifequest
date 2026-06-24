"use client";

import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  type User,
} from "firebase/auth";
import { doc, setDoc } from "firebase/firestore";
import { auth, db } from "./firebase";

export async function signInParent(email: string, password: string) {
  return signInWithEmailAndPassword(auth, email.trim(), password);
}

export async function registerParent(input: {
  email: string;
  password: string;
  displayName: string;
}) {
  const cred = await createUserWithEmailAndPassword(
    auth,
    input.email.trim(),
    input.password,
  );
  await setDoc(doc(db, "users", cred.user.uid), {
    role: "parent",
    displayName: input.displayName.trim() || "Parent",
    locale: "en",
    region: "AE",
    createdAt: new Date().toISOString(),
  });
  return cred.user;
}

export async function signOut() {
  await firebaseSignOut(auth);
}

export function authErrorMessage(error: unknown): string {
  const code = (error as { code?: string })?.code ?? "";
  switch (code) {
    case "auth/invalid-email":
      return "Enter a valid email address.";
    case "auth/user-not-found":
    case "auth/wrong-password":
    case "auth/invalid-credential":
      return "Email or password is incorrect.";
    case "auth/email-already-in-use":
      return "An account with this email already exists. Sign in instead.";
    case "auth/weak-password":
      return "Password must be at least 6 characters.";
    default:
      return error instanceof Error ? error.message : "Something went wrong.";
  }
}

export type { User };

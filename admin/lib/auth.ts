import {
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
} from "firebase/auth";
import { auth } from "./firebase";

export async function signInAdmin(email: string, password: string) {
  return signInWithEmailAndPassword(auth, email.trim(), password);
}

export async function signOutAdmin() {
  await firebaseSignOut(auth);
}

export async function userIsAdmin(user: { getIdTokenResult: () => Promise<{ claims: Record<string, unknown> }> }) {
  const token = await user.getIdTokenResult();
  return token.claims.admin === true;
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
    default:
      return error instanceof Error ? error.message : "Something went wrong.";
  }
}

"use client";

import { useRouter } from "next/navigation";
import { FormEvent, useEffect, useState } from "react";
import { authErrorMessage, signInAdmin, userIsAdmin } from "@/lib/auth";
import { DEMO_VIDYA } from "@/lib/demoAccounts";
import { useAuth } from "@/lib/AuthProvider";

export default function AdminLoginPage() {
  const router = useRouter();
  const { user, loading: authLoading } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function fillAdminDemo() {
    setEmail(DEMO_VIDYA.admin.email);
    setPassword(DEMO_VIDYA.password);
  }

  useEffect(() => {
    if (authLoading || !user) return;
    userIsAdmin(user).then((ok) => {
      if (ok) router.replace("/");
    });
  }, [authLoading, user, router]);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const cred = await signInAdmin(email, password);
      const ok = await userIsAdmin(cred.user);
      if (!ok) {
        setError("This account does not have admin access.");
        return;
      }
      router.replace("/");
    } catch (err) {
      setError(authErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-surface p-6">
      <form
        onSubmit={onSubmit}
        className="w-full max-w-md space-y-5 rounded-lg border border-surface-border bg-surface-raised p-8"
        aria-label="Admin sign in"
      >
        <div>
          <h1 className="text-xl font-semibold text-ink">LifeQuest Admin</h1>
          <p className="mt-1 text-sm text-ink-muted">
            Sign in with an account that has the admin claim.
          </p>
        </div>

        {error && (
          <p className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-800" role="alert">
            {error}
          </p>
        )}

        <div>
          <label htmlFor="email" className="block text-sm font-medium text-ink">
            Email
          </label>
          <input
            id="email"
            type="email"
            className="mt-1 w-full rounded-md border border-surface-border px-3 py-2 text-sm"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>

        <div>
          <label htmlFor="password" className="block text-sm font-medium text-ink">
            Password
          </label>
          <input
            id="password"
            type="password"
            className="mt-1 w-full rounded-md border border-surface-border px-3 py-2 text-sm"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-md bg-brand px-4 py-2 text-sm font-medium text-white disabled:opacity-60"
        >
          {loading ? "Signing in…" : "Sign in"}
        </button>

        <div className="rounded-md border border-surface-border bg-surface p-3 text-xs text-ink-muted">
          <p className="font-medium text-ink">Demo — Vidya admin</p>
          <p className="mt-1">{DEMO_VIDYA.admin.email}</p>
          <button
            type="button"
            className="mt-2 text-brand underline"
            onClick={fillAdminDemo}
          >
            Fill demo login
          </button>
        </div>
      </form>
    </div>
  );
}

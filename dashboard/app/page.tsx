"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useEffect, useState } from "react";
import { useAuth } from "../components/AuthProvider";
import { signInParent, authErrorMessage } from "../lib/auth";
import { DEMO_VIDYA } from "../lib/demoAccounts";

export default function LoginPage() {
  const router = useRouter();
  const { user, loading: authLoading } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function fillParentDemo() {
    setEmail(DEMO_VIDYA.parent.email);
    setPassword(DEMO_VIDYA.password);
  }

  useEffect(() => {
    if (!authLoading && user) {
      router.replace("/parent");
    }
  }, [authLoading, user, router]);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await signInParent(email, password);
      router.replace("/parent");
    } catch (err) {
      setError(authErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-b from-lq-slate-100 to-lq-slate-50">
      <header className="border-b border-lq-slate-200 bg-white/80 backdrop-blur-sm">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-4 sm:px-6">
          <div className="flex items-center gap-3">
            <div
              className="flex h-9 w-9 items-center justify-center rounded-lg bg-lq-emerald-600 text-sm font-semibold text-white"
              aria-hidden="true"
            >
              LQ
            </div>
            <span className="text-lg font-semibold tracking-tight text-lq-slate-900">
              LifeQuest
            </span>
          </div>
          <span className="text-sm text-lq-slate-500">Parent & Teacher</span>
        </div>
      </header>

      <main className="flex flex-1 items-center justify-center px-4 py-12 sm:px-6">
        <div className="w-full max-w-md">
          <div className="mb-8 text-center">
            <h1 className="text-2xl font-semibold tracking-tight text-lq-slate-900 sm:text-3xl">
              Welcome back
            </h1>
            <p className="mt-2 text-sm text-lq-slate-500">
              Sign in to view your child&apos;s live progress.
            </p>
          </div>

          <form
            className="lq-card space-y-5"
            onSubmit={onSubmit}
            aria-label="Sign in form"
          >
            {error && (
              <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-800" role="alert">
                {error}
              </p>
            )}

            <div>
              <label htmlFor="email" className="lq-label">
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                placeholder="you@example.com"
                className="lq-input"
                aria-required="true"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div>
              <label htmlFor="password" className="lq-label">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                placeholder="Enter your password"
                className="lq-input"
                aria-required="true"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="lq-btn-primary w-full" disabled={loading}>
              {loading ? "Signing in…" : "Sign in"}
            </button>

            <p className="text-center text-sm text-lq-slate-500">
              New parent?{" "}
              <Link href="/register" className="font-medium text-lq-emerald-700 hover:underline">
                Create an account
              </Link>
            </p>
          </form>

          <div className="lq-card mt-6 space-y-3">
            <p className="text-sm font-medium text-lq-slate-900">Demo account — Vidya</p>
            <p className="text-xs text-lq-slate-500">
              Parent: {DEMO_VIDYA.parent.email} · Password: {DEMO_VIDYA.password}
            </p>
            <button
              type="button"
              className="lq-btn-secondary w-full text-sm"
              onClick={fillParentDemo}
            >
              Fill demo login
            </button>
          </div>
        </div>
      </main>

      <footer className="border-t border-lq-slate-200 py-6 text-center text-xs text-lq-slate-400">
        LifeQuest — proficiency-based financial literacy
      </footer>
    </div>
  );
}

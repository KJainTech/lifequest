"use client";

import Link from "next/link";

export default function LoginPage() {
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
              Sign in to view progress and manage classes.
            </p>
          </div>

          <form
            className="lq-card space-y-5"
            onSubmit={(e) => e.preventDefault()}
            aria-label="Sign in form"
          >
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
              />
            </div>

            <button type="submit" className="lq-btn-primary w-full">
              Sign in
            </button>

            <p className="text-center text-xs text-lq-slate-400">
              Authentication wiring comes in a later phase. Use the links below
              to preview dashboards.
            </p>
          </form>

          <nav
            className="mt-8 flex flex-col gap-3 sm:flex-row sm:justify-center"
            aria-label="Dashboard previews"
          >
            <Link
              href="/parent"
              className="lq-btn-secondary text-center"
              aria-label="Preview parent dashboard"
            >
              Parent dashboard
            </Link>
            <Link
              href="/teacher"
              className="lq-btn-secondary text-center"
              aria-label="Preview teacher dashboard"
            >
              Teacher dashboard
            </Link>
          </nav>
        </div>
      </main>

      <footer className="border-t border-lq-slate-200 py-6 text-center text-xs text-lq-slate-400">
        LifeQuest — proficiency-based financial literacy
      </footer>
    </div>
  );
}

"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { FormEvent, useEffect, useState } from "react";
import { httpsCallable } from "firebase/functions";
import { useAuth } from "../../components/AuthProvider";
import { signOut } from "../../lib/auth";
import { functions } from "../../lib/firebase";
import { useParentDashboard } from "../../lib/useParentDashboard";

function ScoreRing({ score }: { score: number }) {
  const circumference = 2 * Math.PI * 36;
  const offset = circumference - (score / 100) * circumference;

  return (
    <div className="relative h-24 w-24 shrink-0" aria-hidden="true">
      <svg className="h-24 w-24 -rotate-90" viewBox="0 0 80 80">
        <circle
          cx="40"
          cy="40"
          r="36"
          fill="none"
          stroke="#e2e8f0"
          strokeWidth="6"
        />
        <circle
          cx="40"
          cy="40"
          r="36"
          fill="none"
          stroke="#28B77F"
          strokeWidth="6"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center">
        <span className="text-xl font-semibold text-lq-slate-900">{score}</span>
      </div>
    </div>
  );
}

const businessIqLabels = [
  {
    key: "profit" as const,
    title: "Profit sense",
    summary: "Connecting work, cost, and reward.",
  },
  {
    key: "decision" as const,
    title: "Decision quality",
    summary: "Choosing wisely under pressure.",
  },
  {
    key: "resilience" as const,
    title: "Resilience",
    summary: "Bouncing back when plans wobble.",
  },
];

export default function ParentDashboardClient() {
  const router = useRouter();
  const params = useSearchParams();
  const childIdParam = params.get("childId");
  const { user, loading: authLoading } = useAuth();
  const {
    children,
    selectedChildId,
    setSelectedChildId,
    profileName,
    stats,
    loading,
    error,
    derived,
  } = useParentDashboard(childIdParam);

  const [childUidInput, setChildUidInput] = useState("");
  const [linking, setLinking] = useState(false);
  const [linkMessage, setLinkMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !user) {
      router.replace("/");
    }
  }, [authLoading, user, router]);

  async function handleSignOut() {
    await signOut();
    router.replace("/");
  }

  async function handleLinkChild(e: FormEvent) {
    e.preventDefault();
    const uid = childUidInput.trim();
    if (!uid) return;
    setLinking(true);
    setLinkMessage(null);
    try {
      const linkChild = httpsCallable(functions, "linkChild");
      await linkChild({ childUid: uid });
      setSelectedChildId(uid);
      setChildUidInput("");
      setLinkMessage("Child linked successfully.");
      window.location.reload();
    } catch (err) {
      setLinkMessage(
        err instanceof Error ? err.message : "Could not link child account.",
      );
    } finally {
      setLinking(false);
    }
  }

  if (authLoading || !user) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-lq-slate-50">
        <p className="text-sm text-lq-slate-500">Loading…</p>
      </div>
    );
  }

  const childName = profileName;
  const lqScore = stats?.lqScore ?? 0;

  return (
    <div className="min-h-screen bg-lq-slate-50">
      <header className="border-b border-lq-slate-200 bg-white">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <div className="flex items-center gap-3">
            <div
              className="flex h-9 w-9 items-center justify-center rounded-lg bg-lq-emerald-600 text-sm font-semibold text-white"
              aria-hidden="true"
            >
              LQ
            </div>
            <div>
              <p className="text-xs font-medium uppercase tracking-wider text-lq-slate-500">
                Parent view
              </p>
              <h1 className="text-lg font-semibold text-lq-slate-900">
                {childName}&apos;s progress
              </h1>
            </div>
          </div>
          <button type="button" onClick={handleSignOut} className="lq-btn-secondary text-sm">
            Sign out
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10">
        {children.length === 0 && (
          <section className="lq-card mb-6" aria-labelledby="link-child-heading">
            <h2 id="link-child-heading" className="text-base font-semibold text-lq-slate-900">
              Link a child account
            </h2>
            <p className="mt-2 text-sm text-lq-slate-600">
              Open the LifeQuest app on your child&apos;s device, go to{" "}
              <strong>Me → Parents</strong>, and copy their account ID. Paste it
              below.
            </p>
            <form className="mt-4 flex flex-col gap-3 sm:flex-row" onSubmit={handleLinkChild}>
              <input
                type="text"
                className="lq-input flex-1 font-mono text-sm"
                placeholder="Child account ID"
                value={childUidInput}
                onChange={(e) => setChildUidInput(e.target.value)}
                aria-label="Child account ID"
              />
              <button type="submit" className="lq-btn-primary shrink-0" disabled={linking}>
                {linking ? "Linking…" : "Link child"}
              </button>
            </form>
            {linkMessage && (
              <p
                className={`mt-3 text-sm ${linkMessage.includes("success") ? "text-lq-emerald-700" : "text-red-800"}`}
                role="status"
              >
                {linkMessage}
              </p>
            )}
          </section>
        )}

        {children.length > 1 && (
          <div className="mb-6 flex flex-wrap gap-2">
            {children.map((c) => (
              <button
                key={c.uid}
                type="button"
                className={
                  c.uid === selectedChildId
                    ? "lq-btn-primary text-sm"
                    : "lq-btn-secondary text-sm"
                }
                onClick={() => setSelectedChildId(c.uid)}
              >
                {c.displayName}
              </button>
            ))}
          </div>
        )}

        {error && (
          <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
            {error}
          </div>
        )}

        {loading && (
          <p className="text-sm text-lq-slate-500">Loading live progress…</p>
        )}

        {!loading && !selectedChildId && children.length === 0 && (
          <div className="lq-card">
            <p className="text-sm text-lq-slate-600">
              No linked children yet. Link an account above to see live stats.
            </p>
          </div>
        )}

        {selectedChildId && !loading && (
          <>
            <section aria-labelledby="overview-heading" className="mb-10">
              <h2 id="overview-heading" className="sr-only">
                Overview
              </h2>
              <div className="grid gap-6 lg:grid-cols-3">
                <div className="lq-card flex flex-col items-center gap-4 sm:flex-row sm:items-start lg:col-span-1">
                  <ScoreRing score={lqScore} />
                  <div className="text-center sm:text-left">
                    <p className="text-sm font-medium text-lq-slate-500">
                      LifeQuest Score
                    </p>
                    <p className="mt-1 text-2xl font-semibold text-lq-slate-900">
                      {derived.questName}
                    </p>
                    <p className="mt-2 text-sm text-lq-slate-600">
                      {derived.completed}/48 stages · {stats?.coins ?? 0} coins ·{" "}
                      {stats?.streak ?? 0}-day streak
                    </p>
                  </div>
                </div>

                <div className="lq-card lg:col-span-2">
                  <div className="mb-3 flex items-center justify-between gap-2">
                    <h3 className="text-base font-semibold text-lq-slate-900">
                      This week
                    </h3>
                    <span className="rounded-full bg-lq-emerald-50 px-2.5 py-0.5 text-xs font-medium text-lq-emerald-700">
                      Live
                    </span>
                  </div>
                  <p className="text-sm leading-relaxed text-lq-slate-600">
                    {derived.journeyDone
                      ? `${childName} completed the full journey — Chief Money Officer!`
                      : `Quest Level ${derived.questLevel} · ${derived.questName}.`}{" "}
                    {derived.sessionsThisWeek === 0
                      ? "No stages finished in the last 7 days yet."
                      : `${derived.sessionsThisWeek} stage${derived.sessionsThisWeek === 1 ? "" : "s"} this week.`}
                  </p>
                  <p className="mt-4 text-xs text-lq-slate-400">
                    Synced from Firestore · Updated in real time
                  </p>
                </div>
              </div>
            </section>

            <section aria-labelledby="business-iq-heading">
              <div className="mb-5 flex flex-wrap items-end justify-between gap-2">
                <div>
                  <h2
                    id="business-iq-heading"
                    className="text-xl font-semibold text-lq-slate-900"
                  >
                    Business IQ
                  </h2>
                  <p className="mt-1 text-sm text-lq-slate-500">
                    Three pillars from your child&apos;s live stats.
                  </p>
                </div>
              </div>

              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {businessIqLabels.map((domain) => {
                  const score = stats?.businessIQ[domain.key] ?? 0;
                  return (
                    <article key={domain.key} className="lq-card">
                      <div className="mb-4 flex items-start justify-between gap-3">
                        <div>
                          <h3 className="text-base font-semibold text-lq-slate-900">
                            {domain.title}
                          </h3>
                        </div>
                        <span
                          className="rounded-lg bg-lq-slate-100 px-2.5 py-1 text-sm font-semibold tabular-nums text-lq-slate-800"
                          aria-label={`${domain.title} score ${score} out of 100`}
                        >
                          {score}
                        </span>
                      </div>
                      <div
                        className="mb-3 h-1.5 overflow-hidden rounded-full bg-lq-slate-200"
                        role="progressbar"
                        aria-valuenow={score}
                        aria-valuemin={0}
                        aria-valuemax={100}
                        aria-label={`${domain.title} progress`}
                      >
                        <div
                          className="h-full rounded-full bg-lq-emerald-500 transition-all"
                          style={{ width: `${Math.min(score, 100)}%` }}
                        />
                      </div>
                      <p className="text-sm text-lq-slate-600">
                        {domain.summary}
                      </p>
                    </article>
                  );
                })}
              </div>
            </section>

            <section className="mt-10" aria-labelledby="coach-heading">
              <div className="lq-card">
                <h2
                  id="coach-heading"
                  className="text-base font-semibold text-lq-slate-900"
                >
                  ParentCoach tip
                </h2>
                <p className="mt-2 text-sm leading-relaxed text-lq-slate-600">
                  {(stats?.businessIQ.profit ?? 0) >= 10
                    ? `${childName} is building strong profit sense. Try a real AED purchase together: need or want?`
                    : `${childName} is just getting started. Talk about one thing they wanted vs needed this week.`}
                </p>
              </div>
            </section>
          </>
        )}
      </main>
    </div>
  );
}

import Link from "next/link";

const businessIqDomains = [
  {
    id: "earn",
    title: "Earn",
    score: 72,
    summary: "Understands how work connects to income.",
    trend: "+4 this month",
  },
  {
    id: "save",
    title: "Save",
    score: 65,
    summary: "Building habits around setting money aside.",
    trend: "+2 this month",
  },
  {
    id: "spend",
    title: "Spend",
    score: 58,
    summary: "Learning to compare needs and wants.",
    trend: "Steady",
  },
  {
    id: "grow",
    title: "Grow",
    score: 44,
    summary: "Early exposure to how money can grow.",
    trend: "+6 this month",
  },
];

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
          stroke="#059669"
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

export default function ParentDashboardPage() {
  const childName = "Aisha";
  const lqScore = 62;

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
          <Link href="/" className="lq-btn-secondary text-sm">
            Sign out
          </Link>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10">
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
                  Proficiency level
                </p>
                <p className="mt-2 text-sm text-lq-slate-600">
                  A calm snapshot of overall financial literacy progress — not a
                  ranking.
                </p>
              </div>
            </div>

            <div className="lq-card lg:col-span-2">
              <div className="mb-3 flex items-center justify-between gap-2">
                <h3 className="text-base font-semibold text-lq-slate-900">
                  Coach note
                </h3>
                <span className="rounded-full bg-lq-emerald-50 px-2.5 py-0.5 text-xs font-medium text-lq-emerald-700">
                  Placeholder
                </span>
              </div>
              <p className="text-sm leading-relaxed text-lq-slate-600">
                {childName} is making steady progress with saving concepts. A
                gentle next step: talk together about one small goal to save
                toward this week. ParentCoach AI insights will appear here once
                connected.
              </p>
              <p className="mt-4 text-xs text-lq-slate-400">
                Updated weekly · No competitive comparisons
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
                Four domains of money confidence — personal progress only.
              </p>
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            {businessIqDomains.map((domain) => (
              <article key={domain.id} className="lq-card">
                <div className="mb-4 flex items-start justify-between gap-3">
                  <div>
                    <h3 className="text-base font-semibold text-lq-slate-900">
                      {domain.title}
                    </h3>
                    <p className="mt-1 text-xs text-lq-slate-500">
                      {domain.trend}
                    </p>
                  </div>
                  <span
                    className="rounded-lg bg-lq-slate-100 px-2.5 py-1 text-sm font-semibold tabular-nums text-lq-slate-800"
                    aria-label={`${domain.title} score ${domain.score} out of 100`}
                  >
                    {domain.score}
                  </span>
                </div>
                <div
                  className="mb-3 h-1.5 overflow-hidden rounded-full bg-lq-slate-200"
                  role="progressbar"
                  aria-valuenow={domain.score}
                  aria-valuemin={0}
                  aria-valuemax={100}
                  aria-label={`${domain.title} progress`}
                >
                  <div
                    className="h-full rounded-full bg-lq-emerald-500 transition-all"
                    style={{ width: `${domain.score}%` }}
                  />
                </div>
                <p className="text-sm text-lq-slate-600">{domain.summary}</p>
              </article>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

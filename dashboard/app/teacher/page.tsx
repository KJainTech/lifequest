"use client";

import Link from "next/link";

const roster = [
  {
    id: "1",
    name: "Aisha Khan",
    grade: "Year 5",
    lastActive: "Today",
    lqScore: 62,
  },
  {
    id: "2",
    name: "Omar Hassan",
    grade: "Year 5",
    lastActive: "Yesterday",
    lqScore: 58,
  },
  {
    id: "3",
    name: "Layla Ahmed",
    grade: "Year 6",
    lastActive: "2 days ago",
    lqScore: 71,
  },
  {
    id: "4",
    name: "Yusuf Ali",
    grade: "Year 5",
    lastActive: "Today",
    lqScore: 54,
  },
];

export default function TeacherDashboardPage() {
  const classCode = "LQ-7K3M";
  const className = "Year 5 · Financial Foundations";

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
                Teacher view
              </p>
              <h1 className="text-lg font-semibold text-lq-slate-900">
                {className}
              </h1>
            </div>
          </div>
          <Link href="/" className="lq-btn-secondary text-sm">
            Sign out
          </Link>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10">
        <div className="grid gap-8 lg:grid-cols-3">
          <section
            aria-labelledby="class-code-heading"
            className="lg:col-span-1"
          >
            <div className="lq-card">
              <h2
                id="class-code-heading"
                className="text-base font-semibold text-lq-slate-900"
              >
                Class code
              </h2>
              <p className="mt-1 text-sm text-lq-slate-500">
                Share this code so students can join your class.
              </p>

              <div className="mt-5 rounded-lg border border-dashed border-lq-slate-300 bg-lq-slate-50 px-4 py-6 text-center">
                <p
                  className="font-mono text-2xl font-semibold tracking-widest text-lq-emerald-700"
                  aria-label={`Class code ${classCode}`}
                >
                  {classCode}
                </p>
                <p className="mt-2 text-xs text-lq-slate-400">
                  Placeholder · regenerates when connected
                </p>
              </div>

              <form
                className="mt-5 space-y-4"
                onSubmit={(e) => e.preventDefault()}
                aria-label="Create class code form"
              >
                <div>
                  <label htmlFor="class-name" className="lq-label">
                    Class name
                  </label>
                  <input
                    id="class-name"
                    name="className"
                    type="text"
                    defaultValue="Year 5 · Financial Foundations"
                    className="lq-input"
                  />
                </div>
                <button type="submit" className="lq-btn-primary w-full">
                  Generate new code
                </button>
              </form>
            </div>

            <div className="lq-card mt-4">
              <h3 className="text-sm font-semibold text-lq-slate-900">
                Class summary
              </h3>
              <dl className="mt-3 space-y-2 text-sm">
                <div className="flex justify-between">
                  <dt className="text-lq-slate-500">Students</dt>
                  <dd className="font-medium text-lq-slate-900">
                    {roster.length}
                  </dd>
                </div>
                <div className="flex justify-between">
                  <dt className="text-lq-slate-500">Active this week</dt>
                  <dd className="font-medium text-lq-slate-900">3</dd>
                </div>
              </dl>
            </div>
          </section>

          <section
            aria-labelledby="roster-heading"
            className="lg:col-span-2"
          >
            <div className="mb-5">
              <h2
                id="roster-heading"
                className="text-xl font-semibold text-lq-slate-900"
              >
                Class roster
              </h2>
              <p className="mt-1 text-sm text-lq-slate-500">
                Individual progress for your students — no leaderboards.
              </p>
            </div>

            <div className="lq-card overflow-hidden p-0">
              <div className="overflow-x-auto">
                <table className="w-full min-w-[480px] text-left text-sm">
                  <thead>
                    <tr className="border-b border-lq-slate-200 bg-lq-slate-50">
                      <th
                        scope="col"
                        className="px-5 py-3 font-medium text-lq-slate-600"
                      >
                        Student
                      </th>
                      <th
                        scope="col"
                        className="px-5 py-3 font-medium text-lq-slate-600"
                      >
                        Grade
                      </th>
                      <th
                        scope="col"
                        className="px-5 py-3 font-medium text-lq-slate-600"
                      >
                        Last active
                      </th>
                      <th
                        scope="col"
                        className="px-5 py-3 font-medium text-lq-slate-600"
                      >
                        LQ score
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-lq-slate-100">
                    {roster.map((student) => (
                      <tr
                        key={student.id}
                        className="transition-colors hover:bg-lq-slate-50/80"
                      >
                        <td className="px-5 py-4 font-medium text-lq-slate-900">
                          {student.name}
                        </td>
                        <td className="px-5 py-4 text-lq-slate-600">
                          {student.grade}
                        </td>
                        <td className="px-5 py-4 text-lq-slate-600">
                          {student.lastActive}
                        </td>
                        <td className="px-5 py-4">
                          <span className="inline-flex rounded-md bg-lq-emerald-50 px-2 py-0.5 font-medium tabular-nums text-lq-emerald-700">
                            {student.lqScore}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <p className="mt-4 text-xs text-lq-slate-400">
              Scores reflect proficiency, not competition. Detailed student
              views coming in a later phase.
            </p>
          </section>
        </div>
      </main>
    </div>
  );
}

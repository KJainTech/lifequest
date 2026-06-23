import { PageHeader } from "@/components/PageHeader";
import { StatCard } from "@/components/StatCard";

export default function OverviewPage() {
  return (
    <>
      <PageHeader
        title="Overview"
        description="High-level operational stats for LifeQuest. Values are placeholders until Firestore and Functions metrics are connected."
      />
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Active learners (7d)"
          value="—"
          hint="Distinct child profiles with a session"
        />
        <StatCard
          label="Lessons completed (7d)"
          value="—"
          hint="Read → Quiz → Game → Reward loops"
        />
        <StatCard
          label="Pending content reviews"
          value="3"
          hint="See Content queue"
        />
        <StatCard
          label="AI spend (MTD)"
          value="AED —"
          hint="Gemini token costs vs budget"
        />
      </div>
      <section className="mt-8 rounded-lg border border-surface-border bg-surface-raised p-6">
        <h3 className="text-sm font-medium text-ink">System status</h3>
        <ul className="mt-4 space-y-3 text-sm text-ink-muted">
          <li className="flex items-center justify-between border-b border-surface-border pb-3">
            <span>Firebase project</span>
            <span className="font-mono text-xs text-ink">lifequest-dev</span>
          </li>
          <li className="flex items-center justify-between border-b border-surface-border pb-3">
            <span>Auth guard</span>
            <span className="text-xs text-amber-200">Not wired</span>
          </li>
          <li className="flex items-center justify-between">
            <span>Audit logging</span>
            <span className="text-xs text-ink-muted">
              Content actions will write to audit log
            </span>
          </li>
        </ul>
      </section>
    </>
  );
}

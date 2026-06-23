import { PageHeader } from "@/components/PageHeader";
import { StatCard } from "@/components/StatCard";

export default function AnalyticsPage() {
  return (
    <>
      <PageHeader
        title="Analytics"
        description="Engagement and learning-loop metrics. Charts and Firestore aggregations are placeholders for Phase 11."
      />
      <div className="grid gap-4 md:grid-cols-3">
        <StatCard
          label="Daily active users"
          value="—"
          hint="Unique child sessions per day (7-day avg)"
        />
        <StatCard
          label="D7 retention"
          value="—%"
          hint="Return rate one week after first lesson"
        />
        <StatCard
          label="Loop completion rate"
          value="—%"
          hint="Read → Quiz → Game → Reward finished same session"
        />
      </div>
      <div className="mt-8 grid gap-4 lg:grid-cols-2">
        <section className="rounded-lg border border-surface-border bg-surface-raised p-6">
          <h3 className="text-sm font-medium text-ink">DAU trend</h3>
          <div className="mt-6 flex h-40 items-center justify-center rounded-md border border-dashed border-surface-border">
            <p className="text-xs text-ink-muted">Chart placeholder</p>
          </div>
        </section>
        <section className="rounded-lg border border-surface-border bg-surface-raised p-6">
          <h3 className="text-sm font-medium text-ink">Retention cohorts</h3>
          <div className="mt-6 flex h-40 items-center justify-center rounded-md border border-dashed border-surface-border">
            <p className="text-xs text-ink-muted">Chart placeholder</p>
          </div>
        </section>
      </div>
      <section className="mt-4 rounded-lg border border-surface-border bg-surface-raised p-6">
        <h3 className="text-sm font-medium text-ink">Loop completion by age band</h3>
        <div className="mt-4 space-y-3">
          {["5–8", "9–12", "13–17"].map((band) => (
            <div key={band} className="flex items-center gap-4">
              <span className="w-12 text-xs text-ink-muted">{band}</span>
              <div className="h-2 flex-1 rounded-full bg-surface">
                <div className="h-2 w-0 rounded-full bg-accent" />
              </div>
              <span className="w-10 text-right text-xs tabular-nums text-ink-muted">
                —%
              </span>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}

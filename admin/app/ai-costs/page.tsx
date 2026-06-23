import { PageHeader } from "@/components/PageHeader";
import { StatCard } from "@/components/StatCard";

const budgetAed = 5000;
const spentAed = 0;
const spentPct = budgetAed > 0 ? (spentAed / budgetAed) * 100 : 0;

export default function AiCostsPage() {
  return (
    <>
      <PageHeader
        title="AI Costs"
        description="Gemini token usage versus monthly budget. Values sync from Cloud Functions cost tracking once wired."
      />
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label="Tokens used (MTD)"
          value="—"
          hint="Input + output tokens across all Functions"
        />
        <StatCard
          label="Estimated spend"
          value={`AED ${spentAed.toLocaleString()}`}
          hint="Converted from token pricing"
        />
        <StatCard
          label="Monthly budget"
          value={`AED ${budgetAed.toLocaleString()}`}
          hint="Remote Config: ai.monthlyBudgetAed"
        />
        <StatCard
          label="Budget remaining"
          value={`AED ${(budgetAed - spentAed).toLocaleString()}`}
          hint={`${(100 - spentPct).toFixed(0)}% of budget unused`}
        />
      </div>
      <section className="mt-8 rounded-lg border border-surface-border bg-surface-raised p-6">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-medium text-ink">Usage vs budget</h3>
          <span className="text-xs tabular-nums text-ink-muted">
            {spentPct.toFixed(1)}% consumed
          </span>
        </div>
        <div className="mt-4 h-3 overflow-hidden rounded-full bg-surface">
          <div
            className="h-full rounded-full bg-accent transition-all"
            style={{ width: `${Math.min(spentPct, 100)}%` }}
            role="progressbar"
            aria-valuenow={spentPct}
            aria-valuemin={0}
            aria-valuemax={100}
            aria-label="Token spend as percentage of monthly budget"
          />
        </div>
        <ul className="mt-6 space-y-3 text-sm">
          <li className="flex justify-between border-b border-surface-border pb-3 text-ink-muted">
            <span>ParentCoach AI</span>
            <span className="tabular-nums">AED —</span>
          </li>
          <li className="flex justify-between border-b border-surface-border pb-3 text-ink-muted">
            <span>Content generation</span>
            <span className="tabular-nums">AED —</span>
          </li>
          <li className="flex justify-between text-ink-muted">
            <span>FinBot / screening</span>
            <span className="tabular-nums">AED —</span>
          </li>
        </ul>
      </section>
    </>
  );
}

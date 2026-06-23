type StatCardProps = {
  label: string;
  value: string;
  hint?: string;
};

export function StatCard({ label, value, hint }: StatCardProps) {
  return (
    <div className="rounded-lg border border-surface-border bg-surface-raised p-5">
      <p className="text-xs font-medium uppercase tracking-wide text-ink-muted">
        {label}
      </p>
      <p className="mt-2 text-2xl font-semibold tabular-nums text-ink">
        {value}
      </p>
      {hint ? (
        <p className="mt-2 text-xs text-ink-muted">{hint}</p>
      ) : null}
    </div>
  );
}

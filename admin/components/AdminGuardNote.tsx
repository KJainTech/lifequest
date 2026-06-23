export function AdminGuardNote() {
  return (
    <div
      role="note"
      className="mb-6 rounded-lg border border-amber-900/40 bg-amber-950/30 px-4 py-3"
    >
      <p className="text-sm font-medium text-amber-200">
        Admin-claim protected (placeholder)
      </p>
      <p className="mt-1 text-xs leading-relaxed text-amber-200/70">
        Production access requires Firebase Auth with custom claim{" "}
        <code className="rounded bg-surface px-1 py-0.5 font-mono text-[11px]">
          admin: true
        </code>
        . Auth middleware and session checks are not wired yet — this UI is
        scaffold-only for Phase 11.
      </p>
    </div>
  );
}

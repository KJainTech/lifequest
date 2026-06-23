import { PageHeader } from "@/components/PageHeader";

export default function UsersPage() {
  return (
    <>
      <PageHeader
        title="Users"
        description="Search child profiles, parent accounts, and teacher links. Query wiring is a Phase 11 placeholder."
      />
      <div className="rounded-lg border border-surface-border bg-surface-raised p-6">
        <label htmlFor="user-search" className="text-sm font-medium text-ink">
          Search users
        </label>
        <div className="mt-3 flex flex-col gap-3 sm:flex-row">
          <input
            id="user-search"
            type="search"
            placeholder="Email, child profile id, or display name"
            disabled
            className="flex-1 rounded-md border border-surface-border bg-surface px-4 py-2.5 text-sm text-ink placeholder:text-ink-muted/50 disabled:cursor-not-allowed disabled:opacity-60"
            aria-describedby="user-search-hint"
          />
          <button
            type="button"
            disabled
            className="rounded-md bg-accent px-5 py-2.5 text-sm font-medium text-white disabled:cursor-not-allowed disabled:opacity-60"
          >
            Search
          </button>
        </div>
        <p id="user-search-hint" className="mt-3 text-xs text-ink-muted">
          Firestore-backed search and role filters will connect here. Admin
          actions require verified admin claim before any user data is shown.
        </p>
      </div>
      <div className="mt-6 rounded-lg border border-dashed border-surface-border p-8 text-center">
        <p className="text-sm text-ink-muted">
          No results — enter a query once search is enabled.
        </p>
      </div>
    </>
  );
}

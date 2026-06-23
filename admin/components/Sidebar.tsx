import Link from "next/link";

const navItems = [
  { href: "/", label: "Overview" },
  { href: "/content", label: "Content" },
  { href: "/users", label: "Users" },
  { href: "/analytics", label: "Analytics" },
  { href: "/ai-costs", label: "AI Costs" },
];

export function Sidebar() {
  return (
    <aside className="flex w-56 shrink-0 flex-col border-r border-surface-border bg-surface-raised">
      <div className="border-b border-surface-border px-5 py-6">
        <p className="text-xs font-medium uppercase tracking-widest text-ink-muted">
          LifeQuest
        </p>
        <h1 className="mt-1 text-lg font-semibold text-ink">Admin</h1>
      </div>
      <nav className="flex flex-1 flex-col gap-1 p-3" aria-label="Admin navigation">
        {navItems.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className="rounded-md px-3 py-2 text-sm text-ink-muted transition-colors hover:bg-surface hover:text-ink"
          >
            {item.label}
          </Link>
        ))}
      </nav>
      <div className="border-t border-surface-border p-4">
        <p className="text-xs leading-relaxed text-ink-muted">
          Phase 11 · Internal tooling
        </p>
      </div>
    </aside>
  );
}

"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";

const navItems = [
  { href: "/", label: "Overview" },
  { href: "/content", label: "Content" },
  { href: "/users", label: "Users" },
  { href: "/analytics", label: "Analytics" },
  { href: "/ai-costs", label: "AI Costs" },
];

export function Sidebar({ onSignOut }: { onSignOut?: () => Promise<void> }) {
  const router = useRouter();

  async function handleSignOut() {
    if (onSignOut) await onSignOut();
    router.replace("/login");
  }

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
      <div className="border-t border-surface-border p-4 space-y-3">
        {onSignOut && (
          <button
            type="button"
            onClick={handleSignOut}
            className="w-full rounded-md border border-surface-border px-3 py-2 text-sm text-ink-muted hover:bg-surface hover:text-ink"
          >
            Sign out
          </button>
        )}
        <p className="text-xs leading-relaxed text-ink-muted">
          LifeQuest internal console
        </p>
      </div>
    </aside>
  );
}

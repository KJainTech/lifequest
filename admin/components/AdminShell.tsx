"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState, type ReactNode } from "react";
import { signOutAdmin, userIsAdmin } from "@/lib/auth";
import { useAuth } from "@/lib/AuthProvider";
import { AdminGuardNote } from "@/components/AdminGuardNote";
import { Sidebar } from "@/components/Sidebar";

export function AdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, loading } = useAuth();
  const [adminOk, setAdminOk] = useState<boolean | null>(null);

  const isLogin = pathname === "/login";

  useEffect(() => {
    if (loading) return;
    if (isLogin) {
      setAdminOk(null);
      return;
    }
    if (!user) {
      router.replace("/login");
      return;
    }
    userIsAdmin(user).then((ok) => {
      setAdminOk(ok);
      if (!ok) router.replace("/login");
    });
  }, [loading, user, isLogin, router]);

  if (isLogin) {
    return <>{children}</>;
  }

  if (loading || adminOk !== true) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-surface">
        <p className="text-sm text-ink-muted">Loading…</p>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen">
      <Sidebar onSignOut={signOutAdmin} />
      <main className="flex-1 overflow-auto p-8">
        {children}
      </main>
    </div>
  );
}

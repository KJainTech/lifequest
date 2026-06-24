import { Suspense } from "react";
import ParentDashboardClient from "./ParentDashboardClient";

export default function ParentDashboardPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center text-sm text-lq-slate-500">
          Loading dashboard…
        </div>
      }
    >
      <ParentDashboardClient />
    </Suspense>
  );
}

"use client";

import { PageHeader } from "@/components/PageHeader";

type ReviewItem = {
  id: string;
  type: string;
  title: string;
  submittedBy: string;
  submittedAt: string;
  status: "pending" | "in_review";
};

const pendingQueue: ReviewItem[] = [
  {
    id: "lesson-042-quiz",
    type: "Quiz",
    title: "Needs vs Wants — Quiz v2",
    submittedBy: "content-pipeline",
    submittedAt: "2026-06-22",
    status: "pending",
  },
  {
    id: "lesson-042-read",
    type: "Read",
    title: "Needs vs Wants — Read copy",
    submittedBy: "gemini-draft",
    submittedAt: "2026-06-22",
    status: "pending",
  },
  {
    id: "world-atlas-tip",
    type: "Tip",
    title: "Atlas world — savings tip",
    submittedBy: "content-pipeline",
    submittedAt: "2026-06-21",
    status: "in_review",
  },
];

function handleApprove(id: string) {
  console.info(`[audit-log placeholder] content.approve ${id}`);
}

function handleReject(id: string) {
  console.info(`[audit-log placeholder] content.reject ${id}`);
}

export default function ContentPage() {
  return (
    <>
      <PageHeader
        title="Content"
        description="Pending review queue for AI-generated and pipeline-submitted lesson assets. Approve and reject actions will append to the admin audit log."
      />
      <div className="overflow-hidden rounded-lg border border-surface-border">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-surface-border bg-surface-raised">
            <tr>
              <th className="px-4 py-3 font-medium text-ink-muted">Asset</th>
              <th className="px-4 py-3 font-medium text-ink-muted">Type</th>
              <th className="px-4 py-3 font-medium text-ink-muted">Source</th>
              <th className="px-4 py-3 font-medium text-ink-muted">Submitted</th>
              <th className="px-4 py-3 font-medium text-ink-muted">Status</th>
              <th className="px-4 py-3 font-medium text-ink-muted">Actions</th>
            </tr>
          </thead>
          <tbody>
            {pendingQueue.map((item) => (
              <tr
                key={item.id}
                className="border-b border-surface-border last:border-0"
              >
                <td className="px-4 py-4">
                  <p className="font-medium text-ink">{item.title}</p>
                  <p className="mt-0.5 font-mono text-xs text-ink-muted">
                    {item.id}
                  </p>
                </td>
                <td className="px-4 py-4 text-ink-muted">{item.type}</td>
                <td className="px-4 py-4 text-ink-muted">{item.submittedBy}</td>
                <td className="px-4 py-4 tabular-nums text-ink-muted">
                  {item.submittedAt}
                </td>
                <td className="px-4 py-4">
                  <span className="rounded-full border border-surface-border px-2 py-0.5 text-xs capitalize text-ink-muted">
                    {item.status.replace("_", " ")}
                  </span>
                </td>
                <td className="px-4 py-4">
                  <div className="flex flex-wrap gap-2">
                    <button
                      type="button"
                      onClick={() => handleApprove(item.id)}
                      aria-label={`Approve ${item.title} and write audit log entry`}
                      className="rounded-md bg-accent px-3 py-1.5 text-xs font-medium text-white transition-colors hover:bg-accent-muted"
                    >
                      Approve (audit log)
                    </button>
                    <button
                      type="button"
                      onClick={() => handleReject(item.id)}
                      aria-label={`Reject ${item.title} and write audit log entry`}
                      className="rounded-md border border-surface-border px-3 py-1.5 text-xs font-medium text-ink-muted transition-colors hover:border-red-900/50 hover:text-red-300"
                    >
                      Reject (audit log)
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <p className="mt-4 text-xs text-ink-muted">
        Each approve/reject action will record actor, asset id, timestamp, and
        prior state in the admin audit log collection once backend wiring is
        complete.
      </p>
    </>
  );
}

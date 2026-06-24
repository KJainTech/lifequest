"use client";

import { useEffect, useMemo, useState } from "react";
import {
  collection,
  doc,
  getDocs,
  onSnapshot,
  query,
  where,
  type Unsubscribe,
} from "firebase/firestore";
import { onAuthStateChanged, type User } from "firebase/auth";
import { auth, db } from "../lib/firebase";

export type ChildSummary = {
  uid: string;
  displayName: string;
};

export type ChildStats = {
  lqScore: number;
  coins: number;
  level: number;
  xp: number;
  streak: number;
  businessIQ: {
    profit: number;
    decision: number;
    resilience: number;
  };
};

export type LessonProgressRow = {
  lessonId: string;
  status: string;
  quizScore?: number;
  completedAt?: string;
};

const QUEST_LEVEL_NAMES = [
  "Coin Keeper",
  "Smart Spender",
  "Budget Boss",
  "Junior Investor",
  "Wealth Builder",
  "Chief Money Officer",
];

const STAGES_PER_LEVEL = [5, 6, 7, 9, 10, 11];

function questLevelFromCompleted(completedCount: number): number {
  let remaining = completedCount;
  for (let i = 0; i < STAGES_PER_LEVEL.length; i++) {
    if (remaining < STAGES_PER_LEVEL[i]) return i + 1;
    remaining -= STAGES_PER_LEVEL[i];
  }
  return 6;
}

function questLevelName(completedCount: number, journeyDone: boolean): string {
  if (journeyDone || completedCount >= 48) {
    return QUEST_LEVEL_NAMES[5];
  }
  const level = questLevelFromCompleted(completedCount);
  return QUEST_LEVEL_NAMES[level - 1] ?? QUEST_LEVEL_NAMES[0];
}

export function useParentDashboard(childIdParam?: string | null) {
  const [user, setUser] = useState<User | null>(null);
  const [children, setChildren] = useState<ChildSummary[]>([]);
  const [selectedChildId, setSelectedChildId] = useState<string | null>(
    childIdParam ?? null,
  );
  const [profileName, setProfileName] = useState<string>("Explorer");
  const [stats, setStats] = useState<ChildStats | null>(null);
  const [lessons, setLessons] = useState<LessonProgressRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (u) => setUser(u));
    return () => unsub();
  }, []);

  useEffect(() => {
    if (childIdParam) setSelectedChildId(childIdParam);
  }, [childIdParam]);

  useEffect(() => {
    let cancelled = false;

    async function loadChildren() {
      if (childIdParam) {
        if (!cancelled) {
          setSelectedChildId(childIdParam);
        }
      }

      if (!user) {
        if (childIdParam && !cancelled) {
          setChildren([{ uid: childIdParam, displayName: "Child" }]);
        } else if (!cancelled) {
          setChildren([]);
        }
        return;
      }

      try {
        const q = query(
          collection(db, "users"),
          where("parentUid", "==", user.uid),
        );
        const snap = await getDocs(q);
        const rows: ChildSummary[] = snap.docs.map((d) => ({
          uid: d.id,
          displayName: (d.data().displayName as string) ?? "Explorer",
        }));
        if (!cancelled) {
          setChildren(rows);
          if (!selectedChildId && rows.length > 0) {
            setSelectedChildId(rows[0].uid);
          }
        }
      } catch (e) {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : "Could not load children");
        }
      }
    }

    loadChildren();
    return () => {
      cancelled = true;
    };
  }, [user, childIdParam]);

  useEffect(() => {
    if (!selectedChildId) {
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);
    const unsubs: Unsubscribe[] = [];

    unsubs.push(
      onSnapshot(
        doc(db, "users", selectedChildId),
        (snap) => {
          if (snap.exists()) {
            setProfileName((snap.data().displayName as string) ?? "Explorer");
          }
        },
        (err) => setError(err.message),
      ),
    );

    unsubs.push(
      onSnapshot(
        doc(db, "profiles", selectedChildId, "stats", "current"),
        (snap) => {
          if (!snap.exists()) {
            setStats(null);
            setLoading(false);
            return;
          }
          const d = snap.data();
          setStats({
            lqScore: (d.lqScore as number) ?? 0,
            coins: (d.coins as number) ?? 0,
            level: (d.level as number) ?? 1,
            xp: (d.xp as number) ?? 0,
            streak: (d.streak as { count?: number })?.count ?? 0,
            businessIQ: {
              profit: (d.businessIQ as { profit?: number })?.profit ?? 0,
              decision: (d.businessIQ as { decision?: number })?.decision ?? 0,
              resilience:
                (d.businessIQ as { resilience?: number })?.resilience ?? 0,
            },
          });
          setLoading(false);
        },
        (err) => {
          setError(err.message);
          setLoading(false);
        },
      ),
    );

    unsubs.push(
      onSnapshot(
        collection(db, "progress", selectedChildId, "lessons"),
        (snap) => {
          setLessons(
            snap.docs.map((d) => ({
              lessonId: d.id,
              ...(d.data() as Omit<LessonProgressRow, "lessonId">),
            })),
          );
        },
        (err) => setError(err.message),
      ),
    );

    return () => {
      for (const u of unsubs) u();
    };
  }, [selectedChildId]);

  const derived = useMemo(() => {
    const completed = lessons.filter((l) => l.status === "completed").length;
    const journeyDone = completed >= 48;
    const sessionsThisWeek = lessons.filter((l) => {
      if (l.status !== "completed" || !l.completedAt) return false;
      const dt = new Date(l.completedAt);
      const diff = Date.now() - dt.getTime();
      return diff >= 0 && diff < 7 * 24 * 60 * 60 * 1000;
    }).length;

    return {
      completed,
      journeyDone,
      sessionsThisWeek,
      questLevel: questLevelFromCompleted(completed),
      questName: questLevelName(completed, journeyDone),
    };
  }, [lessons]);

  return {
    user,
    children,
    selectedChildId,
    setSelectedChildId,
    profileName,
    stats,
    lessons,
    loading,
    error,
    derived,
  };
}

export { QUEST_LEVEL_NAMES };

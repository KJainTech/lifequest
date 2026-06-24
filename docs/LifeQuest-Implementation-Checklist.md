# LifeQuest — Implementation Checklist
**Sources:** Creative DevPlan v3 · Build Review doc · P0 polish pass  
**Date:** June 2026 · **App version:** 1.6.3+20+

---

## P0 bugs (Review doc) — DONE

- [x] MCQ answer shuffle per question (cannot tap position 1 every time)
- [x] Guide persistence — Profile picker saves to Firestore
- [x] Lemon City / slider integer AED steps (no 29.9)
- [x] Quiz white-flash between questions reduced (fade switcher)
- [x] No Level 7 rollover — `displayQuestLevel()` caps at L6 / Programme complete
- [x] Session activity writes in `completeLesson` (`activity/{uid}/weeks/`)
- [x] Web audio path fixed (`assets/audio/`)
- [x] Sound toggle wired to `LQSound.enabled`
- [x] Parent view shows quest level + sessions this week (not XP level 7)

## P0 polish — DONE

- [x] Learn path auto-scrolls to current stage node
- [x] City map ignores taps on locked plots
- [x] Locked learn nodes (no tap when `LessonStatus.locked`)

## Creative DevPlan — Phase 1 Foundation — DONE / PARTIAL

- [x] AppShell with Back · Home · Exit “Take a break?” sheet (`lib/design/lq_app_shell.dart`)
- [x] Splash screen (existing)
- [x] Onboarding: guide → start → screening → profile save
- [x] Riverpod session + lesson providers
- [ ] Parent registration / invite code (web dashboard mock only)
- [ ] Full parent auth on dashboard (static UI)

## Creative DevPlan — Phase 2 City Map — PARTIAL

- [x] 48 plots · 6 districts · lock/next/built logic
- [x] City HUD · plot sheet · build celebration overlay
- [x] Hero video city map (production)
- [ ] Isometric tappable node map wired (painter exists, unused)
- [ ] Guide walk-between-nodes animation

## Creative DevPlan — Phase 3 Gameplay Engine — DONE / PARTIAL

- [x] Stage intro screen (guide voice line)
- [x] Activity engine with 5 types: MCQ · drag-drop buckets · slider · card-sort · scenario
- [x] Drag-drop: labelled Needs/Wants buckets always visible
- [x] Slider quiz: integer values, exact match required
- [x] Read → Activity → Lemon City → Reward flow
- [x] Stage complete / reward ceremony (stars, confetti, coins)
- [x] Exit Challenge screen (level-end, ≥80% pass)
- [x] Level complete ceremony screen
- [x] Money Wisdom Letter (6 levels × 3 guide voices)
- [x] Brag card (share + Maybe later)
- [x] City finale (lesson 48 / programme complete)
- [x] 30-minute session break overlay + 15-min snooze
- [ ] Dedicated Flame coin-rain game widget (uses existing celebration burst)
- [ ] Dedicated Flame fireworks level ceremony
- [ ] Coin fly path animations per answer
- [ ] Validation cadence (guide speaks every 3rd correct only)
- [ ] Credit Score Simulator arc gauge (L5.5)
- [ ] Crash Experiment live graph (L4.6)
- [ ] Blueprint Defence one-attempt finale screen

## Creative DevPlan — Phase 4–6 Content — PARTIAL

- [x] 48-stage curriculum + stage-specific snippets
- [x] Activity type auto-mapping by stage title
- [x] Teen variants L4–L6
- [x] Adaptive AI lessons 7+
- [x] FAQ screen — Kids / Parents / Schools tabs
- [ ] Coin shop · goal tracker · chore tracker
- [ ] Guide change ceremony animation
- [ ] Overnight reveal gifts
- [ ] Concept explainer animations (20–45s)
- [ ] Concept cards / printable sheets
- [ ] Timeline replay after level complete
- [ ] Real-world milestone prompt after each level
- [ ] Dashboard live Firebase wiring (parent/teacher/admin)

## Tests & deploy — DONE

- [x] 53 Flutter tests passing
- [x] Functions economy tests passing
- [x] `flutter analyze` — no errors
- [x] Web deploy script run

---

## Honest gap summary

The **full play experience** from the review (Credit Score Simulator, per-stage bespoke interactives for all 48 stages, dashboard live data) is **partially implemented**. The **engine and ceremonies** are in place; **L5.5/L4.6-grade bespoke simulators** and **dashboard auth** remain the largest remaining builds.

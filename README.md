# LifeQuest

A premium, proficiency-based financial-literacy game for ages 5–17 · UAE-first.

## Monorepo layout

```
lib/                  Flutter kid app (iOS / Android / web)
dashboard/            Parent & teacher web app (Next.js)
admin/                Admin panel (Next.js)
functions/            Firebase Cloud Functions (TypeScript)
packages/types/       Shared Zod schemas + scoring logic
docs/BIBLE.md         Product spec
firestore.rules       Security rules (server-authoritative economy)
```

## Quick start — Flutter app

```bash
flutter pub get
flutter run
```

## Quick start — Firebase emulators

```bash
cd packages/types && npm install && npm run build && cd ../..
cd functions && npm install && cd ..
npx firebase emulators:start --only auth,firestore,functions
flutter run
```

## Web apps

```bash
cd dashboard && npm install && npm run dev   # http://localhost:3000
cd admin && npm install && npm run dev       # http://localhost:3001 (use -p 3001)
```

## Cloud Functions

| Function | Purpose |
|---|---|
| `submitQuiz` | Score quiz server-side |
| `submitGamePlay` | Record game session |
| `completeLesson` | Award XP/coins/LQ, badge, tower |
| `runScreening` | Adaptive placement |
| `linkChild` | Parent ↔ child link |
| `createClass` / `joinClass` | Teacher class codes |
| `generateCoachNote` | ParentCoach (Gemini + fallback) |
| `generateContent` / `approveContent` | AI content pipeline |
| `refreshContent` | Seed/refresh content cache |

## Tests

```bash
flutter analyze && flutter test
cd packages/types && npm test
cd functions && npm test && npm run build
```

## Build phases (complete)

- [x] Phase 0–1: Design system + showcase
- [x] Phase 2: Backend (Firestore, rules, Functions)
- [x] Phase 3: Onboarding + anonymous auth
- [x] Phase 4: Lesson loop (Read → Quiz → Game → Reward)
- [x] Phase 5: City build sequence
- [x] Phase 6: Home + Learn + Progress + 5-tab shell
- [x] Phase 7: AI layer (generateContent, ParentCoach, safety filters)
- [x] Phase 8: Curriculum seed script + reviewed content gate
- [x] Phase 9: Parental gate + parent view + EN/AR locale
- [x] Phase 10: Parent/teacher dashboard (`dashboard/`)
- [x] Phase 11: Admin panel (`admin/`)

## Human setup (before prod)

See **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** for full Firebase + DigitalOcean + store deployment.

1. Create Firebase project + `flutterfire configure`
2. Set `GEMINI_API_KEY` for Functions
3. Commission Penny Rive rig → `assets/rive/penny.riv`
4. Wire dashboard/admin Firebase Auth + admin custom claims
5. (Optional) DO App Platform for `dashboard/` and `admin/` — `doctl auth init` then deploy specs in `deploy/digitalocean/`

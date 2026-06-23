# LifeQuest Dashboard

Parent and teacher web dashboard for LifeQuest Phase 10. Built with Next.js 14, TypeScript, Tailwind CSS, and Firebase JS SDK v11.

## Routes

| Route | Description |
|-------|-------------|
| `/` | Login placeholder (email/password form UI) |
| `/parent` | Parent dashboard — LQ score, Business IQ cards, coach note |
| `/teacher` | Teacher dashboard — class roster, class code UI |

## Setup

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Firebase

Demo config in `lib/firebase.ts` matches the Flutter kid app (`projectId: lifequest-dev`).

To connect to local emulators:

```bash
NEXT_PUBLIC_USE_FIREBASE_EMULATORS=true npm run dev
```

Emulator ports: Auth `9099`, Firestore `8080`, Functions `5001` (region `europe-west1`).

## Scripts

- `npm run dev` — start development server
- `npm run build` — production build
- `npm run start` — serve production build
- `npm run lint` — run Next.js lint

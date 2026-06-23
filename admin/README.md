# LifeQuest Admin

Internal admin console for **LifeQuest Phase 11**. Next.js 14 App Router, TypeScript, Tailwind CSS, and Firebase JS SDK.

## Surfaces

| Route | Purpose |
|-------|---------|
| `/` | Overview stats placeholders |
| `/content` | Pending content review queue |
| `/users` | User search placeholder |
| `/analytics` | DAU, retention, loop completion |
| `/ai-costs` | Gemini token usage vs budget |

## Prerequisites

- Node.js 18+
- Firebase project `lifequest-dev` (or override via env)

## Setup

```bash
cd admin
npm install
cp .env.example .env.local   # optional — demo config works without it
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Firebase

Demo config lives in `lib/firebase.ts` with `projectId: lifequest-dev`. Override with:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=lifequest-dev
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
```

## Auth (placeholder)

Production access requires Firebase Auth with custom claim `admin: true`. Middleware and session checks are **not** wired in this scaffold — the banner in the layout documents this.

Content approve/reject buttons log to the console and label audit-log intent; backend writes to an admin audit collection are a follow-up task.

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start dev server |
| `npm run build` | Production build |
| `npm run start` | Serve production build |
| `npm run lint` | Next.js lint |

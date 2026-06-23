# LifeQuest — Deployment Guide

LifeQuest is a **split stack**. Most of the product does **not** run on DigitalOcean.

## What runs where

| Component | Where to deploy | Why |
|-----------|-----------------|-----|
| **Auth, Firestore, Cloud Functions** | **Firebase / Google Cloud** | Already built for this; server-authoritative economy |
| **Kid app (iOS / Android)** | **App Store + Google Play** | Native Flutter builds |
| **Kid app (web)** | Firebase Hosting **or** DO App Platform **or** DO Spaces + CDN | Static `flutter build web` output |
| **Parent/teacher dashboard** | DO App Platform **or** Vercel | Next.js (`dashboard/`) |
| **Admin panel** | DO App Platform **or** Vercel | Next.js (`admin/`) |

You **do not** need a DigitalOcean Droplet with a raw public IP unless you want to self-host everything manually. **App Platform** is the recommended DO path: it gives you HTTPS URLs like `https://lifequest-dashboard-xxxxx.ondigitalocean.app` without managing IPs, nginx, or TLS.

---

## Build status (code)

All **11 playbook phases** are implemented in this repo. Before production you still need:

1. Real **Firebase project** (not `lifequest-dev` demo config)
2. `flutterfire configure` → real `firebase_options` / env for web apps
3. `GEMINI_API_KEY` on Cloud Functions (optional; fallbacks exist)
4. Penny Rive asset (`assets/rive/penny.riv`)
5. App Store / Play signing & store listings (mobile)

---

## Part A — Firebase (required for everyone)

### 1. Create Firebase project

1. [Firebase Console](https://console.firebase.google.com/) → **Add project**
2. Enable **Authentication** → Anonymous + Email/Password
3. Create **Firestore** (production mode, pick region e.g. `europe-west1` to match Functions)
4. Upgrade to **Blaze** plan (pay-as-you-go) for Cloud Functions

### 2. Local CLI setup

```bash
npm i -g firebase-tools
firebase login
firebase use --add   # link local repo to your Firebase project
```

### 3. Flutter app config

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Replace demo `FirebaseOptions` in `lib/app/bootstrap/firebase_providers.dart` with generated config (or use `firebase_options.dart` from flutterfire).

### 4. Deploy backend

```bash
cd packages/types && npm install && npm run build && cd ../..
cd functions && npm install && npm run build && cd ..
firebase deploy --only firestore:rules,functions
```

Set secrets (Functions):

```bash
firebase functions:secrets:set GEMINI_API_KEY
```

### 5. Flutter web on Firebase Hosting (optional)

```bash
flutter build web
firebase init hosting   # public dir: build/web
firebase deploy --only hosting
```

---

## Part B — DigitalOcean (optional web hosting)

### Do you need a new DO project?

**Yes — recommended.** In the DO control panel:

1. **Account** → [API Tokens](https://cloud.digitalocean.com/account/api/tokens) → **Generate token** (read + write)
2. **Projects** → **New project** → name e.g. `LifeQuest`
3. Add **App Platform** apps inside that project (not a VPS unless you prefer ops work)

### What to get from DigitalOcean

| Item | Where in DO | Used for |
|------|-------------|----------|
| **Personal access token** | Account → API → Tokens | `doctl auth init` |
| **Project** | Projects → New project | Organize apps |
| **App Platform app(s)** | Create → Apps | Host `dashboard/` and `admin/` |
| **Domain (optional)** | Networking → Domains | `dashboard.yourdomain.com` |
| **Spaces (optional)** | Spaces | Static Flutter web CDN |
| **Droplet + public IP (optional)** | Droplets | Only if you reject App Platform |

**Public IP:** App Platform apps get a **default HTTPS URL** automatically. You only need a **Floating IP / Droplet IP** if you run your own VM.

### Environment variables (web apps)

Set these on each App Platform app (Settings → App-Level Environment Variables):

```
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
```

Copy values from Firebase Console → Project settings → Your apps → Web app config.

---

## Part C — Deploy with `doctl` CLI

### 1. Install & authenticate

```bash
brew install doctl          # macOS
doctl auth init             # paste your DO API token
doctl account get           # verify
```

### 2. Deploy dashboard

From repo root:

```bash
# Edit deploy/digitalocean/dashboard-app.yaml — set your GitHub repo OR use spec as-is for doctl
doctl apps create --spec deploy/digitalocean/dashboard-app.yaml
doctl apps list
doctl apps create-deployment <APP_ID>
```

Or use the helper script (after setting env vars):

```bash
export DO_APP_DASHBOARD_SPEC=deploy/digitalocean/dashboard-app.yaml
./deploy/digitalocean/deploy-dashboard.sh
```

### 3. Deploy admin (second app)

```bash
doctl apps create --spec deploy/digitalocean/admin-app.yaml
```

### 4. Useful doctl commands

```bash
doctl apps list
doctl apps get <app-id>
doctl apps logs <app-id> --type run
doctl apps update <app-id> --spec deploy/digitalocean/dashboard-app.yaml
doctl apps delete <app-id>
```

---

## Part D — Mobile stores

```bash
flutter build apk --release          # Android
flutter build appbundle --release    # Play Store
flutter build ipa --release          # iOS (Xcode / Apple Developer account)
```

Requires Apple Developer ($99/yr) and Google Play Console ($25 one-time).

---

## Architecture diagram

```
                    ┌─────────────────────────────┐
                    │   Firebase (Google Cloud)    │
                    │  Auth · Firestore · Functions│
                    └──────────────┬──────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
         ▼                         ▼                         ▼
  Flutter mobile/web        DO App Platform           DO App Platform
  (stores / hosting)        dashboard/                admin/
```

---

## Can Cursor deploy for you?

**Only if you provide:**

1. `doctl auth init` completed on your machine (API token)
2. Firebase project linked (`firebase use`)
3. Approval to create paid DO App Platform resources
4. Firebase web config env vars for Next.js apps

Without your DO token and Firebase project, deployment stops at **emulators + local dev**. This repo includes specs and scripts; **you** run auth + deploy commands with your accounts.

---

## Cost rough estimate

| Service | Typical starter cost |
|---------|---------------------|
| Firebase Spark + emulators | Free (local) |
| Firebase Blaze + low traffic | ~$0–25/mo |
| DO App Platform (1 small app) | ~$5–12/mo |
| DO App Platform (dashboard + admin) | ~$10–24/mo |
| Droplet 1GB (DIY) | ~$6/mo + your time |

---

## Quick local verify (no cloud)

```bash
npx firebase emulators:start --only auth,firestore,functions
flutter run
cd dashboard && npm run dev
cd admin && npm run dev
```

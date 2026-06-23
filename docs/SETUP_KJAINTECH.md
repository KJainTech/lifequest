# One-time and deploy checklist for KJainTech / LifeQuest
# Repo: https://github.com/KJainTech/lifequest

## What is already done in code

- All 11 app phases (Flutter kid app, dashboard, admin, Cloud Functions, AI pipeline)
- GitHub-ready CI workflow (`.github/workflows/ci.yml`)
- DigitalOcean App Platform specs (`deploy/digitalocean/`)
- Env-based Firebase config for web apps

## What YOU must provide (I cannot do without your accounts)

### 1. Firebase project (~15 min)

1. Go to [Firebase Console](https://console.firebase.google.com/) → **Create project** (e.g. `lifequest-prod`)
2. **Upgrade to Blaze** (required for Cloud Functions + Gemini)
3. Enable **Authentication** → Anonymous + Email/Password
4. Create **Firestore** database (region: `europe-west1` recommended)
5. Register **Web app** → copy config values
6. Install CLI and link project:

```bash
npm i -g firebase-tools
firebase login
cd /path/to/lifequest
firebase use --add   # pick your project
```

7. Flutter config:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

8. Deploy backend + rules:

```bash
cd packages/types && npm install && npm run build && cd ../..
cd functions && npm install && npm run build && cd ..
firebase deploy --only firestore:rules,functions
```

9. **AI (Gemini)** — [Google AI Studio](https://aistudio.google.com/apikey) → create API key:

```bash
firebase functions:secrets:set GEMINI_API_KEY
# paste key when prompted
firebase deploy --only functions
```

Without `GEMINI_API_KEY`, AI still works via **safe fallbacks** (content + coach notes).

### 2. GitHub (done by deploy script)

Repo: `KJainTech/lifequest` — push from local machine after `git init`.

### 3. DigitalOcean (~10 min)

1. [DigitalOcean](https://www.digitalocean.com) account
2. **API token**: Account → API → Generate (Read + Write)
3. Authorize GitHub for App Platform (DO will ask when creating app)

```bash
brew install doctl
doctl auth init
doctl apps create --spec deploy/digitalocean/dashboard-app.yaml
doctl apps create --spec deploy/digitalocean/admin-app.yaml
```

4. In each DO app → **Settings → Environment Variables**, set:

```
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
```

(From Firebase Console → Project settings → Your apps → Web)

5. DO will auto-deploy on every push to `main` once GitHub is connected.

### 4. Optional: Flutter web hosting

```bash
flutter build web --dart-define=FIREBASE_PROJECT_ID=your-project-id ...
firebase init hosting   # public: build/web
firebase deploy --only hosting
```

### 5. Mobile (later)

- Apple Developer account + `flutter build ipa`
- Google Play Console + `flutter build appbundle`

---

## Verify AI + full app locally (before prod)

```bash
# Terminal 1
cd functions && npx firebase emulators:start --only auth,firestore,functions

# Terminal 2
flutter run

# Terminal 3
cd dashboard && NEXT_PUBLIC_USE_FIREBASE_EMULATORS=true npm run dev

# Terminal 4
cd admin && NEXT_PUBLIC_USE_FIREBASE_EMULATORS=true npm run dev
```

Complete onboarding → lesson 6 → city → check Progress tab updates.

---

## Send me these to finish deploy for you

| Item | Where to get it |
|------|-----------------|
| Firebase project ID | Firebase Console |
| Firebase web config (6 values) | Project settings → Web app |
| `GEMINI_API_KEY` | Google AI Studio |
| DO API token | digitalocean.com → API |
| Confirm: create public GitHub repo? | Yes — `KJainTech/lifequest` |

Do **not** paste API keys in chat if you prefer — set them in Firebase/DO consoles yourself using this guide.

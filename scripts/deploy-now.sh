#!/usr/bin/env bash
# Full LifeQuest deploy — run once in Terminal after Firebase Auth is enabled.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
REPO="${GITHUB_REPO:-KJainTech/lifequest}"
PROJECT_ID="${FIREBASE_PROJECT_ID:-lifequest-97bf9}"

echo "=== LifeQuest full deploy ==="
echo "Project: $PROJECT_ID"
echo ""

# 1. Firebase login (opens browser)
if ! firebase projects:list >/dev/null 2>&1; then
  echo ">>> Step 1: Firebase login (browser will open)"
  firebase login
fi

firebase use "$PROJECT_ID"

# 2. Firestore reminder
echo ""
echo ">>> Ensure Firestore exists: Firebase Console → Firestore → Create (europe-west1)"
read -r -p "Firestore created? [y/N] " fs
if [[ "${fs,,}" != "y" ]]; then
  echo "Create Firestore first: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
  exit 1
fi

# 3. Build + deploy backend
echo ""
echo ">>> Step 2: Deploy Firestore rules + Cloud Functions"
cd "$ROOT/packages/types" && npm ci && npm run build
cd "$ROOT/functions" && npm ci && npm run build
cd "$ROOT"
firebase deploy --only firestore:rules,functions

# 4. Gemini AI (optional)
echo ""
read -r -p "Set GEMINI_API_KEY now? Get from https://aistudio.google.com/apikey [y/N] " gem
if [[ "${gem,,}" == "y" ]]; then
  firebase functions:secrets:set GEMINI_API_KEY
  firebase deploy --only functions
fi

# 5. FlutterFire
echo ""
echo ">>> Step 3: FlutterFire configure"
if command -v flutter >/dev/null; then
  dart pub global activate flutterfire_cli 2>/dev/null || true
  flutterfire configure --project="$PROJECT_ID" --yes --platforms=android,ios,web 2>/dev/null || \
    flutterfire configure --project="$PROJECT_ID"
fi

# 6. Flutter web hosting
echo ""
read -r -p "Deploy Flutter web to Firebase Hosting? [y/N] " host
if [[ "${host,,}" == "y" ]]; then
  flutter pub get
  flutter build web --release --dart-define=FIREBASE_PROJECT_ID="$PROJECT_ID"
  firebase deploy --only hosting
fi

# 7. GitHub Actions secrets for CI deploy
echo ""
echo ">>> Step 4: GitHub deploy secrets"
read -r -p "Save CI token to GitHub for future deploys? [y/N] " ghsec
if [[ "${ghsec,,}" == "y" ]]; then
  echo "Run: firebase login:ci"
  read -r -p "Paste FIREBASE_TOKEN: " FB_TOKEN
  echo "$FB_TOKEN" | gh secret set FIREBASE_TOKEN --repo "$REPO"
  echo "$PROJECT_ID" | gh secret set FIREBASE_PROJECT_ID --repo "$REPO"
  read -r -p "DIGITALOCEAN_ACCESS_TOKEN (Enter to skip): " DO_TOKEN
  if [[ -n "$DO_TOKEN" ]]; then
    echo "$DO_TOKEN" | gh secret set DIGITALOCEAN_ACCESS_TOKEN --repo "$REPO"
  fi
  gh workflow run deploy.yml --repo "$REPO"
  echo "GitHub deploy triggered. Watch: gh run watch --repo $REPO"
fi

echo ""
echo "=== Done ==="
echo "Kid app:     flutter run"
echo "Emulators:   cd functions && npx firebase emulators:start --only auth,firestore,functions"
echo "Console:     https://console.firebase.google.com/project/$PROJECT_ID"

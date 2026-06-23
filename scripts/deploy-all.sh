#!/usr/bin/env bash
# LifeQuest full deploy helper — run AFTER Firebase project + secrets are configured.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "==> 1/4 Build shared types + functions"
(cd packages/types && npm ci && npm run build)
(cd functions && npm ci && npm run build)

echo "==> 2/4 Deploy Firebase (rules + functions)"
if command -v firebase >/dev/null; then
  firebase deploy --only firestore:rules,functions
else
  npx firebase-tools deploy --only firestore:rules,functions
fi

echo "==> 3/4 Optional: Flutter web → Firebase Hosting"
read -r -p "Deploy Flutter web to Firebase Hosting? [y/N] " ans
if [[ "${ans,,}" == "y" ]]; then
  flutter build web
  if command -v firebase >/dev/null; then
    firebase deploy --only hosting
  else
    npx firebase-tools deploy --only hosting
  fi
fi

echo "==> 4/4 Optional: DigitalOcean apps"
if command -v doctl >/dev/null && doctl account get >/dev/null 2>&1; then
  read -r -p "Create/update DO dashboard app? [y/N] " ans
  if [[ "${ans,,}" == "y" ]]; then
    "$ROOT/deploy/digitalocean/deploy-dashboard.sh"
  fi
else
  echo "Skip DO: run 'doctl auth init' first."
fi

echo "Done. See docs/SETUP_KJAINTECH.md for env vars."

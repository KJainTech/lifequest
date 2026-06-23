#!/usr/bin/env bash
# Store deploy secrets in GitHub and trigger deploy workflow.
# Run locally after: firebase login:ci  and  doctl auth init
set -euo pipefail

REPO="${GITHUB_REPO:-KJainTech/lifequest}"

echo "=== LifeQuest deploy bootstrap ==="
echo "Repo: $REPO"
echo ""

if [[ -z "${FIREBASE_TOKEN:-}" ]]; then
  echo "Get Firebase CI token (opens browser if needed):"
  echo "  npx firebase-tools login:ci"
  read -r -p "Paste FIREBASE_TOKEN: " FIREBASE_TOKEN
fi

if [[ -z "${FIREBASE_PROJECT_ID:-}" ]]; then
  read -r -p "Firebase project ID (e.g. lifequest-prod): " FIREBASE_PROJECT_ID
fi

if [[ -z "${DIGITALOCEAN_ACCESS_TOKEN:-}" ]]; then
  echo "Get DO token: https://cloud.digitalocean.com/account/api/tokens"
  read -r -p "Paste DIGITALOCEAN_ACCESS_TOKEN (or Enter to skip DO): " DIGITALOCEAN_ACCESS_TOKEN
fi

echo "$FIREBASE_TOKEN" | gh secret set FIREBASE_TOKEN --repo "$REPO"
echo "$FIREBASE_PROJECT_ID" | gh secret set FIREBASE_PROJECT_ID --repo "$REPO"

if [[ -n "${DIGITALOCEAN_ACCESS_TOKEN:-}" ]]; then
  echo "$DIGITALOCEAN_ACCESS_TOKEN" | gh secret set DIGITALOCEAN_ACCESS_TOKEN --repo "$REPO"
fi

if [[ -n "${GEMINI_API_KEY:-}" ]]; then
  echo "$GEMINI_API_KEY" | gh secret set GEMINI_API_KEY --repo "$REPO"
fi

echo ""
echo "Secrets saved. Triggering deploy workflow..."
gh workflow run deploy.yml --repo "$REPO"
echo "Watch: gh run watch --repo $REPO"

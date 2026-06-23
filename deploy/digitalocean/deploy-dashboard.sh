#!/usr/bin/env bash
# Deploy LifeQuest dashboard to DigitalOcean App Platform via doctl.
# Prerequisites: doctl auth init, Firebase env vars set in spec or DO console.
set -euo pipefail

SPEC="${DO_APP_DASHBOARD_SPEC:-deploy/digitalocean/dashboard-app.yaml}"

if ! command -v doctl >/dev/null; then
  echo "Install doctl: brew install doctl"
  exit 1
fi

if ! doctl account get >/dev/null 2>&1; then
  echo "Run: doctl auth init"
  exit 1
fi

if grep -q "YOUR_GITHUB_USER" "$SPEC"; then
  echo "Edit $SPEC — set your GitHub repo and Firebase env vars first."
  exit 1
fi

echo "Creating/updating dashboard app from $SPEC ..."
if doctl apps list --format ID,Spec.Name --no-header | grep -q "lifequest-dashboard"; then
  APP_ID=$(doctl apps list --format ID,Spec.Name --no-header | awk '$2=="lifequest-dashboard"{print $1; exit}')
  doctl apps update "$APP_ID" --spec "$SPEC"
  doctl apps create-deployment "$APP_ID"
  echo "Updated app $APP_ID"
else
  doctl apps create --spec "$SPEC"
  echo "Created new app. Run: doctl apps list"
fi

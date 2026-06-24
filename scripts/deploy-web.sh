#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
echo "Building LifeQuest web $VERSION …"

flutter build web --release --pwa-strategy=none

# Strip service worker registration if Flutter still injects it.
if [[ -f build/web/flutter_bootstrap.js ]]; then
  perl -i -pe 's/serviceWorkerSettings:\s*\{[^}]*\},?//g' build/web/flutter_bootstrap.js || true
fi

# Ensure index.html has correct build stamp (Flutter may overwrite template).
if [[ -f build/web/index.html ]]; then
  perl -i -pe "s/<!-- build: .* -->/<!-- build: $VERSION -->/g" build/web/index.html || true
  perl -i -pe "s/var BUILD = '[^']*'/var BUILD = '$VERSION'/g" build/web/index.html || true
fi

echo "Deploying to Firebase hosting:app …"
firebase deploy --only hosting:app --project lifequest-97bf9

echo "Done — https://lifequest-97bf9.web.app (expect v$VERSION on City tab)"

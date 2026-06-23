#!/usr/bin/env bash
# Pack @lifequest/types into functions/ so Cloud Build can install it.
# Backs up package.json and patches the dependency only for upload.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TYPES="$ROOT/packages/types"
FUNCS="$ROOT/functions"

echo "Building @lifequest/types..."
cd "$TYPES"
npm run build
npm pack --pack-destination "$FUNCS" --quiet
TGZ=$(ls -t "$FUNCS"/lifequest-types-*.tgz | head -1)
TGZ_NAME=$(basename "$TGZ")
echo "Packed $TGZ_NAME"

cd "$FUNCS"
if [[ ! -f package.json.bak ]]; then
  cp package.json package.json.bak
fi

node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json.bak', 'utf8'));
pkg.dependencies['@lifequest/types'] = 'file:${TGZ_NAME}';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"

echo "Installing $TGZ_NAME into functions..."
npm install --no-audit --no-fund
npm run build
echo "Functions ready to deploy."

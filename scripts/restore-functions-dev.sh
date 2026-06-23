#!/usr/bin/env bash
# Restore functions/package.json for local dev and CI (file:../packages/types).
set -euo pipefail
FUNCS="$(cd "$(dirname "$0")/../functions" && pwd)"
if [[ -f "$FUNCS/package.json.bak" ]]; then
  cp "$FUNCS/package.json.bak" "$FUNCS/package.json"
  echo "Restored functions/package.json from backup."
else
  echo "No package.json.bak — already in dev mode."
fi

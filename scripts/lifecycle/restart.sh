#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

if [ -f ./scripts/world-tools/prepare-mods.sh ]; then
  bash ./scripts/world-tools/prepare-mods.sh
elif [ -f ./scripts/prepare-mods.sh ]; then
  bash ./scripts/prepare-mods.sh
else
  echo "ERROR: prepare-mods.sh not found. Expected ./scripts/world-tools/prepare-mods.sh or ./scripts/prepare-mods.sh"
  exit 1
fi
docker compose restart


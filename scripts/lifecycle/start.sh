#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

ensure_dir() {
  local path="$1"
  if [ -d "$path" ]; then
    return 0
  fi
  if [ -e "$path" ] && [ ! -d "$path" ]; then
    echo "ERROR: $path exists but is not a directory."
    echo "Remove or rename ./$path, then run again."
    exit 1
  fi
  mkdir -p "$path"
}

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

set -a
. ./.env
set +a

if [ -z "${VELOCITY_FORWARDING_SECRET:-}" ]; then
  echo "ERROR: VELOCITY_FORWARDING_SECRET is empty in .env"
  exit 1
fi

mkdir -p velocity
printf "%s\n" "$VELOCITY_FORWARDING_SECRET" > velocity/forwarding.secret
echo "Synced velocity/forwarding.secret from .env"

ensure_dir "data"

if [ -f ./scripts/lifecycle/sync-server-properties.sh ]; then
  bash ./scripts/lifecycle/sync-server-properties.sh
fi

if [ -f ./scripts/world-tools/render-fabricproxy-config.sh ]; then
  bash ./scripts/world-tools/render-fabricproxy-config.sh
fi

if [ -f ./scripts/world-tools/prepare-mods.sh ]; then
  bash ./scripts/world-tools/prepare-mods.sh
elif [ -f ./scripts/prepare-mods.sh ]; then
  bash ./scripts/prepare-mods.sh
else
  echo "ERROR: prepare-mods.sh not found. Expected ./scripts/world-tools/prepare-mods.sh or ./scripts/prepare-mods.sh"
  exit 1
fi
docker compose up -d


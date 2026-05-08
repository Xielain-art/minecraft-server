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

if [ ! -f velocity/forwarding.secret ]; then
  cp velocity/forwarding.secret.example velocity/forwarding.secret
  echo "Created velocity/forwarding.secret from example"
fi

ensure_dir "data"

if [ -x ./scripts/world/prepare-mods.sh ]; then
  ./scripts/world/prepare-mods.sh
elif [ -x ./scripts/prepare-mods.sh ]; then
  ./scripts/prepare-mods.sh
else
  echo "ERROR: prepare-mods.sh not found. Expected ./scripts/world/prepare-mods.sh or ./scripts/prepare-mods.sh"
  exit 1
fi
docker compose up -d

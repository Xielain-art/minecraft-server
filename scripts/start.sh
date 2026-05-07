#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

ensure_dir() {
  local path="$1"
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

./scripts/prepare-mods.sh
docker compose up -d

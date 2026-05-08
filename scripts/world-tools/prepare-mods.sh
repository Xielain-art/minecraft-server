#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

SERVERS_READER="scripts/lib/read-servers.py"
PYTHON_BIN="${PYTHON_BIN:-python3}"

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

load_env_file() {
  if [ -f .env ]; then
    set -a
    . ./.env
    set +a
  fi
}

if [ ! -f "$SERVERS_READER" ]; then
  echo "ERROR: $SERVERS_READER not found."
  exit 1
fi

ensure_dir "data"
load_env_file

packwiz_mode="${PACKWIZ_SERVER_MODE:-false}"
manual_overrides="${ENABLE_MANUAL_MOD_OVERRIDES:-false}"

if [ "$packwiz_mode" = "true" ] && [ "$manual_overrides" != "true" ]; then
  echo "PACKWIZ_SERVER_MODE=true, skipping automatic shared/mods copy."
  echo "shared/mods is kept for manual/future overrides."
  exit 0
fi

if [ "$packwiz_mode" = "true" ] && [ "$manual_overrides" = "true" ]; then
  echo "PACKWIZ_SERVER_MODE=true and ENABLE_MANUAL_MOD_OVERRIDES=true."
  echo "Copying manual override mods without deleting packwiz-managed mods."
  echo "Manual mod overrides are enabled. Make sure override jars do not conflict with packwiz-managed mods."
fi

while IFS='|' read -r name container service host port center_x center_z diameter preg_radius preg_enabled gen_map; do
  name="${name//$'\r'/}"
  name="$(echo "$name" | xargs)"

  if [ -z "$name" ] || [[ "$name" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  echo "Preparing mods for $name..."
  ensure_dir "data/$name"
  ensure_dir "data/$name/mods"
  if [ "$packwiz_mode" != "true" ]; then
    rm -f "data/$name/mods"/*.jar
  fi
  cp shared/mods/*.jar "data/$name/mods/" 2>/dev/null || true
  cp "servers/$name/mods"/*.jar "data/$name/mods/" 2>/dev/null || true
  echo "done: data/$name/mods"
done < <("$PYTHON_BIN" "$SERVERS_READER")

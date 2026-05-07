#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

CONFIG_FILE="config/servers.conf"

ensure_dir() {
  local path="$1"
  if [ -e "$path" ] && [ ! -d "$path" ]; then
    echo "ERROR: $path exists but is not a directory."
    echo "Remove or rename ./$path, then run again."
    exit 1
  fi
  mkdir -p "$path"
}

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: config/servers.conf not found."
  exit 1
fi

ensure_dir "data"

while IFS='|' read -r name container service host port center_x center_z diameter preg_radius preg_enabled gen_map; do
  name="${name//$'\r'/}"
  name="$(echo "$name" | xargs)"

  if [ -z "$name" ] || [[ "$name" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  echo "Preparing mods for $name..."
  ensure_dir "data/$name"
  ensure_dir "data/$name/mods"
  rm -f "data/$name/mods"/*.jar
  cp shared/mods/*.jar "data/$name/mods/" 2>/dev/null || true
  cp "servers/$name/mods"/*.jar "data/$name/mods/" 2>/dev/null || true
  echo "done: data/$name/mods"
done < "$CONFIG_FILE"

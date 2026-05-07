#!/bin/bash
set -e

CONFIG_FILE="config/servers.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: config/servers.conf not found."
  exit 1
fi

while IFS='|' read -r name container service host port center_x center_z diameter preg_radius preg_enabled gen_map; do
  name="${name//$'\r'/}"
  name="$(echo "$name" | xargs)"

  if [ -z "$name" ] || [[ "$name" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  echo "Preparing mods for $name..."
  mkdir -p "data/$name/mods"
  rm -f "data/$name/mods"/*.jar
  cp shared/mods/*.jar "data/$name/mods/" 2>/dev/null || true
  cp "servers/$name/mods"/*.jar "data/$name/mods/" 2>/dev/null || true
  echo "done: data/$name/mods"
done < "$CONFIG_FILE"

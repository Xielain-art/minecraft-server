#!/usr/bin/env bash
set -e

SERVERS=("hub" "island1" "island2" "island3" "island4")

echo "Preparing mods..."

for SERVER in "${SERVERS[@]}"; do
  echo "-> Preparing mods for ${SERVER}"
  mkdir -p "data/${SERVER}/mods"
  rm -f "data/${SERVER}/mods"/*.jar
  cp shared/mods/*.jar "data/${SERVER}/mods/" 2>/dev/null || true
  cp "servers/${SERVER}/mods"/*.jar "data/${SERVER}/mods/" 2>/dev/null || true
  echo "   done: data/${SERVER}/mods"
done

echo "Mods prepared."
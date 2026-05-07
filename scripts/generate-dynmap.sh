#!/bin/bash
set -e

CONFIG_FILE="config/servers.conf"

docker --version >/dev/null

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: config/servers.conf not found."
  exit 1
fi

while IFS='|' read -r name container service host port center_x center_z diameter preg_radius preg_enabled gen_map; do
  name="${name//$'\r'/}"
  container="${container//$'\r'/}"
  gen_map="${gen_map//$'\r'/}"

  name="$(echo "$name" | xargs)"
  container="$(echo "$container" | xargs)"
  gen_map="$(echo "$gen_map" | xargs)"

  if [ -z "$name" ] || [[ "$name" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  if [ "$gen_map" != "true" ]; then
    echo "Skipping dynmap fullrender for $name because gen_map=false."
    continue
  fi

  if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
    echo "ERROR: Container $container for server $name is not running."
    echo "Start the network first: ./scripts/start.sh"
    exit 1
  fi

  if ! docker exec "$container" rcon-cli "dynmap fullrender" >/dev/null 2>&1; then
    echo "ERROR: Dynmap command failed on $container ($name)."
    echo "Make sure Dynmap Fabric jar is installed and RCON is working, then try again."
    exit 1
  fi

  echo "Started dynmap fullrender for $name."
done < "$CONFIG_FILE"

echo "Dynmap fullrender started for configured servers."
echo "Use docker logs -f <container> to monitor progress."
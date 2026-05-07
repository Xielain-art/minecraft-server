#!/bin/bash
set -e

CONFIG_FILE="config/servers.conf"

docker --version >/dev/null

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: config/servers.conf not found."
  exit 1
fi

while IFS='|' read -r name container service host port center_x center_z diameter preg_radius preg_enabled; do
  name="${name//$'\r'/}"
  container="${container//$'\r'/}"
  center_x="${center_x//$'\r'/}"
  center_z="${center_z//$'\r'/}"
  preg_radius="${preg_radius//$'\r'/}"
  preg_enabled="${preg_enabled//$'\r'/}"

  name="$(echo "$name" | xargs)"
  container="$(echo "$container" | xargs)"
  center_x="$(echo "$center_x" | xargs)"
  center_z="$(echo "$center_z" | xargs)"
  preg_radius="$(echo "$preg_radius" | xargs)"
  preg_enabled="$(echo "$preg_enabled" | xargs)"

  if [ -z "$name" ] || [[ "$name" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  if [ "$preg_enabled" != "true" ]; then
    echo "Skipping pregeneration for $name because pregeneration_enabled=false."
    continue
  fi

  if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
    echo "ERROR: Container $container for server $name is not running."
    echo "Start the network first: ./scripts/start.sh"
    exit 1
  fi

  if ! docker exec "$container" rcon-cli "chunky help" >/dev/null 2>&1; then
    echo "ERROR: Chunky does not seem to be installed on $container ($name)."
    echo "Put Chunky Fabric jar into shared/mods/, run ./scripts/restart.sh, and try again."
    exit 1
  fi

  echo "Starting pregeneration for $name..."
  echo "center: $center_x $center_z"
  echo "radius: $preg_radius"

  docker exec "$container" rcon-cli "chunky center $center_x $center_z"
  docker exec "$container" rcon-cli "chunky radius $preg_radius"
  docker exec "$container" rcon-cli "chunky start"

  echo "done."
done < "$CONFIG_FILE"

echo "Chunk pregeneration started for configured servers."
echo "Use docker logs -f <container> to monitor progress."

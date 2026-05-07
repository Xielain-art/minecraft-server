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
  diameter="${diameter//$'\r'/}"

  name="$(echo "$name" | xargs)"
  container="$(echo "$container" | xargs)"
  center_x="$(echo "$center_x" | xargs)"
  center_z="$(echo "$center_z" | xargs)"
  diameter="$(echo "$diameter" | xargs)"

  if [ -z "$name" ] || [[ "$name" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
    echo "ERROR: Container $container for server $name is not running."
    echo "Start the network first: ./scripts/start.sh"
    exit 1
  fi

  radius=$((diameter / 2))

  echo "Setting worldborder for $name..."
  echo "center: $center_x $center_z"
  echo "diameter: $diameter"
  echo "radius: $radius"

  docker exec "$container" rcon-cli "worldborder center $center_x $center_z"
  docker exec "$container" rcon-cli "worldborder set $diameter"

  echo "done."
done < "$CONFIG_FILE"

echo "World borders configured successfully."

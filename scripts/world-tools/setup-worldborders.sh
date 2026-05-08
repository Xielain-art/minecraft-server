#!/bin/bash
set -e

SERVERS_READER="scripts/lib/read-servers.py"
PYTHON_BIN="${PYTHON_BIN:-python3}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "setup-worldborders: starting..."
docker --version >/dev/null

if [ ! -f "$SERVERS_READER" ]; then
  echo "ERROR: $SERVERS_READER not found."
  exit 1
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "ERROR: $PYTHON_BIN not found."
  exit 1
fi

rows=0
while IFS='|' read -r name container service host port center_x center_z diameter preg_radius preg_enabled gen_map; do
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
  rows=$((rows + 1))

  if ! docker ps --format '{{.Names}}' | grep -qx "$container"; then
    echo "ERROR: Container $container for server $name is not running."
    echo "Start the network first: ./scripts/lifecycle/start.sh"
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
done < <("$PYTHON_BIN" "$SERVERS_READER")

if [ "$rows" -eq 0 ]; then
  echo "WARNING: No backend servers found in config/servers.json or config/servers.conf."
fi

echo "World borders configured successfully."

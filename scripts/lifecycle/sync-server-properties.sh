#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

set -a
. ./.env
set +a

MC_ONLINE_MODE="${MC_ONLINE_MODE:-false}"
MC_ENFORCE_SECURE_PROFILE="${MC_ENFORCE_SECURE_PROFILE:-false}"
MC_SERVER_PORT="${MC_SERVER_PORT:-25565}"
MC_SERVER_IP="${MC_SERVER_IP-}"
MC_PREVENT_PROXY_CONNECTIONS="${MC_PREVENT_PROXY_CONNECTIONS:-false}"
MC_ENABLE_RCON="${MC_ENABLE_RCON:-true}"
MC_RCON_PORT="${MC_RCON_PORT:-25575}"

if [ ! -f ./scripts/lib/read-servers.py ]; then
  echo "ERROR: scripts/lib/read-servers.py not found"
  exit 1
fi

upsert_property() {
  local file="$1"
  local key="$2"
  local value="$3"
  local escaped
  escaped="$(printf '%s' "$value" | sed -e 's/[\\/&]/\\&/g')"
  if grep -q "^${key}=" "$file"; then
    sed -i "s/^${key}=.*/${key}=${escaped}/" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}

while IFS='|' read -r SERVER _; do
  [ -z "$SERVER" ] && continue
  DATA_DIR="data/$SERVER"
  PROPS_FILE="$DATA_DIR/server.properties"
  TEMPLATE_FILE="servers/$SERVER/server.properties"

  mkdir -p "$DATA_DIR"

  if [ ! -s "$PROPS_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
      cp "$TEMPLATE_FILE" "$PROPS_FILE"
      echo "Bootstrapped $PROPS_FILE from $TEMPLATE_FILE"
    else
      touch "$PROPS_FILE"
      echo "WARN: template $TEMPLATE_FILE not found; created empty $PROPS_FILE"
    fi
  fi

  upsert_property "$PROPS_FILE" "online-mode" "$MC_ONLINE_MODE"
  upsert_property "$PROPS_FILE" "enforce-secure-profile" "$MC_ENFORCE_SECURE_PROFILE"
  upsert_property "$PROPS_FILE" "server-port" "$MC_SERVER_PORT"
  upsert_property "$PROPS_FILE" "server-ip" "$MC_SERVER_IP"
  upsert_property "$PROPS_FILE" "prevent-proxy-connections" "$MC_PREVENT_PROXY_CONNECTIONS"
  upsert_property "$PROPS_FILE" "enable-rcon" "$MC_ENABLE_RCON"
  upsert_property "$PROPS_FILE" "rcon.port" "$MC_RCON_PORT"

  echo "Synced $PROPS_FILE"
done < <(python3 ./scripts/lib/read-servers.py)

if [ "$(id -u)" -eq 0 ]; then
  chown -R 1000:1000 data/hub data/island1 data/island2 data/island3 data/island4
else
  echo "WARN: skip chown (not root)."
fi

chmod -R u+rwX data/hub data/island1 data/island2 data/island3 data/island4 || \
  echo "WARN: chmod failed for one or more backend data directories."

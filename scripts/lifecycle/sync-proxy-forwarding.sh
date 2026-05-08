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

if [ -z "${VELOCITY_FORWARDING_SECRET:-}" ]; then
  echo "ERROR: VELOCITY_FORWARDING_SECRET is empty in .env"
  exit 1
fi

if [ ! -f ./scripts/lib/read-servers.py ]; then
  echo "ERROR: scripts/lib/read-servers.py not found"
  exit 1
fi

mkdir -p velocity
printf "%s\n" "$VELOCITY_FORWARDING_SECRET" > velocity/forwarding.secret
echo "Synced velocity/forwarding.secret from .env"

while IFS='|' read -r SERVER _; do
  [ -z "$SERVER" ] && continue
  TARGET_DIR="data/$SERVER/config"
  TARGET_FILE="$TARGET_DIR/FabricProxy-Lite.toml"

  mkdir -p "$TARGET_DIR"

  cat > "$TARGET_FILE" <<EOF
hackOnlineMode = ${FABRIC_PROXY_HACK_ONLINE_MODE}
hackEarlySend = ${FABRIC_PROXY_HACK_EARLY_SEND}
hackMessageChain = ${FABRIC_PROXY_HACK_MESSAGE_CHAIN}
disconnectMessage = "${FABRIC_PROXY_DISCONNECT_MESSAGE}"
secret = "${VELOCITY_FORWARDING_SECRET}"
EOF

  echo "Rendered $TARGET_FILE from .env"
done < <(python3 ./scripts/lib/read-servers.py)

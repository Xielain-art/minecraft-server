#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

echo "== Check docker compose config =="
docker compose config >/dev/null

echo "== Sync server config =="
bash ./scripts/lifecycle/sync-server-properties.sh
bash ./scripts/lifecycle/sync-proxy-forwarding.sh

echo "== Restart Minecraft services only =="
docker compose restart \
  velocity \
  hub \
  island1 \
  island2 \
  island3 \
  island4

echo "== Current containers =="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "== Minecraft restart done =="2
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

echo "== Sync configs =="
./scripts/lifecycle/sync-server-properties.sh
./scripts/lifecycle/sync-proxy-forwarding.sh

echo "== Validate compose =="
docker compose config >/dev/null

echo "== Restart Minecraft services only =="
docker compose up -d --no-deps --force-recreate \
  velocity \
  hub \
  island1 \
  island2 \
  island3 \
  island4

echo "== Minecraft deploy done =="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
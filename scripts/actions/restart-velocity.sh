#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

echo "== Check docker compose config =="
docker compose config >/dev/null

echo "== Restart Velocity only =="
docker compose restart velocity

echo "== Velocity status =="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAMES|mc-velocity"

echo "== Velocity logs =="
docker compose logs --tail=80 velocity

echo "== Velocity restart done =="
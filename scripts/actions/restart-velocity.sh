#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

echo "== Check docker compose config =="
docker compose config >/dev/null

echo "== Restart Velocity only =="
docker compose restart velocity

echo "== Wait for Velocity startup =="
sleep 15

echo "== Velocity status =="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAMES|mc-velocity"

echo "== Velocity recent logs =="
docker compose logs --since=2m velocity

echo "== Velocity restart done =="
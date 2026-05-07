#!/usr/bin/env bash
set -e

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

if [ ! -f velocity/forwarding.secret ]; then
  cp velocity/forwarding.secret.example velocity/forwarding.secret
  echo "Created velocity/forwarding.secret from example"
fi

if [ -e "data" ] && [ ! -d "data" ]; then
  echo "ERROR: data exists but is not a directory."
  echo "Remove or rename ./data file, then run again."
  exit 1
fi

./scripts/prepare-mods.sh
docker compose up -d

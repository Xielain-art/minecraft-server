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

./scripts/prepare-mods.sh
docker compose up -d
#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <plain_password> [username]"
  echo "Example: $0 'MyStrongPass123!' paneladmin"
  exit 1
fi

PLAIN_PASSWORD="$1"
PANEL_USER="${2:-paneladmin}"

HASH="$(docker run --rm caddy:2 caddy hash-password --plaintext "$PLAIN_PASSWORD")"

echo "Generated hash:"
echo "$HASH"
echo
echo "Put this into .env:"
echo "PANEL_BASIC_AUTH_USER=$PANEL_USER"
echo "PANEL_BASIC_AUTH_PASSWORD_HASH='$HASH'"

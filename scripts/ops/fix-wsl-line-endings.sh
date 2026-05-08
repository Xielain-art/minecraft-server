#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "Fixing BOM/CRLF for shell scripts..."
find scripts -type f -name "*.sh" -print0 | xargs -0 sed -i '1s/^\xEF\xBB\xBF//'
find scripts -type f -name "*.sh" -print0 | xargs -0 sed -i 's/\r$//'

echo "Fixing CRLF for env files..."
if [ -f .env ]; then
  sed -i 's/\r$//' .env
fi
if [ -f .env.example ]; then
  sed -i 's/\r$//' .env.example
fi

echo "Setting executable bits..."
find scripts -type f -name "*.sh" -exec chmod +x {} \;

echo "Done. You can run:"
echo "./scripts/lifecycle/start-local.sh"

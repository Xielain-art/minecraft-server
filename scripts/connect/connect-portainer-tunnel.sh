#!/usr/bin/env bash
set -e

SERVER_IP="${1:-}"
SSH_USER="${2:-root}"
SSH_PORT="${3:-22}"
LOCAL_PORT="${4:-9443}"

if [ -z "$SERVER_IP" ]; then
  echo "Usage: ./scripts/connect/connect-portainer-tunnel.sh <server_ip> [ssh_user] [ssh_port] [local_port]"
  exit 1
fi

echo "Opening SSH tunnel to ${SSH_USER}@${SERVER_IP} ..."
echo "Portainer URL: https://localhost:${LOCAL_PORT}"
ssh -p "$SSH_PORT" -L "${LOCAL_PORT}:127.0.0.1:9443" "${SSH_USER}@${SERVER_IP}"

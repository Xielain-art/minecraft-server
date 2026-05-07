# Caddy reverse proxy

`caddy/Caddyfile` reads domains/ports/basic-auth from `.env`.
You usually do not need to edit `caddy/Caddyfile` manually.

Required `.env` keys:
- `PUBLIC_DOMAIN`
- `PANEL_DOMAIN`
- `STATUS_DOMAIN`
- `MAP1_DOMAIN`, `MAP2_DOMAIN`, `MAP3_DOMAIN`, `MAP4_DOMAIN`
- `MAP1_PORT`, `MAP2_PORT`, `MAP3_PORT`, `MAP4_PORT`
- `VELOCITY_WEB_API_PORT`
- `PANEL_BASIC_AUTH_USER`
- `PANEL_BASIC_AUTH_PASSWORD_HASH`

Generate `PANEL_BASIC_AUTH_PASSWORD_HASH` with helper script:

```bash
./scripts/caddy/generate-password-hash.sh 'YOUR_STRONG_PASSWORD' paneladmin
```

## What is proxied

- `panel.<domain>` -> `portainer:9443` (+ Caddy `basic_auth`)
- `status.<domain>` -> `velocity:${VELOCITY_WEB_API_PORT}`
- `map1..map4.<domain>` -> `host.docker.internal:${MAP1_PORT}..${MAP4_PORT}`
- Fallback paths on root domain:
  - `/panel`
  - `/status`
  - `/maps/map1`
  - `/maps/map2`
  - `/maps/map3`
  - `/maps/map4`

## Map upstream notes

- If map services run on VPS host, keep `host.docker.internal`.
- If map services run in Compose services, replace with service names (`map1-service:8153`, etc.).
- If map services run in Minecraft containers, use actual backend hostnames and ports (for example `hub:8153`, `island1:8154`, `island2:8155`, `island3:8156`).

## Important

- Minecraft Java traffic is NOT proxied by Caddy.
- Players connect to Velocity TCP `25565`.
- `extra_hosts: host.docker.internal:host-gateway` is required in Caddy service on Linux Docker.
- Caddy `basic_auth` requires hashed password, not plaintext. Put hash in `.env` as `PANEL_BASIC_AUTH_PASSWORD_HASH`.

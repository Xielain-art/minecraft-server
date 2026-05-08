# Caddy reverse proxy

Mode split:
- Production: `caddy/Caddyfile` + `docker-compose.yml`
- Local: `caddy/Caddyfile.local` + `docker-compose.local.yml`

`caddy/Caddyfile` reads values from `.env`.

Required `.env` keys:
- `PUBLIC_DOMAIN`
- `STATUS_DOMAIN`
- `MAP1_DOMAIN`, `MAP2_DOMAIN`, `MAP3_DOMAIN`, `MAP4_DOMAIN`
- `MAP1_PORT`, `MAP2_PORT`, `MAP3_PORT`, `MAP4_PORT`
- `VELOCITY_WEB_API_PORT`

What is proxied:
- `status.<domain>` -> `velocity:${VELOCITY_WEB_API_PORT}`
- `map1..map4.<domain>` -> `host.docker.internal:${MAP1_PORT}..${MAP4_PORT}`
- root fallback:
  - `/status`
  - `/maps/map1`
  - `/maps/map2`
  - `/maps/map3`
  - `/maps/map4`

Important:
- Minecraft Java traffic is NOT proxied by Caddy.
- Players connect to Velocity TCP `25565`.
- Portainer is NOT proxied by Caddy.

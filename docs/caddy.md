# Caddy (prod + local)

## Роль Caddy

Caddy проксирует только HTTP/HTTPS сервисы:
- `status` (Velocity Web API)
- `map1..map4`

Minecraft protocol Caddy не проксирует. Игроки идут в Velocity `:25565`.

## Production

- Файл: `caddy/Caddyfile`
- Домены/порты берутся из `.env`
- Порты Caddy: `80`, `443`
- Portainer через Caddy не проксируется

## Local

- Файл: `caddy/Caddyfile.local`
- Поднимается через `docker-compose.local.yml`
- Порты: `8080`, `8081`, `8153..8156`

## Portainer

Portainer работает отдельно от Caddy:
- local: `https://localhost:9443`
- prod: только через SSH tunnel на `https://localhost:9443`

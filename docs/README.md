# Документация проекта

## Быстрый выбор

- Локальный запуск: [docs/local.md](/C:/Users/user/test/minecraft-server/docs/local.md)
- Запуск на VPS: [docs/vps.md](/C:/Users/user/test/minecraft-server/docs/vps.md)
- Конфиг backend-серверов (`servers.json`): [docs/servers-json.md](/C:/Users/user/test/minecraft-server/docs/servers-json.md)
- Caddy (prod + local): [docs/caddy.md](/C:/Users/user/test/minecraft-server/docs/caddy.md)

## Ключевая идея

- Один репозиторий для двух режимов:
- `./scripts/start.sh` -> обычный (VPS/prod-like), `docker-compose.yml`
- `./scripts/start-local.sh` -> локальный, `docker-compose.yml + docker-compose.local.yml`

Minecraft-трафик всегда идет напрямую в Velocity на `25565`. Caddy проксирует только веб-сервисы.

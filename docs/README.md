# Документация проекта

## Быстрый выбор

- Локальный запуск: [docs/local.md](/C:/Users/user/test/minecraft-server/docs/local.md)
- Запуск на VPS: [docs/vps.md](/C:/Users/user/test/minecraft-server/docs/vps.md)
- Конфиг backend-серверов (`servers.json`): [docs/servers-json.md](/C:/Users/user/test/minecraft-server/docs/servers-json.md)
- Caddy (prod + local): [docs/caddy.md](/C:/Users/user/test/minecraft-server/docs/caddy.md)

## Меню скриптов

Запуск единого меню:

```bash
./scripts/menu.sh
```

Логика меню:
- шаг 1: выбрать папку/категорию (`lifecycle`, `world`, `ops`, `connect`, `caddy`)
- шаг 2: выбрать скрипт внутри выбранной папки
- перед запуском можно ввести аргументы; для известных скриптов меню показывает короткий hint по параметрам

## Ключевая идея

- Один репозиторий для двух режимов:
- `./scripts/lifecycle/start.sh` -> обычный (VPS/prod-like), `docker-compose.yml`
- `./scripts/lifecycle/start-local.sh` -> локальный, `docker-compose.yml + docker-compose.local.yml`

## Структура scripts

- `scripts/lifecycle/` -> start/stop/restart/hard-restart
- `scripts/world/` -> mods, worldborder, pregenerate, dynmap
- `scripts/ops/` -> logs/status
- `scripts/connect/` -> SSH/доступ (постепенно переносим сюда)
- `scripts/caddy/` -> caddy утилиты

Примечание:
- Старые пути в `scripts/*.sh` сохранены как wrapper для совместимости.

Minecraft-трафик всегда идет напрямую в Velocity на `25565`. Caddy проксирует только веб-сервисы.


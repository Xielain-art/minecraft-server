# Конфиг backend-серверов: `config/servers.json`

## Источник правды

Скрипты читают сервера из `config/servers.json` через `scripts/lib/read-servers.py`.
Fallback на `config/servers.conf` сохранен для обратной совместимости, но основной формат теперь JSON.

## Формат

Массив объектов:

```json
[
  {
    "name": "hub",
    "container": "mc-hub",
    "service": "hub",
    "host": "hub",
    "port": 25565,
    "worldborder_center_x": 0,
    "worldborder_center_z": 0,
    "worldborder_diameter": 1000,
    "pregeneration_radius": 500,
    "pregeneration_enabled": true,
    "gen_map": true
  }
]
```

## Где используется

- `scripts/world/prepare-mods.sh`
- `scripts/world/setup-worldborders.sh`
- `scripts/world/pregenerate-worlds.sh`
- `scripts/world/generate-dynmap.sh`

## Добавление нового backend-сервера

1. Добавить service в `docker-compose.yml`.
2. Добавить backend в `velocity/velocity.toml`.
3. Создать `servers/<name>/mods`, `servers/<name>/config`, `servers/<name>/server.properties`.
4. Добавить объект в `config/servers.json`.
5. Выполнить `./scripts/lifecycle/restart.sh`.


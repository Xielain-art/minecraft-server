# ÐšÐ¾Ð½Ñ„Ð¸Ð³ backend-ÑÐµÑ€Ð²ÐµÑ€Ð¾Ð²: `config/servers.json`

## Ð˜ÑÑ‚Ð¾Ñ‡Ð½Ð¸Ðº Ð¿Ñ€Ð°Ð²Ð´Ñ‹

Ð¡ÐºÑ€Ð¸Ð¿Ñ‚Ñ‹ Ñ‡Ð¸Ñ‚Ð°ÑŽÑ‚ ÑÐµÑ€Ð²ÐµÑ€Ð° Ð¸Ð· `config/servers.json` Ñ‡ÐµÑ€ÐµÐ· `scripts/lib/read-servers.py`.
Fallback Ð½Ð° `config/servers.conf` ÑÐ¾Ñ…Ñ€Ð°Ð½ÐµÐ½ Ð´Ð»Ñ Ð¾Ð±Ñ€Ð°Ñ‚Ð½Ð¾Ð¹ ÑÐ¾Ð²Ð¼ÐµÑÑ‚Ð¸Ð¼Ð¾ÑÑ‚Ð¸, Ð½Ð¾ Ð¾ÑÐ½Ð¾Ð²Ð½Ð¾Ð¹ Ñ„Ð¾Ñ€Ð¼Ð°Ñ‚ Ñ‚ÐµÐ¿ÐµÑ€ÑŒ JSON.

## Ð¤Ð¾Ñ€Ð¼Ð°Ñ‚

ÐœÐ°ÑÑÐ¸Ð² Ð¾Ð±ÑŠÐµÐºÑ‚Ð¾Ð²:

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

## Ð“Ð´Ðµ Ð¸ÑÐ¿Ð¾Ð»ÑŒÐ·ÑƒÐµÑ‚ÑÑ

- `scripts/world-tools/prepare-mods.sh`
- `scripts/world-tools/setup-worldborders.sh`
- `scripts/world-tools/pregenerate-worlds.sh`
- `scripts/world-tools/generate-dynmap.sh`

## Ð”Ð¾Ð±Ð°Ð²Ð»ÐµÐ½Ð¸Ðµ Ð½Ð¾Ð²Ð¾Ð³Ð¾ backend-ÑÐµÑ€Ð²ÐµÑ€Ð°

1. Ð”Ð¾Ð±Ð°Ð²Ð¸Ñ‚ÑŒ service Ð² `docker-compose.yml`.
2. Ð”Ð¾Ð±Ð°Ð²Ð¸Ñ‚ÑŒ backend Ð² `velocity/velocity.toml`.
3. Ð¡Ð¾Ð·Ð´Ð°Ñ‚ÑŒ `servers/<name>/mods`, `servers/<name>/config`, `servers/<name>/server.properties`.
4. Ð”Ð¾Ð±Ð°Ð²Ð¸Ñ‚ÑŒ Ð¾Ð±ÑŠÐµÐºÑ‚ Ð² `config/servers.json`.
5. Ð’Ñ‹Ð¿Ð¾Ð»Ð½Ð¸Ñ‚ÑŒ `./scripts/lifecycle/restart.sh`.




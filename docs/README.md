# Ð”Ð¾ÐºÑƒÐ¼ÐµÐ½Ñ‚Ð°Ñ†Ð¸Ñ Ð¿Ñ€Ð¾ÐµÐºÑ‚Ð°

## Ð‘Ñ‹ÑÑ‚Ñ€Ñ‹Ð¹ Ð²Ñ‹Ð±Ð¾Ñ€

- Ð›Ð¾ÐºÐ°Ð»ÑŒÐ½Ñ‹Ð¹ Ð·Ð°Ð¿ÑƒÑÐº: [docs/local.md](/C:/Users/user/test/minecraft-server/docs/local.md)
- Ð—Ð°Ð¿ÑƒÑÐº Ð½Ð° VPS: [docs/vps.md](/C:/Users/user/test/minecraft-server/docs/vps.md)
- ÐšÐ¾Ð½Ñ„Ð¸Ð³ backend-ÑÐµÑ€Ð²ÐµÑ€Ð¾Ð² (`servers.json`): [docs/servers-json.md](/C:/Users/user/test/minecraft-server/docs/servers-json.md)
- Caddy (prod + local): [docs/caddy.md](/C:/Users/user/test/minecraft-server/docs/caddy.md)

## ÐœÐµÐ½ÑŽ ÑÐºÑ€Ð¸Ð¿Ñ‚Ð¾Ð²

Ð—Ð°Ð¿ÑƒÑÐº ÐµÐ´Ð¸Ð½Ð¾Ð³Ð¾ Ð¼ÐµÐ½ÑŽ:

```bash
./scripts/menu.sh
```

Ð›Ð¾Ð³Ð¸ÐºÐ° Ð¼ÐµÐ½ÑŽ:
- ÑˆÐ°Ð³ 1: Ð²Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ Ð¿Ð°Ð¿ÐºÑƒ/ÐºÐ°Ñ‚ÐµÐ³Ð¾Ñ€Ð¸ÑŽ (`lifecycle`, `world`, `ops`, `connect`, `caddy`)
- ÑˆÐ°Ð³ 2: Ð²Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ ÑÐºÑ€Ð¸Ð¿Ñ‚ Ð²Ð½ÑƒÑ‚Ñ€Ð¸ Ð²Ñ‹Ð±Ñ€Ð°Ð½Ð½Ð¾Ð¹ Ð¿Ð°Ð¿ÐºÐ¸
- Ð¿ÐµÑ€ÐµÐ´ Ð·Ð°Ð¿ÑƒÑÐºÐ¾Ð¼ Ð¼Ð¾Ð¶Ð½Ð¾ Ð²Ð²ÐµÑÑ‚Ð¸ Ð°Ñ€Ð³ÑƒÐ¼ÐµÐ½Ñ‚Ñ‹; Ð´Ð»Ñ Ð¸Ð·Ð²ÐµÑÑ‚Ð½Ñ‹Ñ… ÑÐºÑ€Ð¸Ð¿Ñ‚Ð¾Ð² Ð¼ÐµÐ½ÑŽ Ð¿Ð¾ÐºÐ°Ð·Ñ‹Ð²Ð°ÐµÑ‚ ÐºÐ¾Ñ€Ð¾Ñ‚ÐºÐ¸Ð¹ hint Ð¿Ð¾ Ð¿Ð°Ñ€Ð°Ð¼ÐµÑ‚Ñ€Ð°Ð¼

## ÐšÐ»ÑŽÑ‡ÐµÐ²Ð°Ñ Ð¸Ð´ÐµÑ

- ÐžÐ´Ð¸Ð½ Ñ€ÐµÐ¿Ð¾Ð·Ð¸Ñ‚Ð¾Ñ€Ð¸Ð¹ Ð´Ð»Ñ Ð´Ð²ÑƒÑ… Ñ€ÐµÐ¶Ð¸Ð¼Ð¾Ð²:
- `./scripts/lifecycle/start.sh` -> Ð¾Ð±Ñ‹Ñ‡Ð½Ñ‹Ð¹ (VPS/prod-like), `docker-compose.yml`
- `./scripts/lifecycle/start-local.sh` -> Ð»Ð¾ÐºÐ°Ð»ÑŒÐ½Ñ‹Ð¹, `docker-compose.yml + docker-compose.local.yml`

## Ð¡Ñ‚Ñ€ÑƒÐºÑ‚ÑƒÑ€Ð° scripts

- `scripts/lifecycle/` -> start/stop/restart/hard-restart
- `scripts/world-tools/` -> mods, worldborder, pregenerate, dynmap
- `scripts/ops/` -> logs/status
- `scripts/connect/` -> SSH/Ð´Ð¾ÑÑ‚ÑƒÐ¿ (Ð¿Ð¾ÑÑ‚ÐµÐ¿ÐµÐ½Ð½Ð¾ Ð¿ÐµÑ€ÐµÐ½Ð¾ÑÐ¸Ð¼ ÑÑŽÐ´Ð°)
- `scripts/caddy/` -> caddy ÑƒÑ‚Ð¸Ð»Ð¸Ñ‚Ñ‹

ÐŸÑ€Ð¸Ð¼ÐµÑ‡Ð°Ð½Ð¸Ðµ:
- Ð¡Ñ‚Ð°Ñ€Ñ‹Ðµ Ð¿ÑƒÑ‚Ð¸ Ð² `scripts/*.sh` ÑÐ¾Ñ…Ñ€Ð°Ð½ÐµÐ½Ñ‹ ÐºÐ°Ðº wrapper Ð´Ð»Ñ ÑÐ¾Ð²Ð¼ÐµÑÑ‚Ð¸Ð¼Ð¾ÑÑ‚Ð¸.

Minecraft-Ñ‚Ñ€Ð°Ñ„Ð¸Ðº Ð²ÑÐµÐ³Ð´Ð° Ð¸Ð´ÐµÑ‚ Ð½Ð°Ð¿Ñ€ÑÐ¼ÑƒÑŽ Ð² Velocity Ð½Ð° `25565`. Caddy Ð¿Ñ€Ð¾ÐºÑÐ¸Ñ€ÑƒÐµÑ‚ Ñ‚Ð¾Ð»ÑŒÐºÐ¾ Ð²ÐµÐ±-ÑÐµÑ€Ð²Ð¸ÑÑ‹.




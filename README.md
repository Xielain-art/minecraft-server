# Minecraft Network (Velocity + Fabric)

Переносимая Minecraft-сеть на Docker Compose:
- `velocity` + `hub` + `island1/island2/island3/island4`
- Minecraft `1.20.1`, Fabric, Java 17

Архитектура:

`Player -> Velocity :25565 -> hub -> island1/island2/island3/island4`

`hub` — стартовый сервер: игрок заходит, читает инфо проекта, выбирает остров.

## Документация

- Общий индекс: [docs/README.md](/C:/Users/user/test/minecraft-server/docs/README.md)
- Локальный запуск: [docs/local.md](/C:/Users/user/test/minecraft-server/docs/local.md)
- VPS запуск: [docs/vps.md](/C:/Users/user/test/minecraft-server/docs/vps.md)
- `servers.json`: [docs/servers-json.md](/C:/Users/user/test/minecraft-server/docs/servers-json.md)
- Caddy режимы: [docs/caddy.md](/C:/Users/user/test/minecraft-server/docs/caddy.md)

## Где лежат моды

- Общие моды: `shared/mods/`
- Сервер-специфичные моды: `servers/<SERVER>/mods/`

## Запуск на новой VPS

```bash
git clone <repo>
cd minecraft-network
cp .env.example .env
cp velocity/forwarding.secret.example velocity/forwarding.secret
nano velocity/forwarding.secret
chmod +x scripts/*.sh
./scripts/start.sh
```

Логи:

```bash
./scripts/logs.sh
```

Остановка:

```bash
./scripts/stop.sh
```

Перезапуск после добавления модов:

```bash
git pull
./scripts/restart.sh
```

## Локальный запуск

```bash
./scripts/start-local.sh
```

Portainer локально:
- `https://localhost:9443`

Portainer на VPS (через SSH tunnel, рекомендовано):

```powershell
.\scripts\connect-portainer-tunnel.ps1 -ServerIp SERVER_IP
```

```bash
./scripts/connect-portainer-tunnel.sh SERVER_IP
```

## Порты

Публично открывать на VPS:
- `TCP 25565` (Minecraft)
- обычно также `22`, `80`, `443` для SSH/HTTPS инфраструктуры

Backend Minecraft-сервера публично не открывать.

## Важные примечания

- `data/` не хранится в Git.
- В `data/` находятся миры, логи, playerdata, runtime-файлы.
- MVP использует `player-info-forwarding-mode = "none"`.
- Для production нужен secure forwarding (`modern` + совместимый стек).
- В MVP игрок всегда сначала попадает в `hub`.
- Возврат на последний остров после релога требует Velocity Last Server/Reconnect plugin (или кастомный плагин).

## Ресурсы

- Минимум: `4 vCPU / 16 GB RAM / 50 GB SSD`
- RAM по умолчанию:
- Velocity `512m`
- Hub `2G`
- Каждый island `3G`
- Если RAM мало: уменьшить `ISLAND_MEMORY` до `2G`.

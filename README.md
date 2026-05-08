# Minecraft Network (Velocity + Fabric)

Переносимая Minecraft-сеть на Docker Compose:
- `velocity` + `hub` + `island1/island2/island3/island4`
- Minecraft `1.20.1`, Fabric, Java 17

Архитектура:

`Player -> Velocity :25565 -> hub -> island1/island2/island3/island4`

`hub` — стартовый сервер: игрок заходит, читает информацию о проекте, выбирает остров.

## Документация

- Общий индекс: `docs/README.md`
- Локальный запуск: `docs/local.md`
- VPS запуск: `docs/vps.md`
- `servers.json`: `docs/servers-json.md`
- Caddy режимы: `docs/caddy.md`

## Где лежат моды

- Общие legacy/override моды: `shared/mods/`
- Сервер-специфичные legacy/override моды: `servers/<SERVER>/mods/`
- Основной источник серверных модов: `packs/server/`

## Packwiz для серверных модов

В репозиторий добавлен единый server packwiz-пак для backend Fabric серверов.

- Все backend Fabric серверы используют один URL: `SERVER_PACKWIZ_URL`
- Пак находится в `packs/server/pack.toml`
- Пак хостится через GitHub Pages
- Velocity не использует packwiz
- Плагины Velocity по-прежнему кладутся в `velocity/plugins/`
- Fabric backend моды в штатном режиме ведутся через `packs/server/`

Пример `.env`:

```env
SERVER_PACKWIZ_URL=https://xielain-art.github.io/minecraft-server/packs/server/pack.toml
PACKWIZ_SERVER_MODE=true
ENABLE_MANUAL_MOD_OVERRIDES=false
```

## GitHub Pages для packwiz

Для хостинга packwiz metadata используется GitHub Pages.

- Caddy/VPS не должен раздавать packwiz-файлы
- Репозиторий: `Xielain-art/minecraft-server`

Как включить:
1. Открыть GitHub репозиторий `Xielain-art/minecraft-server`
2. Открыть `Settings -> Pages`
3. Выбрать `Source: Deploy from a branch`
4. Выбрать `Branch: main`
5. Выбрать `Folder: /root`
6. Нажать `Save`

Production URL:

```text
https://xielain-art.github.io/minecraft-server/packs/server/pack.toml
```

Проверка:

```bash
curl https://xielain-art.github.io/minecraft-server/packs/server/pack.toml
```

Примечания:
- GitHub Pages бесплатен для публичных репозиториев на GitHub Free
- Есть лимиты на размер/трафик
- Для MVP packwiz metadata маленькие, этого достаточно
- Не коммитить большие `.jar` без необходимости
- Для основных модов предпочитать packwiz metadata + Modrinth/CurseForge/GitHub Releases/CDN URL
- Для приватных/кастомных jar использовать GitHub Releases/CDN/direct HTTPS + sha256 в `.pw.toml`

## Почему один server pack на все backend-сервера

Игроки перемещаются между backend-серверами через Velocity, поэтому набор контент-модов должен быть одинаковым на всех backend-серверах.

Иначе можно сломать:
- инвентари
- item/block registries
- entities
- dimensions
- playerdata
- network packets

Поэтому используется один общий server pack.

## Legacy и override режим shared/mods

`shared/mods` и `servers/<server>/mods` сохранены намеренно.

- Эти каталоги не удаляются
- Это legacy/manual/override режим
- При `PACKWIZ_SERVER_MODE=true` и `ENABLE_MANUAL_MOD_OVERRIDES=false`:
  `scripts/world-tools/prepare-mods.sh` пропускает копирование ручных модов, packwiz остается единственным автоматическим источником
- При `PACKWIZ_SERVER_MODE=true` и `ENABLE_MANUAL_MOD_OVERRIDES=true`:
  моды из `shared/mods` и `servers/<server>/mods` копируются поверх packwiz-модов без удаления уже скачанных packwiz `.jar`
- При `PACKWIZ_SERVER_MODE=false`:
  работает старое поведение с `shared/mods`

Production-режим: предпочитать packwiz. Не смешивать режимы без понимания последствий.

## Как добавить серверный мод через packwiz

```bash
cd packs/server
packwiz modrinth install fabric-api
packwiz modrinth install chunky
packwiz modrinth install lithium
packwiz refresh
```

Для CurseForge:

```bash
packwiz curseforge install <mod>
```

Обновление всего пака:

```bash
packwiz update --all
packwiz refresh
```

Пример прямой загрузки кастомного мода (`.pw.toml`):

```toml
name = "Gerbarium Core"
filename = "gerbarium-core-1.0.0.jar"
side = "both"

[download]
url = "https://example.com/mods/gerbarium-core-1.0.0.jar"
hash-format = "sha256"
hash = "<sha256>"
```

Как посчитать sha256:

Linux:

```bash
sha256sum gerbarium-core-1.0.0.jar
```

Windows PowerShell:

```powershell
Get-FileHash .\gerbarium-core-1.0.0.jar -Algorithm SHA256
```

## Как проверить packwiz URL

Локально:

```bash
cd packs/server
python -m http.server 8080
```

URL:

```text
http://localhost:8080/pack.toml
```

Production через GitHub Pages:

```text
https://xielain-art.github.io/minecraft-server/packs/server/pack.toml
```

## Запуск на новой VPS

```bash
git clone <repo>
cd minecraft-network
cp .env.example .env
cp velocity/forwarding.secret.example velocity/forwarding.secret
nano velocity/forwarding.secret
sed -i 's/\r$//' scripts/*.sh
find scripts -name "*.sh" -exec chmod +x {} \;
./scripts/lifecycle/start.sh
```

Логи:

```bash
./scripts/ops/logs.sh
```

Остановка:

```bash
./scripts/lifecycle/stop.sh
```

Перезапуск:

```bash
git pull
./scripts/lifecycle/restart.sh
```

## Что открыть в firewall

Public:
- TCP 22 (SSH)
- TCP 80 (Caddy HTTP)
- TCP 443 (Caddy HTTPS)
- TCP 25565 (Velocity Minecraft)

Не открывать публично:
- RCON 25575
- backend server ports
- 9443 Portainer (кроме debug)
- 25576 Velocity Web API (кроме debug)
- 8153-8156 map ports (кроме debug)

## Важные примечания

- `data/` не хранится в Git
- В `data/` лежат миры, логи, playerdata, runtime-файлы
- MVP использует `player-info-forwarding-mode = "none"`
- Для production нужен secure forwarding
- В MVP игрок сначала попадает в `hub`
- Возврат на последний остров после релога требует Velocity Last Server/Reconnect plugin (или кастомный плагин)
- Минимум ресурсов: `4 vCPU / 16 GB RAM / 50 GB SSD`
- RAM по умолчанию: Velocity `512m`, Hub `2G`, каждый island `3G`
- Если RAM мало, уменьшить `ISLAND_MEMORY` до `2G`



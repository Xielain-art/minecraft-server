# Minecraft Network (Velocity + Fabric)

Этот репозиторий содержит переносимую Minecraft-сеть на Docker Compose: **Velocity + Hub + 4 Fabric 1.20.1 сервера-острова**.

## Архитектура

Поток подключения:

Игрок -> Velocity `:25565` -> `hub` -> `island1` / `island2` / `island3` / `island4`

- `velocity` — единственная публичная точка входа.
- Backend-сервера (`hub`, `island1..4`) работают только во внутренней Docker-сети.
- `caddy` — reverse proxy только для HTTP/HTTPS веб-сервисов (не для Minecraft TCP).
- В MVP вход игроков всегда через `hub` (`try = ["hub"]`).

## Что такое Hub

`hub` — стартовый сервер-лобби, где игрок:
- знакомится с проектом;
- читает правила;
- выбирает стартовый остров;
- может вернуться к выбору островов.

## Моды

Общие моды для всех backend-серверов:
- `shared/mods/`

Уникальные моды по серверам:
- `servers/hub/mods/`
- `servers/island1/mods/`
- `servers/island2/mods/`
- `servers/island3/mods/`
- `servers/island4/mods/`

Перед запуском скрипт `scripts/prepare-mods.sh` собирает итоговые моды в runtime-папки `data/<server>/mods`.

## Конфигурация серверов

Backend-сервера описываются в `config/servers.json`. Скрипты не хардкодят `island1/island2/island3/island4` и работают по данным из этого файла.

Формат записи (JSON object):

`name, container, service, host, port, worldborder_center_x, worldborder_center_z, worldborder_diameter, pregeneration_radius, pregeneration_enabled, gen_map`

Пример:

`{"name":"forest","container":"mc-forest","service":"forest","host":"forest","port":25565,"worldborder_center_x":0,"worldborder_center_z":0,"worldborder_diameter":10000,"pregeneration_radius":5000,"pregeneration_enabled":true,"gen_map":true}`

Чтобы добавить новый backend-сервер:
1. Добавить `service` в `docker-compose.yml`.
2. Добавить backend в `velocity/velocity.toml`.
3. Создать `servers/<server-name>/mods/` и `servers/<server-name>/config/`.
4. Добавить объект в массив `config/servers.json`.
5. Запустить `./scripts/restart.sh`.

## Mods vs Plugins

- Velocity plugins размещаются в `velocity/plugins/`.
- Fabric mods размещаются в `shared/mods/` или `servers/<server-name>/mods/`.
- Velocity Web API — это Velocity plugin.
- Будущий launcher auth plugin — это Velocity plugin.
- Fabric API, Chunky, Lithium, FerriteCore, Krypton, ModernFix — это Fabric mods.
- LuckPerms имеет разные сборки:
- LuckPerms Velocity plugin идет в `velocity/plugins/`.
- LuckPerms Fabric mod идет в `shared/mods/` или `servers/<server-name>/mods/`.
- Нельзя класть Fabric mods в `velocity/plugins/`.
- Нельзя класть Velocity plugins в `shared/mods/`.

## Worldborder and pregeneration

- Worldborder ограничивает размер мира.
- `worldborder set` использует диаметр, не радиус.
- Chunky pregeneration использует радиус.
- Значения берутся из `config/servers.json`.
- Запуск:

```bash
./scripts/setup-worldborders.sh
./scripts/pregenerate-worlds.sh
```

- Перед pregeneration нужно вручную положить Chunky в `shared/mods/`.
- На слабом VPS не запускайте pregeneration для многих больших миров одновременно.
- Чтобы отключить pregeneration для сервера, установите `pregeneration_enabled=false`.

## Запуск на новой VPS

```bash
git clone <repo>
cd minecraft-network
cp .env.example .env
cp velocity/forwarding.secret.example velocity/forwarding.secret
nano velocity/forwarding.secret
chmod +x scripts/*.sh scripts/caddy/*.sh
./scripts/start.sh
```

## Полезные команды

```bash
./scripts/logs.sh      # логи
./scripts/stop.sh      # остановка
./scripts/restart.sh   # перезапуск (после добавления модов)
```

После обновления:

```bash
git pull
./scripts/restart.sh
```

## Reverse proxy через Caddy

- Caddy проксирует только веб-сервисы (HTTP/HTTPS).
- Minecraft-трафик Velocity остается прямым TCP `25565`.
- Velocity Web API доступен через Caddy (`status`).
- Portainer доступен через Caddy (`panel`).
- Для `panel` включена Caddy Basic Auth (логин/пароль задаются в `.env`).
- Map-сервисы `8153-8156` доступны через Caddy (`map1..map4` или `/maps/...`).
- Не открывайте `8153-8156`, `9443`, `25576` публично, кроме временной отладки.

Команды:

```bash
docker compose up -d caddy
docker logs -f mc-caddy
docker compose ps
```

Локально (без DuckDNS/боевого TLS) используйте отдельный профиль:

```bash
./scripts/start-local.sh
```

Локальные URL:
- `http://localhost:8080` — health/fallback
- `http://localhost:8081` — Velocity Web API proxy
- `http://localhost:8082` — Portainer proxy (Basic Auth)
- `http://localhost:8153..8156` — map proxy

Проверка на VPS:

```bash
curl http://localhost
curl https://status.gerbarium.duckdns.org/health
curl https://gerbarium.duckdns.org/status/health
```

Если HTTPS не работает:
- проверьте, что DNS указывает на IP VPS;
- проверьте, что открыты порты `80` и `443`;
- проверьте логи Caddy:

```bash
docker logs mc-caddy --tail=100
```

## DuckDNS домен

1. Создайте DuckDNS-домен, например `gerbarium.duckdns.org`.
2. Укажите публичный IP вашего VPS.
3. Если настроены поддомены, используйте:
   - `https://panel.gerbarium.duckdns.org`
   - `https://status.gerbarium.duckdns.org`
   - `https://map1.gerbarium.duckdns.org`
   - `https://map2.gerbarium.duckdns.org`
   - `https://map3.gerbarium.duckdns.org`
   - `https://map4.gerbarium.duckdns.org`
4. Если в вашей схеме доступен только root-домен, используйте fallback пути:
   - `https://gerbarium.duckdns.org/panel`
   - `https://gerbarium.duckdns.org/status`
   - `https://gerbarium.duckdns.org/maps/map1`
   - `https://gerbarium.duckdns.org/maps/map2`
   - `https://gerbarium.duckdns.org/maps/map3`
   - `https://gerbarium.duckdns.org/maps/map4`
5. Подключение Minecraft остается:
   - `gerbarium.duckdns.org:25565`
   - или `play.gerbarium.duckdns.org:25565`, если создан `play`-поддомен.
6. Caddy автоматически запросит HTTPS-сертификаты при открытых `80/443` и корректном DNS.
7. `caddy/Caddyfile` использует переменные из `.env` (`PUBLIC_DOMAIN`, `PANEL_DOMAIN`, `STATUS_DOMAIN`, `MAP*_DOMAIN`, `MAP*_PORT`).

## Панель управления Docker: Portainer

- Portainer — веб-панель управления Docker.
- Что можно делать:
  - смотреть контейнеры;
  - перезапускать `velocity/hub/island` сервисы;
  - смотреть логи;
  - проверять volumes и сети;
  - открывать консоль контейнера.
- Это не Minecraft-специфичная панель.
- Она не заменяет workflow Git + Docker Compose.
- Git остается source of truth.

Доступ:
- Предпочтительно: `https://panel.<your-duckdns-domain>`
- Fallback: `https://<your-duckdns-domain>/panel`
- Поддомен предпочтительнее, т.к. Portainer под path-prefix может работать нестабильно.
- Вход в panel защищен Caddy Basic Auth, креды задаются в `.env`.

Первичная настройка:
1. Запустите сервисы: `docker compose up -d`
2. Откройте: `https://panel.<your-duckdns-domain>`
3. Создайте admin-пользователя.
4. Выберите local Docker environment.

Безопасность:
- Используйте сильный пароль.
- Не открывайте `9443` напрямую, кроме отладки.
- Предпочитайте доступ через Caddy HTTPS.
- Для production ограничьте доступ по IP или добавьте дополнительную аутентификацию.
- `PANEL_BASIC_AUTH_PASSWORD_HASH` храните в виде hash (не plaintext).

Генерация hash для Caddy Basic Auth:

```bash
./scripts/caddy/generate-password-hash.sh 'YOUR_STRONG_PASSWORD' paneladmin
```

Скрипт принимает:
- 1-й аргумент: plaintext пароль (обязателен);
- 2-й аргумент: username (опционально, по умолчанию `paneladmin`).

Скрипт сам выводит готовые строки для `.env`:

```env
PANEL_BASIC_AUTH_USER=paneladmin
PANEL_BASIC_AUTH_PASSWORD_HASH='$2a$14$...'
```

Временный прямой debug-доступ (если Caddy еще не работает):

```yaml
portainer:
  ports:
    - "9443:9443"
```

Потом откройте `https://SERVER_IP:9443`, завершите отладку и уберите прямой порт.

## Порты и безопасность

- Открыть публично:
  - `TCP 22` (SSH)
  - `TCP 80` (Caddy HTTP / Let's Encrypt)
  - `TCP 443` (Caddy HTTPS)
  - `TCP 25565` (Minecraft Velocity)
- Опционально только для отладки:
  - `TCP 25576` (direct Velocity Web API)
  - `TCP 9443` (direct Portainer)
  - `TCP 8153-8156` (direct maps)
- Не открывать по умолчанию:
  - backend Minecraft порты;
  - `RCON 25575`;
  - `9443`, `25576`, `8153-8156`.
- `data/` не хранится в Git: там миры, логи, playerdata и runtime-данные.
- В Git хранится только `velocity/forwarding.secret.example`; реальный `velocity/forwarding.secret` создается на сервере.

## Forwarding и вход игроков

Сейчас используется `player-info-forwarding-mode = "none"` для простого MVP-старта. Для production нужно настроить безопасный forwarding (`modern`) и совместимые Fabric-компоненты.

Если нужно возвращать игрока на последний остров после выхода, добавьте Velocity-плагин Last Server/Reconnect (или кастомный плагин):
- `player UUID -> last backend server`

Тогда логика будет: выход на `island3` -> сохранение `island3` -> следующий вход на `island3` -> восстановление позиции самим Fabric-сервером.

## Ресурсы

Минимум для теста:
- 4 vCPU / 16 GB RAM / 50 GB SSD

Распределение RAM по умолчанию:
- Velocity: `512m`
- Hub: `2G`
- Каждый остров: `3G`

Итого ~14.5G под Minecraft-процессы. Если памяти не хватает, уменьшите `ISLAND_MEMORY` до `2G`.

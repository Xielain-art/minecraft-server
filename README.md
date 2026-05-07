# Minecraft Network (Velocity + Fabric)

Этот репозиторий содержит переносимую Minecraft-сеть на Docker Compose: **Velocity + Hub + 4 Fabric 1.20.1 сервера-острова**.

## Архитектура

Поток подключения:

Игрок -> Velocity `:25565` -> `hub` -> `island1` / `island2` / `island3` / `island4`

- `velocity` — единственная публичная точка входа.
- Backend-сервера (`hub`, `island1..4`) работают только во внутренней Docker-сети.
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

## Порты и безопасность

- Открывать наружу только **TCP 25565**.
- Backend-порты наружу не открывать.
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

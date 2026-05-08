# Packwiz server pack (Gerbarium)

Этот каталог — единый shared packwiz server-модпак для backend Fabric серверов.

- Все backend Fabric серверы используют этот pack
- Pack публикуется через GitHub Pages, не через Minecraft VPS/Caddy
- Не создавать отдельные packwiz-паки на `island1/island2/...`
- Добавлять сюда только server-side или both-side Fabric моды
- Не добавлять сюда client-only моды (например Sodium, Iris, Mod Menu, minimap/HUD/zoom)
- Не добавлять сюда плагины Velocity

Плагины Velocity размещаются только в `velocity/plugins/`.

Обычный production-путь управления модами: `packs/server` через packwiz.
`shared/mods` в корне репозитория сохранен как emergency/manual override слой.

## Инициализация

```bash
cd packs/server
packwiz init
```

Рекомендуемые ответы:
- Name: `Gerbarium Server`
- Author: `Gerbarium`
- Version: `0.1.0`
- Minecraft: `1.20.1`
- Loader: `Fabric`
- Fabric loader: `0.19.2`

## Добавить мод (Modrinth)

```bash
packwiz modrinth install <mod>
```

## Добавить мод (CurseForge)

```bash
packwiz curseforge install <mod>
```

## Обновить индексы

```bash
packwiz refresh
```

## Обновить все моды

```bash
packwiz update --all
```

## Локальная проверка URL

```bash
python -m http.server 8080
```

Проверка:

```text
http://localhost:8080/pack.toml
```

Production URL:

```text
https://xielain-art.github.io/minecraft-server/packs/server/pack.toml
```

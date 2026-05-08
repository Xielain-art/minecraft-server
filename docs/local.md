# Локальный запуск

## Команды

```bash
chmod +x scripts/*.sh
./scripts/start-local.sh
docker compose -f docker-compose.yml -f docker-compose.local.yml ps
```

Остановка:

```bash
docker compose -f docker-compose.yml -f docker-compose.local.yml down
```

## Локальные адреса

- `localhost:25565` -> вход игроков (Velocity)
- `http://localhost:8080` -> Caddy health
- `http://localhost:8081` -> Velocity Web API proxy
- `https://localhost:9443` -> Portainer (прямой доступ, без Caddy)
- `http://localhost:8153..8156` -> map proxy

## Примечание

В local-профиле `portainer` публикуется как `9443:9443`.

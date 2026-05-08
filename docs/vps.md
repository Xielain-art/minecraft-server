# Запуск на VPS

## Первый запуск

```bash
git clone <repo>
cd minecraft-network
cp .env.example .env
cp velocity/forwarding.secret.example velocity/forwarding.secret
nano velocity/forwarding.secret
chmod +x scripts/*.sh scripts/caddy/*.sh
./scripts/start.sh
docker compose ps
```

## Portainer в проде: только SSH tunnel

`docker-compose.yml` публикует Portainer только на loopback VPS:
- `127.0.0.1:9443:9443`

Открывать `9443` в интернет не нужно.

Подключение с Windows:

```powershell
.\scripts\connect-portainer-tunnel.ps1 -ServerIp SERVER_IP
```

Подключение с Linux/macOS:

```bash
./scripts/connect-portainer-tunnel.sh SERVER_IP
```

Пока tunnel открыт:
- открыть `https://localhost:9443`

## Что открывать публично

- `22/tcp`
- `80/tcp`
- `443/tcp`
- `25565/tcp`

## Что не открывать публично

- `9443/tcp`
- `25576/tcp`
- `8153-8156/tcp`
- backend Minecraft порты
- `25575` (RCON)

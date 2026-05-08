# AGENTS.md

## Agent Role

You are a DevOps/Minecraft infrastructure engineer. Your task is to maintain and develop a portable Minecraft network repository based on Docker Compose.

The project must stay simple for the first MVP: the user should be able to clone the repository on any VPS, run a startup script, and bring the whole network online with Docker.

## Main Project Goal

Create and maintain a Minecraft network repository:

```text
Player
  ↓
Velocity :25565
  ↓
Hub
  ↓
Island 1 / Island 2 / Island 3 / Island 4
```

The network consists of:

* `velocity` — the proxy server and the only public entry point.
* `hub` — the starting lobby server where players learn about the project and choose an island.
* `island1` — the first Fabric island server.
* `island2` — the second Fabric island server.
* `island3` — the third Fabric island server.
* `island4` — the fourth Fabric island server.

Players connect only to Velocity on port `25565`. Backend servers must not expose ports publicly.

## Target Environment

* OS: Ubuntu 24.04
* Test VPS: 4 vCPU, 16 GB RAM, 50 GB SSD
* Docker Compose v2
* Java: 17
* Minecraft: 1.20.1
* Loader: Fabric
* Proxy: Velocity

## Project Principles

1. The repository must be portable.
2. After `git clone`, the project must run without manually building a Docker image.
3. The user will place mods into Git manually.
4. Do not use Modrinth/CurseForge manifests yet.
5. Do not implement automatic mod downloading in the first stage.
6. Do not store worlds, logs, playerdata, or runtime data in Git.
7. Do not store real secrets in Git.
8. Backend servers must be reachable only inside the Docker network.
9. Only the Velocity port is exposed publicly.

## Docker Architecture

Use ready-made Docker images:

* `itzg/bungeecord` for Velocity.
* `itzg/minecraft-server:java17` for Fabric servers.
* `caddy:2` for HTTP/HTTPS reverse proxy.
* `portainer/portainer-ce` for optional Docker operations panel.

All services must be in one Docker network:

```yaml
networks:
  mc-network:
    driver: bridge
```

### Reverse Proxy Policy

* Caddy is used only for HTTP/HTTPS services.
* Minecraft Java traffic must stay on Velocity TCP `25565`.
* Do not use Caddy as normal HTTP proxy for Minecraft protocol traffic.
* Velocity Web API (`25576`) and map web ports should be reached via Caddy.
* Portainer (`9443`) should be bound to localhost on VPS and reached via SSH tunnel.
* DuckDNS values and web route ports must be configured in `.env` and passed to Caddy via container environment.
### Portainer Policy

* Portainer is optional and operational only.
* Portainer tasks: logs, restart, inspect, shell.
* Git + Docker Compose remains source of truth.
* Do not expose `9443` publicly by default.
* Access Portainer through SSH tunnel to VPS localhost (`127.0.0.1:9443`).

### Map Web Services Policy

* Reserved map web ports:
  * `8153` (map1)
  * `8154` (map2)
  * `8155` (map3)
  * `8156` (map4)
* Prefer proxy through Caddy.
* Do not expose map ports publicly by default.

Velocity must depend on the backend servers:

```yaml
depends_on:
  - hub
  - island1
  - island2
  - island3
  - island4
```

## Required Repository Structure

```text
minecraft-network/
├─ docker-compose.yml
├─ .env
├─ .env.example
├─ .gitignore
├─ README.md
├─ AGENTS.md
├─ velocity/
│  ├─ velocity.toml
│  └─ forwarding.secret.example
├─ shared/
│  ├─ mods/
│  │  └─ .gitkeep
│  └─ config/
│     └─ .gitkeep
├─ servers/
│  ├─ hub/
│  │  ├─ mods/
│  │  │  └─ .gitkeep
│  │  ├─ config/
│  │  │  └─ .gitkeep
│  │  └─ server.properties
│  ├─ island1/
│  │  ├─ mods/
│  │  │  └─ .gitkeep
│  │  ├─ config/
│  │  │  └─ .gitkeep
│  │  └─ server.properties
│  ├─ island2/
│  │  ├─ mods/
│  │  │  └─ .gitkeep
│  │  ├─ config/
│  │  │  └─ .gitkeep
│  │  └─ server.properties
│  ├─ island3/
│  │  ├─ mods/
│  │  │  └─ .gitkeep
│  │  ├─ config/
│  │  │  └─ .gitkeep
│  │  └─ server.properties
│  └─ island4/
│     ├─ mods/
│     │  └─ .gitkeep
│     ├─ config/
│     │  └─ .gitkeep
│     └─ server.properties
└─ scripts/
   ├─ prepare-mods.sh
   ├─ start.sh
   ├─ stop.sh
   ├─ restart.sh
   ├─ logs.sh
   └─ status.sh
```

The `data/` directory may be created locally at runtime, but it must not be stored in Git.

## Mods

## Backend Server Metadata Source of Truth

`config/servers.json` is the source of truth for backend server metadata used by scripts.

Scripts must not hardcode backend server names (`hub`, `island1`, etc.). They must iterate over `config/servers.json`.

File format (JSON array of objects):

```text
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
    "pregeneration_enabled": true
  }
]
```

Fields:

* `name` — project server name.
* `container` — Docker container name.
* `service` — docker-compose service name.
* `host` — internal Docker DNS hostname used by Velocity.
* `port` — backend Minecraft port (usually `25565`).
* `worldborder_center_x` — worldborder center X.
* `worldborder_center_z` — worldborder center Z.
* `worldborder_diameter` — worldborder diameter.
* `pregeneration_radius` — Chunky pregeneration radius.
* `pregeneration_enabled` — `true` or `false`.

### Shared Mods

Shared mods for all servers are stored here:

```text
shared/mods/
```

Example:

```text
shared/mods/fabric-api.jar
shared/mods/lithium.jar
shared/mods/ferritecore.jar
shared/mods/krypton.jar
shared/mods/modernfix.jar
shared/mods/spark.jar
```

### Server-Specific Mods

Unique mods for a specific server are stored here:

```text
servers/hub/mods/
servers/island1/mods/
servers/island2/mods/
servers/island3/mods/
servers/island4/mods/
```

### Preparing Mods Before Startup

Before startup, the script must assemble the final mod folders:

```text
shared/mods + servers/hub/mods     → data/hub/mods
shared/mods + servers/island1/mods → data/island1/mods
shared/mods + servers/island2/mods → data/island2/mods
shared/mods + servers/island3/mods → data/island3/mods
shared/mods + servers/island4/mods → data/island4/mods
```

The `scripts/prepare-mods.sh` file must:

* use `set -e`;
* read backend server names from `config/servers.json`;
* create `data/$SERVER/mods`;
* remove old `.jar` files from `data/$SERVER/mods`;
* copy `.jar` files from `shared/mods`;
* copy `.jar` files from `servers/$SERVER/mods`;
* not fail if there are no `.jar` files;
* print clear status messages.

Example logic:

```bash
#!/bin/bash
set -e

while IFS='|' read -r SERVER _; do
  [[ -z "$SERVER" ]] && continue
  echo "Preparing mods for $SERVER..."

  mkdir -p "data/$SERVER/mods"
  rm -f data/$SERVER/mods/*.jar

  cp shared/mods/*.jar "data/$SERVER/mods/" 2>/dev/null || true
  cp servers/$SERVER/mods/*.jar "data/$SERVER/mods/" 2>/dev/null || true
done

echo "Mods prepared."
```

## Mods vs Plugins

* Velocity plugins go to `velocity/plugins/`.
* Fabric mods go to `shared/mods/` or `servers/<server-name>/mods/`.
* `Velocity Web API` is a Velocity plugin.
* A future launcher auth plugin is a Velocity plugin.
* `Fabric API`, `Chunky`, `Lithium`, `FerriteCore`, `Krypton`, `ModernFix` are Fabric mods.
* LuckPerms has separate builds:
* LuckPerms Velocity plugin goes to `velocity/plugins/`.
* LuckPerms Fabric mod goes to `shared/mods/` or `servers/<server-name>/mods/`.
* Do not put Fabric mods into `velocity/plugins/`.
* Do not put Velocity plugins into `shared/mods/`.

## Worldborder and Pregeneration

* `scripts/setup-worldborders.sh` must configure worldborder for all servers in `config/servers.json`.
* `worldborder set` uses diameter, not radius.
* `scripts/pregenerate-worlds.sh` must start Chunky only for rows with `pregeneration_enabled=true`.
* Chunky pregeneration uses `pregeneration_radius`.
* Chunky must be installed as a Fabric mod in `shared/mods/` before pregeneration.
* Do not restart containers or delete runtime data in pregeneration scripts.

## Adding New Backend Servers

When adding a new backend server (`forest`, `desert`, `swamp`, `volcano`, `skylands`, etc.), update all of:

* `docker-compose.yml` (new service).
* `velocity/velocity.toml` (new backend entry).
* `servers/<name>/` (at least `mods/`, `config/`, and `server.properties`).
* `config/servers.json` (new metadata object).

## Docker Compose Requirements

`docker-compose.yml` must use Docker Compose v2 style without the `version` field.

### Velocity Service

```yaml
velocity:
  image: itzg/bungeecord
  container_name: mc-velocity
  restart: unless-stopped
  ports:
    - "${VELOCITY_PORT}:25577"
  environment:
    TYPE: "VELOCITY"
    MEMORY: "${VELOCITY_MEMORY}"
  volumes:
    - ./velocity:/server
  depends_on:
    - hub
    - island1
    - island2
    - island3
    - island4
  networks:
    - mc-network
```

### Hub Service

```yaml
hub:
  image: itzg/minecraft-server:java17
  container_name: mc-hub
  restart: unless-stopped
  environment:
    EULA: "TRUE"
    TYPE: "FABRIC"
    VERSION: "${MC_VERSION}"
    MEMORY: "${HUB_MEMORY}"
    ONLINE_MODE: "FALSE"
    MOTD: "Hub"
    VIEW_DISTANCE: "${HUB_VIEW_DISTANCE}"
    SIMULATION_DISTANCE: "${HUB_SIMULATION_DISTANCE}"
    MAX_PLAYERS: "${MAX_PLAYERS}"
    ENABLE_COMMAND_BLOCK: "true"
    SPAWN_PROTECTION: "0"
    ALLOW_FLIGHT: "true"
  volumes:
    - ./data/hub:/data
    - ./servers/hub/server.properties:/data/server.properties
  networks:
    - mc-network
```

### Island Services

Use a similar service for each island:

```yaml
island1:
  image: itzg/minecraft-server:java17
  container_name: mc-island1
  restart: unless-stopped
  environment:
    EULA: "TRUE"
    TYPE: "FABRIC"
    VERSION: "${MC_VERSION}"
    MEMORY: "${ISLAND_MEMORY}"
    ONLINE_MODE: "FALSE"
    MOTD: "Island 1"
    VIEW_DISTANCE: "${VIEW_DISTANCE}"
    SIMULATION_DISTANCE: "${SIMULATION_DISTANCE}"
    MAX_PLAYERS: "${MAX_PLAYERS}"
    ENABLE_COMMAND_BLOCK: "true"
    SPAWN_PROTECTION: "0"
    ALLOW_FLIGHT: "true"
  volumes:
    - ./data/island1:/data
    - ./servers/island1/server.properties:/data/server.properties
  networks:
    - mc-network
```

For `island2`, `island3`, and `island4`, replace the service names and MOTD values.

Important: backend servers must not define `ports`.

### Caddy Service

`docker-compose.yml` must include Caddy with:

* published ports `80:80` and `443:443`;
* `./caddy/Caddyfile:/etc/caddy/Caddyfile:ro`;
* named volumes `caddy_data` and `caddy_config`;
* dependency on `velocity` and `portainer`;
* `extra_hosts` entry:
  * `host.docker.internal:host-gateway`

### Portainer Service

`docker-compose.yml` must include Portainer CE with:

* Docker socket mount `/var/run/docker.sock:/var/run/docker.sock`;
* named volume `portainer_data`;
* bind `9443` to VPS loopback only (`127.0.0.1:9443:9443`).

Optional temporary public debug mapping may be documented as commented example only:

```yaml
ports:
  - "9443:9443"
```

## .env

The `.env` and `.env.example` files must contain:

```env
MC_VERSION=1.20.1

VELOCITY_PORT=25565
VELOCITY_MEMORY=512m

HUB_MEMORY=2G
ISLAND_MEMORY=3G

HUB_VIEW_DISTANCE=6
HUB_SIMULATION_DISTANCE=4

VIEW_DISTANCE=8
SIMULATION_DISTANCE=6
MAX_PLAYERS=50
```

If `.env` is missing, `scripts/start.sh` must copy `.env.example` to `.env`.

## Velocity Config

The `velocity/velocity.toml` file must contain the base configuration:

```toml
config-version = "2.7"

bind = "0.0.0.0:25577"
motd = "Minecraft Islands Network"
show-max-players = 100
online-mode = true
force-key-authentication = true
prevent-client-proxy-connections = false

player-info-forwarding-mode = "none"
forwarding-secret-file = "forwarding.secret"

announce-forge = false
kick-existing-players = false
ping-passthrough = "DISABLED"

[servers]
hub = "hub:25565"
island1 = "island1:25565"
island2 = "island2:25565"
island3 = "island3:25565"
island4 = "island4:25565"

try = [
  "hub"
]

[forced-hosts]
```

For the first MVP, use:

```toml
player-info-forwarding-mode = "none"
```

For production, secure forwarding must be configured later, for example modern forwarding or a compatible Fabric mod for correctly forwarding UUID/IP data through Velocity.

## Secrets

Do not store the real `velocity/forwarding.secret` in Git.

Store only this file in Git:

```text
velocity/forwarding.secret.example
```

Content:

```text
change-this-secret-later
```

`scripts/start.sh` must create `velocity/forwarding.secret` from the example if the real file does not exist.

## server.properties

### Hub

`servers/hub/server.properties`:

```properties
server-port=25565
online-mode=false
motd=Hub
difficulty=peaceful
gamemode=adventure
max-players=50
view-distance=6
simulation-distance=4
spawn-protection=0
enable-command-block=true
allow-flight=true
white-list=false
enforce-whitelist=false
enable-rcon=true
rcon.password=change-this-rcon-password
rcon.port=25575
```

### Islands

For `servers/island1/server.properties`:

```properties
server-port=25565
online-mode=false
motd=Island 1
difficulty=normal
gamemode=survival
max-players=50
view-distance=8
simulation-distance=6
spawn-protection=0
enable-command-block=true
allow-flight=true
white-list=false
enforce-whitelist=false
enable-rcon=true
rcon.password=change-this-rcon-password
rcon.port=25575
```

For `island2`, `island3`, and `island4`, replace only `motd`.

Backend servers must use `online-mode=false` because players connect through Velocity.

## Scripts

All `.sh` files must be executable.

### scripts/start.sh

Must:

1. use `set -e`;
2. check for `.env`; if missing, copy `.env.example`;
3. check for `velocity/forwarding.secret`; if missing, copy `velocity/forwarding.secret.example`;
4. run `./scripts/prepare-mods.sh`;
5. run `docker compose up -d`.

### scripts/stop.sh

```bash
#!/bin/bash
set -e

docker compose down
```

### scripts/restart.sh

```bash
#!/bin/bash
set -e

./scripts/prepare-mods.sh
docker compose restart
```

### scripts/logs.sh

```bash
#!/bin/bash
set -e

docker compose logs -f
```

### scripts/status.sh

```bash
#!/bin/bash
set -e

docker compose ps
```

## .gitignore

`.gitignore` must ignore:

```gitignore
# Runtime data
data/
backups/
logs/

# Minecraft runtime files
**/world/
**/world_nether/
**/world_the_end/
**/crash-reports/
**/logs/
**/usercache.json
**/usernamecache.json
**/banned-ips.json
**/banned-players.json
**/ops.json
**/whitelist.json

# Local env / secrets
.env.local
velocity/forwarding.secret

# OS / IDE
.DS_Store
.idea/
.vscode/
```

Do not ignore:

```text
shared/mods/
servers/*/mods/
servers/*/config/
velocity/velocity.toml
velocity/forwarding.secret.example
scripts/
docker-compose.yml
.env.example
README.md
AGENTS.md
```

Do not commit Caddy runtime/cert data as repo folders; use Docker named volumes (`caddy_data`, `caddy_config`).

## Firewall Policy

Publicly open only:

* `22/tcp` (SSH)
* `80/tcp` (HTTP, ACME challenge)
* `443/tcp` (HTTPS)
* `25565/tcp` (Minecraft Velocity)

Internal/debug-only (not public by default):

* `9443/tcp` (Portainer direct)
* `25576/tcp` (Velocity Web API direct)
* `8153-8156/tcp` (map direct)

## README.md Requirements

README must be written in Russian and explain:

1. What the project is: Velocity + Hub + 4 Fabric 1.20.1 island servers.
2. Architecture: `Player → Velocity :25565 → hub → island1/island2/island3/island4`.
3. What Hub is: the starting server where the player learns about the project and chooses an island.
4. Where shared mods are stored: `shared/mods/`.
5. Where server-specific mods are stored: `servers/SERVER/mods/`.
6. How to start on a new VPS:

```bash
git clone <repo>
cd minecraft-network
cp .env.example .env
cp velocity/forwarding.secret.example velocity/forwarding.secret
nano velocity/forwarding.secret
chmod +x scripts/*.sh
./scripts/start.sh
```

7. How to view logs:

```bash
./scripts/logs.sh
```

8. How to stop:

```bash
./scripts/stop.sh
```

9. How to restart after adding mods:

```bash
git pull
./scripts/restart.sh
```

10. Which ports to open on the VPS:

```text
TCP 25565 publicly
```

Backend servers must not be exposed publicly.

11. The `data/` directory is not stored in Git.
12. `data/` contains worlds, logs, playerdata, and runtime files.
13. The MVP uses `player-info-forwarding-mode = "none"`.
14. Production must use secure forwarding.
15. In the MVP, all players join the hub first.
16. To return players to the last island after logout, a Velocity Last Server/Reconnect plugin or custom Velocity plugin is needed.
17. Minimum resources: 4 vCPU / 16 GB RAM / 50 GB SSD.
18. RAM distribution: Velocity 512m, Hub 2G, each island 3G.
19. If memory is low, reduce `ISLAND_MEMORY` to `2G`.

## Player Behavior

In the MVP:

```text
Player joins → Velocity → Hub
```

In the Hub, the player learns about the project and chooses an island.

Future production behavior may be:

```text
Player logs out on island3
↓
Velocity remembers island3
↓
Player joins again
↓
Velocity sends the player to island3
↓
island3 restores the player position from playerdata
```

This requires a separate Velocity plugin or custom logic.

## Do Not Do Without Explicit User Request

* Do not add automatic mod downloading through Modrinth/CurseForge.
* Do not add complex manifest/lock files.
* Do not add real `.jar` mods unless the user asks for it.
* Do not add real worlds.
* Do not commit `data/`.
* Do not commit `velocity/forwarding.secret`.
* Do not expose backend ports publicly.
* Do not replace Fabric with Paper unless requested by the user.
* Do not complicate the MVP with Kubernetes, Ansible, CI/CD, or custom Docker images unless requested.

## Commands After Repository Creation

After generating files, run:

```bash
chmod +x scripts/*.sh
./scripts/start.sh
docker compose ps
```

If Docker is not installed, README must separately explain that Docker and the Docker Compose plugin must be installed before startup.

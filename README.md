# DeVpn Docker

Dockerized deployment of [DeVpn](https://github.com/DeVpn-social/devpn-provider/tree/main) with persistent storage and reproducible container builds.

This repository provides a standalone Docker implementation built from the official DeVpn components, with additional testing, validation, and deployment improvements focused on containerized environments.

The goal is to provide a simple and transparent way to run DeVpn using Docker while keeping all node data persistent across container updates and host reboots.

### Why This Exists

DeVpn currently focuses primarily on bare-metal deployments.

This repository provides a Docker-native deployment option with persistent storage, reproducible builds, and transparent source code while remaining compatible with the official DeVpn infrastructure.

The goal is not to replace the official project, but to offer an alternative deployment method for users who prefer containerized environments or cannot use the official bare-metal installer due to platform limitations.

### Features

* Persistent node data storage
* Docker-native deployment
* Automatic container restart
* Source-available build process
* GitHub Container Registry image distribution
* Supports ARM64, AMD64, and other Docker-supported Linux platforms
* Migration path from existing DeVpn installations
* Multi-architecture container images

### Referral Link

If you do not already have a DeVpn account, you may use the following referral link:

https://devpn.org/signup?ref=LWfOwJEQFVQ

### Obtaining a DIY Token

After creating a DeVpn account and accessing the Provider Dashboard, use the **Add DIY Node** button to generate a DIY installation token.

The dashboard will display a command similar to:

```bash
curl -sSL https://api.devpn.org/static/install-provider.sh | sudo bash -s -- --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

The value after `--token` is your DIY token.

Example:

```text
fN16gBKryTjHd2nE-4lPueuQyTwE2ZupqECxmdmAp4Y
```

For additional nodes, it is recommended to generate a new DIY token from the dashboard for each deployment.

This Docker project only requires the token itself.

### Repository Contents

This repository contains all files required to reproduce the published image:

* Dockerfile
* entrypoint.sh
* docker-compose.yml
* GitHub Actions workflow
* Documentation

Users can inspect, modify, and build the image themselves if desired.

### Requirements

* Docker
* Docker Compose (optional)
* Host system with WireGuard support
* Valid DeVpn DIY token

### Important Note

The host operating system must provide WireGuard kernel support.

Systems that do not include WireGuard support may successfully:

* Pull the image
* Start the container
* Register a DeVpn node
* Communicate with the DeVpn API

but will be unable to establish VPN tunnels and therefore cannot function as a provider node.

Examples include embedded Linux distributions such as CrankkOS running on devices like Bobcat Miner 300, Linxdot RK3566, Nebra RockPi, Browan MerryIOT, Panther X2, and similar hardware. (tested on Bobcat Miner 300, Linxdot RK3566 and Browan MerryIOT/Panther X2)

---

## Quick Setup

Run a DeVpn node using a single command:

```bash
docker run -d \
  --name devpn-docker \
  --restart unless-stopped \
  --privileged \
  --network host \
  -e DEVPN_TOKEN=YOUR_TOKEN_HERE \
  -v devpn-data:/opt/devpn \
  ghcr.io/c-man-the-man/devpn-docker:latest
```

View logs:

```bash
docker logs -f devpn-docker
```

Verify:

```bash
docker ps
```

---

## Docker Compose Setup

Create a working directory:

```bash
mkdir devpn-docker
cd devpn-docker
```

Clone the repository:

```bash
git clone https://github.com/C-Man-The-Man/devpn-docker .
```

Edit the compose file:

```bash
nano docker-compose.yml
```

Replace:

```yaml
DEVPN_TOKEN: YOUR_TOKEN_HERE
```

with your DIY token.

Start the container:

```bash
docker compose up -d
```

View logs:

```bash
docker compose logs -f
```

Verify:

```bash
docker ps
```

---

## Migration From Existing Installations

Existing DeVpn installations can be migrated while preserving node identity.

### Step 1 - Stop Existing Service

```bash
sudo systemctl stop devpn-agent
sudo systemctl disable devpn-agent
```

### Step 2 - Back Up Existing Data

```bash
mkdir ~/devpn-backup
```

```bash
sudo cp /opt/devpn/config.json ~/devpn-backup/
sudo cp /opt/devpn/.env ~/devpn-backup/
```

### Step 3 - Verify Existing Identity

Open:

```bash
sudo cat /opt/devpn/config.json
```

Confirm the file contains your existing:

```json
{
  "provider_id": "...",
  "agent_token": "..."
}
```

These values identify your existing node.

### Step 4 - Deploy Docker Version

```bash
mkdir devpn-docker
cd devpn-docker
```

```bash
git clone https://github.com/C-Man-The-Man/devpn-docker .
```

Create the persistent storage directory:

```bash
mkdir -p devpn-data
```

Copy the backup files:

```bash
cp ~/devpn-backup/config.json ./devpn-data/
cp ~/devpn-backup/.env ./devpn-data/
```

Verify:

```bash
cat ./devpn-data/.env
```

Expected format:

```text
DIY_TOKEN=
AGENT_TOKEN=
PROVIDER_ID=
```

### Step 5 - Start Container

```bash
docker compose up -d
```

### Step 6 - Verify

```bash
docker compose logs -f
```

Confirm the node starts normally and appears in the DeVpn Dashboard with the same identity.

---

## Data Persistence

All persistent node data is stored inside:

```text
./devpn-data
```

for Docker Compose deployments, or inside the Docker volume:

```text
devpn-data
```

for Quick Setup deployments.

Back up this data before major migrations, operating system changes, or hardware replacements.

---

## Disclaimer

This repository is an independent Docker packaging project.

It is not affiliated with, endorsed by, or maintained by the official DeVpn team.

Users are responsible for reviewing the source code, understanding the software they run, and complying with all applicable laws, regulations, and service provider requirements.


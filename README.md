# DeVpn Docker

Dockerized deployment of [DeVpn](https://github.com/DeVpn-social/devpn-provider/tree/main) with persistent storage and reproducible container builds.

This repository provides a standalone Docker implementation built from the official DeVpn components, with additional testing, validation, and deployment improvements focused on containerized environments.

The goal is to provide a simple and transparent way to run DeVpn using Docker while keeping all node data persistent across container updates and host reboots.

### Why This Exists

DeVpn currently focuses primarily on bare-metal deployments.

This repository provides a Docker-native deployment option with persistent storage, reproducible builds, and transparent source code while remaining compatible with the official DeVpn infrastructure.

The goal is not to replace the official project, but to offer an alternative deployment method for users who prefer containerized environments.

### Features

* Persistent node data storage
* Docker-native deployment
* Automatic container restart
* Source-available build process
* GitHub Container Registry image distribution
* Supports ARM64, AMD64 and other Docker-supported Linux platforms

### Referral Link

If you do not already have a DeVPN account, you may use the following referral link:

https://devpn.org/signup?ref=LWfOwJEQFVQ

**Attention!!!**

After the registration process, a web page displays the command line for bare-metal install, as follows:

```bash
curl -sSL https://api.devpn.org/static/install-provider.sh | sudo bash -s -- --token XXXXXXXXXXXXXXXXXXXXXX
```

make sure to save your DIY token (43 characters long), there's no other way to recover the token from the DeVpn Dashboard at the time of pushing this repository.

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
* Docker Compose
* WireGuard support
* Valid DeVpn DIY token

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

with your DeVpn DIY token.

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

### Step 3 - Save Agent Token

Open:

```bash
sudo cat /opt/devpn/config.json
```

Locate:

```json
"agent_token": "xxxxxxxxxxxxxxxx"
```

Save this value.

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

Ensure it contains:

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

Confirm that the node appears normally in the DeVpn Dashboard.

---

## Data Persistence

All persistent data is stored inside:

```text
./devpn-data
```

Back up this directory before major migrations or system changes.

---

## Disclaimer

This repository is an independent Docker packaging project.

Users are responsible for reviewing the source code, understanding the software they run, and complying with all applicable laws, regulations, and service provider requirements.


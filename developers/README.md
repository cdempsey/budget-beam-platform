# Developer Setup Guide

This guide will help you set up your development environment for the BudgetBeam platform. Follow these steps in order to ensure a smooth setup process.

## Prerequisites

### System Requirements

#### Linux (Ubuntu 22.04 or later)
- At least 16GB RAM
- At least 50GB free disk space
- Git installed (`sudo apt-get install git`)

#### macOS (Ventura 13.0 or later)
- Apple Silicon (M1/M2/M3/M4) or Intel processor
- At least 16GB RAM
- At least 50GB free disk space
- Homebrew installed (see https://brew.sh)
- Git installed (`brew install git`)

## Installation Steps

### 1. Install asdf Version Manager

asdf is our preferred tool version manager. It helps manage multiple runtime versions.

#### Linux (Ubuntu)
```bash
# Install dependencies
sudo apt install curl git build-essential

# Download and install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

# For bash users
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
source ~/.bashrc

# For zsh users
# echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
# echo 'fpath=(${ASDF_DIR}/completions $fpath)' >> ~/.zshrc
# echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
# source ~/.zshrc
```

#### macOS
```bash
# Install using Homebrew
brew install asdf

# For zsh users (default shell on macOS)
echo '. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.zshrc
source ~/.zshrc

# For bash users
echo '. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.bash_profile
source ~/.bash_profile
```

### 2. Install Required Runtime Versions

```bash
# Install Java plugin
asdf plugin add java

# Install Java 21
asdf install java temurin-21.0.1+12.0.LTS

# Set Java 21 as global version
asdf global java temurin-21.0.1+12.0.LTS

# Verify Java installation
java --version
```

### 3. Install Docker

#### Linux (Ubuntu)
```bash
# Remove any old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install required packages
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to the docker group
sudo usermod -aG docker $USER

# Important: Log out and back in for group changes to take effect!
```

#### macOS
```bash
# Install Docker Desktop for Mac using Homebrew
brew install --cask docker

# Start Docker Desktop
open -a Docker

# Wait for Docker Desktop to start and finish initialization
# You should see the Docker icon in your menu bar
```

Note for macOS users:
- For Apple Silicon (M1/M2/M3/M4) Macs, Docker Desktop will automatically use the ARM64 version
- The first time you open Docker Desktop, you'll need to accept the terms and conditions
- You may need to grant additional permissions when prompted
- Docker Desktop includes both Docker Engine and Docker Compose
```

### Install lazydocker (optional, recommended)

lazydocker is a simple terminal UI for Docker and docker-compose that many developers find helpful.

#### Linux (Ubuntu)

Option A — snap (recommended if you have snap installed):

```bash
sudo snap install lazydocker
```

Option B — run without installing (works on systems with Docker):

```bash
# Run lazydocker in a container (no install required)
docker run --rm -it \
   -v /var/run/docker.sock:/var/run/docker.sock \
   -v "$HOME/.config/jesseduffield/lazydocker":/config \
   jesseduffield/lazydocker:latest lazydocker
```

Notes:
- If you don't have `snap` on your Linux distribution, prefer the Docker-run approach above or follow the manual binary install instructions from the project's releases page: https://github.com/jesseduffield/lazydocker/releases

#### macOS

Install via Homebrew (recommended):

```bash
brew install lazydocker

# Verify installation
lazydocker --version
```

On macOS you can also use the Docker-run option above if you prefer not to install the binary.

One-line auto-detect installer (runs the best available option):

```bash
sh -c 'if command -v brew >/dev/null 2>&1; then \
   echo "Installing lazydocker via Homebrew..." && brew install lazydocker; \
elif command -v snap >/dev/null 2>&1; then \
   echo "Installing lazydocker via snap..." && sudo snap install lazydocker; \
elif command -v docker >/dev/null 2>&1; then \
   echo "Launching lazydocker via Docker (no install)..." && \
   docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v "$HOME/.config/jesseduffield/lazydocker":/config jesseduffield/lazydocker:latest lazydocker; \
else \
   echo "No supported installer found. Install Homebrew (macOS) or snap (Linux), or install Docker and run lazydocker via the container. See developers/README.md for details."; fi'
```

### 4. Verify Docker Installation

```bash
# Check Docker version
docker --version
docker compose version

# Run test container
docker run hello-world
```

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/cdempsey/budget-beam-platform.git
cd budget-beam-platform
```

### 2. Configure Local Development Environment

```bash
# Create secrets directory and password file
mkdir -p secrets
echo "development_only" > secrets/db_password.txt

# Make build hooks executable
chmod +x services/*/hooks/build
```

### 3. Start the Services

```bash
# Build and start all services
docker compose up -d

# Check service status
docker compose ps
```

### 4. Configure Docker Resources

#### macOS (Docker Desktop)
1. Open Docker Desktop
2. Click on the gear icon (Settings)
3. Go to "Resources"
4. Allocate at least:
   - 8GB RAM
   - 4 CPUs
   - 2GB Swap
5. Click "Apply & Restart"

### 5. Verify Services

Wait for all services to be healthy. You can check their status with:

```bash
docker compose ps
```

#### Application Service Endpoints

The following application endpoints should be available:

- Query Service: http://localhost:8080
- Ingestion Service: http://localhost:8081
- Enrichment Service: http://localhost:8082
- Budgeting Service: http://localhost:8083
- Web UI (Vite dev): http://localhost:5173

To check service health:

```bash
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health
```

#### Infrastructure Services

The following infrastructure services are also running:

- PostgreSQL: localhost:5432
  - Database: budgetbeam
  - Username: budgetbeam
  - Password: development_only (stored in secrets/db_password.txt)
- Kafka: localhost:9092
- Zookeeper: localhost:2181
- Redis: localhost:6379

### Running the React Web UI (Dev)

The UI is a Vite-based React app with hot reloading. Run it in a dev container:

```bash
# Start only the UI dev server
docker compose up -d web-ui

# Follow logs (optional)
docker compose logs -f web-ui

# Open in browser
xdg-open http://localhost:5173 || open http://localhost:5173
```

Notes:
- Source is bind-mounted into the container, so edits in `ui/web-ui` hot-reload automatically.
- If your network blocks HMR websockets, ensure port 5173 is open.

## Development Workflow

### Building Individual Services

To rebuild a specific service:

```bash
docker compose build service-name
docker compose up -d service-name
```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f service-name
```

### Stopping Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (caution: this will delete all data)
docker compose down -v
```

## Troubleshooting

### Common Issues

1. **Services Failing to Start**
   - Check logs: `docker compose logs service-name`
   - Verify dependencies are healthy
   - Check port conflicts

2. **Permission Issues**
   #### Linux
   - Verify Docker group membership: `groups $USER`
   - Check file permissions in secrets directory
   - Try logging out and back in if you recently added your user to the docker group

   #### macOS
   - Ensure Docker Desktop is running
   - Check that you've granted necessary permissions in System Settings
   - For directory mounting issues, verify Docker Desktop has permission to access your project directory

3. **Resource Issues**
   #### Linux
   - Verify Docker has enough resources allocated
   - Check system memory and CPU usage: `top` or `htop`

   #### macOS
   - Open Docker Desktop preferences
   - Go to "Resources" section
   - Adjust CPU, Memory, and Swap limits as needed (recommend at least 8GB RAM)
   - For Apple Silicon Macs, ensure Rosetta 2 is installed if needed: `softwareupdate --install-rosetta`

4. **Architecture-Specific Issues**
   #### macOS (Apple Silicon)
   - If you see "no matching manifest for linux/arm64/v8", try adding `platform: linux/amd64` to the service in docker-compose.yml
   - Some images might not support ARM64 architecture; check image compatibility
   - Use `--platform` flag with Docker commands if needed

   #### macOS (Intel)
   - Legacy Intel-only containers should work without modification
   - For performance issues, check Docker Desktop resource allocation

### Getting Help

1. Check the service logs for specific error messages
2. Review the GitHub issues for known problems
3. Contact the development team on Slack

## Additional Resources

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Docker Documentation](https://docs.docker.com/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)

# SharkNet Messenger Web App

The SharkNet Manager (SNM) Web Application is a web-based management layer built on top of the SharkNet peer-to-peer communication framework. Its primary goal is to expose core SharkNet functionality, traditionally accessed via a command-line interface, through a structured, persistent, and user-friendly web interface and REST API.

The application enables users to create, manage, and switch between SharkNet peers, interact with ASAP hubs, inspect messaging channels, and control runtime behavior without directly invoking CLI commands. It bridges the gap between SharkNet’s low-level runtime model and modern web-based system interaction.

---

## Prerequisites

Make sure the following are installed on your machine:

- **Java JDK 17+**
- **Maven 3.8+**
- **Apache Tomcat 10+ (Jakarta EE 9+ / jakarta.servlet — Tomcat 9 will NOT work)**
- **Git**
- **Unix-based OS (Linux / macOS)** or **Git Bash / WSL on Windows**

> **Note:** All project scripts (`scripts/*.sh`) are Bash scripts. On Windows, run them from **Git Bash** or **WSL** — plain **CMD** or **PowerShell** cannot execute them directly.

---

## Project Setup

### 1. Clone the repository

```bash
git clone https://github.com/othman-aldaood/SNM-Webapp
cd SNM-Webapp
```

---

### 2. Install the bundled Shark/ASAP libraries

This project depends on a few Shark/ASAP jars (`ASAPHub`, `ASAPJava`, `SharkPeer`, `SharkPKI`) that aren't published to Maven Central. They're bundled under `libs/` and need to be installed into your local Maven repository once before the first build:

```bash
./scripts/install-libs.sh
```

---

### 3. Configure Tomcat

Make sure Tomcat is installed and accessible.

Tomcat location is auto-detected (by `scripts/start.sh` / `scripts/stop.sh`) in this exact order:
1. `$CATALINA_HOME` environment variable (if set)
2. `/opt/homebrew/opt/tomcat@10/libexec`
3. `/opt/homebrew/opt/tomcat/libexec`
4. `/opt/homebrew/opt/tomcat@9/libexec` (used as a last-resort fallback — prints a warning since this project requires Tomcat 10+)
5. `/usr/share/tomcat10`
6. `/usr/local/tomcat10`
7. `/c/Apache/Tomcat10`
8. `/c/Program Files/Apache Software Foundation/Tomcat 10.0`
9. Otherwise, whatever `catalina.sh` is found on your `PATH`
10. If none of the above match, the script exits with an error and asks you to set `CATALINA_HOME` manually

No manual path editing is needed for standard Homebrew installs.

> **Note:** This project requires **Tomcat 10+**. Tomcat 9 will deploy without errors but silently return 404 on all `/api/*` endpoints (annotation-based servlets are not supported under the Jakarta 6.0 schema on Tomcat 9).

#### Troubleshooting

- If you get 404 errors on all `/api/*` endpoints but pages load fine, you're running Tomcat 9 — this project requires Tomcat 10+.
- If Tomcat isn't found automatically, set it manually:
  ```bash
  export CATALINA_HOME=/path/to/your/tomcat
  ```
- Always make sure you have the latest code before troubleshooting:
  ```bash
  git pull origin main
  ```

---

### 4. Build the project

```bash
./scripts/build.sh
```

---

### 5. Start the server

Use the provided script:

```bash
./scripts/start.sh
```

What this does:

- Builds the project
- Stops Tomcat if already running
- Deploys the WAR file
- Starts Tomcat

Once started, the app is available at:

```text
http://localhost:8080/snm-webapp/
```

---

### 6. Stop the server

```bash
./scripts/stop.sh
```

This shuts down Tomcat gracefully.

---

### 7. View logs

```bash
./scripts/logs.sh
```

This tails the Tomcat logs so you can see runtime output,
peer lifecycle events, and shutdown hooks.

---

## Application Pages

Once logged in, the app is organized into the following pages (left sidebar):

- **Messenger** — create/select channels and send signed or encrypted messages to other peers; each message displays a trust badge showing its Identity Assurance (IA) score and hop path, based on the sender's certificate chain.
- **Manageable Peers** — create, start, stop, and manage your local peers.
- **Encounter Management** — track peer encounters recorded during the current session.
- **TCP Connections** — open a listening port or connect directly to another peer over TCP.
- **Hub Connections** — connect to ASAP hub routers for background data synchronization.
- **Certificate Management** — manage PKI credentials, trust, and identity certificates.
- **Settings** — configure message defaults, hub connection behavior, and display preferences.
- **My Profile** — view your peer identity, cryptographic fingerprint, and network activity.

---

## Peer Lifecycle (High-Level)

- Peers are **restored from disk on server startup**
- No peer is active by default
- A user selects a peer via API → peer becomes active
- Only **one peer is active at a time**
- Switching peers automatically:
  - Stops the currently active peer
  - Closes all TCP ports
  - Activates the selected peer
- On server shutdown:
  - All peers are stopped
  - All TCP ports are closed gracefully

---

## Data Persistence

Peer-related data is stored under:

```text
./data/<peerName>/
```

Peer IDs remain **stable across restarts**.

---

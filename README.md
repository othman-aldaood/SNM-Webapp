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
- **Unix-based OS (Linux / macOS)** or WSL on Windows

---

## Project Setup

### 1. Clone the repository

```bash
git clone https://github.com/othman-aldaood/SNM-Webapp
cd snm-webapp
```

---

### 2. Configure Tomcat

Make sure Tomcat is installed and accessible.

Tomcat location is auto-detected in this order:
1. `$CATALINA_HOME` environment variable (if set)
2. `/opt/homebrew/opt/tomcat/libexec`
3. `/opt/homebrew/opt/tomcat@9/libexec`
4. `/opt/homebrew/opt/tomcat@10/libexec`

No manual path editing is needed for standard Homebrew installs.

> **Note:** This project requires **Tomcat 10+**. Tomcat 9 will deploy without errors but silently return 404 on all `/api/*` endpoints (annotation-based servlets are not supported under the Jakarta 6.0 schema on Tomcat 9).

---

### 3. Build the project

```bash
./scripts/build.sh
```

---

### 4. Start the server

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

### 5. Stop the server

```bash
./scripts/stop.sh
```

This shuts down Tomcat gracefully.

---

### 6. View logs

```bash
./scripts/logs.sh
```

This tails the Tomcat logs so you can see runtime output,
peer lifecycle events, and shutdown hooks.

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

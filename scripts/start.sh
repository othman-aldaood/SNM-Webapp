#!/usr/bin/env bash
set -e

# Always run from the project root, no matter where the script is called from
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# Tell the webapp where peer data lives (absolute path, survives any Tomcat
# working directory). Read by DataDir.java; safe with spaces in the path.
export SNM_DATA_DIR="$PROJECT_DIR/data"

if [ -n "$CATALINA_HOME" ]; then
  TOMCAT_HOME="$CATALINA_HOME"
elif [ -d "/opt/homebrew/opt/tomcat@10/libexec" ]; then
  TOMCAT_HOME="/opt/homebrew/opt/tomcat@10/libexec"
elif [ -d "/opt/homebrew/opt/tomcat/libexec" ]; then
  TOMCAT_HOME="/opt/homebrew/opt/tomcat/libexec"
elif [ -d "/opt/homebrew/opt/tomcat@9/libexec" ]; then
  echo "⚠ Warning: only Tomcat 9 found. This project requires Tomcat 10+."
  TOMCAT_HOME="/opt/homebrew/opt/tomcat@9/libexec"
elif command -v catalina.sh &>/dev/null; then
  TOMCAT_HOME="$(dirname $(dirname $(which catalina.sh)))"
else
  echo "✖ Tomcat not found. Set CATALINA_HOME environment variable."
  exit 1
fi

WAR="snm-webapp.war"

# Persist SNM_DATA_DIR into Tomcat's setenv.sh so the data dir is also found
# when Tomcat is started outside this script (e.g. `brew services start tomcat`,
# which runs with cwd=/ and no inherited environment).
SETENV="$TOMCAT_HOME/bin/setenv.sh"
if [ ! -f "$SETENV" ] || ! grep -q "SNM_DATA_DIR" "$SETENV"; then
  {
    echo ""
    echo "# --- added by SNM-Webapp scripts/start.sh ---"
    echo "export SNM_DATA_DIR=\"$PROJECT_DIR/data\""
  } >> "$SETENV"
  chmod +x "$SETENV" 2>/dev/null || true
  echo "✔ Wrote SNM_DATA_DIR to $SETENV"
fi

echo "Starting SharkNet Web App..."

./scripts/build.sh

if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
  echo "Stopping Tomcat..."
  "$TOMCAT_HOME/bin/shutdown.sh" || true
  sleep 3
fi

echo "Deploying WAR..."
rm -rf "$TOMCAT_HOME/webapps/snm-webapp"
rm -f "$TOMCAT_HOME/webapps/snm-webapp.war"
cp target/$WAR "$TOMCAT_HOME/webapps/"

echo "Starting Tomcat..."
"$TOMCAT_HOME/bin/startup.sh"

echo "✔ SharkNet Web App is starting"
echo "→ http://localhost:8080/snm-webapp/"

#!/usr/bin/env bash
set -e

# Downloads the sync-server artifact from GitLab and runs it in the background.
# Intended for CI use.
# Usage: ./download-and-run-server.sh [--stop]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PID_FILE="$SCRIPT_DIR/sync-server.pid"

# Handle --stop option
if [ "$1" = "--stop" ]; then
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        echo "Stopping sync server (PID: $PID)..."
        kill $PID 2>/dev/null || true
        for i in $(seq 1 10); do
            if ! kill -0 $PID 2>/dev/null; then
                echo "Sync server stopped after ${i}s"
                break
            fi
            sleep 1
        done
        if kill -0 $PID 2>/dev/null; then
            echo "Sync server still running after 10s, sending SIGKILL..."
            kill -9 $PID 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    else
        echo "No sync server PID file found, nothing to stop"
    fi
    exit 0
fi

# GitLab artifact download configuration; https://docs.gitlab.com/ci/jobs/job_artifacts/
GITLAB_BASE_URL="${CI_SERVER_URL}"
PROJECT_ID="4"
JOB_NAME="b:mac-arm64-server"
BRANCH="syncdev"

# URL-encode the job name (colon -> %3A)
JOB_NAME_ENCODED="${JOB_NAME//:/%3A}"

ARTIFACT_URL="${GITLAB_BASE_URL}/api/v4/projects/${PROJECT_ID}/jobs/artifacts/${BRANCH}/download?job=${JOB_NAME_ENCODED}"

echo "Downloading sync-server artifact from: ${ARTIFACT_URL}"

# Download the artifact (requires CI_JOB_TOKEN in CI environment)
if [ -z "$CI_JOB_TOKEN" ]; then
    echo "Error: CI_JOB_TOKEN not set, cannot download artifact"
    exit 1
fi
curl --fail --location --header "JOB-TOKEN: ${CI_JOB_TOKEN}" -o artifact.zip "$ARTIFACT_URL"

# Extract the outer artifact zip
unzip -o artifact.zip

# Find and extract the sync-server zip (flexible filename)
SYNC_SERVER_ZIP=$(find ./artifacts -name "objectbox-sync-server-*.zip" | head -1)
if [ -z "$SYNC_SERVER_ZIP" ]; then
    echo "Error: Could not find objectbox-sync-server-*.zip in artifacts"
    exit 1
fi

echo "Found sync-server archive: $SYNC_SERVER_ZIP"
unzip -o "$SYNC_SERVER_ZIP"

# Verify sync-server executable exists
if [ ! -f "./sync-server" ]; then
    echo "Error: sync-server executable not found after extraction"
    exit 1
fi

chmod +x ./sync-server
ls -lh ./sync-server
./sync-server --version

# Wait for port 9999 to be free (max 3 minutes)
PORT=9999
MAX_WAIT=180
WAITED=0
LAST_MESSAGE=0

while lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; do
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo "Error: Port $PORT still in use after ${MAX_WAIT} seconds, giving up"
        exit 1
    fi
    if [ $((WAITED - LAST_MESSAGE)) -ge 10 ]; then
        echo "Port $PORT is in use, waiting... (${WAITED}s elapsed)"
        LAST_MESSAGE=$WAITED
    fi
    sleep 2
    WAITED=$((WAITED + 2))
done

echo "Starting sync-server in background..."

# Run sync-server in background with the same arguments as the docker script
./sync-server \
    --model test-model.json \
    --unsecured-no-authentication \
    --debug &

SYNC_SERVER_PID=$!
echo "Sync server started with PID: $SYNC_SERVER_PID"

# Write PID to file for cleanup by CI
echo "$SYNC_SERVER_PID" > "$SCRIPT_DIR/sync-server.pid"
echo "PID written to $SCRIPT_DIR/sync-server.pid"

# Give the server a moment to start up
sleep 2

# Check if server is still running
if ! kill -0 $SYNC_SERVER_PID 2>/dev/null; then
    echo "Error: Sync server failed to start"
    exit 1
fi

echo "Sync server is running"

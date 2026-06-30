#!/bin/sh
set -e

echo "=== Environment Variables ==="
echo "HOST: '$HOST'"
echo "PORT: '$PORT'"
echo "============================"

# Set default values
DEFAULT_HOST="0.0.0.0"
DEFAULT_PORT="8080"

# Use the values from environment or defaults
HOST_VALUE="${HOST:-$DEFAULT_HOST}"
PORT_VALUE="${PORT:-$DEFAULT_PORT}"

echo "Using HOST: $HOST_VALUE"
echo "Using PORT: $PORT_VALUE"

# Export for envsubst
export HOST="$HOST_VALUE"
export PORT="$PORT_VALUE"

echo "Substituting environment variables..."
envsubst < /app/config.template.yaml > /app/config.yaml

echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Verify that substitution worked (no template variables left)
if grep -q "\${" /app/config.yaml; then
    echo "ERROR: Template variables not substituted in config!"
    exit 1
fi

# Use the appuser's home directory for Hermes config
HERMES_CONFIG_DIR="/home/appuser/.hermes"
HERMES_CONFIG_FILE="$HERMES_CONFIG_DIR/config.yaml"

echo "Hermes config directory: $HERMES_CONFIG_DIR"
mkdir -p "$HERMES_CONFIG_DIR"
echo "Copying config to $HERMES_CONFIG_FILE"
cp /app/config.yaml "$HERMES_CONFIG_FILE"

# Start Hermes gateway
echo "Starting Hermes gateway..."
hermes gateway run
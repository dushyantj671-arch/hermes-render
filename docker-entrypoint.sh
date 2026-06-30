#!/bin/sh
set -e

echo "=== Environment Variables ==="
echo "HOST: '$HOST'"
echo "PORT: '$PORT'"
echo "HOME: '$HOME'"
echo "============================"

# Default values if not set
: "${HOST:=0.0.0.0}"
: "${PORT:=8080}"

echo "Using HOST: $HOST"
echo "Using PORT: $PORT"

echo "Substituting environment variables in config template..."
# Use envsubst to replace variables in the template
# We need to export the variables for envsubst to pick them up
export HOST PORT
envsubst < /app/config.template.yaml > /app/config.yaml

echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Use the appuser's home directory for Hermes config
HERMES_CONFIG_DIR="/home/appuser/.hermes"
HERMES_CONFIG_FILE="$HERMES_CONFIG_DIR/config.yaml"

echo "Hermes config directory: $HERMES_CONFIG_DIR"
mkdir -p "$HERMES_CONFIG_DIR"
echo "Copying config to $HERMES_CONFIG_FILE"
cp /app/config.yaml "$HERMES_CONFIG_FILE"

# Start Hermes gateway (it will pick up the config from the default location)
echo "Starting Hermes gateway..."
hermes gateway run
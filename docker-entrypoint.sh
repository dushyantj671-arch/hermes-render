#!/bin/sh
set -e

echo "HOST: $HOST"
echo "PORT: $PORT"

echo "Substituting environment variables..."
envsubst < /app/config.template.yaml > /app/config.yaml
echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Use the appuser's home directory for Hermes config
echo "HOME is: $HOME"
HERMES_CONFIG_DIR="$HOME/.hermes"
HERMES_CONFIG_FILE="$HERMES_CONFIG_DIR/config.yaml"

echo "Hermes config directory: $HERMES_CONFIG_DIR"
mkdir -p "$HERMES_CONFIG_DIR"
echo "Copying config to $HERMES_CONFIG_FILE"
cp /app/config.yaml "$HERMES_CONFIG_FILE"

# Start Hermes gateway (it will pick up the config from the default location)
echo "Starting Hermes gateway..."
hermes gateway run
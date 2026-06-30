#!/bin/sh
set -e

echo "=== Environment Variables ==="
echo "HOST: '$HOST'"
echo "PORT: '$PORT'"
echo "============================"

# Set default values if variables are unset or empty
: "${HOST:=0.0.0.0}"
: "${PORT:=8080}"

echo "Using HOST: $HOST"
echo "Using PORT: $PORT"

# Export for envsubst
export HOST
export PORT

echo "Substituting environment variables..."
envsubst < /app/config.template.yaml > /app/config.yaml
echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Check if substitution worked (look for $HOST or $PORT in the output)
if grep -q '\$HOST\|\$PORT' /app/config.yaml; then
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
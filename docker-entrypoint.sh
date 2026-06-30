#!/bin/sh
set -e

echo "=== Environment Variables ==="
echo "HOST: '$HOST'"
echo "PORT: '$PORT'"
echo "============================"

# Provide defaults if environment variables are not set
# This ensures we always have valid values even if envsubst fails
: "${HOST:=0.0.0.0}"
: "${PORT:=8080}"

echo "Using HOST: $HOST"
echo "Using PORT: $PORT"

# Read the template and replace placeholders with actual values
# Using sed for reliable substitution
echo "Creating config from template..."
sed -e "s|\${HOST:-0\.0\.0\.0}|$HOST|g" -e "s|\${PORT:-8080}|$PORT|g" /app/config.template.yaml > /app/config.yaml

# Alternative approach: if the above doesn't work due to escaping, try this:
# cat /app/config.template.yaml | sed "s/\${HOST:-0.0.0.0}/$HOST/g; s/\${PORT:-8080}/$PORT/g" > /app/config.yaml

echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Verify that the substitution actually worked (no template variables left)
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

# Start Hermes gateway (it will pick up the config from the default location)
echo "Starting Hermes gateway..."
hermes gateway run
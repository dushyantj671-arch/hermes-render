#!/bin/sh
set -e

echo "=== Environment Variables ==="
echo "HOST: '$HOST'"
echo "PORT: '$PORT'"
echo "============================"

# Set default values if variables are not set or empty
HOST_VALUE=${HOST:-0.0.0.0}
PORT_VALUE=${PORT:-8080}

echo "Using HOST: $HOST_VALUE"
echo "Using PORT: $PORT_VALUE"

# Read the template and replace placeholders with actual values
# Using sed with delimiter '|' to avoid conflicts with slashes in values
echo "Creating config from template..."
sed -e "s|\${HOST:-0\.0\.0\.0}|$HOST_VALUE|g" -e "s|\${PORT:-8080}|$PORT_VALUE|g" /app/config.template.yaml > /app/config.yaml

# Check if substitution succeeded (no template variables left)
if grep -q "\${" /app/config.yaml; then
    echo "ERROR: Template variables not substituted in config!"
    echo "Contents of config.yaml:"
    cat /app/config.yaml
    exit 1
fi

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
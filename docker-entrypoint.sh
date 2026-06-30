#!/bin/sh
set -e

echo "=== Environment Variables ==="
echo "HOST: '$HOST'"
echo "PORT: '$PORT'"
echo "============================"

# Set default values if variables are not set or empty
: "${HOST:=0.0.0.0}"
: "${PORT:=8080}"

echo "Using HOST: $HOST"
echo "Using PORT: $PORT"

# Replace variables in the template - handle both $VAR and ${VAR:-default} formats
# First, try to replace the default value format if it exists
sed -e "s/\${HOST:-0\.0\.0\.0}/$HOST/g" -e "s/\${PORT:-8080}/$PORT/g" /app/config.template.yaml > /app/config.yaml.tmp

# If that didn't change anything (pattern not found), try direct variable replacement
if ! grep -q "\${HOST:-0\.0\.0\.0}\|\${PORT:-8080}" /app/config.yaml.tmp; then
    # Try replacing $HOST and $PORT directly
    sed -e "s/\$HOST/$HOST/g" -e "s/\$PORT/$PORT/g" /app/config.template.yaml > /app/config.yaml.tmp
fi

# If still no substitution happened, use the template as-is (will use defaults from envsubst later if needed)
mv /app/config.yaml.tmp /app/config.yaml

echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Verify that substitution worked (no template variables left)
if grep -q "\${" /app/config.yaml; then
    echo "WARNING: Template variables not fully substituted in config!"
    echo "This might be okay if envsubst will handle them, but let's check..."
    # Try one more approach with envsubst as fallback
    export HOST PORT
    envsubst < /app/config.template.yaml > /app/config.yaml
    echo "After envsubst:"
    cat /app/config.yaml
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
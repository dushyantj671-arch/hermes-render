#!/bin/sh
set -e

echo "Substituting environment variables..."
envsubst < /app/config.template.yaml > /app/config.yaml
echo "Substitution complete."
echo "Generated config:"
cat /app/config.yaml

# Ensure the Hermes config directory exists
mkdir -p /appuser/.hermes
# Copy the generated config to the default location
cp /app/config.yaml /appuser/.hermes/config.yaml
echo "Copied config to /appuser/.hermes/config.yaml"

# Start Hermes gateway (it will pick up the config from the default location)
echo "Starting Hermes gateway..."
hermes gateway start

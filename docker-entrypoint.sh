#!/bin/sh
set -e

echo "Substituting environment variables..."
envsubst < /app/config.template.yaml > /app/config.yaml
echo "Substitution complete."

echo "Starting Hermes gateway..."
exec hermes gateway run --config /app/config.yaml
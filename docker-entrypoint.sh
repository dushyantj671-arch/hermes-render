#!/bin/bash
set -e

# Substitute environment variables in the template config
envsubst < /app/config.template.yaml > /app/config.yaml

# Start Hermes gateway
hermes gateway start --config /app/config.yaml
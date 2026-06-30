FROM python:3.11-slim

# Install system dependencies including gettext for envsubst
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gettext && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy entrypoint script and make executable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create non-root user for security
RUN useradd --create-home appuser
USER appuser

# Copy application source
COPY . .

# Entrypoint: template config then run gateway
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
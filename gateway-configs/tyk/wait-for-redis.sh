#!/bin/sh
# wait-for-redis.sh - Script to wait for Redis to be ready before starting Tyk

set -e

REDIS_HOST="${TYK_GW_STORAGE_HOST:-tyk-redis}"
REDIS_PORT="${TYK_GW_STORAGE_PORT:-6379}"
MAX_RETRIES=30
RETRY_INTERVAL=2

echo "Waiting for Redis at $REDIS_HOST:$REDIS_PORT..."

for i in $(seq 1 $MAX_RETRIES); do
    if nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; then
        echo "Redis is ready!"
        # Give Redis an extra second to fully initialize
        sleep 1

        # Start Tyk Gateway
        echo "Starting Tyk Gateway..."
        exec /opt/tyk-gateway/tyk --conf=/opt/tyk-gateway/tyk.conf
    fi

    echo "Attempt $i/$MAX_RETRIES: Redis not ready yet, waiting ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
done

echo "ERROR: Redis failed to become ready after $MAX_RETRIES attempts"
exit 1

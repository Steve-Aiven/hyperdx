#!/bin/sh
set -eu

# Map Aiven Runtime ClickHouse application_service_credential env vars into
# ClickStack / HyperDX. Integration "port" is the native TCP port, not HTTPS.
# Prefer an explicit CLICKHOUSE_ENDPOINT (https://host:https_port) when set.

if [ -z "${CLICKHOUSE_ENDPOINT:-}" ]; then
  if [ -n "${CLICKHOUSE_HOST:-}" ]; then
    https_port="${CLICKHOUSE_HTTPS_PORT:-}"
    if [ -z "$https_port" ] && [ -n "${CLICKHOUSE_NATIVE_PORT:-}" ]; then
      # Aiven ClickHouse HTTPS is conventionally native_port + 1.
      https_port=$((CLICKHOUSE_NATIVE_PORT + 1))
    fi
    if [ -n "${https_port:-}" ]; then
      export CLICKHOUSE_ENDPOINT="https://${CLICKHOUSE_HOST}:${https_port}"
    fi
  fi
fi

if [ -n "${CLICKHOUSE_USER:-}" ]; then
  export CLICKHOUSE_USER
fi
if [ -n "${CLICKHOUSE_PASSWORD:-}" ]; then
  export CLICKHOUSE_PASSWORD
fi

export HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE="${HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE:-otel}"

# HyperDX UI / session. FRONTEND_URL is set after deploy to the Runtime HTTPS URL.
if [ -n "${FRONTEND_URL:-}" ]; then
  export HYPERDX_APP_URL="${HYPERDX_APP_URL:-$FRONTEND_URL}"
fi

if [ -z "${EXPRESS_SESSION_SECRET:-}" ]; then
  echo "warning: EXPRESS_SESSION_SECRET is unset; sessions will not survive restarts" >&2
fi

if [ -n "${CLICKHOUSE_ENDPOINT:-}" ]; then
  echo "ClickStack using external ClickHouse at ${CLICKHOUSE_ENDPOINT} (database=${HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE})"
else
  echo "warning: CLICKHOUSE_ENDPOINT unset; ClickStack will use the in-image ClickHouse" >&2
fi

# clickhouse/clickstack-all-in-one default entrypoint
exec sh /etc/local/entry.sh "$@"

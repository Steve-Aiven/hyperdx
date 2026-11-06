# HyperDX on Aiven Runtime (deploy notes)

**Active project:** `hyperdx-test` (AMER / `google-europe-west1`)

**Build source:** [`Steve-Aiven/hyperdx-app`](https://github.com/Steve-Aiven/hyperdx-app)

| Setting | Value |
| --- | --- |
| Repository | `Steve-Aiven/hyperdx-app` |
| Dockerfile | `docker/aiven/Dockerfile.runtime` |
| Branch | `aiven/datastore-interface` |

## Services in `hyperdx-test`

| Service | Type | Plan | Role |
| --- | --- | --- | --- |
| `hyperdx` | application | `startup-100-2048` | UI + API |
| `hyperdx-pg` | pg | `startup-4` | App state (`DATASTORE=postgres`) |
| `hyperdx-ch` | clickhouse | `startup-8` | Telemetry |
| `hyperdx-logs-kafka` | kafka | `startup-4` | Platform logs buffer (optional wiring) |

Integrations already attached to `hyperdx`:

- `hyperdx-pg` → `DATABASE_URL`
- `hyperdx-ch` → `CLICKHOUSE_HOST` / `CLICKHOUSE_NATIVE_PORT` / `CLICKHOUSE_USER` / `CLICKHOUSE_PASSWORD` / `CLICKHOUSE_SERVICE_DATABASE` / `CLICKHOUSE_SECURE`

After the app is `RUNNING`, set `FRONTEND_URL` to the public Runtime HTTPS URL (Console → Application → Overview).

## Local preview (monorepo)

```bash
cd ../hyperdx-app
docker build -f docker/aiven/Dockerfile.runtime -t hyperdx-aiven .
```

## Limits

- Demo / steve-test style stack only; do not treat public OTLP as production-safe.
- App-state durability is in `hyperdx-pg`; telemetry durability is in `hyperdx-ch`.

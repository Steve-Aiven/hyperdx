# HyperDX on Aiven Runtime (deploy notes)

**Build source moved.** The Runtime application should build from
[`Steve-Aiven/hyperdx-app`](https://github.com/Steve-Aiven/hyperdx-app) using:

| Setting | Value |
| --- | --- |
| Repository | `Steve-Aiven/hyperdx-app` |
| Dockerfile | `docker/aiven/Dockerfile.runtime` |
| Branch | `aiven/datastore-interface` (until merged to `main`) |

## Architecture

| Concern | Service |
| --- | --- |
| UI + API | Aiven Runtime app `hyperdx` |
| App state (users, dashboards, alerts, sessions) | Aiven for PostgreSQL `hyperdx-pg` |
| Telemetry | Aiven for ClickHouse `hyperdx-ch` |
| Platform logs buffer | Kafka `hyperdx-logs-kafka` |

`DATASTORE=postgres` is the default in the Runtime image. Embedded Mongo from
the old ClickStack all-in-one image is not used.

## Required Runtime env

| Variable | Kind | Purpose |
| --- | --- | --- |
| `DATABASE_URL` | integration | Injected from `hyperdx-pg` via `application_service_credential` (`connection_string`) |
| `CLICKHOUSE_*` / `CLICKHOUSE_ENDPOINT` | integration / variable | Aiven ClickHouse HTTPS endpoint |
| `HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE` | variable | `otel` |
| `EXPRESS_SESSION_SECRET` | secret | Stable session signing key |
| `FRONTEND_URL` | variable | Public Runtime HTTPS URL |
| `DATASTORE` | variable | `postgres` (default in image) |

Expose ports **8080** (UI) and **4318** only if you also run a collector in the
same image; the current Runtime image is HyperDX UI+API (ports **8080** UI and
internal API **8000**). Wire OTLP separately or keep a collector sidecar later.

## Integrations to create

1. `hyperdx-pg` → `hyperdx` (`application_service_credential`, expose
   `connection_string` as `DATABASE_URL`)
2. `hyperdx-ch` → `hyperdx` (`application_service_credential`, ClickHouse host /
   port / user / password / database / secure as today)

## Local preview (monorepo)

```bash
cd ../hyperdx-app
docker build -f docker/aiven/Dockerfile.runtime -t hyperdx-aiven .
# Run with DATABASE_URL pointing at local or Aiven PG, plus CLICKHOUSE_ENDPOINT
```

## Limits

- Public OTLP without auth is for **steve-test** demos only.
- App-state durability is in `hyperdx-pg`; telemetry durability is in `hyperdx-ch`.

# HyperDX on Aiven Runtime (Pulse observability)

ClickStack (HyperDX UI + OpenTelemetry collector + embedded Mongo) deployed as an **Aiven Runtime** application in project `steve-test`, writing telemetry to **Aiven for ClickHouse** (`hyperdx-ch`).

Monitors:

| Signal | Source | Path into HyperDX |
| --- | --- | --- |
| Pulse app traces / logs / metrics | `pulse-ui` OTEL export | OTLP/HTTP → Runtime `:4318` → ClickHouse `otel` |
| Aiven service metrics | `pulse-ch-euw1`, `pulse-db-euw1` | OpenTelemetry integration endpoint → same OTLP URL |
| Aiven platform logs | `pulse-ch-euw1`, `pulse-db-euw1` | `kafka_logs` → `hyperdx-logs-kafka` → `clickhouse_kafka` → `aiven_logs` |

## Services

- `hyperdx` – Runtime app (this repo)
- `hyperdx-ch` – ClickHouse (`otel`, `aiven_logs` databases)
- `hyperdx-logs-kafka` – Kafka buffer for platform logs

## Runtime environment

Set via Aiven Console / API (do not commit secrets):

| Variable | Kind | Purpose |
| --- | --- | --- |
| `CLICKHOUSE_HOST` / `CLICKHOUSE_NATIVE_PORT` / `CLICKHOUSE_USER` / `CLICKHOUSE_PASSWORD` / `CLICKHOUSE_SECURE` / `CLICKHOUSE_SERVICE_DATABASE` | integration | Injected by ClickHouse credential integration |
| `CLICKHOUSE_ENDPOINT` | variable | `https://<host>:<https_port>` from the `clickhouse_https` component |
| `CLICKHOUSE_HTTPS_PORT` | variable | Optional; used if `CLICKHOUSE_ENDPOINT` is unset (`native + 1`) |
| `HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE` | variable | `otel` |
| `EXPRESS_SESSION_SECRET` | secret | Stable session signing key |
| `FRONTEND_URL` | variable | Public Runtime HTTPS URL for the UI port |

Expose ports **8080** (UI) and **4318** (OTLP/HTTP). Runtime public ports are HTTP-only; do not rely on gRPC `4317`.

## Pulse app OTEL

On `pulse-ui`:

```text
OTEL_EXPORTER_OTLP_ENDPOINT=<hyperdx OTLP HTTPS base URL>
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

The OTLP base looks like `https://<id>-4318.<region>.aiven.app` (Runtime terminates TLS on 443 and forwards to container 4318).

## Aiven OpenTelemetry metrics endpoint

1. Project → Integration endpoints → OpenTelemetry
2. `service_address` = HyperDX OTLP HTTPS URL (same as above)
3. Integrate `pulse-ch-euw1` and `pulse-db-euw1` to that endpoint

`application` services cannot use this metrics integration; `pulse-ui` relies on app OTEL.

## Platform logs → ClickHouse

1. Create Kafka service `hyperdx-logs-kafka`
2. `kafka_logs` from `pulse-ch-euw1` / `pulse-db-euw1` into topics such as `aiven.pulse-ch-euw1.logs`
3. `clickhouse_kafka` from Kafka into `hyperdx-ch`
4. Persist with MVs into `aiven_logs.service_logs` (see [`clickhouse/aiven_logs.sql`](clickhouse/aiven_logs.sql))
5. In HyperDX, add a custom log source on `aiven_logs.service_logs`

There is no direct Aiven `logs` → ClickHouse integration (`logs` targets OpenSearch only). Rsyslog cannot terminate on Runtime (HTTP-only public ports).

## Local preview

```bash
cp .env.example .env   # if present; or export CLICKHOUSE_* yourself
docker compose up --build
```

Open `http://localhost:8080`. Local preview is optional; Aiven Runtime builds from the `Dockerfile` on the pushed branch.

## Limits

- Public OTLP without auth is fine for **steve-test** demos only.
- Embedded Mongo in the ClickStack image is ephemeral on Runtime; dashboards/users reset on rebuild. Telemetry durability is in `hyperdx-ch`.
- Kafka and ClickHouse keep billing until stopped or deleted.

# HyperDX / ClickStack on Aiven Runtime, with Aiven for ClickHouse as the
# telemetry store. The image still ships an embedded ClickHouse + Mongo; the
# collector is pointed at Aiven CH via CLICKHOUSE_ENDPOINT (see entrypoint.sh).
FROM clickhouse/clickstack-all-in-one:latest

USER root
COPY entrypoint.sh /aiven-entrypoint.sh
RUN chmod +x /aiven-entrypoint.sh

# Runtime public ports are HTTP-only. Expose UI and OTLP/HTTP (not gRPC 4317).
EXPOSE 8080 4318

ENTRYPOINT ["/aiven-entrypoint.sh"]

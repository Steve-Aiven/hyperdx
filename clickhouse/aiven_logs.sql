-- Platform logs via kafka_logs -> Kafka -> clickhouse_kafka.
-- Aiven rejects database names that start with "aiven"; use platform_logs.
-- Tables below are created by the clickhouse_kafka integration user_config
-- (see steve-test integration edb7331f-ac05-4b45-a6c6-36e9e41d2b8a). Documented
-- here for reference / local recreation.

CREATE DATABASE IF NOT EXISTS platform_logs;

-- Kafka engine tables live in service_hyperdx-logs-kafka:
--   pulse_ch_logs  (topic aiven.pulse-ch-euw1.logs)
--   pulse_db_logs  (topic aiven.pulse-db-euw1.logs)
-- Materialized views persist into platform_logs:
--   pulse_ch_logs_mv
--   pulse_db_logs_mv
--
-- Journal JSON shape from Aiven kafka_logs:
--   PRIORITY, SYSTEMD_UNIT, HOSTNAME, MESSAGE, REALTIME_TIMESTAMP, timestamp

CREATE TABLE IF NOT EXISTS platform_logs.service_logs
(
    timestamp DateTime64(3),
    service_name LowCardinality(String),
    unit LowCardinality(String),
    hostname LowCardinality(String),
    message String,
    raw String
)
ENGINE = MergeTree
PARTITION BY toYYYYMMDD(timestamp)
ORDER BY (service_name, timestamp)
TTL toDateTime(timestamp) + INTERVAL 14 DAY;

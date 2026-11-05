-- Platform logs landed via kafka_logs -> Kafka -> clickhouse_kafka.
-- After the clickhouse_kafka integration exists, create Kafka Engine tables
-- in the auto-created service_<kafka> database, then persist with MVs here.
-- Adjust topic names / Kafka database name to match the Console integration.

CREATE DATABASE IF NOT EXISTS aiven_logs;

CREATE TABLE IF NOT EXISTS aiven_logs.service_logs
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

-- Example after clickhouse_kafka creates service_hyperdx_logs_kafka.*:
--
-- CREATE MATERIALIZED VIEW IF NOT EXISTS aiven_logs.mv_pulse_ch_logs
-- TO aiven_logs.service_logs AS
-- SELECT
--     parseDateTime64BestEffortOrZero(JSONExtractString(raw, 'timestamp')) AS timestamp,
--     'pulse-ch-euw1' AS service_name,
--     JSONExtractString(raw, 'unit') AS unit,
--     JSONExtractString(raw, 'hostname') AS hostname,
--     JSONExtractString(raw, 'message') AS message,
--     raw
-- FROM service_hyperdx_logs_kafka.aiven_pulse_ch_euw1_logs;

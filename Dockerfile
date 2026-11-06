# DEPRECATED packaging path.
# Build HyperDX for Aiven Runtime from the fork monorepo instead:
#
#   Repo:   Steve-Aiven/hyperdx-app
#   File:   docker/aiven/Dockerfile.runtime
#
# That image uses DATASTORE=postgres (Aiven for PostgreSQL) for app state and
# CLICKHOUSE_ENDPOINT (Aiven for ClickHouse) for telemetry. Embedded Mongo is
# no longer used.
#
# This stub keeps the old Runtime service from building an incompatible
# all-in-one image by mistake. Point the Aiven application VCS integration at
# hyperdx-app and dockerfile docker/aiven/Dockerfile.runtime.

FROM alpine:3.20
RUN echo "Use Steve-Aiven/hyperdx-app docker/aiven/Dockerfile.runtime" >&2 && exit 1

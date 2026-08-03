# Source https://github.com/VictoriaMetrics/VictoriaMetrics/

ARG DOCKER_HUB=
ARG VICTORIA_LOGS_VERSION=1.52.0
ARG ALPINE_VERSION=3.20

# Stage 1: the upstream image ships a statically-linked binary we can lift out.
FROM ${DOCKER_HUB}victoriametrics/victoria-logs:v${VICTORIA_LOGS_VERSION} AS upstream

# Stage 2: Alpine + knot toolchain (upstream is distroless, so we rebase).
FROM ${DOCKER_HUB}alpine:${ALPINE_VERSION}

ARG TZ='Etc/UTC'

ENV TZ=$TZ \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514 \
  VICTORIA_LOGS_RETENTION_PERIOD=30d

RUN apk add --no-cache bash curl libcap rsyslog unzip sudo tzdata \
  # gosu - https://github.com/tianon/gosu/releases
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64') url="https://github.com/tianon/gosu/releases/latest/download/gosu-amd64";; \
      'aarch64') url="https://github.com/tianon/gosu/releases/latest/download/gosu-arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fsSL "$url" -o /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu \
  \
  # make rsyslog work in container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  \
  # create a service user with a real home (upstream image is distroless)
  && addgroup -S victoria-logs \
  && adduser -S -G victoria-logs -h /home/victoria-logs -s /bin/sh -D victoria-logs \
  && mkdir -p /home/victoria-logs /data \
  && chown victoria-logs:victoria-logs /home/victoria-logs /data

# Copy the static binary from the upstream image
COPY --from=upstream /victoria-logs-prod /usr/local/bin/victoria-logs

# Copy files
COPY knot-entrypoint /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["-storageDataPath", "/data"]

# Source https://github.com/docker-library/redis/

ARG DOCKER_HUB=
ARG REDIS_VERSION=8.10.0

FROM ${DOCKER_HUB}library/redis:${REDIS_VERSION}-alpine

ARG TZ='Etc/UTC'

ENV TZ=$TZ \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

RUN apk add --no-cache bash curl libcap rsyslog unzip \
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
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf

RUN mkdir -p /etc/knot-startup.d

# Copy files
COPY knot-entrypoint /usr/local/bin/
COPY redis.conf /etc/redis/redis.conf

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["redis-server", "/etc/redis/redis.conf"]

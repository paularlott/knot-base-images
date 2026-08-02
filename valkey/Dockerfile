# Source https://github.com/valkey-io/valkey-container/

ARG DOCKER_HUB=
ARG VALKEY_VERSION=8.0.0

FROM ${DOCKER_HUB}valkey/valkey:${VALKEY_VERSION}-alpine

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
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && mkdir -p /home/valkey \
  && chown valkey:valkey /home/valkey

# Copy files
COPY files/knot-entrypoint /usr/local/bin/
COPY files/valkey-server.conf /etc/valkey/valkey-server.conf

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["valkey-server", "/etc/valkey/valkey-server.conf"]

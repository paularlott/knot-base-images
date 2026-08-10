# Source https://github.com/axllent/mailpit

ARG DOCKER_HUB=
ARG MAILPIT_VERSION=1.30

FROM ${DOCKER_HUB}axllent/mailpit:v${MAILPIT_VERSION}

ARG TZ='Etc/UTC'

ENV TZ=$TZ \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

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
  # create a service user with a real home (upstream image has none)
  && addgroup -S mailpit \
  && adduser -S -G mailpit -h /home/mailpit -s /bin/sh -D mailpit \
  && mkdir -p /home/mailpit /data \
  && chown mailpit:mailpit /home/mailpit /data

RUN mkdir -p /etc/knot-startup.d

# Copy files
COPY knot-entrypoint /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["--database", "/data/mailpit.db"]

# Source https://github.com/docker-library/postgres/

ARG DOCKER_HUB=
ARG POSTGRES_VERSION=18

FROM ${DOCKER_HUB}library/postgres:${POSTGRES_VERSION}

ARG TZ='Etc/UTC'
ARG APT_CACHE

ENV DEBIAN_FRONTEND=noninteractive \
  TZ=$TZ \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514 \
  PGDATA=/var/lib/postgresql/data

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y bash unzip curl sudo rsyslog locales vim libcap2-bin \
  # https://github.com/tianon/gosu/releases
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64') url="https://github.com/tianon/gosu/releases/latest/download/gosu-amd64";; \
      'aarch64') url="https://github.com/tianon/gosu/releases/latest/download/gosu-arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -sLk "$url" > /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi \
  \
  # make rsyslog work in container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && if [ -f /etc/rsyslog.d/50-default.conf ]; then \
       sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.d/50-default.conf; \
       sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.d/50-default.conf; \
     fi \
  \
  # relocate the postgres user's home out of the data directory (default is /var/lib/postgresql)
  && mkdir -p /home/postgres \
  && chown postgres:postgres /home/postgres \
  && usermod -d /home/postgres postgres

# Copy files
COPY knot-entrypoint /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["postgres"]

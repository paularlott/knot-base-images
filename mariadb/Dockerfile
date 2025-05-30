# Source https://github.com/MariaDB/mariadb-docker/

ARG DOCKER_HUB=
ARG MARIADB_VERSION=10.6

FROM ${DOCKER_HUB}library/mariadb:${MARIADB_VERSION}

ARG TZ='Etc/UTC'

ENV DEBIAN_FRONTEND=noninteractive \
  TZ=$TZ

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y bash unzip curl sudo libcap2-bin rsyslog locales vim \
  # https://github.com/tianon/gosu/releases
  && ARCH=$(uname -m); \
    GOSU_VERSION=1.17; \
    case "$ARCH" in \
      'x86_64') url="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64";; \
      'aarch64') url="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -sLk "$url" > /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi \
  \
  # make rsyslog work in container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.d/50-default.conf

# Copy files
COPY knot-entrypoint /usr/local/bin/
COPY localaccess.sql /docker-entrypoint-initdb.d/
COPY 99-logging.cnf /etc/mysql/mariadb.conf.d/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["mariadbd"]

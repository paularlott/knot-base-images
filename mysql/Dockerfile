# Source https://github.com/docker-library/mysql/

ARG DOCKER_HUB=
ARG MYSQL_VERSION=9.7

FROM ${DOCKER_HUB}library/mysql:${MYSQL_VERSION}

ARG TZ='Etc/UTC'

ENV TZ=$TZ \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

RUN --mount=type=cache,sharing=private,target=/var/cache/dnf \
    --mount=type=cache,sharing=private,target=/var/cache/yum \
  microdnf update -y \
  && microdnf install -y \
    bash unzip curl sudo rsyslog glibc-langpack-en vim \
  # https://github.com/tianon/gosu/releases
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64') url="https://github.com/tianon/gosu/releases/latest/download/gosu-amd64";; \
      'aarch64') url="https://github.com/tianon/gosu/releases/latest/download/gosu-arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -sLk "$url" > /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu \
  && microdnf clean all \
  # relocate the mysql user's home out of the data directory (default is /var/lib/mysql)
  && mkdir -p /home/mysql \
  && chown mysql:mysql /home/mysql \
  && usermod -d /home/mysql mysql

# Copy files
COPY knot-entrypoint /usr/local/bin/
COPY localaccess.sql /docker-entrypoint-initdb.d/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["mysqld"]

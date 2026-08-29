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

RUN mkdir -p /var/lib/mysql-keyring \
  && chown mysql:mysql /var/lib/mysql-keyring \
  && _plugindir="$(mysqld --verbose --help 2>/dev/null | awk '/^plugin-dir[[:space:]]/{print $2; exit}')" \
  && printf '{\n  "path": "/var/lib/mysql-keyring/keyring",\n  "read_only": false\n}\n' \
     > "${_plugindir}/component_keyring_file.cnf" \
  && chmod 644 "${_plugindir}/component_keyring_file.cnf"

RUN mkdir -p /etc/knot-startup.d

# Copy files
COPY knot-entrypoint /usr/local/bin/
COPY localaccess.sql /docker-entrypoint-initdb.d/

# localaccess.sql blanks root's password while the temporary init server is
# still running, but docker_temp_server_stop then tries to shut that server
# down with MYSQL_ROOT_PASSWORD — access denied, initialisation aborts. Shut
# down without a password first (root over the unix socket after localaccess
# ran), falling back to the password for setups that restored one.
RUN sed -i \
  's|mysqladmin --defaults-extra-file=<( _mysql_passfile ) shutdown -uroot --socket="${SOCKET}"|( mysqladmin --defaults-extra-file=<( _mysql_passfile --dont-use-mysql-root-password ) shutdown -uroot --socket="${SOCKET}" 2>/dev/null \|\| mysqladmin --defaults-extra-file=<( _mysql_passfile ) shutdown -uroot --socket="${SOCKET}" )|' \
  /usr/local/bin/docker-entrypoint.sh \
  && grep -q -- '--dont-use-mysql-root-password ) shutdown' /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["mysqld"]

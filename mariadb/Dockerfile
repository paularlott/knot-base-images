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
  && apt-get install -y bash unzip curl sudo libcap2-bin \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

# Copy files
COPY knot-entrypoint /usr/local/bin/
COPY localaccess.sql /docker-entrypoint-initdb.d/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["mariadbd"]

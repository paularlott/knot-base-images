# Source https://github.com/docker-library/redis/

ARG DOCKER_HUB=
ARG VALKEY_VERSION=8.0.0

FROM ${DOCKER_HUB}valkey/valkey:${VALKEY_VERSION}-bookworm

ARG TZ='Etc/UTC'

ENV DEBIAN_FRONTEND=noninteractive \
  TZ=$TZ

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y bash unzip curl libcap2-bin \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

# Copy files
COPY knot-entrypoint /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["valkey-server"]

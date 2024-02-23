ARG DOCKER_HUB
ARG IMAGE_VERSION
ARG IMAGE_BASE

FROM ${DOCKER_HUB}library/${IMAGE_BASE}:${IMAGE_VERSION}

LABEL org.opencontainers.image.source=https://github.com/paularlott/knot-base-images
LABEL org.opencontainers.image.description="Base container"

ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='en_US.UTF-8'
ARG APT_CACHE=${APT_CACHE}
ARG TZ='Etc/UTC'
ARG TERM='xterm-256color'

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=$LANG \
  LANGUAGE=$LANGUAGE \
  LC_ALL=$LC_ALL \
  TZ=$TZ \
  TERM=$TERM

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    tzdata procps rsync openssh-server sudo tzdata fish iputils-ping htop iproute2 iftop \
    git vim curl wget unzip locales ssl-cert gettext software-properties-common lsb-release \
    uuid-runtime screen \
  \
  # https://github.com/tianon/gosu/releases
  && ARCH=$(uname -m); \
    GOSU_VERSION=1.17; \
    case "$ARCH" in \
      'x86_64') url="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64";; \
      'aarch64') url="https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    wget -O /usr/local/bin/gosu "$url"; \
    chmod +x /usr/local/bin/gosu \
  && echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && locale-gen en_US.UTF-8 \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

# Copy files
COPY knot-entrypoint /usr/local/bin/

RUN mkdir -p /opt/code-server \
  && curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/opt/code-server \
  && mkdir -p /run/sshd

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["/usr/local/bin/knot", "agent"]

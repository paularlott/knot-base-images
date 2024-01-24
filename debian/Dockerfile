ARG DOCKER_HUB
ARG IMAGE_VERSION

FROM ${DOCKER_HUB}library/debian:${IMAGE_VERSION}

LABEL org.opencontainers.image.source=https://github.com/paularlott/knot-base-images
LABEL org.opencontainers.image.description="Debian base container"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_CACHE=

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo 'Acquire::HTTP::Proxy "$APT_CACHE";' > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    tzdata procps rsync openssh-server sudo tzdata fish \
    git vim curl wget unzip \
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
	chmod +x /usr/local/bin/gosu

# Copy files
COPY knot-entrypoint /usr/local/bin/

ENV LANG en_US.UTF-8

RUN mkdir -p /opt/code-server \
  && curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/opt/code-server \
  && mkdir -p /run/sshd

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
CMD ["/usr/local/bin/knot", "agent"]

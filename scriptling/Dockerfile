ARG DOCKER_HUB=
ARG IMAGE_VERSION=26.04
ARG IMAGE_BASE=ubuntu
ARG TAG_BASE=paularlott
ARG SCRIPTLING_VERSION=v0.21.3

FROM ${TAG_BASE}/knot-${IMAGE_BASE}:${IMAGE_VERSION}

ARG SCRIPTLING_VERSION
ENV SCRIPTLING_VERSION=${SCRIPTLING_VERSION}

# Scriptling is a static binary - download the release for this architecture
# and install it into /usr/local/bin.
RUN ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  slarch="amd64";; \
      'aarch64') slarch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/paularlott/scriptling/releases/download/${SCRIPTLING_VERSION}/scriptling-linux-${slarch}.zip" -o /tmp/scriptling.zip \
    && unzip -q /tmp/scriptling.zip -d /tmp/scriptling \
    && install -m 0755 /tmp/scriptling/scriptling /usr/local/bin/scriptling \
    && rm -rf /tmp/scriptling /tmp/scriptling.zip \
    && scriptling --version

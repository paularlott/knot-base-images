ARG TAG_BASE=paularlott
ARG PHP_VERSION=8.5
ARG APT_CACHE=

# =============================================================================
# knot-frankenphp: the knot-frankenphp-runtime image plus development tools
# (ssh, git, editors, shells, node, composer, mago, mutagen). The PHP runtime,
# extensions, Caddy config and knot entrypoint all come from the runtime image.
# =============================================================================
FROM ${TAG_BASE}/knot-frankenphp-runtime:${PHP_VERSION}

ARG APT_CACHE
ARG APT_DEV_PACKAGES

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  # Shared dev CLI set (see APT_DEV_PACKAGES in the bake file)
  && apt-get install -y \
    ${APT_DEV_PACKAGES} \
  \
  # mago - PHP toolchain - https://github.com/carthage-software/mago (latest)
  && DPKG_ARCH=$(dpkg --print-architecture); \
    case "$DPKG_ARCH" in \
      'amd64') mago_triple="x86_64-unknown-linux-gnu";; \
      'arm64') mago_triple="aarch64-unknown-linux-gnu";; \
      *) echo >&2 "error: unsupported architecture: '$DPKG_ARCH'"; exit 1 ;; \
    esac; \
    MAGO_VERSION=$(curl -fsSL https://api.github.com/repos/carthage-software/mago/releases/latest | jq -r '.tag_name'); \
    curl -fsSL "https://github.com/carthage-software/mago/releases/download/${MAGO_VERSION}/mago-${MAGO_VERSION}-${mago_triple}.tar.gz" -o /tmp/mago.tgz; \
    tar -xzf /tmp/mago.tgz -C /tmp; \
    install -m 0755 "/tmp/mago-${MAGO_VERSION}-${mago_triple}/mago" /usr/local/bin/mago; \
    rm -rf "/tmp/mago-${MAGO_VERSION}-${mago_triple}" /tmp/mago.tgz \
  \
  # mutagen - https://github.com/mutagen-io/mutagen (latest)
  && MUTAGEN_VERSION=$(curl -fsSL https://api.github.com/repos/mutagen-io/mutagen/releases/latest | jq -r '.tag_name'); \
    curl -fsSL "https://github.com/mutagen-io/mutagen/releases/download/${MUTAGEN_VERSION}/mutagen_linux_${DPKG_ARCH}_${MUTAGEN_VERSION}.tar.gz" -o /tmp/mutagen.tgz; \
    tar -xzf /tmp/mutagen.tgz -C /tmp mutagen; \
    install -m 0755 /tmp/mutagen /usr/local/bin/mutagen; \
    rm -rf /tmp/mutagen /tmp/mutagen.tgz \
  \
  # Node.js (latest LTS)
  && NODEJS_MAJOR=$(curl -fsSL https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)] | .[0].version' | sed 's/^v//; s/\..*//') \
  && curl -fsSL "https://deb.nodesource.com/setup_${NODEJS_MAJOR}.x" | bash - \
  && apt-get install -y nodejs \
  \
  # Composer
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  \
  # sshd
  && mkdir -p /run/sshd \
  \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

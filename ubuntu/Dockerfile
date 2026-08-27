ARG TAG_BASE=paularlott
ARG IMAGE_VERSION=26.04
ARG IMAGE_BASE=ubuntu
ARG APT_CACHE=

# =============================================================================
# knot-ubuntu: the knot-ubuntu-runtime image plus the development toolchain
# (ssh, git, editors, shells, db clients, mutagen). The knot entrypoint,
# runtime user, rsyslog and startup-hook framework all come from the runtime
# image.
# =============================================================================
FROM ${TAG_BASE}/knot-${IMAGE_BASE}-runtime:${IMAGE_VERSION}

ARG APT_CACHE
ARG APT_DEV_PACKAGES

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  # Shared dev CLI set (see APT_DEV_PACKAGES in the bake file) plus the
  # extras this family needs: rsync, envsubst, Sury/NodeSource repo
  # prerequisites and the database CLI clients.
  && apt-get install -y \
    ${APT_DEV_PACKAGES} \
    rsync gettext software-properties-common lsb-release apt-transport-https \
    mariadb-client postgresql-client \
  \
  # mutagen - https://github.com/mutagen-io/mutagen (latest)
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  mutagen_arch="amd64";; \
      'aarch64') mutagen_arch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    MUTAGEN_VERSION=$(curl -fsSL https://api.github.com/repos/mutagen-io/mutagen/releases/latest | jq -r '.tag_name'); \
    curl -fsSL "https://github.com/mutagen-io/mutagen/releases/download/${MUTAGEN_VERSION}/mutagen_linux_${mutagen_arch}_${MUTAGEN_VERSION}.tar.gz" -o /tmp/mutagen.tgz; \
    tar -xzf /tmp/mutagen.tgz -C /tmp mutagen; \
    install -m 0755 /tmp/mutagen /usr/local/bin/mutagen; \
    rm -rf /tmp/mutagen /tmp/mutagen.tgz \
  \
  # sshd
  && mkdir -p /run/sshd \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

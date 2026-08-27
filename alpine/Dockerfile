# knot-alpine: the knot-alpine-runtime image plus the development toolchain.
#
# Alpine sibling of knot-ubuntu: same knot entrypoint framework (from
# knot-alpine-runtime) and as much of the same dev tooling as Alpine has
# equivalents for (git, vim, ssh, etc.). Notable differences from knot-ubuntu:
# musl (no locale-gen, C.UTF-8 built in), bind-tools replaces dnsutils,
# valkey-cli replaces valkey-tools.

ARG TAG_BASE=paularlott
ARG ALPINE_VERSION=3.24

FROM ${TAG_BASE}/knot-alpine-runtime:${ALPINE_VERSION}

RUN apk add --no-cache \
    openssh rsync fish iputils htop iproute2 iftop screen \
    git vim nano tmux wget \
    gettext bind-tools gnupg jq make direnv \
    mariadb-client postgresql-client valkey-cli \
    bat ripgrep fzf zoxide \
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
    rm -rf /tmp/mutagen /tmp/mutagen.tgz

# Source https://www.alpinelinux.org/
#
# Alpine sibling of knot-ubuntu: same knot entrypoint framework and as much of
# the same tooling as Alpine has equivalents for (git, vim, ssh, rsyslog,
# etc.). Notable differences from knot-ubuntu: musl (no locale-gen, C.UTF-8
# built in), no ssl-cert group, bind-tools replaces dnsutils, cronie replaces
# cron, valkey-cli replaces valkey-tools.

ARG DOCKER_HUB=
ARG ALPINE_VERSION=3.24

FROM ${DOCKER_HUB}alpine:${ALPINE_VERSION}

ARG TZ='Etc/UTC'
ARG TERM='xterm-256color'

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  TZ=$TZ \
  TERM=$TERM \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

RUN apk add --no-cache \
    bash sudo tzdata rsyslog logrotate cronie \
    libcap util-linux procps openssh rsync \
    fish iputils htop iproute2 iftop screen \
    git vim nano tmux curl wget unzip \
    gettext bind-tools gnupg jq make direnv \
    mariadb-client postgresql-client valkey-cli \
    bat ripgrep fzf zoxide \
  # Alpine's stock sudoers lacks the sudoers.d drop-in include Debian ships
  && { grep -qE '^[#@]includedir /etc/sudoers.d' /etc/sudoers \
       || echo '@includedir /etc/sudoers.d' >> /etc/sudoers; } \
  \
  # gosu - https://github.com/tianon/gosu/releases (latest)
  # mutagen - https://github.com/mutagen-io/mutagen (latest)
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  gosu_arch="amd64"; mutagen_arch="amd64";; \
      'aarch64') gosu_arch="arm64"; mutagen_arch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/tianon/gosu/releases/latest/download/gosu-${gosu_arch}" -o /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu; \
    MUTAGEN_VERSION=$(curl -fsSL https://api.github.com/repos/mutagen-io/mutagen/releases/latest | jq -r '.tag_name'); \
    curl -fsSL "https://github.com/mutagen-io/mutagen/releases/download/${MUTAGEN_VERSION}/mutagen_linux_${mutagen_arch}_${MUTAGEN_VERSION}.tar.gz" -o /tmp/mutagen.tgz; \
    tar -xzf /tmp/mutagen.tgz -C /tmp mutagen; \
    install -m 0755 /tmp/mutagen /usr/local/bin/mutagen; \
    rm -rf /tmp/mutagen /tmp/mutagen.tgz \
  \
  # make rsyslog work in container (disable the kernel log modules — there is
  # no /dev/kmsg and no kernel inside a container)
  && sed -i 's/^\(module(load="imk\(log\|msg\).*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && mkdir -p /etc/rsyslog.d /etc/knot-startup.d

# Copy files
COPY knot-entrypoint /usr/local/bin/

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]

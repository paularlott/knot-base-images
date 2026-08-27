ARG DOCKER_HUB=
ARG ALPINE_VERSION=3.24

# =============================================================================
# knot-alpine-runtime: minimal Alpine with the knot entrypoint framework and
# only what it needs to run (curl + funzip for the agent download, uuidgen,
# sudo, gosu, setcap, rsyslog, cronie/logrotate for hook scripts). No ssh,
# git, editors, shells or db clients — knot-alpine (the dev image) builds on
# this and adds the dev toolchain.
# =============================================================================
FROM ${DOCKER_HUB}alpine:${ALPINE_VERSION}

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  TZ=Etc/UTC \
  TERM=xterm-256color \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

# Runtime essentials only — no openssh, git, editors, shells or db clients
RUN apk add --no-cache \
    bash sudo tzdata rsyslog logrotate cronie \
    libcap util-linux procps curl unzip \
  # Alpine's stock sudoers lacks the sudoers.d drop-in include Debian ships
  && { grep -qE '^[#@]includedir /etc/sudoers.d' /etc/sudoers \
       || echo '@includedir /etc/sudoers.d' >> /etc/sudoers; } \
  \
  # gosu - https://github.com/tianon/gosu/releases (latest)
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  gosu_arch="amd64";; \
      'aarch64') gosu_arch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/tianon/gosu/releases/latest/download/gosu-${gosu_arch}" -o /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu \
  \
  # make rsyslog work in container (disable the kernel log modules — there is
  # no /dev/kmsg and no kernel inside a container)
  && sed -i 's/^\(module(load="imk\(log\|msg\).*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && mkdir -p /etc/rsyslog.d /etc/knot-startup.d

COPY knot-entrypoint /usr/local/bin/

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]

ARG DOCKER_HUB=
ARG ALPINE_VERSION=3.24
ARG SCRIPTLING_VERSION=v0.20.1

# =============================================================================
# knot-scriptling-runtime: Alpine with the knot entrypoint framework and the
# Scriptling interpreter, but no dev tools — no ssh, git, editors, extra
# shells, db clients or mutagen. knot-scriptling (the dev image) builds on
# the dev-ful knot-ubuntu / knot-alpine bases instead.
# =============================================================================
FROM ${DOCKER_HUB}alpine:${ALPINE_VERSION}

ARG SCRIPTLING_VERSION

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  TZ=Etc/UTC \
  TERM=xterm-256color \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514 \
  SCRIPTLING_VERSION=${SCRIPTLING_VERSION}

# Runtime essentials only: what the knot entrypoint needs (bash for the user
# shell and startup hooks, sudo + the sudoers.d drop-in, uuidgen, curl +
# funzip for the agent download, setcap, rsyslogd/logger) plus cron/logrotate
# for hook scripts. No openssh — KNOT_SSHD=native is not supported here; use
# knot-scriptling for ssh and the rest of the dev toolchain.
RUN apk add --no-cache \
    bash sudo tzdata rsyslog logrotate cronie \
    libcap util-linux procps curl unzip \
  # Alpine's stock sudoers lacks the sudoers.d drop-in include Debian ships
  && { grep -qE '^[#@]includedir /etc/sudoers.d' /etc/sudoers \
       || echo '@includedir /etc/sudoers.d' >> /etc/sudoers; } \
  \
  # gosu - https://github.com/tianon/gosu/releases (latest)
  # Scriptling - static release binary (works on musl)
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  gosu_arch="amd64"; slarch="amd64";; \
      'aarch64') gosu_arch="arm64"; slarch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/tianon/gosu/releases/latest/download/gosu-${gosu_arch}" -o /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/gosu; \
    curl -fsSL "https://github.com/paularlott/scriptling/releases/download/${SCRIPTLING_VERSION}/scriptling-linux-${slarch}.zip" -o /tmp/scriptling.zip \
    && unzip -q /tmp/scriptling.zip -d /tmp/scriptling \
    && install -m 0755 /tmp/scriptling/scriptling /usr/local/bin/scriptling \
    && rm -rf /tmp/scriptling /tmp/scriptling.zip \
    && scriptling --version \
  \
  # make rsyslog work in container (disable the kernel log modules — there is
  # no /dev/kmsg and no kernel inside a container)
  && sed -i 's/^\(module(load="imk\(log\|msg\).*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && mkdir -p /etc/rsyslog.d /etc/knot-startup.d

COPY knot-entrypoint /usr/local/bin/

VOLUME /home

EXPOSE 8080

# Serve the Scriptling HTTP server by default so the container has a
# long-running process without an explicit command. MCP exec (--mcp-exec-script)
# is deliberately not enabled by default — it executes code sent to the server,
# so pair it with --bearer-token if you opt in.
CMD ["scriptling", "--server", "0.0.0.0:8080"]

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]

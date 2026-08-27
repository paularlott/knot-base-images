ARG DOCKER_HUB=
ARG IMAGE_VERSION=latest
ARG IMAGE_BASE=ubuntu

# =============================================================================
# knot-ubuntu-runtime: minimal Ubuntu with the knot entrypoint framework and
# only what it needs to run (curl + funzip for the agent download, uuidgen,
# sudo, gosu, setcap, rsyslog, cron/logrotate for hook scripts). No ssh, git,
# editors, shells or db clients — knot-ubuntu (the dev image) builds on this
# and adds the dev toolchain.
# =============================================================================
FROM ${DOCKER_HUB}library/${IMAGE_BASE}:${IMAGE_VERSION}

ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='en_US.UTF-8'
ARG APT_CACHE
ARG APT_RUNTIME_PACKAGES
ARG TZ='Etc/UTC'
ARG TERM='xterm-256color'

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=$LANG \
  LANGUAGE=$LANGUAGE \
  LC_ALL=$LC_ALL \
  TZ=$TZ \
  TERM=$TERM \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  # Runtime essentials only (shared list, see APT_RUNTIME_PACKAGES in the
  # bake file) — no ssh, git, editors, shells or db clients
  && apt-get install -y \
    ${APT_RUNTIME_PACKAGES} \
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
  # Locale
  && echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && locale-gen en_US.UTF-8 \
  && if id -u ubuntu > /dev/null 2>&1; then userdel -r ubuntu; fi \
  && apt-get clean \
  \
  # make rsyslog work in container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\$RepeatedMsgReduction on$/\$RepeatedMsgReduction off/' /etc/rsyslog.conf \
  && touch /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

# Copy files
COPY files/bin/* /usr/local/bin/
RUN mkdir -p /etc/knot-startup.d

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]

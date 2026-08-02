ARG DOCKER_HUB=
ARG IMAGE_VERSION=latest
ARG IMAGE_BASE=ubuntu

FROM ${DOCKER_HUB}library/${IMAGE_BASE}:${IMAGE_VERSION}

ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='en_US.UTF-8'
ARG APT_CACHE
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
  && apt-get install -y \
    tzdata procps rsync openssh-client openssh-server sudo tzdata fish iputils-ping htop iproute2 iftop rsync \
    git vim curl wget unzip locales ssl-cert gettext software-properties-common lsb-release \
    uuid-runtime screen apt-transport-https dnsutils iputils-ping gnupg2 \
    cron logrotate mariadb-client valkey-tools jq gettext-base make direnv nano rsyslog tmux \
    bat ripgrep fzf zoxide \
  \
  # gosu - https://github.com/tianon/gosu/releases (latest)
  && ARCH=$(uname -m); \
    case "$ARCH" in \
      'x86_64')  gosu_arch="amd64"; mutagen_arch="amd64";; \
      'aarch64') gosu_arch="arm64"; mutagen_arch="arm64";; \
      *) echo >&2 "error: unsupported architecture: '$ARCH'"; exit 1 ;; \
    esac; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/latest/download/gosu-${gosu_arch}"; \
    chmod +x /usr/local/bin/gosu; \
  \
  # mutagen - https://github.com/mutagen-io/mutagen (latest)
  MUTAGEN_VERSION=$(curl -fsSL https://api.github.com/repos/mutagen-io/mutagen/releases/latest | jq -r '.tag_name'); \
    curl -fsSL "https://github.com/mutagen-io/mutagen/releases/download/${MUTAGEN_VERSION}/mutagen_linux_${mutagen_arch}_${MUTAGEN_VERSION}.tar.gz" -o /tmp/mutagen.tgz; \
    tar -xzf /tmp/mutagen.tgz -C /tmp mutagen; \
    install -m 0755 /tmp/mutagen /usr/local/bin/mutagen; \
    rm -rf /tmp/mutagen /tmp/mutagen.tgz \
  \
  && echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && locale-gen en_US.UTF-8 \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi \
  && if id -u ubuntu > /dev/null 2>&1; then userdel -r ubuntu; fi \
  && apt-get clean \
  && mkdir -p /run/sshd \
  \
  # make rsyslog work in container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\$RepeatedMsgReduction on$/\$RepeatedMsgReduction off/' /etc/rsyslog.conf \
  && touch /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.d/50-default.conf

# Copy files
COPY files/bin/* /usr/local/bin/
#COPY files/knot-startup.d/* /etc/knot-startup.d/

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
#CMD ["/usr/local/bin/knot", "agent"]

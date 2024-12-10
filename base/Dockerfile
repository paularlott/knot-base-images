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
  TERM=$TERM

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    tzdata procps rsync openssh-client sudo tzdata fish iputils-ping htop iproute2 iftop rsync \
    git vim curl wget unzip locales ssl-cert gettext software-properties-common lsb-release \
    uuid-runtime screen apt-transport-https dnsutils iputils-ping iproute2 procps gnupg2 \
    cron logrotate mariadb-client jq gettext-base make direnv nano rsyslog \
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
    chmod +x /usr/local/bin/gosu \
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

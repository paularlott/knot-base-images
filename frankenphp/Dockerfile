ARG FRANKENPHP_VERSION=1.12.6
ARG PHP_VERSION=8.5
ARG GOSU_VERSION=1.19
ARG APT_CACHE=
ARG NODEJS_VERSION=20.x

# =============================================================================
# Stage 1: Build FrankenPHP with custom Caddy modules
# =============================================================================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-builder-php${PHP_VERSION} AS builder

COPY --from=caddy:builder /usr/bin/xcaddy /usr/bin/xcaddy

ARG FRANKENPHP_VERSION

RUN CGO_ENABLED=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s' -tags nobadger,nomysql,nopgx" \
    CGO_CFLAGS="-D_GNU_SOURCE $(php-config --includes)" \
    CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
    xcaddy build \
        --output /usr/local/bin/frankenphp \
        --with github.com/dunglas/frankenphp/caddy@v${FRANKENPHP_VERSION} \
        --with github.com/dunglas/mercure/caddy@latest \
        --with github.com/dunglas/vulcain/caddy@latest \
        --with github.com/dunglas/caddy-cbrotli@latest \
        --with github.com/caddy-dns/cloudflare@latest \
        --with github.com/caddyserver/transform-encoder@latest

# =============================================================================
# Stage 2: Runtime — based on official FrankenPHP image
# =============================================================================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}

ARG GOSU_VERSION
ARG APT_CACHE
ARG NODEJS_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8 \
  TZ=Etc/UTC \
  TERM=xterm-256color \
  KNOT_SSH_PORT=2222 \
  KNOT_SYSLOG_PORT=1514

RUN --mount=type=cache,sharing=private,target=/var/cache/apt \
    --mount=type=cache,sharing=private,target=/var/lib/apt \
  if [ -n "$APT_CACHE" ]; then echo "Acquire::HTTP::Proxy \"$APT_CACHE\";" > /etc/apt/apt.conf.d/00proxy; fi \
  && apt-get update -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    tzdata procps rsync openssh-client openssh-server sudo fish iputils-ping htop iproute2 iftop \
    git vim curl wget unzip locales ssl-cert gettext lsb-release \
    uuid-runtime screen dnsutils gnupg2 \
    cron logrotate mariadb-client jq gettext-base make direnv nano rsyslog tmux \
    bat ripgrep fzf zoxide \
  \
  # gosu
  && ARCH=$(dpkg --print-architecture); \
    curl -Lo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${ARCH}"; \
    chmod +x /usr/local/bin/gosu \
  \
  # Locale
  && echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && dpkg-reconfigure --frontend=noninteractive locales \
  \
  # Node.js
  && curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION} | bash - \
  && apt-get install -y nodejs \
  \
  # Composer
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  \
  # sshd
  && mkdir -p /run/sshd \
  \
  # rsyslog for container
  && sed -i 's/^\(module(load="imklog".*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.conf \
  && sed -i 's/^\$RepeatedMsgReduction on$/\$RepeatedMsgReduction off/' /etc/rsyslog.conf \
  && touch /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(auth,.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  && sed -i 's/^\(\*\.\*;.*\)$/#\1/' /etc/rsyslog.d/50-default.conf \
  \
  && if [ -n "$APT_CACHE" ]; then rm -f /etc/apt/apt.conf.d/00proxy; fi

# Replace the FrankenPHP binary with our custom build (includes transform-encoder etc.)
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp

# Knot entrypoint and startup scripts
COPY files/bin/* /usr/local/bin/
COPY files/knot-startup.d/ /etc/knot-startup.d/
COPY files/caddy/Caddyfile /etc/frankenphp/Caddyfile
COPY files/misc/container-crons /etc/cron.d/container-crons

VOLUME /home

ENTRYPOINT ["/usr/local/bin/knot-entrypoint"]
